module Data.PostList exposing (PostGistWithSummary, viewGists)

import Custom.Bool exposing (ifElse)
import Custom.Int as Int
import Custom.List as List
import Data.Category as Category
import Data.Date as Date
import Data.Language as Language exposing (Language)
import Data.Post as Post exposing (PostGist)
import Date
import Html exposing (Html)
import Html.Attributes exposing (class, href)
import Html.Extra
import List.NonEmpty


type alias PostGistWithSummary =
    { gist : PostGist, summary : Maybe String }


viewGists : List Language -> List PostGistWithSummary -> Html msg
viewGists selectedLanguages posts =
    let
        filteredPosts =
            posts
                |> List.filter (.gist >> Post.matchesLanguage selectedLanguages)

        postsByYearAndMonth : List ( Int, List ( Int, List PostGistWithSummary ) )
        postsByYearAndMonth =
            filteredPosts
                |> List.gatherUnder (.gist >> .dateTime >> Date.fromPosixTzCl >> Date.year)
                |> List.map
                    (\( year, yearPosts ) ->
                        ( year
                        , yearPosts
                            |> List.gatherUnder (.gist >> .dateTime >> Date.fromPosixTzCl >> Date.monthNumber)
                        )
                    )

        hiddenPostsCount =
            List.length posts - List.length filteredPosts

        hiddenPostsMessage =
            if hiddenPostsCount > 0 then
                [ Html.p [ class "italic text-layout-50" ]
                    [ Html.text
                        (if hiddenPostsCount == 1 then
                            "(1 post in another language remains hidden.)"

                         else
                            "({count} posts in other languages remain hidden.)"
                                |> String.replace "{count}" (String.fromInt hiddenPostsCount)
                        )
                    ]
                ]

            else
                []
    in
    Html.div [ class "flex flex-col gap-8" ]
        (List.map viewPostYear postsByYearAndMonth
            ++ hiddenPostsMessage
        )



-- INTERNAL


viewPostYear : ( Int, List ( Int, List PostGistWithSummary ) ) -> Html msg
viewPostYear ( year, postMonths ) =
    let
        heading =
            Html.h2 [ class "text-layout-70 text-2xl" ]
                [ Html.text (Int.padLeft 4 year) ]

        months =
            postMonths
                |> List.map viewPostMonth
    in
    Html.div [ class "flex flex-col gap-4" ]
        (heading :: months)


viewPostMonth : ( Int, List PostGistWithSummary ) -> Html msg
viewPostMonth ( month, posts ) =
    let
        heading : Html msg
        heading =
            Html.h3 [ class "text-layout-70" ]
                [ Html.text (Date.intToMonthFullName month) ]

        gistsList : List (Html msg)
        gistsList =
            List.map viewPost posts
    in
    Html.div [ class "flex flex-col gap-1" ]
        (heading :: gistsList)


viewPost : PostGistWithSummary -> Html msg
viewPost { gist, summary } =
    let
        postDayOfMonth : Html msg
        postDayOfMonth =
            Html.div [ class "text-layout-70 min-w-5 tabular-nums" ]
                [ Html.text (gist.dateTime |> Date.fromPosixTzCl |> Date.day |> Int.padLeft 2)
                ]

        postLink : Html msg
        postLink =
            Html.b []
                [ Html.a [ href (Post.gistToUrl gist) ]
                    [ Html.text gist.title ]
                ]

        postLanguages : List (Html msg)
        postLanguages =
            gist.language
                |> List.NonEmpty.map
                    (\language ->
                        Html.span [ class "bg-layout-40 text-layout-10 rounded-sm px-1 text-xs" ]
                            [ Html.text (Language.toShortString language |> String.toUpper) ]
                    )
                |> List.NonEmpty.toList

        postCategoryEls : List (Html msg)
        postCategoryEls =
            gist.categories
                |> List.map
                    (\category ->
                        Html.a [ href (Category.toUrl category) ]
                            [ Html.text (Category.getName category) ]
                    )

        postCategories : Html msg
        postCategories =
            Html.span [ class "text-layout-50 text-sm" ]
                (Html.text "("
                    :: (postCategoryEls |> List.intersperse (Html.text ", "))
                    ++ [ Html.text ")" ]
                )

        postSummary : Html msg
        postSummary =
            case summary of
                Just text ->
                    Html.p [ class "text-layout-40 pt-1 text-sm italic" ] [ Html.text text ]

                Nothing ->
                    Html.Extra.nothing
    in
    Html.div [ class "flex flex-row gap-2" ]
        [ postDayOfMonth
        , Html.div []
            [ Html.p []
                ([ [ postLink ], postLanguages, [ postCategories ] ]
                    |> List.concat
                    |> List.intersperse (Html.text " ")
                )
            , postSummary
            ]
        ]
