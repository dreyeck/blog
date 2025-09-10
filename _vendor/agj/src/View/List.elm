module View.List exposing
    ( ViewList
    , fromItems
    , view
    , withNumbers
    )

import Html exposing (Html)
import Html.Attributes exposing (class)


type ViewList msg
    = ViewList
        { startNumber : Maybe Int
        , items : List (List (Html msg))
        }


fromItems : List (List (Html msg)) -> ViewList msg
fromItems items =
    ViewList
        { startNumber = Nothing
        , items = items
        }


withNumbers : Int -> ViewList msg -> ViewList msg
withNumbers startNumber (ViewList config) =
    ViewList { config | startNumber = Just startNumber }


view : ViewList msg -> Html msg
view (ViewList { items, startNumber }) =
    let
        renderItem : List (Html msg) -> Html msg
        renderItem item =
            Html.li [ class "ml-4" ]
                [ Html.div [ class "flex flex-col" ]
                    item
                ]

        renderedItems : List (Html msg)
        renderedItems =
            items
                |> List.map renderItem
    in
    case startNumber of
        Just num ->
            Html.ol
                [ class "marker:text-layout-60 flex list-decimal flex-col"
                , Html.Attributes.attribute "start" (String.fromInt num)
                ]
                renderedItems

        Nothing ->
            Html.ul
                [ class "marker:text-layout-60 flex list-disc flex-col" ]
                renderedItems
