module Custom.Int exposing (padLeft)


padLeft : Int -> Int -> String
padLeft minLength int =
    String.fromInt int
        |> String.padLeft minLength '0'
