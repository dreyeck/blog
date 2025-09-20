module Compat.WikiMarkup exposing (renderParagraphs)

import Html exposing (Html, a, span, text)
import Html.Attributes as A
import Regex


renderParagraphs : List String -> List (Html msg)
renderParagraphs paragraphs =
    paragraphs
        |> List.map cleanFactoryLines
        |> List.map renderInlineLinks



-- 1) Drop lines like "⚠️ INFO – Factory" (or any "⚠️ INFO – …")


cleanFactoryLines : String -> String
cleanFactoryLines str =
    let
        -- remove whole line if it starts with "⚠️ INFO –"
        pattern =
            Regex.fromString "^\\s*⚠️\\s*INFO\\s*–.*$"
                |> Maybe.withDefault Regex.never
    in
    if Regex.contains pattern str then
        ""

    else
        str



-- 2) Replace [[Wiki Style Links]] with anchors to /view/slug


renderInlineLinks : String -> Html msg
renderInlineLinks s =
    let
        linkPat =
            Regex.fromString "\\[\\[([^\\]]+)\\]\\]"
                |> Maybe.withDefault Regex.never

        parts =
            Regex.split linkPat s

        matches =
            Regex.find linkPat s

        interleave : List String -> List Regex.Match -> List (Html msg)
        interleave ps ms =
            case ( ps, ms ) of
                ( [], [] ) ->
                    []

                ( p :: [], [] ) ->
                    [ text p ]

                ( p :: restP, m :: restM ) ->
                    let
                        title =
                            m.submatches
                                |> List.head
                                |> Maybe.withDefault (Just "")
                                |> Maybe.withDefault ""

                        slug =
                            title
                                |> String.toLower
                                |> String.trim
                                |> String.replace " " "-"
                                |> sanitizeSlug
                    in
                    text p
                        :: a [ A.href ("/view/" ++ slug) ] [ text title ]
                        :: interleave restP restM

                ( p :: restP, [] ) ->
                    text p :: interleave restP []

                ( [], _ ) ->
                    []
    in
    span [] (interleave parts matches)


sanitizeSlug : String -> String
sanitizeSlug s =
    -- keep letters, digits, dash; turn everything else into dash and squeeze dashes
    let
        nonOk =
            Regex.fromString "[^a-z0-9-]"
                |> Maybe.withDefault Regex.never

        multiDash =
            Regex.fromString "-{2,}"
                |> Maybe.withDefault Regex.never
    in
    s
        |> (\x -> Regex.replace nonOk (\_ -> "-") x)
        |> (\x -> Regex.replace multiDash (\_ -> "-") x)
        |> String.trim
        |> String.trimLeft
        |> String.trimRight
