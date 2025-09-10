module Icon exposing
    ( Icon
    , Size(..)
    , devToLogo
    , foldLeft
    , foldRight
    , heart
    , info
    , mastodonLogo
    , minus
    , moon
    , none
    , pause
    , play
    , plus
    , rss
    , stop
    , sun
    , xMark
    )

import Html exposing (Html)
import Html.Attributes
import Phosphor


type alias Icon msg =
    Size -> Html msg


type Size
    = Medium
    | Small


play : Icon msg
play =
    icon icons.play


pause : Icon msg
pause =
    icon icons.pause


stop : Icon msg
stop =
    icon icons.stop


moon : Icon msg
moon =
    icon icons.moon


sun : Icon msg
sun =
    icon icons.sun


minus : Icon msg
minus =
    icon icons.minus


plus : Icon msg
plus =
    icon icons.plus


xMark : Icon msg
xMark =
    icon icons.xMark


info : Icon msg
info =
    icon icons.info


rss : Icon msg
rss =
    icon icons.rss


foldLeft : Icon msg
foldLeft =
    icon icons.foldLeft


foldRight : Icon msg
foldRight =
    icon icons.foldRight


heart : Icon msg
heart =
    icon icons.heart


mastodonLogo : Icon msg
mastodonLogo =
    icon icons.mastodonLogo


devToLogo : Icon msg
devToLogo =
    icon icons.devToLogo


none : Icon msg
none size =
    Html.div
        [ Html.Attributes.style "width" (sizeToRems size)
        , Html.Attributes.style "height" (sizeToRems size)
        ]
        []



-- INTERNAL


icon :
    { icon : Phosphor.Icon
    , md : Phosphor.IconWeight
    , sm : Phosphor.IconWeight
    }
    -> Size
    -> Html msg
icon definition size =
    let
        weight =
            case size of
                Medium ->
                    definition.md

                Small ->
                    definition.sm
    in
    definition.icon weight
        |> Phosphor.withSize (sizeToRemsNoUnit size)
        |> Phosphor.withSizeUnit "rem"
        |> Phosphor.toHtml []


sizeToRems : Size -> String
sizeToRems size =
    String.fromFloat (sizeToRemsNoUnit size) ++ "rem"


sizeToRemsNoUnit : Size -> Float
sizeToRemsNoUnit size =
    case size of
        Medium ->
            1

        Small ->
            0.75


icons =
    { play = { icon = Phosphor.play, md = Phosphor.Fill, sm = Phosphor.Fill }
    , pause = { icon = Phosphor.pause, md = Phosphor.Fill, sm = Phosphor.Fill }
    , stop = { icon = Phosphor.stop, md = Phosphor.Fill, sm = Phosphor.Fill }
    , moon = { icon = Phosphor.moon, md = Phosphor.Fill, sm = Phosphor.Fill }
    , sun = { icon = Phosphor.sun, md = Phosphor.Fill, sm = Phosphor.Fill }
    , minus = { icon = Phosphor.minus, md = Phosphor.Bold, sm = Phosphor.Bold }
    , plus = { icon = Phosphor.plus, md = Phosphor.Bold, sm = Phosphor.Bold }
    , xMark = { icon = Phosphor.x, md = Phosphor.Bold, sm = Phosphor.Bold }
    , info = { icon = Phosphor.info, md = Phosphor.Bold, sm = Phosphor.Bold }
    , rss = { icon = Phosphor.rss, md = Phosphor.Bold, sm = Phosphor.Bold }
    , foldLeft = { icon = Phosphor.caretLeft, md = Phosphor.Bold, sm = Phosphor.Bold }
    , foldRight = { icon = Phosphor.caretRight, md = Phosphor.Bold, sm = Phosphor.Bold }
    , heart = { icon = Phosphor.heart, md = Phosphor.Bold, sm = Phosphor.Bold }
    , mastodonLogo = { icon = Phosphor.mastodonLogo, md = Phosphor.Fill, sm = Phosphor.Fill }
    , devToLogo = { icon = Phosphor.devToLogo, md = Phosphor.Fill, sm = Phosphor.Fill }
    }
