module Custom.Bool exposing (..)


ifElse : Bool -> a -> a -> a
ifElse condition thenValue elseValue =
    if condition then
        thenValue

    else
        elseValue
