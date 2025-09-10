module Route.Tag.Tag_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Data.Tag as Tag
import FatalError exposing (FatalError)
import Head
import Html
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import View exposing (View)


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


type alias Model =
    {}


type alias Msg =
    ()



-- ROUTES


type alias RouteParams =
    { tag : String }


pages : BackendTask FatalError (List RouteParams)
pages =
    Tag.all
        |> List.map Tag.getSlug
        |> List.map (\slug -> { tag = slug })
        |> BackendTask.succeed



-- DATA


type alias Data =
    ()


type alias ActionData =
    {}


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    BackendTask.succeed ()



-- VIEW


title : String
title =
    ""


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    [ Head.metaRedirect
        (Head.raw
            ("0; url="
                ++ Tag.slugsToUrl app.routeParams.tag []
            )
        )
    ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app shared =
    { title = title
    , body = Html.text ""
    }
