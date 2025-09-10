module View.LanguageToggle exposing (viewButton, viewCard)

import Custom.Html.Attributes exposing (ariaPressed)
import Data.Language as Language exposing (Language)
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events
import List.Extra as List
import View.Card


viewCard :
    { onSelectionChange : List Language -> msg
    , selectedLanguages : List Language
    }
    -> Html msg
viewCard config =
    View.Card.view
        { title = Just (Html.text "Language")
        , class = Nothing
        , content =
            Html.div [ class "flex flex-row flex-wrap gap-1" ]
                (Language.all |> List.map (viewButton config))
        }


viewButton :
    { onSelectionChange : List Language -> msg
    , selectedLanguages : List Language
    }
    -> Language
    -> Html msg
viewButton config language =
    let
        isSelected =
            List.member language config.selectedLanguages

        noneSelected =
            config.selectedLanguages == []

        newLanguagesOnClick =
            if isSelected then
                List.remove language config.selectedLanguages

            else
                language :: config.selectedLanguages
    in
    Html.button
        [ class "rounded-sm px-1 text-xs"
        , if noneSelected then
            class "bg-layout-60 text-layout-10"

          else
            class "bg-layout-30 text-layout-10 decoration-layout-50 aria-pressed:bg-layout-90 line-through decoration-2 aria-pressed:no-underline"
        , ariaPressed isSelected
        , Html.Events.onClick (config.onSelectionChange newLanguagesOnClick)
        ]
        [ Html.text (Language.toShortString language |> String.toUpper) ]
