module Doc.ToPlainText exposing (view)

import Doc


view : List (Doc.Block msg) -> String
view blocks =
    viewInternal blocks
        |> wrapBlocks



-- INTERNAL


viewInternal : List (Doc.Block msg) -> List String
viewInternal blocks =
    case blocks of
        (Doc.Paragraph inlines) :: nextBlocks ->
            (inlines
                |> List.map viewInline
                |> paragraph
            )
                :: viewInternal nextBlocks

        (Doc.OrderedList firstItem restItems) :: nextBlocks ->
            viewList (Just 1) firstItem restItems
                :: viewInternal nextBlocks

        (Doc.UnorderedList firstItem restItems) :: nextBlocks ->
            viewList Nothing firstItem restItems
                :: viewInternal nextBlocks

        (Doc.BlockQuote blockQuoteBlocks) :: nextBlocks ->
            viewBlockQuote blockQuoteBlocks
                :: viewInternal nextBlocks

        (Doc.Section { heading, content }) :: nextBlocks ->
            viewSection heading content
                :: viewInternal nextBlocks

        Doc.Separation :: nextBlocks ->
            viewSeparation
                :: viewInternal nextBlocks

        (Doc.Image _) :: nextBlocks ->
            ""
                :: viewInternal nextBlocks

        (Doc.Video _) :: nextBlocks ->
            ""
                :: viewInternal nextBlocks

        (Doc.CodeBlock { code }) :: nextBlocks ->
            code
                :: viewInternal nextBlocks

        (Doc.LanguageBreak _) :: nextBlocks ->
            viewSeparation
                :: viewInternal nextBlocks

        (Doc.AudioPlayer _) :: nextBlocks ->
            ""
                :: viewInternal nextBlocks

        [] ->
            []


viewInline : Doc.Inline -> String
viewInline inline =
    case inline of
        Doc.Text styledText ->
            viewStyledText styledText

        Doc.InlineCode text ->
            "`{text}`"
                |> String.replace "{text}" text

        Doc.Link { inlines } ->
            List.map viewStyledText inlines
                |> String.join ""

        Doc.LineBreak ->
            "\n"


viewStyledText : Doc.StyledText -> String
viewStyledText { text } =
    text


viewList : Maybe Int -> Doc.ListItem msg -> List (Doc.ListItem msg) -> String
viewList maybeStartNumber firstItem restItems =
    let
        list : List String
        list =
            (firstItem :: restItems)
                |> List.map
                    (\( firstBlock, restBlocks ) ->
                        (firstBlock :: restBlocks)
                            |> viewInternal
                            |> wrapBlocks
                    )
    in
    case maybeStartNumber of
        Just startNumber ->
            list
                |> List.indexedMap
                    (\index item ->
                        "{n}. {item}"
                            |> String.replace "{n}" (String.fromInt (index + startNumber))
                            |> String.replace "{item}" item
                    )
                |> String.join "\n"

        Nothing ->
            list
                |> List.map (\item -> "- " ++ item)
                |> String.join "\n"


viewBlockQuote : List (Doc.Block msg) -> String
viewBlockQuote blocks =
    wrapBlocks (viewInternal blocks)


viewSection : List Doc.Inline -> List (Doc.Block msg) -> String
viewSection heading content =
    wrapBlocks
        [ heading
            |> List.map viewInline
            |> String.join ""
        , wrapBlocks (viewInternal content)
        ]


viewSeparation : String
viewSeparation =
    "---"


paragraph : List String -> String
paragraph inlines =
    inlines
        |> String.join ""


wrapBlocks : List String -> String
wrapBlocks blocks =
    blocks
        |> String.join "\n\n"
