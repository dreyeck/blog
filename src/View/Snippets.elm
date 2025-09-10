module View.Snippets exposing (backToIndex)

import Html exposing (Html)
import Html.Attributes exposing (href)


backToIndex : List (Html msg)
backToIndex =
    [ Html.text "Back to "
    , Html.a [ href "/" ]
        [ Html.text "the index" ]
    , Html.text "."
    ]
