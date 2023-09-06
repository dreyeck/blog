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


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app shared model =
    { title = "View.Slug_.SPLAT__"
    , body =
        [ Html.h2 [] [ Html.text app.data.title ]
        , Html.div [] (List.map renderStory app.data.story)
        ]
    }


renderStory : Wiki.Story -> Html msg
renderStory story =
    case story of
        Paragraph paragraph ->
            case paragraph.type_ of
                "paragraph" ->
                    Html.p [] [ Html.text paragraph.text ]

                _ ->
                    Html.text "Unknown story type"

        Future future ->
            Html.div [] [ Html.text "Future: " ]

        Factory factory ->
            Html.div [] [ Html.text "Factory: " ]

        EmptyStory ->
            Html.text "Empty Story"
