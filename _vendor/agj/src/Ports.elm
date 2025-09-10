port module Ports exposing (Msg(..), listen, saveConfig, setTheme)

import AppUrl exposing (QueryParameters)
import Custom.Json.Decode
import Flags exposing (Flags)
import Json.Decode exposing (Decoder, Value)
import Json.Encode
import Theme exposing (Theme, ThemeColor)
import Url



-- INCOMING


type Msg
    = QueryParamsChanged QueryParameters
    | DefaultThemeChanged ThemeColor
    | Invalid


listen : Sub Msg
listen =
    let
        decoder =
            Json.Decode.oneOf
                [ rawMsgDecoder "urlChanged" queryParamsDecoder QueryParamsChanged
                , rawMsgDecoder "defaultThemeChanged" Theme.themeColorDecoder DefaultThemeChanged
                ]
    in
    receiveFromJs
        (\raw ->
            Json.Decode.decodeValue decoder raw
                |> Result.toMaybe
                |> Maybe.withDefault Invalid
        )



-- OUTGOING


saveConfig : Flags -> Cmd msg
saveConfig flags =
    sendOut "saveConfig" (Flags.encode flags)


setTheme : Theme -> Cmd msg
setTheme theme =
    sendOut "setTheme" (Theme.encode theme)



-- INTERNAL


sendOut : String -> Value -> Cmd msg
sendOut msg value =
    sendToJs
        (Json.Encode.object
            [ ( "msg", Json.Encode.string msg )
            , ( "value", value )
            ]
        )



-- DECODERS


rawMsgDecoder : String -> Decoder value -> (value -> Msg) -> Decoder Msg
rawMsgDecoder msg valueDecoder toMsg =
    Json.Decode.map2 (\_ -> toMsg)
        (Json.Decode.field "msg" (Custom.Json.Decode.literalString msg))
        (Json.Decode.field "value" valueDecoder)


queryParamsDecoder : Decoder QueryParameters
queryParamsDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\string ->
                case Url.fromString string of
                    Just url ->
                        AppUrl.fromUrl url
                            |> .queryParameters
                            |> Json.Decode.succeed

                    Nothing ->
                        Json.Decode.fail "Not a valid URL."
            )



-- PORTS


port sendToJs : Value -> Cmd msg


port receiveFromJs : (Value -> msg) -> Sub msg
