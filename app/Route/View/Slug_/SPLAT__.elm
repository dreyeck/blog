module Route.View.Slug_.SPLAT__ exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask exposing (BackendTask)
import BackendTask.File as File
import Effect
import ErrorPage
import FatalError exposing (FatalError)
import Head
import Html exposing (Html)
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Server.Request
import Server.Response
import Shared
import UrlPath
import View exposing (View)
import Wiki exposing (Story(..))


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    { slug : String, splat : List String }


init :
    App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    ( {}, Effect.none )


update :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    Wiki.Page


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data routeParams request =
    "../pages/"
        ++ routeParams.slug
        |> File.jsonFile Wiki.pageDecoder
        |> BackendTask.allowFatal
        |> BackendTask.map
            (\page ->
                Server.Response.render page
            )


type alias ActionData =
    {}


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    []


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender { data = data, action = action, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view app _ _ =
    let
        content : Html (PagesMsg Msg)
        content =
            Html.div []
                [ Html.h2 [] [ Html.text app.data.title ]
                , Html.div []
                    (List.map (Html.map Basics.never) (List.map Wiki.renderStory app.data.story))
                ]
    in
    { title = app.data.title
    , body = content
    }
