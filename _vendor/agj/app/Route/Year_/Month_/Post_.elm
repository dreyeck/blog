module Route.Year_.Month_.Post_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Custom.Bool exposing (ifElse)
import Custom.Int as Int
import Custom.Markdown as Markdown
import Data.Category as Category
import Data.Date as Date
import Data.DevTo as DevTo
import Data.Mastodon.Status
import Data.Post as Post exposing (Post, PostGist)
import Data.Tag as Tag
import Date
import Dict exposing (Dict)
import Doc.FromMarkdown
import Doc.ToHtml
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Html exposing (Html)
import Html.Attributes exposing (class, href, target)
import Html.Extra
import Icon
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Site
import Url
import UrlPath exposing (UrlPath)
import View exposing (View)
import View.AudioPlayer
import View.PageBody


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildWithSharedState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init app shared =
    ( { audioPlayerState = View.AudioPlayer.initialState }
    , case app.data.gist.mastodonStatusId of
        Just statusId ->
            if Dict.get statusId shared.mastodonStatuses == Nothing then
                Effect.immediate (SharedMsg (Shared.RequestedMastodonStatus statusId))

            else
                Effect.none

        Nothing ->
            Effect.none
    )



-- PAGES


type alias RouteParams =
    { year : String
    , month : String
    , post : String
    }


pages : BackendTask FatalError (List RouteParams)
pages =
    Post.gistsList
        |> BackendTask.map
            (List.map
                (\{ postGist } ->
                    let
                        date =
                            Date.fromPosixTzCl postGist.dateTime
                    in
                    { year = Date.year date |> Int.padLeft 4
                    , month = Date.monthNumber date |> Int.padLeft 2
                    , post = postGist.slug
                    }
                )
            )



-- DATA


type alias Data =
    Post


type alias ActionData =
    {}


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    Post.single
        routeParams.year
        routeParams.month
        routeParams.post
        |> BackendTask.allowFatal



-- UPDATE


type alias Model =
    { audioPlayerState : View.AudioPlayer.State
    }


type Msg
    = AudioPlayerStateUpdated View.AudioPlayer.State
    | SharedMsg Shared.Msg


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg, Maybe Shared.Msg )
update app shared msg model =
    case msg of
        AudioPlayerStateUpdated state ->
            ( { model | audioPlayerState = state }
            , Effect.none
            , Nothing
            )

        SharedMsg sharedMsg ->
            ( model, Effect.none, Just sharedMsg )



-- SUBSCRIPTIONS


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none



-- VIEW


title : String -> String
title postTitle =
    Site.windowTitle postTitle


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    Site.postMeta
        { title = title app.data.gist.title
        , description = Markdown.getSummary app.data.markdown
        , publishedDate = app.data.gist.dateTime
        , tags = app.data.gist.tags
        , mainCategory =
            app.data.gist.categories
                |> List.head
        }


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app shared model =
    let
        date : String
        date =
            Date.formatShortDate (Date.fromPosixTzCl app.data.gist.dateTime)

        categoryEls : List (Html Msg)
        categoryEls =
            app.data.gist.categories
                |> List.map Category.toLink
                |> List.intersperse (Html.text ", ")

        categoriesTextEls : List (Html Msg)
        categoriesTextEls =
            if List.length app.data.gist.categories > 0 then
                [ Html.text "Categories: "
                , Html.i [] categoryEls
                , Html.text ". "
                ]

            else
                [ Html.text "No categories. " ]

        tagEls : List (Html Msg)
        tagEls =
            app.data.gist.tags
                |> List.map Tag.toLink
                |> List.intersperse (Html.text ", ")

        tagsTextEls : List (Html Msg)
        tagsTextEls =
            if List.length app.data.gist.tags > 0 then
                [ Html.text "Tags: "
                , Html.i [] tagEls
                , Html.text "."
                ]

            else
                [ Html.text "No tags." ]

        postInfo : Html Msg
        postInfo =
            Html.p [ class "w-full" ]
                ([ Html.text
                    ("Posted {date}, on "
                        |> String.replace "{date}" date
                    )
                 , Html.a [ href "/" ]
                    [ Html.text "agj's blog" ]
                 , Html.text ". "
                 ]
                    ++ categoriesTextEls
                    ++ tagsTextEls
                )

        contentEl : Html Msg
        contentEl =
            [ app.data.markdown
                |> Doc.FromMarkdown.parse
                    { audioPlayer = Just { onAudioPlayerStateUpdated = AudioPlayerStateUpdated } }
                |> Doc.ToHtml.view { audioPlayerState = Just model.audioPlayerState, onClick = Nothing }
            ]
                |> Html.div [ class "flex flex-col" ]
    in
    { title = title app.data.gist.title
    , body =
        View.PageBody.fromContent
            { theme = shared.theme
            , onRequestedChangeTheme = SharedMsg Shared.SelectedChangeTheme
            }
            contentEl
            |> View.PageBody.withTitleAndSubtitle
                [ Html.text app.data.gist.title ]
                postInfo
            |> View.PageBody.withFooter (viewInteractions { postGist = app.data.gist, mastodonStatuses = shared.mastodonStatuses })
            |> View.PageBody.view
    }


