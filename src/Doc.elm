module Doc exposing (..)

import View.AudioPlayer
import View.LanguageBreak
import View.VideoEmbed


type Inline
    = Text StyledText
    | InlineCode String
    | Link { target : String, inlines : List StyledText }
    | LineBreak


type Block msg
    = Paragraph (List Inline)
    | Section { heading : List Inline, content : List (Block msg) }
    | UnorderedList (ListItem msg) (List (ListItem msg))
    | OrderedList (ListItem msg) (List (ListItem msg))
    | BlockQuote (List (Block msg))
    | CodeBlock { language : Maybe String, code : String }
    | Image { url : String, description : String, caption : String }
    | Separation
    | Video View.VideoEmbed.VideoEmbed
    | AudioPlayer (View.AudioPlayer.AudioPlayerWithConfig msg)
    | LanguageBreak View.LanguageBreak.LanguageBreak


type alias StyledText =
    { text : String, styles : Styles }


type alias Styles =
    { bold : Bool
    , italic : Bool
    , strikethrough : Bool
    }


type alias ListItem msg =
    ( Block msg, List (Block msg) )


plainText : String -> Inline
plainText text =
    Text { text = text, styles = emptyStyles }


inlineCode : String -> Inline
inlineCode text =
    InlineCode text


setBold : Inline -> Inline
setBold =
    mapStyles (\styles -> { styles | bold = True })


setItalic : Inline -> Inline
setItalic =
    mapStyles (\styles -> { styles | italic = True })


setStrikethrough : Inline -> Inline
setStrikethrough =
    mapStyles (\styles -> { styles | strikethrough = True })


toLink : String -> List Inline -> Inline
toLink target inlines =
    let
        styledTexts =
            inlines
                |> List.filterMap
                    (\inline ->
                        case inline of
                            Text styledText ->
                                Just [ styledText ]

                            Link l ->
                                Just l.inlines

                            InlineCode text ->
                                Just [ { text = text, styles = emptyStyles } ]

                            LineBreak ->
                                Nothing
                    )
                |> List.concat
    in
    Link { target = target, inlines = styledTexts }


mapStyles : (Styles -> Styles) -> Inline -> Inline
mapStyles mapper inline =
    case inline of
        Text styledText ->
            Text (mapStyledTextStyles mapper styledText)

        Link ({ inlines } as config) ->
            Link { config | inlines = inlines |> List.map (mapStyledTextStyles mapper) }

        InlineCode _ ->
            inline

        LineBreak ->
            inline


mapStyledTextStyles : (Styles -> Styles) -> StyledText -> StyledText
mapStyledTextStyles mapper styledText =
    { styledText | styles = mapper styledText.styles }


emptyStyles : Styles
emptyStyles =
    { bold = False
    , italic = False
    , strikethrough = False
    }
