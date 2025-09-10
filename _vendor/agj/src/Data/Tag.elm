module Data.Tag exposing
    ( Tag
    , all
    , baseUrl
    , decoder
    , fromSlug
    , getName
    , getSlug
    , listView
    , listViewShort
    , slugsToUrl
    , toCanonicalUrl
    , toLink
    , toUrl
    )

import Consts
import Custom.Html
import Custom.Html.Attributes
import Custom.Int as Int
import Custom.List as List
import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, href)
import Html.Events
import Icon
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as Decode
import List.Extra as List


type Tag
    = Tag
        { name : String
        , slug : String
        }


getSlug : Tag -> String
getSlug (Tag { slug }) =
    slug


fromSlug : String -> Result String Tag
fromSlug slug =
    all
        |> List.find (\(Tag tag) -> tag.slug == slug)
        |> Result.fromMaybe ("Couldn't find tag: " ++ slug)


getName : Tag -> String
getName (Tag { name }) =
    name


baseUrl : String
baseUrl =
    "/tag/"


toUrl : Tag -> List Tag -> String
toUrl firstTag moreTags =
    slugsToUrl
        (getSlug firstTag)
        (List.map getSlug moreTags)


toCanonicalUrl : Tag -> List Tag -> String
toCanonicalUrl firstTag moreTags =
    "{root}{path}"
        |> String.replace "{root}" Consts.siteCanonicalUrl
        |> String.replace "{path}" (toUrl firstTag moreTags)


slugsToUrl : String -> List String -> String
slugsToUrl firstSlug moreSlugs =
    let
        slugs =
            firstSlug
                :: moreSlugs
                |> List.sort
                |> String.join "&t="
    in
    "{baseUrl}?t={slugs}"
        |> String.replace "{baseUrl}" baseUrl
        |> String.replace "{slugs}" slugs


toLink : Tag -> Html msg
toLink tag =
    Html.span []
        [ Html.a [ href (toUrl tag []) ]
            [ Html.text (getName tag) ]
        ]


listView :
    { onClick : Maybe (String -> msg)
    , selectedTags : List Tag
    , posts : List { a | tags : List Tag }
    }
    -> List Tag
    -> List (Html msg)
listView { onClick, selectedTags, posts } relatedTags =
    relatedTags
        |> List.map (addUseCountToTag posts)
        |> sortByCount
        |> List.map (\{ tag, count } -> viewItem { onClick = onClick, count = Just count, tagsToAddTo = selectedTags } tag)


listViewShort : Int -> List { a | tags : List Tag } -> List Tag -> List (Html msg)
listViewShort maxToTake allPosts tags =
    tags
        |> List.map (addUseCountToTag allPosts)
        |> sortByCount
        |> List.take maxToTake
        |> List.map
            (\{ tag, count } ->
                viewItem { onClick = Nothing, count = Just count, tagsToAddTo = [] } tag
            )


decoder : Decoder Tag
decoder =
    Decode.string
        |> Decode.map fromSlug
        |> Decode.andThen Decode.fromResult



-- INTERNAL


viewItem :
    { onClick : Maybe (String -> msg)
    , count : Maybe Int
    , tagsToAddTo : List Tag
    }
    -> Tag
    -> Html msg
viewItem { onClick, count, tagsToAddTo } tag =
    let
        url =
            toUrl tag []
    in
    Html.div [ class "flex w-max max-w-full shrink flex-row items-center gap-1 whitespace-nowrap" ]
        [ Html.a
            [ href url
            , maybeOnClick onClick url
            , class "shrink truncate"
            ]
            [ Html.text (getName tag) ]

        -- Count.
        , case count of
            Just c ->
                Html.div [ class "text-layout-50" ]
                    [ Html.text
                        ("({count})"
                            |> String.replace "{count}" (String.fromInt c)
                        )
                    ]

            Nothing ->
                Custom.Html.none

        -- Add button.
        , if List.length tagsToAddTo > 0 then
            Html.a
                [ attribute "aria" "button"
                , class "button text-layout-50 size-4"
                , href (toUrl tag tagsToAddTo)
                , maybeOnClick onClick (toUrl tag tagsToAddTo)
                ]
                [ Icon.plus Icon.Small ]

          else
            Custom.Html.none
        ]


