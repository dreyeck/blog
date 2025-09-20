module Compat.FedWiki exposing
    ( Page, StoryItem(..)
    , pageDecoder, storyItemDecoder
    , renderStoryItem, renderPage
    )

import Html exposing (Html, div, p, text, a)
import Html.Attributes as A
import Json.Decode as D
import Json.Decode.Pipeline as P
import Regex


-- TYPES -----------------------------------------------------------------------

type alias Page =
    { title : String
    , story : List StoryItem
    }

type StoryItem
    = Paragraph { id : String, text : String }
    | Factory { id : String }                  -- meta/template hint → not rendered
    | Unknown { id : String, typ : String, raw : D.Value }  -- keep data for debugging



-- DECODERS --------------------------------------------------------------------

pageDecoder : D.Decoder Page
pageDecoder =
    D.map2 Page
        (D.field "title" D.string)
        (D.field "story" (D.list storyItemDecoder))


storyItemDecoder : D.Decoder StoryItem
storyItemDecoder =
    let
        base =
            D.map2 Tuple.pair
                (D.field "type" D.string)
                (D.field "id" D.string)
    in
    D.oneOf
        [ base
            |> D.andThen
                (\( typ, id_ ) ->
                    case typ of
                        "paragraph" ->
                            D.map (\txt -> Paragraph { id = id_, text = txt })
                                (D.field "text" D.string)

                        "factory" ->
                            -- Factory rows are scaffolding in FedWiki; we carry the id but render nothing.
                            D.succeed (Factory { id = id_ })

                        -- Add more plugin types here as needed:
                        -- "video" -> ...
                        -- "image" -> ...
                        _ ->
                            D.value
                                |> D.map (\v -> Unknown { id = id_, typ = typ, raw = v })
                )
        ]


-- RENDERING -------------------------------------------------------------------

renderPage : Page -> Html msg
renderPage page =
    div []
        (List.map renderStoryItem page.story)


renderStoryItem : StoryItem -> Html msg
renderStoryItem item =
    case item of
        Paragraph rec ->
            p [] [ renderInlineWikiLinks rec.text ]

        Factory _ ->
            -- Intentionally skip (no “⚠️” reminder anymore).
            Html.text ""

        Unknown u ->
            -- Still show a subtle hint so you notice other missing decoders,
            -- but without breaking the page.
            p [ A.class "wiki-unknown-item" ]
                [ text ("⚠️ Unknown item: " ++ u.typ) ]


-- [[Wiki Links]] → <a href="/view/slug">Title</a>
renderInlineWikiLinks : String -> Html msg
renderInlineWikiLinks s =
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

                ( p0 :: [], [] ) ->
                    [ text p0 ]

                ( p0 :: psRest, m0 :: msRest ) ->
                    let
                        title =
                            m0.submatches
                                |> List.head
                                |> Maybe.withDefault (Just "")
                                |> Maybe.withDefault ""

                        slug =
                            title
                                |> String.toLower
                                |> String.trim
                                |> String.replace " " "-"
                                |> slugSanitize
                    in
                    text p0
                        :: a [ A.href ("/view/" ++ slug) ] [ text title ]
                        :: interleave psRest msRest

                ( p0 :: psRest, [] ) ->
                    text p0 :: interleave psRest []

                _ ->
                    []
    in
    Html.span [] (interleave parts matches)


slugSanitize : String -> String
slugSanitize s =
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
