module Doc.FromMarkdown exposing
    ( AudioPlayerConfig
    , Config
    , parse
    )

import Doc
import List.Extra as List
import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Result.Extra as Result
import View.AudioPlayer
import View.AudioPlayer.Track exposing (Track)
import View.LanguageBreak
import View.VideoEmbed


type alias Config msg =
    { audioPlayer : Maybe (AudioPlayerConfig msg)
    }


type alias AudioPlayerConfig msg =
    { onAudioPlayerStateUpdated : View.AudioPlayer.State -> msg
    }


type Intermediate msg
    = IntermediateBlock (Doc.Block msg)
    | IntermediateHeading Int (List Doc.Inline)
    | IntermediateInline Doc.Inline
    | IntermediateInlineList (List Doc.Inline)
    | IntermediateCustomChild CustomChildData


type CustomChildData
    = AudioPlayerTrack Track


parse : Config msg -> String -> List (Doc.Block msg)
parse config markdown =
    markdown
        |> Markdown.Parser.parse
        |> Result.mapError (List.map Markdown.Parser.deadEndToString >> String.join "\n")
        |> Result.andThen (Markdown.Renderer.render (renderer config))
        |> Result.map (intermediatesToBlocks 0 [])
        |> Result.mapError (\error -> [ Doc.Paragraph [ Doc.plainText error ] ])
        |> Result.merge


renderer : Config msg -> Markdown.Renderer.Renderer (Intermediate msg)
renderer config =
    { -- Inline
      text = Doc.plainText >> IntermediateInline
    , strong = renderInlineWithStyle Doc.setBold
    , emphasis = renderInlineWithStyle Doc.setItalic
    , strikethrough = renderInlineWithStyle Doc.setStrikethrough
    , link = renderLink
    , codeSpan = renderInlineCode

    -- Block
    , paragraph = renderParagraph
    , heading = renderHeading
    , unorderedList = renderUnorderedList
    , orderedList = renderOrderedList
    , blockQuote = renderBlockQuote
    , codeBlock = renderCodeBlock

    -- Special
    , hardLineBreak = Doc.LineBreak |> IntermediateInline
    , image = renderImage
    , thematicBreak = Doc.Separation |> IntermediateBlock
    , html = renderCustom config.audioPlayer

    -- Table
    , table = \_ -> placeholderDoc
    , tableBody = \_ -> placeholderDoc
    , tableCell = \_ _ -> placeholderDoc
    , tableHeader = \_ -> placeholderDoc
    , tableHeaderCell = \_ _ -> placeholderDoc
    , tableRow = \_ -> placeholderDoc
    }


placeholderDoc : Intermediate msg
placeholderDoc =
    Doc.plainText "[Doc]"
        |> IntermediateInline


intermediatesToBlocks : Int -> List (Doc.Block msg) -> List (Intermediate msg) -> List (Doc.Block msg)
intermediatesToBlocks currentSectionLevel acc intermediates =
    case intermediates of
        [] ->
            acc

        intermediate :: nextIntermediates ->
            case intermediate of
                IntermediateBlock block ->
                    intermediatesToBlocks currentSectionLevel (acc ++ [ block ]) nextIntermediates

                IntermediateInline inline ->
                    intermediatesToBlocks
                        currentSectionLevel
                        (acc ++ [ Doc.Paragraph [ inline ] ])
                        nextIntermediates

                IntermediateInlineList inlines ->
                    intermediatesToBlocks
                        currentSectionLevel
                        (acc ++ [ Doc.Paragraph inlines ])
                        nextIntermediates

                IntermediateHeading incomingLevel inlines ->
                    if incomingLevel > currentSectionLevel then
                        let
                            ( nextIntermediatesInSection, nextIntermediatesAfterSection ) =
                                nextIntermediates
                                    |> List.splitWhen
                                        (\itmdt ->
                                            case itmdt of
                                                IntermediateHeading level _ ->
                                                    level <= incomingLevel

                                                _ ->
                                                    False
                                        )
                                    |> Maybe.withDefault ( nextIntermediates, [] )
                        in
                        intermediatesToBlocks
                            currentSectionLevel
                            (acc
                                ++ [ Doc.Section
                                        { heading = inlines
                                        , content = intermediatesToBlocks incomingLevel [] nextIntermediatesInSection
                                        }
                                   ]
                            )
                            nextIntermediatesAfterSection

                    else
                        -- This is an error.
                        []

                IntermediateCustomChild _ ->
                    -- We're supposed to have taken care of these already. Ignore.
                    intermediatesToBlocks currentSectionLevel acc nextIntermediates



-- INLINE


renderInlineWithStyle : (Doc.Inline -> Doc.Inline) -> List (Intermediate msg) -> Intermediate msg
renderInlineWithStyle styler intermediates =
    intermediates
        |> List.filterMap
            (\intermediate ->
                case intermediate of
                    IntermediateInline inline ->
                        Just [ styler inline ]

                    IntermediateInlineList inlines ->
                        Just (inlines |> List.map styler)

                    IntermediateBlock _ ->
                        Nothing

                    IntermediateHeading _ _ ->
                        Nothing

                    IntermediateCustomChild _ ->
                        Nothing
            )
        |> List.concat
        |> IntermediateInlineList


