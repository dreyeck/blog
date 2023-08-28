module Route.View.Slug_.SPLAT__ exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask
import BackendTask.Custom
import Effect
import ErrorPage
import FatalError
import Head
import Html
import Json.Decode as Decode
import Json.Encode as Encode
import PagesMsg
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import UrlPath
import View


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    { slug : String, splat : List String }


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender { data = data, action = action, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    ( {}, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
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
    { hello : String }


type alias ActionData =
    {}


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data routeParams request =
    BackendTask.Custom.run "hello"
        -- Encode parameter name for hello(name)
        (Encode.string routeParams.slug)
        Decode.string
        |> BackendTask.allowFatal
        |> BackendTask.map
            (\hello -> Server.Response.render { hello = hello })


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


slug : RouteBuilder.App Data ActionData RouteParams -> String
slug app =
    app.routeParams.slug


{-| The splat data in RouteParams for an optional splat
are List String rather than (String, List String)
to represent the fact that optional splat routes could match 0 segments.
See Optional Splat Routes <https://wiki.ralfbarkow.ch/view/optional-splat-routes>
and <https://elm-pages.com/docs/file-based-routing/#optional-splat-routes>
-}
splat : RouteBuilder.App Data ActionData RouteParams -> String
splat app =
    String.join ", " app.routeParams.splat


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "View.Slug_.SPLAT__"
    , body = [ Html.h2 [] [ Html.text (app.data.hello ++ ", splat: " ++ splat app) ] ]
    }


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})
