module Route.Category.Category_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Data.AtomFeed as AtomFeed
import Data.Category as Category exposing (Category)
import Data.Post as Post
import Data.PostList
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Html exposing (Html)
import Html.Attributes exposing (class)
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Site
import UrlPath exposing (UrlPath)
import View exposing (View)
import View.ColumnsLayout
import View.LanguageToggle
import View.PageBody
import View.Snippets


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildWithSharedState
            { init = init
            , update = update
            , subscriptions = subscriptions
            , view = view
            }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init app shared =
    ( {}, Effect.none )



-- ROUTES


type alias RouteParams =
    { category : String }


pages : BackendTask FatalError (List RouteParams)
pages =
    Category.all
        |> List.map Category.getSlug
        |> List.map (\slug -> { category = slug })
        |> BackendTask.succeed



-- DATA


type alias Data =
    Category


type alias ActionData =
    {}


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    Category.singleDataSource routeParams.category
        |> BackendTask.mapError FatalError.fromString



-- UPDATE


type alias Model =
    {}


type Msg
    = SharedMsg Shared.Msg


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg, Maybe Shared.Msg )
update app shared msg model =
    case msg of
        SharedMsg sharedMsg ->
            ( model, Effect.none, Just sharedMsg )



-- SUBSCRIPTIONS


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub msg
subscriptions routeParams path shared model =
    Sub.none



-- VIEW


title : App Data ActionData RouteParams -> String
title app =
    "Category: {category}"
        |> String.replace "{category}" app.routeParams.category
        |> Site.windowTitle


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    Site.pageMeta (title app)
        ++ [ Head.rssLink (feedUrls app.data).rssUrl
           , AtomFeed.linkNode (feedUrls app.data).atomUrl
           ]


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app shared model =
    let
        category =
            app.data

        posts =
            app.sharedData.posts
                |> List.filter (\post -> List.member category post.categories)

        { rssUrl, atomUrl } =
            feedUrls category

        titleEls : List (Html Msg)
        titleEls =
            [ Html.text "Category: "
            , Html.i [] [ Html.text (Category.getName category) ]
            ]

        categoryDescription : List (Html Msg)
        categoryDescription =
            Category.getDescription category
                |> Maybe.map
                    (\desc -> [ Html.text (desc ++ " ") ])
                |> Maybe.withDefault []

        subtitle : Html Msg
        subtitle =
            Html.p []
                (categoryDescription
                    ++ View.Snippets.backToIndex
                )

        content =
            View.ColumnsLayout.view2
                { main =
                    Data.PostList.viewGists shared.languages
                        (posts |> List.map (\p -> { gist = p, summary = Nothing }))
                , side = sideColumn
                }

        sideColumn : Html Msg
        sideColumn =
            Html.aside [ class "flex flex-col gap-2" ]
                [ View.LanguageToggle.viewCard
                    { onSelectionChange = \languages -> SharedMsg (Shared.ChangedLanguages languages)
                    , selectedLanguages = shared.languages
                    }
                , Category.viewCard
                ]
    in
    { title = title app
    , body =
        View.PageBody.fromContent
            { theme = shared.theme
            , onRequestedChangeTheme = SharedMsg Shared.SelectedChangeTheme
            }
            content
            |> View.PageBody.withTitleAndSubtitle titleEls subtitle
            |> View.PageBody.withFeeds
                (View.PageBody.FeedUrls
                    { rssFeedUrl = rssUrl
                    , atomFeedUrl = atomUrl
                    }
                )
            |> View.PageBody.view
    }


feedUrls : Category -> { rssUrl : String, atomUrl : String }
feedUrls category =
    { rssUrl = feedUrl "rss" category
    , atomUrl = feedUrl "atom" category
    }


feedUrl : String -> Category -> String
feedUrl feedName category =
    "/category/{categorySlug}/{feedName}.xml"
        |> String.replace "{feedName}" feedName
        |> String.replace "{categorySlug}" (Category.getSlug category)
