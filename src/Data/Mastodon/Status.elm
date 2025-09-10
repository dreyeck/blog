module Data.Mastodon.Status exposing
    ( MastodonStatus
    , getCmd
    , idToUrl
    )

import Http
import Json.Decode as Decode exposing (Decoder)


type alias MastodonStatus =
    { repliesCount : Int
    }


idToUrl : String -> String
idToUrl statusId =
    "https://mstdn.social/@agj/{statusId}"
        |> String.replace "{statusId}" statusId


getCmd : (Result Http.Error MastodonStatus -> msg) -> String -> Cmd msg
getCmd toMsg statusId =
    Http.get
        { url =
            "https://mstdn.social/api/v1/statuses/{statusId}"
                |> String.replace "{statusId}" statusId
        , expect = Http.expectJson toMsg decoder
        }


decoder : Decoder MastodonStatus
decoder =
    Decode.map MastodonStatus
        (Decode.field "replies_count" Decode.int)
