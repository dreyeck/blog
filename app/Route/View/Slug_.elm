module Route.View.Slug_ exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask exposing (BackendTask)
import BackendTask.Http as Http
import FatalError exposing (FatalError)
import Head
import Html exposing (Html)
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)
import Wiki



-- /view/:slug


type alias RouteParams =
    { slug : String }


type alias Model =
    {}


type alias Msg =
    ()


type alias ActionData =
    {}



-- FedWiki page JSON


type alias Data =
    Wiki.Page



-- Choose which slugs to mirror


pages : BackendTask FatalError (List RouteParams)
pages =
    BackendTask.succeed
        [ { slug = "welcome-visitors" }
        ]



-- Fetch HTTPS FedWiki JSON at build time


data : RouteParams -> BackendTask FatalError Data
data params =
    Http.getJson ("https://blog.dreyeck.ch/" ++ params.slug ++ ".json") Wiki.pageDecoder
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    [ Head.canonicalLink (Just ("https://blog.dreyeck.ch/view/" ++ app.routeParams.slug)) ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
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


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { pages = pages
        , data = data
        , head = head
        }
        |> RouteBuilder.buildNoState { view = view }
