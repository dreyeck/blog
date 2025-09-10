module View exposing (View, map)

import Html exposing (Html)


type alias View msg =
    { title : String
    , body : Html msg
    }



-- MODIFICATION


map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = Html.map fn doc.body
    }
