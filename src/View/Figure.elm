module View.Figure exposing
    ( Figure
    , figure
    , setCaption
    , view
    )

import Html exposing (Html)
import Html.Attributes exposing (class)


type Figure msg
    = Figure
        { content : Html msg
        , caption : Maybe String
        }


figure : Html msg -> Figure msg
figure content =
    Figure
        { content = content
        , caption = Nothing
        }


setCaption : String -> Figure msg -> Figure msg
setCaption caption (Figure config) =
    Figure { config | caption = Just caption }



-- VIEW


view : Figure msg -> Html msg
view (Figure config) =
    let
        content : Html msg
        content =
            Html.div [ class "bg-layout-20 flex flex-col p-3" ]
                [ config.content ]

        caption : List (Html msg)
        caption =
            case config.caption of
                Just text ->
                    [ Html.div [ class "text-layout-50 flex flex-col px-10 pt-2 text-center text-sm" ]
                        [ Html.p [] [ Html.text text ] ]
                    ]

                Nothing ->
                    []
    in
    Html.div [ class "flex flex-col items-center" ]
        (List.concat [ [ content ], caption ])
