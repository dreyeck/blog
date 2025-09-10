module Custom.Html.Attributes exposing
    ( ariaDescribedBy
    , ariaPressed
    , none
    , popoverAuto
    , popoverTarget
    , roleTooltip
    , tabIndex
    )

import Html exposing (Attribute)
import Html.Attributes exposing (attribute)


ariaDescribedBy : List String -> Attribute msg
ariaDescribedBy elementIds =
    attribute "aria-describedby" (String.join " " elementIds)


{-| Used for `<button>` elements that can be selected.
-}
ariaPressed : Bool -> Attribute msg
ariaPressed isPressed =
    attribute "aria-pressed"
        (if isPressed then
            "true"

         else
            "false"
        )


roleTooltip : Attribute msg
roleTooltip =
    attribute "role" "tooltip"


popoverAuto : Attribute msg
popoverAuto =
    attribute "popover" "auto"


popoverTarget : String -> Attribute msg
popoverTarget targetElementId =
    attribute "popovertarget" targetElementId


none : Attribute msg
none =
    Html.Attributes.classList []


{-| Use `0` to make any element able to receive keyboard focus.
-}
tabIndex : Int -> Attribute msg
tabIndex index =
    attribute "tabindex" (String.fromInt index)
