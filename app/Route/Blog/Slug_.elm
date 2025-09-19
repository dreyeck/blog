module Route.Blog.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { slug : String }


type alias Data =
    { something : String
    }


type alias ActionData =
    {}


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg ())
view app _ =
    let
        content : Html (PagesMsg ())
        content =
            Html.div []
                [ Html.h2 [] [ Html.text ("Blog: " ++ app.routeParams.slug) ]
                , Html.p [] [ Html.text "…" ]
                ]
    in
    { title = "Blog: " ++ app.routeParams.slug
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


pages : BackendTask FatalError (List RouteParams)
pages =
    BackendTask.succeed
        [ { slug = "hello" }
        ]


data : RouteParams -> BackendTask FatalError Data
data _ =
    BackendTask.map Data
        (BackendTask.succeed "Hi")


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website
