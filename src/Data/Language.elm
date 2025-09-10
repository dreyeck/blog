module Data.Language exposing (Language(..), all, decoder, encodeList, fromString, listDecoder, toShortString)

import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Extra as Decode
import Json.Encode as Encode


type Language
    = English
    | Spanish
    | Japanese



-- | Mandarin


all : List Language
all =
    [ English
    , Spanish
    , Japanese

    -- , Mandarin
    ]


decoder : Decoder Language
decoder =
    Decode.string
        |> Decode.andThen (fromString >> Decode.fromResult)


listDecoder : Decoder (List Language)
listDecoder =
    Decode.list decoder


encode : Language -> Value
encode language =
    let
        string =
            case language of
                English ->
                    "eng"

                Spanish ->
                    "spa"

                Japanese ->
                    "jpn"

        -- Mandarin ->
        --     "cmn"
    in
    Encode.string string


encodeList : List Language -> Value
encodeList languages =
    Encode.list encode languages


fromString : String -> Result String Language
fromString str =
    case str of
        "eng" ->
            Ok English

        "spa" ->
            Ok Spanish

        "jpn" ->
            Ok Japanese

        -- "cmn" ->
        --     Ok Mandarin
        _ ->
            Err ("Unknown language: " ++ str ++ ".")


toShortString : Language -> String
toShortString language =
    case language of
        English ->
            "en"

        Spanish ->
            "es"

        Japanese ->
            "日"



-- Mandarin ->
--     "中"
