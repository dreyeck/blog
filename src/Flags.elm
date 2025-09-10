module Flags exposing (..)

import Data.Language as Language exposing (Language)
import Json.Decode exposing (Decoder, Value)
import Json.Encode
import Theme exposing (Theme)


type alias Flags =
    { languages : List Language
    , theme : Theme
    }


default : Flags
default =
    { languages = []
    , theme = Theme.default
    }


decoder : Decoder Flags
decoder =
    Json.Decode.map2 Flags
        (Json.Decode.field "languages" Language.listDecoder)
        (Json.Decode.field "theme" Theme.decoder)


encode : Flags -> Value
encode flags =
    Json.Encode.object
        [ ( "languages", Language.encodeList flags.languages )
        , ( "theme", Theme.encode flags.theme )
        ]
