module View.Card exposing (view)

import Html exposing (Html)
import Html.Attributes
import Html.Attributes.Extra exposing (attributeMaybe)
import Html.Extra


view : { title : Maybe (Html msg), content : Html msg, class : Maybe String } -> Html msg
view { title, content, class } =
    Html.section
        [ Html.Attributes.class "bg-layout-20 flex flex-col gap-2 rounded-md p-3"
        , attributeMaybe Html.Attributes.class class
        ]
        [ case title of
            Just title_ ->
                Html.h1 [ Html.Attributes.class "text-layout-50 text-xs font-bold uppercase tracking-wider" ]
                    [ title_ ]

            Nothing ->
                Html.Extra.nothing
        , content
        ]