viewInteractions :
    { postGist : PostGist
    , mastodonStatuses : Dict String Shared.MastodonStatusRequest
    }
    -> Html Msg
viewInteractions { postGist, mastodonStatuses } =
    Html.section [ class "flex flex-col gap-4" ]
        [ viewMastodonInteractions postGist mastodonStatuses
        , viewDevToInteractions postGist.devToSlug
        ]


viewDevToInteractions : Maybe String -> Html Msg
viewDevToInteractions maybeDevToSlug =
    case maybeDevToSlug of
        Just devToSlug ->
            Html.section [ class "text-layout-50 flex flex-row gap-4" ]
                [ Html.div [ class "flex items-center justify-center" ]
                    [ Icon.devToLogo Icon.Medium
                    ]
                , Html.p []
                    [ Html.text "This article was "
                    , viewLink
                        { text = "also published over at Dev.to"
                        , url = DevTo.slugToUrl devToSlug
                        }
                    , Html.text "!"
                    ]
                ]

        Nothing ->
            Html.Extra.nothing


viewMastodonInteractions : PostGist -> Dict String Shared.MastodonStatusRequest -> Html Msg
viewMastodonInteractions postGist mastodonStatuses =
    let
        shareData =
            { postTitle = postGist.title
            , postUrl = Post.gistToCanonicalUrl postGist
            }

        justShareThisPostWithOthers : Html Msg
        justShareThisPostWithOthers =
            viewMastodonShareLink shareData
                { text = "just share this post with others"
                , comment = "“{postTitle}” by @agj@mstdn.social\n{postUrl}"
                }

        wrap : List (Html Msg) -> Html Msg
        wrap content =
            Html.section [ class "text-layout-50 flex flex-row gap-4" ]
                [ Html.div [ class "flex items-center justify-center" ]
                    [ Icon.mastodonLogo Icon.Medium
                    ]
                , Html.p []
                    (List.concat
                        [ content
                        , [ Html.text ". "
                          , Html.span [ class "inline-block align-middle" ]
                                [ Icon.heart Icon.Small ]
                          ]
                        ]
                    )
                ]
    in
    case postGist.mastodonStatusId of
        Just mastodonStatusId ->
            let
                mastodonStatusRequest : Maybe Shared.MastodonStatusRequest
                mastodonStatusRequest =
                    mastodonStatuses
                        |> Dict.get mastodonStatusId

                mastodonRepliesCount : Int
                mastodonRepliesCount =
                    case mastodonStatusRequest of
                        Just (Shared.MastodonStatusObtained { repliesCount }) ->
                            repliesCount

                        _ ->
                            0

                replyToMeOnMastodon : Html Msg
                replyToMeOnMastodon =
                    case mastodonRepliesCount of
                        0 ->
                            viewLink
                                { text = "Reply to me on Mastodon"
                                , url = Data.Mastodon.Status.idToUrl mastodonStatusId
                                }

                        _ ->
                            viewLink
                                { text =
                                    "See {repliesCount} repl{ies} on Mastodon"
                                        |> String.replace "{repliesCount}" (String.fromInt mastodonRepliesCount)
                                        |> String.replace "{ies}" (ifElse (mastodonRepliesCount == 1) "y" "ies")
                                , url = Data.Mastodon.Status.idToUrl mastodonStatusId
                                }

                tagMeToShareYourThoughtsWithMe : Html Msg
                tagMeToShareYourThoughtsWithMe =
                    viewMastodonShareLink shareData
                        { text = "tag me to share your thoughts with me"
                        , comment = "@agj@mstdn.social Regarding “{postTitle}”…\n\n{postUrl}"
                        }
            in
            wrap
                [ replyToMeOnMastodon
                , Html.text "! Otherwise, you can "
                , tagMeToShareYourThoughtsWithMe
                , Html.text ", or "
                , justShareThisPostWithOthers
                ]

        Nothing ->
            let
                tagMeToShareYourThoughtsWithMe : Html Msg
                tagMeToShareYourThoughtsWithMe =
                    viewMastodonShareLink shareData
                        { text = "Tag me on Mastodon to share your thoughts with me"
                        , comment = "@agj@mstdn.social Regarding “{postTitle}”…\n\n{postUrl}"
                        }
            in
            wrap
                [ tagMeToShareYourThoughtsWithMe
                , Html.text ", or "
                , justShareThisPostWithOthers
                ]


viewMastodonShareLink :
    { a | postTitle : String, postUrl : String }
    -> { text : String, comment : String }
    -> Html Msg
viewMastodonShareLink { postTitle, postUrl } { text, comment } =
    let
        commentWithReplacements =
            replacePlaceholders comment

        replacePlaceholders string =
            string
                |> String.replace "{postTitle}" postTitle
                |> String.replace "{postUrl}" postUrl
    in
    viewLink
        { text = replacePlaceholders text
        , url =
            "https://tootpick.org/#text={comment}"
                |> String.replace "{comment}" (Url.percentEncode commentWithReplacements)
        }


viewLink : { text : String, url : String } -> Html Msg
viewLink { text, url } =
    Html.a [ href url, target "_blank" ]
        [ Html.text text ]