renderLink : { title : Maybe String, destination : String } -> List (Intermediate msg) -> Intermediate msg
renderLink { destination } intermediates =
    intermediates
        |> unwrapInlines
        |> Doc.toLink destination
        |> IntermediateInline


renderInlineCode : String -> Intermediate msg
renderInlineCode code =
    Doc.inlineCode code
        |> IntermediateInline



-- BLOCK


renderParagraph : List (Intermediate msg) -> Intermediate msg
renderParagraph intermediates =
    case intermediates of
        (IntermediateBlock block) :: _ ->
            -- Images get wrapped in a paragraph.
            IntermediateBlock block

        _ ->
            -- For other cases, we just want the inlines.
            intermediates
                |> unwrapInlines
                |> Doc.Paragraph
                |> IntermediateBlock


renderHeading :
    { level : Markdown.Block.HeadingLevel
    , rawText : String
    , children : List (Intermediate msg)
    }
    -> Intermediate msg
renderHeading { level, children } =
    IntermediateHeading
        (Markdown.Block.headingLevelToInt level)
        (unwrapInlines children)


renderUnorderedList : List (Markdown.Block.ListItem (Intermediate msg)) -> Intermediate msg
renderUnorderedList items =
    let
        docListItems : List (Doc.ListItem msg)
        docListItems =
            items
                |> List.map
                    (\(Markdown.Block.ListItem _ item) ->
                        item |> ensureBlocks |> unwrapBlocks
                    )
                |> List.filterMap List.uncons

        ( firstDocListItem, restDocListItems ) =
            docListItems
                |> List.uncons
                |> Maybe.withDefault
                    ( ( Doc.Paragraph [ Doc.plainText "" ], [] )
                    , []
                    )
    in
    Doc.UnorderedList firstDocListItem restDocListItems
        |> IntermediateBlock


renderOrderedList : Int -> List (List (Intermediate msg)) -> Intermediate msg
renderOrderedList startNumber items =
    let
        docListItems : List (Doc.ListItem msg)
        docListItems =
            items
                |> List.map (ensureBlocks >> unwrapBlocks)
                |> List.filterMap List.uncons

        ( firstDocListItem, restDocListItems ) =
            docListItems
                |> List.uncons
                |> Maybe.withDefault
                    ( ( Doc.Paragraph [ Doc.plainText "" ], [] )
                    , []
                    )
    in
    Doc.OrderedList firstDocListItem restDocListItems
        |> IntermediateBlock


renderBlockQuote : List (Intermediate msg) -> Intermediate msg
renderBlockQuote intermediates =
    intermediates
        |> ensureBlocks
        |> unwrapBlocks
        |> Doc.BlockQuote
        |> IntermediateBlock


renderCodeBlock : { body : String, language : Maybe String } -> Intermediate msg
renderCodeBlock { body, language } =
    Doc.CodeBlock { language = language, code = String.dropRight 1 body }
        |> IntermediateBlock



-- SPECIAL


renderImage : { alt : String, src : String, title : Maybe String } -> Intermediate msg
renderImage { alt, src, title } =
    Doc.Image { url = src, description = alt, caption = title |> Maybe.withDefault "" }
        |> IntermediateBlock



-- CUSTOM


{-| Renders all custom elements. Depending on the supplied configuration, some
of them may not be included, and if used in the Markdown content, will result in
parsing errors.
-}
renderCustom : Maybe (AudioPlayerConfig msg) -> Markdown.Html.Renderer (List (Intermediate msg) -> Intermediate msg)
renderCustom audioPlayerConfig =
    Markdown.Html.oneOf (customRenderers audioPlayerConfig)


{-| List of all custom element renderers.
-}
customRenderers : Maybe (AudioPlayerConfig msg) -> List (Markdown.Html.Renderer (List (Intermediate msg) -> Intermediate msg))
customRenderers audioPlayerConfig =
    let
        audioPlayerRenderers : List (Markdown.Html.Renderer (List (Intermediate msg) -> Intermediate msg))
        audioPlayerRenderers =
            case audioPlayerConfig of
                Just { onAudioPlayerStateUpdated } ->
                    [ View.AudioPlayer.Track.renderer
                        |> renderCustomAsIntermediateCustom AudioPlayerTrack
                    , View.AudioPlayer.renderer
                        |> renderCustomWithCustomChildren
                            (\(AudioPlayerTrack track) -> Just track)
                            (\audioPlayer tracks ->
                                audioPlayer
                                    |> View.AudioPlayer.withConfig
                                        { onStateUpdated = onAudioPlayerStateUpdated
                                        , tracks = tracks
                                        }
                                    |> Doc.AudioPlayer
                                    |> IntermediateBlock
                            )
                    ]

                Nothing ->
                    []

        otherCustomRenderers : List (Markdown.Html.Renderer (List (Intermediate msg) -> Intermediate msg))
        otherCustomRenderers =
            [ View.VideoEmbed.renderer
                |> renderFailableCustom (Doc.Video >> IntermediateBlock)
            , View.LanguageBreak.renderer
                |> renderFailableCustom (Doc.LanguageBreak >> IntermediateBlock)
            ]
    in
    audioPlayerRenderers ++ otherCustomRenderers


