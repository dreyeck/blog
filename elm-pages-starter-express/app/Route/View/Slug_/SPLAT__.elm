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
import Html
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Server.Request
import Server.Response
import Shared
import UrlPath
import View exposing (View)
import Wiki


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    { slug : String, splat : List String }


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender { data = data, action = action, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


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


type alias ActionData =
    {}


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


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app shared model =
    { title = "View.Slug_.SPLAT__"
    , body =
        [ Html.h2 [] [ Html.text app.data.title ]
        , Html.p [] [ Html.text ("splat: " ++ splat app) ]
        , Html.p [] [ Html.text (storyToString app) ]
        , Html.p [] [ Html.text (journalToString app) ]
        ]
    }



-- app.data.story
-- Function to convert app.data.story to a single string


storyToString : App Data ActionData RouteParams -> String
storyToString app =
    app.data.story
        -- |> List.length
        -- Note: It is usually preferable to use a case to deconstruct a List because it gives you (x :: xs) and you can work with both subparts.
        -- |> List.head
        |> Debug.toString


journalToString : App Data ActionData RouteParams -> String
journalToString app =
    app.data.journal
        -- |> List.length
        -- Note: It is usually preferable to use a case to deconstruct a List because it gives you (x :: xs) and you can work with both subparts.
        -- |> List.head
        |> Debug.toString



-- List.map renderStory app.data.story
-- Mapping a List, see <https://elmprogramming.com/list.html#mapping-a-list>


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})


slug : App Data ActionData RouteParams -> String
slug app =
    app.routeParams.slug


{-| The splat data in RouteParams for an optional splat
are List String rather than (String, List String)
to represent the fact that optional splat routes could match 0 segments.
See Optional Splat Routes <https://wiki.ralfbarkow.ch/view/optional-splat-routes>
and <https://elm-pages.com/docs/file-based-routing/#optional-splat-routes>
-}
splat : App Data ActionData RouteParams -> String
splat app =
    String.join ", " app.routeParams.splat
