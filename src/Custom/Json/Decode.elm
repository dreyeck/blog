module Custom.Json.Decode exposing (..)

import Json.Decode exposing (Decoder)


literalString : String -> Decoder String
literalString value =
    Json.Decode.string
        |> Json.Decode.andThen
            (\string ->
                if string == value then
                    Json.Decode.succeed string

                else
                    Json.Decode.fail
                        ("String \"{string}\" is not the correct value \"{value}\"."
                            |> String.replace "{string}" string
                            |> String.replace "{value}" value
                        )
            )
