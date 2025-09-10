module Shared exposing
    ( Data
    , MastodonStatusRequest(..)
    , Model
    , Msg(..)
    , template
    )

import BackendTask exposing (BackendTask)
import Data.Language exposing (Language)
import Data.Mastodon.Status exposing (MastodonStatus)
import Data.Post as Post exposing (PostGist)
import Dict exposing (Dict)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Flags
import Html exposing (Html)
import Http
import Json.Decode
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Ports
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Theme exposing (Theme, ThemeColor)
import UrlPath exposing (UrlPath)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init flagsRaw maybePagePath =
    let
        flags =
            case flagsRaw of
                Pages.Flags.BrowserFlags value ->
                    Json.Decode.decodeValue Flags.decoder value
                        |> Result.withDefault Flags.default

                Pages.Flags.PreRenderFlags ->
                    Flags.default
    in
    ( { theme = flags.theme
      , languages = flags.languages
      , mastodonStatuses = Dict.empty
      }
    , Effect.SetTheme flags.theme
    )



-- DATA


type alias Data =
    { posts : List PostGist
    }


type MastodonStatusRequest
    = MastodonStatusRequesting
    | MastodonStatusObtained MastodonStatus


data : BackendTask FatalError Data
data =
    Post.gistsList
        |> BackendTask.map
            (\postGists ->
                postGists
                    |> List.filterMap
                        (\{ isHidden, postGist } ->
                            if isHidden then
                                Nothing

                            else
                                Just postGist
                        )
                    |> Data
            )



-- UPDATE


type Msg
    = SelectedChangeTheme
    | ChangedLanguages (List Language)
    | RequestedMastodonStatus String
    | GotMastodonStatus String (Result Http.Error MastodonStatus)
    | DefaultThemeChanged ThemeColor
    | NoOp


type alias Model =
    { theme : Theme
    , languages : List Language
    , mastodonStatuses : Dict String MastodonStatusRequest
    }


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SelectedChangeTheme ->
            let
                newTheme =
                    Theme.change model.theme
            in
            ( { model | theme = newTheme }
            , Effect.batch
                [ Effect.SaveConfig
                    { languages = model.languages
                    , theme = newTheme
                    }
                , Effect.SetTheme newTheme
                ]
            )

        ChangedLanguages languages ->
            ( { model | languages = languages }
            , Effect.SaveConfig
                { languages = languages
                , theme = model.theme
                }
            )

        RequestedMastodonStatus statusId ->
            case Dict.get statusId model.mastodonStatuses of
                Just (MastodonStatusObtained _) ->
                    ( model, Effect.none )

                _ ->
                    ( { model
                        | mastodonStatuses =
                            model.mastodonStatuses
                                |> Dict.insert statusId MastodonStatusRequesting
                      }
                    , Effect.GetMastodonStatus (GotMastodonStatus statusId) statusId
                    )

        GotMastodonStatus statusId (Result.Err _) ->
            ( { model
                | mastodonStatuses =
                    model.mastodonStatuses
                        |> Dict.remove statusId
              }
            , Effect.none
            )

        GotMastodonStatus statusId (Result.Ok mastodonStatus) ->
            ( { model
                | mastodonStatuses =
                    model.mastodonStatuses
                        |> Dict.insert statusId (MastodonStatusObtained mastodonStatus)
              }
            , Effect.none
            )

        DefaultThemeChanged themeColor ->
            ( { model | theme = Theme.updateDefault themeColor model.theme }
            , Effect.none
            )

        NoOp ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Ports.listen
        |> Sub.map
            (\msg ->
                case msg of
                    Ports.DefaultThemeChanged theme ->
                        DefaultThemeChanged theme

                    _ ->
                        NoOp
            )



-- VIEW


view :
    Data
    ->
        { path : UrlPath
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view sharedData page model toMsg pageView =
    { body =
        [ pageView.body ]
    , title = pageView.title
    }
