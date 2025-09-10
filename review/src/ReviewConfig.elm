module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import Dict
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule as Rule exposing (Rule)
import Set exposing (Set)
import TailwindCss.ClassOrder exposing (classOrder, classProps)
import TailwindCss.ConsistentClassOrder
import TailwindCss.NoCssConflict
import TailwindCss.NoUnknownClasses


config : List Rule
config =
    [ NoUnused.CustomTypeConstructorArgs.rule
    , NoUnused.CustomTypeConstructors.rule []
    , NoUnused.Exports.rule
        -- elm-pages needs a lot of exposed stuff.
        |> Rule.ignoreErrorsForDirectories [ "app" ]
        -- Want to keep the "none" icon definition.
        |> Rule.ignoreErrorsForFiles [ "src/Icon.elm" ]
    , NoUnused.Variables.rule
    , NoUnused.Patterns.rule
    , TailwindCss.ConsistentClassOrder.rule (TailwindCss.ConsistentClassOrder.defaultOptions { order = classOrder })
    , TailwindCss.NoUnknownClasses.rule (TailwindCss.NoUnknownClasses.defaultOptions { order = classOrder })
    , TailwindCss.NoCssConflict.rule
        (TailwindCss.NoCssConflict.defaultOptions
            { props =
                classProps
                    -- Remove checking for collisions of certain properties.
                    |> Dict.filter
                        (\class properties ->
                            let
                                -- Custom classes have lowest priority, so their styles can be overriden.
                                isCustomClass =
                                    classOrder
                                        |> Dict.get class
                                        -- Custom classes have weight 0.
                                        |> Maybe.map ((==) 0)
                                        |> Maybe.withDefault False

                                hasIgnoredProperties =
                                    properties
                                        |> Set.intersect
                                            (Set.fromList
                                                [ -- Classes such as `text-xl` set it, and it's common
                                                  -- to want to set it to something else.
                                                  "line-height"
                                                ]
                                            )
                                        |> (Set.isEmpty >> not)
                            in
                            not isCustomClass && not hasIgnoredProperties
                        )
            }
        )
    ]
