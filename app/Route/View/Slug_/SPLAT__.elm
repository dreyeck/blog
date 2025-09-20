module Route.View.Slug_.SPLAT__ exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask exposing (BackendTask)
import BackendTask.Http as Http
import Compat.FedWiki as FW
import Compat.WikiMarkup as WikiMarkup
import Effect
import ErrorPage
import FatalError exposing (FatalError)
import Head
import Html exposing (Html)
import Json.Decode as D
import PagesMsg
import RouteBuilder exposing (App)
import Server.Request
import Server.Response
import Shared
import UrlPath
import View exposing (View)



-- ROUTE PARAMS / DATA ---------------------------------------------------------


type alias RouteParams =
    { slug : String
    , splat : List String
    }


type alias Data =
    { page : PageWire }


type alias ActionData =
    {}


type alias Model =
    {}


type Msg
    = NoOp



-- ROUTE -----------------------------------------------------------------------


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender { data = data, action = action, head = head }
        |> RouteBuilder.buildWithLocalState
            { init = init
            , update = update
            , subscriptions = subscriptions
            , view = view
            }



-- SERVER: data/action/head ----------------------------------------------------
-- NOTE: serverRender expects `data` to take the full App AFTER routeParams are parsed.
-- elm-pages passes you a big record (we name it `appCtx` here) plus the Request.


data : RouteParams -> Server.Request.Request -> BackendTask FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data routeParams _ =
    let
        pagePath =
            String.join "/" (routeParams.slug :: routeParams.splat)

        url =
            "http://localhost:3000/" ++ pagePath ++ ".json"
    in
    Http.get url (Http.expectJson pageWireDecoder)
        |> BackendTask.mapError .fatal
        |> BackendTask.map (\page -> Server.Response.render { page = page })


action : RouteParams -> Server.Request.Request -> BackendTask FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action _ _ =
    BackendTask.succeed (Server.Response.render {})


head : App Data ActionData app -> List Head.Tag
head _ =
    []



-- LOCAL STATE (minimal stubs) -------------------------------------------------


init :
    App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init _ _ =
    ( {}, Effect.none )


update :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update _ _ _ model =
    ( model, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none



-- VIEW ------------------------------------------------------------------------


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg.PagesMsg Msg)
view app _ _ =
    let
        title =
            app.data.page.title

        content : Html Msg
        content =
            Html.div []
                ([ Html.h2 [] [ Html.text title ] ]
                    ++ WikiMarkup.renderParagraphs app.data.page.paragraphs
                )
    in
    { title = title
    , body = content |> Html.map PagesMsg.fromMsg
    }



-- WIRE-SAFE TYPES + DECODERS --------------------------------------------------


type alias PageWire =
    { title : String
    , paragraphs : List String
    }


pageWireDecoder : D.Decoder PageWire
pageWireDecoder =
    D.map2 PageWire
        (D.field "title" D.string)
        (D.field "story" (D.list storyParagraphMaybe) |> D.map (List.filterMap identity))



-- Decode only paragraph items: { type = "paragraph", text = "..."}


storyParagraphMaybe : D.Decoder (Maybe String)
storyParagraphMaybe =
    D.field "type" D.string
        |> D.andThen
            (\t ->
                if t == "paragraph" then
                    D.field "text" D.string |> D.map Just

                else
                    D.succeed Nothing
            )
