module View.AudioPlayer.Track exposing
    ( Config
    , PlayState
    , Track
    , playingPlayState
    , renderer
    , stoppedPlayState
    , view
    , withConfig
    )

import Custom.Html
import Html exposing (Html)
import Html.Attributes exposing (class, classList)
import Html.Events
import Html.Extra
import Icon
import Json.Decode as Decode exposing (Decoder)
import Markdown.Html
import TypedSvg as Svg
import TypedSvg.Attributes as Svg
import TypedSvg.Core
import TypedSvg.Types as Svg


type alias Track =
    { title : String
    , src : String
    }


type TrackWithConfig msg
    = TrackWithConfig Track (Config msg)


type alias Config msg =
    { playState : PlayState
    , onPlayStateChanged : PlayState -> msg
    , onFinishedPlayback : msg
    }


type PlayState
    = StateStopped
    | StatePlaying Playhead
    | StatePaused Playhead


type alias Playhead =
    { playing : Bool
    , currentTime : Float
    , duration : Float
    }


renderer : Markdown.Html.Renderer Track
renderer =
    Markdown.Html.tag "track" Track
        |> Markdown.Html.withAttribute "title"
        |> Markdown.Html.withAttribute "src"


withConfig : Config msg -> Track -> TrackWithConfig msg
withConfig config track =
    TrackWithConfig track config


view : TrackWithConfig msg -> Html msg
view (TrackWithConfig track config) =
    let
        ( isSelected, isPlaying, playhead ) =
            case config.playState of
                StatePlaying ph ->
                    ( True, True, ph )

                StatePaused ph ->
                    ( True, False, ph )

                StateStopped ->
                    ( False, False, initialPlayhead )

        { icon, newPlayStateOnPress, classes, iconClasses } =
            case config.playState of
                StatePlaying ph ->
                    { icon = Icon.pause
                    , newPlayStateOnPress = StatePaused ph
                    , classes = "text-white bg-primary-20"
                    , iconClasses = ""
                    }

                StatePaused ph ->
                    { icon = Icon.play
                    , newPlayStateOnPress = StatePlaying ph
                    , classes = "text-white bg-primary-20"
                    , iconClasses = ""
                    }

                StateStopped ->
                    { icon = Icon.play
                    , newPlayStateOnPress = StatePlaying initialPlayhead
                    , classes = "text-layout-90 bg-transparent group-hover:text-primary-60"
                    , iconClasses = "invisible group-hover:visible"
                    }

        audioPlayerEl =
            if isSelected then
                audioPlayerElement
                    { src = track.src
                    , isPlaying = isPlaying
                    , currentTime = playhead.currentTime
                    , onPlayStateChanged = config.onPlayStateChanged
                    , onFinishedPlayback = config.onFinishedPlayback
                    , playState = config.playState
                    }

            else
                Custom.Html.none

        buttonEl =
            Html.button
                [ class "w-full px-2 pt-2"
                , classList [ ( "pb-2", not isSelected ) ]
                , class classes
                , Html.Events.onClick (config.onPlayStateChanged newPlayStateOnPress)
                ]
                [ Html.div [ class "flex flex-row items-center gap-1" ]
                    [ Html.div [ class iconClasses ]
                        [ icon Icon.Medium ]
                    , Html.text track.title
                    , audioPlayerEl
                    ]
                ]

        seekPosToNewState : Float -> PlayState
        seekPosToNewState seekPos =
            case config.playState of
                StatePlaying ph ->
                    StatePlaying { ph | currentTime = ph.duration * seekPos }

                StatePaused ph ->
                    StatePaused { ph | currentTime = ph.duration * seekPos }

                StateStopped ->
                    StateStopped
    in
    Html.div [ class "group px-1" ]
        [ Html.div
            [ class "flex w-full flex-col overflow-clip rounded"
            , class classes
            ]
            [ buttonEl
            , if isSelected then
                seekBarView playhead
                    |> Html.map (seekPosToNewState >> config.onPlayStateChanged)

              else
                Html.Extra.nothing
            ]
        ]


stoppedPlayState : PlayState
stoppedPlayState =
    StateStopped


playingPlayState : PlayState
playingPlayState =
    StatePlaying initialPlayhead



-- INTERNAL


seekBarView : Playhead -> Html Float
seekBarView { currentTime, duration } =
    let
        barWidth =
            "0.5rem"

        halfBarWidth =
            "0.25rem"

        progress =
            Svg.rect
                [ Svg.x (Svg.px 0)
                , TypedSvg.Core.attribute "y" halfBarWidth
                , Svg.width (Svg.percent (currentTime / duration * 100))
                , TypedSvg.Core.attribute "height" halfBarWidth
                , Svg.fill (Svg.CSSVariable "--color-layout-90")
                ]
                []
    in
    Html.div
        [ class "w-full"
        , Html.Events.on "mousedown" trackMouseEventSeekPositionDecoder
        ]
        [ Svg.svg
            [ Svg.width (Svg.percent 100)
            , Html.Attributes.attribute "height" barWidth
            ]
            [ progress ]
        ]


audioPlayerElement :
    { src : String
    , isPlaying : Bool
    , currentTime : Float
    , onPlayStateChanged : PlayState -> msg
    , onFinishedPlayback : msg
    , playState : PlayState
    }
    -> Html msg
audioPlayerElement { src, isPlaying, currentTime, onPlayStateChanged, onFinishedPlayback, playState } =
    Html.node "audio-player"
        [ Html.Attributes.attribute "src" src
        , Html.Attributes.attribute "current-time" (String.fromFloat currentTime)
        , Html.Attributes.attribute "playing"
            (if isPlaying then
                "true"

             else
                "false"
            )
        , Html.Events.on "timeupdate"
            (playingTrackStateMsgDecoder
                { playState = playState
                , onPlayStateChanged = onPlayStateChanged
                , onFinishedPlayback = onFinishedPlayback
                }
            )
        ]
        []


initialPlayhead : Playhead
initialPlayhead =
    { playing = False
    , currentTime = 0
    , duration = 0
    }


playingTrackStateMsgDecoder :
    { playState : PlayState
    , onPlayStateChanged : PlayState -> msg
    , onFinishedPlayback : msg
    }
    -> Decoder msg
playingTrackStateMsgDecoder { playState, onPlayStateChanged, onFinishedPlayback } =
    playheadDecoder
        |> Decode.map
            (\newPlayhead ->
                case playState of
                    StatePlaying _ ->
                        if newPlayhead.playing then
                            onPlayStateChanged (StatePlaying newPlayhead)

                        else
                            onFinishedPlayback

                    StatePaused _ ->
                        onPlayStateChanged (StatePaused newPlayhead)

                    StateStopped ->
                        onPlayStateChanged StateStopped
            )


playheadDecoder : Decoder Playhead
playheadDecoder =
    Decode.map3 Playhead
        (Decode.at [ "detail", "playing" ] Decode.bool)
        (Decode.at [ "detail", "currentTime" ] Decode.float)
        (Decode.at [ "detail", "duration" ] Decode.float)


trackMouseEventSeekPositionDecoder : Decoder Float
trackMouseEventSeekPositionDecoder =
    Decode.map2 (\offsetX targetWidth -> offsetX / targetWidth)
        (Decode.at [ "offsetX" ] Decode.float)
        (Decode.at [ "currentTarget", "offsetWidth" ] Decode.float)
