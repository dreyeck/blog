module Theme exposing (Theme, ThemeColor(..), change, decoder, default, encode, themeColorDecoder, updateDefault)

import Custom.Json.Decode
import Json.Decode exposing (Decoder, Value)
import Json.Encode


type alias Theme =
    { set : Maybe ThemeColor
    , default : ThemeColor
    }


type ThemeColor
    = Light
    | Dark


default : Theme
default =
    { set = Nothing
    , default = Light
    }


change : Theme -> Theme
change theme =
    let
        newSetTheme : Maybe ThemeColor
        newSetTheme =
            case ( theme.set, theme.default ) of
                -- Setting to opposite of default.
                ( Nothing, Light ) ->
                    Just Dark

                ( Nothing, Dark ) ->
                    Just Light

                -- Setting to forced default.
                ( Just Light, Dark ) ->
                    Just Dark

                ( Just Dark, Light ) ->
                    Just Light

                -- Unsetting.
                ( Just Light, Light ) ->
                    Nothing

                ( Just Dark, Dark ) ->
                    Nothing
    in
    { theme | set = newSetTheme }


updateDefault : ThemeColor -> Theme -> Theme
updateDefault newDefault theme =
    { theme | default = newDefault }


decoder : Decoder Theme
decoder =
    Json.Decode.map2 Theme
        (Json.Decode.field "set" (Json.Decode.nullable themeColorDecoder))
        (Json.Decode.field "default" themeColorDecoder)


themeColorDecoder : Decoder ThemeColor
themeColorDecoder =
    Json.Decode.oneOf
        [ Custom.Json.Decode.literalString "light" |> Json.Decode.map (always Light)
        , Custom.Json.Decode.literalString "dark" |> Json.Decode.map (always Dark)
        ]


encode : Theme -> Value
encode theme =
    case theme.set of
        Just themeColor ->
            encodeThemeColor themeColor

        Nothing ->
            Json.Encode.null


encodeThemeColor : ThemeColor -> Value
encodeThemeColor themeColor =
    case themeColor of
        Light ->
            Json.Encode.string "light"

        Dark ->
            Json.Encode.string "dark"