sortByCount : List { tag : Tag, count : Int } -> List { tag : Tag, count : Int }
sortByCount tags =
    tags
        |> List.reverseSortBy
            (\{ tag, count } ->
                "{count}/{tagName}"
                    |> String.replace "{count}" (Int.padLeft 4 count)
                    |> String.replace "{tagName}" (getName tag)
            )


addUseCountToTag :
    List { a | tags : List Tag }
    -> Tag
    -> { tag : Tag, count : Int }
addUseCountToTag allPosts tag =
    { tag = tag
    , count =
        allPosts
            |> List.filter (.tags >> List.member tag)
            |> List.length
    }


maybeOnClick : Maybe (String -> msg) -> String -> Attribute msg
maybeOnClick maybeMsg url =
    case maybeMsg of
        Just msg ->
            Html.Events.onClick (msg url)

        Nothing ->
            Custom.Html.Attributes.none



-- TAGS


all : List Tag
all =
    [ Tag { name = "(Sin asunto)", slug = "sin-asunto" }
    , Tag { name = "album", slug = "album" }
    , Tag { name = "animation", slug = "animation" }
    , Tag { name = "anime", slug = "anime" }
    , Tag { name = "Anything", slug = "anything" }
    , Tag { name = "archive", slug = "archive" }
    , Tag { name = "Asymmetric feedback", slug = "asymmetric-feedback" }
    , Tag { name = "audio games", slug = "audio-games" }
    , Tag { name = "blog", slug = "blog" }
    , Tag { name = "book", slug = "book" }
    , Tag { name = "Buranko", slug = "buranko" }
    , Tag { name = "campodecolor", slug = "campodecolor" }
    , Tag { name = "Cave Trip", slug = "cave-trip" }
    , Tag { name = "Chile", slug = "chile" }
    , Tag { name = "cinema", slug = "cinema" }
    , Tag { name = "Climbrunner", slug = "climbrunner" }
    , Tag { name = "collaboration", slug = "collaboration" }
    , Tag { name = "Come to think of language", slug = "come-to-think-of-language" }
    , Tag { name = "comic", slug = "comic" }
    , Tag { name = "competition", slug = "competition" }
    , Tag { name = "conlang", slug = "conlang" }
    , Tag { name = "Construct", slug = "construct" }
    , Tag { name = "dot-into", slug = "dot-into" }
    , Tag { name = "dream", slug = "dream" }
    , Tag { name = "Elm", slug = "elm" }
    , Tag { name = "elm-knobs", slug = "elm-knobs" }
    , Tag { name = "Entretenimientos Diana", slug = "entretenimientos-diana" }
    , Tag { name = "español", slug = "espanol" }
    , Tag { name = "event", slug = "event" }
    , Tag { name = "exhibition", slug = "exhibition" }
    , Tag { name = "final year's project", slug = "final-years-project" }
    , Tag { name = "Flash", slug = "flash" }
    , Tag { name = "Flixel", slug = "flixel" }
    , Tag { name = "Flower pattern", slug = "flower-pattern" }
    , Tag { name = "Frogs Drink Faces", slug = "frogs-drink-faces" }
    , Tag { name = "front page design", slug = "front-page-design" }
    , Tag { name = "function-promisifier", slug = "function-promisifier" }
    , Tag { name = "Game Boy", slug = "game-boy" }
    , Tag { name = "game engine", slug = "game-engine" }
    , Tag { name = "games aggregate", slug = "games-aggregate" }
    , Tag { name = "Gently", slug = "gently" }
    , Tag { name = "graphic design", slug = "graphic-design" }
    , Tag { name = "GregWS", slug = "gregws" }
    , Tag { name = "Heart", slug = "heart" }
    , Tag { name = "illustration", slug = "illustration" }
    , Tag { name = "Interactive", slug = "interactive" }
    , Tag { name = "interactive fiction", slug = "interactive-fiction" }
    , Tag { name = "Intervalo lúcido del individuo inconsciente", slug = "intervalo-lucido-del-individuo-inconsciente" }
    , Tag { name = "January", slug = "january" }
    , Tag { name = "Japan", slug = "japan" }
    , Tag { name = "japanese", slug = "japanese" }
    , Tag { name = "Japoñol", slug = "japonol" }
    , Tag { name = "javascript", slug = "javascript" }
    , Tag { name = "Jugosa Cocina para Niños", slug = "jugosa-cocina-para-ninos" }
    , Tag { name = "Knytt of the Month", slug = "knytt-of-the-month" }
    , Tag { name = "Knytt Stories", slug = "knytt-stories" }
    , Tag { name = "KOTM", slug = "kotm" }
    , Tag { name = "language", slug = "language" }
    , Tag { name = "library", slug = "library" }
    , Tag { name = "literature", slug = "literature" }
    , Tag { name = "lofi", slug = "lofi" }
    , Tag { name = "Ludum Dare", slug = "ludum-dare" }
    , Tag { name = "Metaclase de Kanji", slug = "metaclase-de-kanji" }
    , Tag { name = "motion graphics", slug = "motion-graphics" }
    , Tag { name = "Muévete", slug = "muevete" }
    , Tag { name = "museography", slug = "museography" }
    , Tag { name = "music video", slug = "music-video" }
    , Tag { name = "Nendo project", slug = "nendo-project" }
    , Tag { name = "Nix", slug = "nix" }
    , Tag { name = "Nushell", slug = "nushell" }
    , Tag { name = "openFrameworks", slug = "openframeworks" }
    , Tag { name = "pen-and-paper game", slug = "pen-and-paper-game" }
    , Tag { name = "perception", slug = "perception" }
    , Tag { name = "PHP", slug = "php" }
    , Tag { name = "Pirate Kart", slug = "pirate-kart" }
    , Tag { name = "pixel art", slug = "pixel-art" }
    , Tag { name = "portfolio", slug = "portfolio" }
    , Tag { name = "post-mortem", slug = "post-mortem" }
    , Tag { name = "Prosopamnesia", slug = "prosopamnesia" }
    , Tag { name = "Racket", slug = "racket" }
    , Tag { name = "release", slug = "release" }
    , Tag { name = "Runnerby", slug = "runnerby" }
    , Tag { name = "Santiago", slug = "santiago" }
    , Tag { name = "Santiago en 100 palabras", slug = "santiago-en-100-palabras" }
    , Tag { name = "Sheets", slug = "sheets" }
    , Tag { name = "short film", slug = "short-film" }
    , Tag { name = "Sound", slug = "sound" }
    , Tag { name = "sound design", slug = "sound-design" }
    , Tag { name = "Spwords", slug = "spwords" }
    , Tag { name = "Super Friendship Club", slug = "super-friendship-club" }
    , Tag { name = "surrealism", slug = "surrealism" }
    , Tag { name = "text game", slug = "text-game" }
    , Tag { name = "The Ants Parade", slug = "the-ants-parade" }
    , Tag { name = "The Color and the Leaves", slug = "the-color-and-the-leaves" }
    , Tag { name = "The Games Collective", slug = "the-games-collective" }
    , Tag { name = "The Lake", slug = "the-lake" }
    , Tag { name = "The tea room", slug = "the-tea-room" }
    , Tag { name = "TIGSource", slug = "tigsource" }
    , Tag { name = "tracker", slug = "tracker" }
    , Tag { name = "translation", slug = "translation" }
    , Tag { name = "Tumblecopter", slug = "tumblecopter" }
    , Tag { name = "Twine", slug = "twine" }
    , Tag { name = "university", slug = "university" }
    , Tag { name = "video", slug = "video" }
    , Tag { name = "video game", slug = "video-game" }
    , Tag { name = "Viewpoints", slug = "viewpoints" }
    , Tag { name = "virtual reality", slug = "virtual-reality" }
    , Tag { name = "visual novel", slug = "visual-novel" }
    , Tag { name = "Walker", slug = "walker" }
    , Tag { name = "web", slug = "web" }
    , Tag { name = "Weekly concern", slug = "weekly-concern" }
    , Tag { name = "While telling with the eyes", slug = "while-telling-with-the-eyes" }
    , Tag { name = "Wirewalk", slug = "wirewalk" }
    , Tag { name = "Within", slug = "within" }
    , Tag { name = "work", slug = "work" }
    , Tag { name = "writing", slug = "writing" }
    , Tag { name = "日本語", slug = "nihongo" }
    ]