{-| Render a custom element that emits a `Result` type, which indicates that it
can fail depending on the supplied attributes. Requires a way to convert its raw
values into `Intermediate` values.
-}
renderFailableCustom :
    (value -> Intermediate msg)
    -> Markdown.Html.Renderer (Result String value)
    -> Markdown.Html.Renderer (List (Intermediate msg) -> Intermediate msg)
renderFailableCustom valueToIntermediate customRenderer =
    customRenderer
        |> Markdown.Html.map
            (Result.mapBoth
                (\err _ -> IntermediateBlock (renderErrorMessage err))
                (\okResult _ -> valueToIntermediate okResult)
            )
        |> Markdown.Html.map Result.merge


{-| Renders a custom element which cannot fail (doesn't emit a `Result` value),
directly as an `IntermediateCustom` value. This kind of value is used for child
custom elements, so that a parent custom element can later use the produced
data. Requires a way to convert its output value into a `CustomChildData`.
-}
renderCustomAsIntermediateCustom :
    (value -> CustomChildData)
    -> Markdown.Html.Renderer value
    -> Markdown.Html.Renderer (List (Intermediate msg) -> Intermediate msg)
renderCustomAsIntermediateCustom toCustomChildData customRenderer =
    customRenderer
        |> Markdown.Html.map
            (\value _ -> IntermediateCustomChild (toCustomChildData value))


{-| Renders a custom element that expects `IntermediateCustomChild`
children. You will need to supply a way to interpret child renderer-produced
`CustomChildData`, and a way to convert a value produced by the custom renderer
plus its children into an `Intermediate` value.
-}
renderCustomWithCustomChildren :
    (CustomChildData -> Maybe child)
    -> (value -> List child -> Intermediate msg)
    -> Markdown.Html.Renderer value
    -> Markdown.Html.Renderer (List (Intermediate msg) -> Intermediate msg)
renderCustomWithCustomChildren customChildDataToChild valueAndChildrenToIntermediate customRenderer =
    let
        intermediateToChild intermediate =
            case intermediate of
                IntermediateCustomChild customChildData ->
                    customChildDataToChild customChildData

                _ ->
                    Nothing
    in
    customRenderer
        |> Markdown.Html.map
            (\value childIntermediates ->
                childIntermediates
                    |> List.filterMap intermediateToChild
                    |> valueAndChildrenToIntermediate value
            )


{-| Converts an error string into a `Doc.Paragraph`.
-}
renderErrorMessage : String -> Doc.Block msg
renderErrorMessage error =
    Doc.Paragraph
        [ Doc.plainText "Parsing error: "
        , Doc.plainText error
        ]



-- OTHER


{-| Gets all `Doc.Inline`s in a list of `Intermediate`s, and drops any others.
-}
unwrapInlines : List (Intermediate msg) -> List Doc.Inline
unwrapInlines intermediates =
    intermediates
        |> List.filterMap
            (\intermediate ->
                case intermediate of
                    IntermediateInline inline ->
                        Just [ inline ]

                    IntermediateInlineList inlines ->
                        Just inlines

                    IntermediateBlock _ ->
                        Nothing

                    IntermediateHeading _ _ ->
                        Nothing

                    IntermediateCustomChild _ ->
                        Nothing
            )
        |> List.concat


{-| Gets all `Doc.Block`s in a list of `Intermediate`s, dropping any others.
-}
unwrapBlocks : List (Intermediate msg) -> List (Doc.Block msg)
unwrapBlocks =
    List.filterMap
        (\intermediate ->
            case intermediate of
                IntermediateBlock block ->
                    Just block

                IntermediateHeading _ _ ->
                    Nothing

                IntermediateInline _ ->
                    Nothing

                IntermediateInlineList _ ->
                    Nothing

                IntermediateCustomChild _ ->
                    Nothing
        )


{-| Converts a list of `Intermediate`s so that it leaves no direct inlines,
wrapping them in blocks.
-}
ensureBlocks : List (Intermediate msg) -> List (Intermediate msg)
ensureBlocks intermediates =
    let
        process :
            Intermediate msg
            -> ( List (Intermediate msg), List (Intermediate msg) )
            -> ( List (Intermediate msg), List (Intermediate msg) )
        process intermediate ( inlines, blocks ) =
            case intermediate of
                IntermediateInline _ ->
                    ( intermediate :: inlines, blocks )

                IntermediateInlineList _ ->
                    ( intermediate :: inlines, blocks )

                _ ->
                    ( [], intermediate :: wrapUpInlines ( inlines, blocks ) )

        wrapUpInlines :
            ( List (Intermediate msg), List (Intermediate msg) )
            -> List (Intermediate msg)
        wrapUpInlines ( inlines, blocks ) =
            case inlines of
                [] ->
                    blocks

                _ :: _ ->
                    renderParagraph inlines :: blocks
    in
    intermediates
        |> List.foldr process ( [], [] )
        |> wrapUpInlines
