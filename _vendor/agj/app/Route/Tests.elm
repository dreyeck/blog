module Route.Tests exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Html exposing (Html)
import Html.Attributes exposing (class)
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import UrlPath exposing (UrlPath)
import View exposing (View)
import View.PageBody


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
    {}


type alias ActionData =
    {}


data : BackendTask FatalError Data
data =
    BackendTask.succeed {}



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


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    []


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app shared model =
    let
        content : Html Msg
        content =
            Html.div [ class "flex flex-col items-center" ]
                [ group "bg-[white]" [ row layoutColors, row primaryColors ]
                , group "bg-[black]" [ row layoutColors, row primaryColors ]
                ]

        group : String -> List (Html Msg) -> Html Msg
        group bgClass =
            Html.div
                [ class "flex flex-col gap-1 p-4"
                , class bgClass
                ]

        row : List (Html Msg) -> Html Msg
        row =
            Html.div [ class "flex flex-row gap-1 p-4" ]

        layoutColors =
            [ color "bg-layout-10"
            , color "bg-layout-20"
            , color "bg-layout-30"
            , color "bg-layout-40"
            , color "bg-layout-50"
            , color "bg-layout-60"
            , color "bg-layout-70"
            , color "bg-layout-80"
            , color "bg-layout-90"
            ]

        primaryColors =
            [ color "bg-primary-10"
            , color "bg-primary-20"
            , color "bg-primary-30"
            , color "bg-primary-40"
            , color "bg-primary-50"
            , color "bg-primary-60"
            , color "bg-primary-70"
            , color "bg-primary-80"
            , color "bg-primary-90"
            ]

        color : String -> Html Msg
        color bgClass =
            Html.div [ class "size-5 rounded-full", class bgClass ] []
    in
    { title = "Tests"
    , body =
        View.PageBody.fromContent
            { theme = shared.theme
            , onRequestedChangeTheme = SharedMsg Shared.SelectedChangeTheme
            }
            content
            |> View.PageBody.withTitle [ Html.text "Tests" ]
            |> View.PageBody.view
    }
