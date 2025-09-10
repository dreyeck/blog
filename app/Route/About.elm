module Route.About exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import Doc.FromMarkdown
import Doc.ToHtml
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Site
import UrlPath exposing (UrlPath)
import View exposing (View)
import View.PageBody
import View.Snippets


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
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



-- DATA


type alias Data =
    { markdown : String
    , title : String
    }


type alias ActionData =
    {}


data : BackendTask FatalError Data
data =
    BackendTask.File.bodyWithFrontmatter decoder "data/about.md"
        |> BackendTask.allowFatal


decoder : String -> Decoder Data
decoder content =
    Decode.succeed (Data content)
        |> Decode.required "title" Decode.string



-- UPDATE


type alias Model =
    {}


type Msg
    = SharedMsg Shared.Msg


type alias RouteParams =
    {}


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
    Site.windowTitle app.data.title


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Site.pageMeta (title app)


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app shared model =
    let
        titleEl : List (Html Msg)
        titleEl =
            [ Html.text app.data.title ]

        subtitle : Html Msg
        subtitle =
            Html.p []
                View.Snippets.backToIndex

        content : Html Msg
        content =
            app.data.markdown
                |> Doc.FromMarkdown.parse { audioPlayer = Nothing }
                |> Doc.ToHtml.view Doc.ToHtml.noConfig
    in
    { title = title app
    , body =
        View.PageBody.fromContent
            { theme = shared.theme
            , onRequestedChangeTheme = SharedMsg Shared.SelectedChangeTheme
            }
            content
            |> View.PageBody.withTitleAndSubtitle titleEl subtitle
            |> View.PageBody.withoutAboutLink
            |> View.PageBody.view
    }
