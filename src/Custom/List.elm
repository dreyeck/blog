module Custom.List exposing (..)

import List.Extra as List


memberOf : List a -> a -> Bool
memberOf list item =
    List.member item list


{-| Groups items in a list under the results of a grouping function.
The returned list's values are tuples of this result and the items that fall under that grouping.
-}
gatherUnder : (a -> comparable) -> List a -> List ( comparable, List a )
gatherUnder toComparable list =
    list
        |> List.gatherEqualsBy toComparable
        |> List.map (\( first, rest ) -> ( toComparable first, first :: rest ))


{-| Same as `List.sortBy`, except it sorts in descending order (highest to
lowest). It is also guaranteed stable.
-}
reverseSortBy : (a -> comparable) -> List a -> List a
reverseSortBy toComparable list =
    List.stableSortWith
        (\left right ->
            let
                leftComparable =
                    toComparable left

                rightComparable =
                    toComparable right
            in
            if leftComparable < rightComparable then
                GT

            else if leftComparable > rightComparable then
                LT

            else
                EQ
        )
        list
