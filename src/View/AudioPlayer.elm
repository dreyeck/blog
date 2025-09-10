module View.AudioPlayer exposing
    ( AudioPlayer
    , AudioPlayerWithConfig
    , Config
    , State
    , initialState
    , renderer
    , view
    , withConfig
    )

import Custom.Html
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events
import Icon
import List.Extra
import Markdown.Html
import View.AudioPlayer.Track as Track exposing (Track)


type alias AudioPlayer =
    { title : String
    }


type AudioPlayerWithConfig msg
    = AudioPlayerWithConfig AudioPlayer (Config msg)


type alias Config msg =
    { onStateUpdated : State -> msg
    , tracks : List Track
    }


type State
    = State StateInternal


type alias StateInternal =
    { playState : PlayState }


type PlayState
    = NoTrackSelected
    | TrackSelected Track Track.PlayState


initialState : State
initialState =
    State { playState = NoTrackSelected }


renderer : Markdown.Html.Renderer AudioPlayer
renderer =
    Markdown.Html.tag "audio-player" AudioPlayer
        |> Markdown.Html.withAttribute "title"


withConfig : Config msg -> AudioPlayer -> AudioPlayerWithConfig msg
withConfig config audioPlayer =
    AudioPlayerWithConfig audioPlayer config


view : State -> AudioPlayerWithConfig msg -> Html msg
view (State state) (AudioPlayerWithConfig audioPlayer config) =
    let
        trackPlayState : Track -> Track.PlayState
        trackPlayState track =
            case state.playState of
                TrackSelected currentTrack currentTrackPlayState ->
                    if currentTrack == track then
                        currentTrackPlayState

                    else
                        Track.stoppedPlayState

                NoTrackSelected ->
                    Track.stoppedPlayState

        nextTrack : Track -> Maybe Track
        nextTrack track =
            config.tracks
                |> List.Extra.findIndex ((==) track)
                |> Maybe.andThen (\index -> List.Extra.getAt (index + 1) config.tracks)

        trackConfig : Track -> Track.Config msg
        trackConfig track =
            { playState = trackPlayState track
            , onPlayStateChanged =
                \newPlayState ->
                    config.onStateUpdated
                        (State { state | playState = TrackSelected track newPlayState })
            , onFinishedPlayback =
                case nextTrack track of
                    Just nextTrack_ ->
                        config.onStateUpdated
                            (State { state | playState = TrackSelected nextTrack_ Track.playingPlayState })

                    Nothing ->
                        config.onStateUpdated
                            (State { state | playState = NoTrackSelected })
            }
    in
    case config.tracks of
        firstTrack :: _ ->
            Html.div [ class "bg-layout-20 flex flex-col overflow-clip rounded-md" ]
                [ titleView state config firstTrack audioPlayer.title
                , Html.div [ class "flex flex-col py-1" ]
                    (config.tracks
                        |> List.map
                            (\track ->
                                track
                                    |> Track.withConfig (trackConfig track)
                                    |> Track.view
                            )
                    )
                ]

        [] ->
            Custom.Html.none



-- INTERNAL


titleView : StateInternal -> Config msg -> Track -> String -> Html msg
titleView state config firstTrack title =
    let
        ( newPlayStateOnPress, icon ) =
            case state.playState of
                TrackSelected _ _ ->
                    ( NoTrackSelected
                    , Icon.stop
                    )

                NoTrackSelected ->
                    ( TrackSelected firstTrack Track.playingPlayState
                    , Icon.play
                    )
    in
    Html.button
        [ class "bg-layout-60 text-layout-10 w-full px-3 py-2"
        , Html.Events.onClick (config.onStateUpdated (State { state | playState = newPlayStateOnPress }))
        ]
        [ Html.div [ class "flex flex-row items-center gap-1" ]
            [ icon Icon.Medium
            , Html.text title
            ]
        ]
