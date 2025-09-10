module Data.Post exposing
    ( Post
    , PostGist
    , gistToCanonicalUrl
    , gistToUrl
    , gistsList
    , list
    , matchesLanguage
    , single
    )

import BackendTask exposing (BackendTask)
import BackendTask.File exposing (FileReadError)
import BackendTask.Glob as Glob
import Consts
import Custom.Int as Int
import Custom.List as List
import Data.Category as Category exposing (Category)
import Data.Date as Date
import Data.Language as Language exposing (Language)
import Data.Tag as Tag exposing (Tag)
import Date
import FatalError exposing (FatalError)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import List.NonEmpty
import Result.Extra
import Time


type alias Post =
    { markdown : String
    , gist : PostGist
    }


type alias PostGist =
    { id : Maybe Int
    , slug : String
    , title : String
    , language : ( Language, List Language )
    , categories : List Category
    , tags : List Tag
    , dateTime : Time.Posix
    , mastodonStatusId : Maybe String
    , devToSlug : Maybe String
    }


type alias Frontmatter =
    { id : Maybe Int
    , title : String
    , language : ( Language, List Language )
    , categories : List Category
    , tags : List Tag
    , dateTime : Time.Posix
    , mastodonStatusId : Maybe String
    , devToSlug : Maybe String
    }


type alias GlobMatch =
    { path : String
    , yearString : String
    , monthString : String
    , slug : String
    , isHidden : Bool
    }


{-| String appended to the filename, to hide the post in lists.
-}
hiddenFlag : String
hiddenFlag =
    "-HIDDEN"


{-| List of all `PostGist`s obtained from the filesystem. Includes
hidden status of the post.
-}
gistsList : BackendTask FatalError (List { isHidden : Bool, postGist : PostGist })
gistsList =
    globMatchList
        |> BackendTask.andThen (List.map addFrontmatterToGlobMatch >> BackendTask.combine)
        |> BackendTask.andThen
            (List.map
                (\( globMatch, frontmatter ) ->
                    case globMatchWithFrontmatterToGist ( globMatch, frontmatter ) of
                        Result.Ok postGist ->
                            Result.Ok { isHidden = globMatch.isHidden, postGist = postGist }

                        Result.Err err ->
                            Result.Err err
                )
                >> Result.Extra.combine
                >> Result.map (List.reverseSortBy (\{ postGist } -> Time.posixToMillis postGist.dateTime))
                >> Result.mapError FatalError.fromString
                >> BackendTask.fromResult
            )


{-| List of all `Post`s obtained from the filesystem, excluding hidden
ones.
-}
list : BackendTask FatalError (List Post)
list =
    globMatchList
        |> BackendTask.map (List.filter (.isHidden >> not))
        |> BackendTask.andThen (List.map globMatchToPost >> BackendTask.combine)
        |> BackendTask.map (List.reverseSortBy (\post -> Time.posixToMillis post.gist.dateTime))


single :
    String
    -> String
    -> String
    -> BackendTask { fatal : FatalError, recoverable : FileReadError Decode.Error } Post
single year month slug =
    getPost year month slug False
        -- Look for it with the "hidden" flag, in case the above fails.
        |> BackendTask.onError (\_ -> getPost year month slug True)


gistToUrl : PostGist -> String
gistToUrl gist =
    let
        date =
            Date.fromPosixTzCl gist.dateTime
    in
    "/{year}/{month}/{post}"
        |> String.replace "{year}" (date |> Date.year |> Int.padLeft 4)
        |> String.replace "{month}" (date |> Date.monthNumber |> Int.padLeft 2)
        |> String.replace "{post}" gist.slug


gistToCanonicalUrl : PostGist -> String
gistToCanonicalUrl gist =
    "{root}{path}"
        |> String.replace "{root}" Consts.siteCanonicalUrl
        |> String.replace "{path}" (gistToUrl gist)


matchesLanguage : List Language -> PostGist -> Bool
matchesLanguage selectedLanguages { language } =
    (selectedLanguages == [])
        || List.NonEmpty.any (List.memberOf selectedLanguages) language



-- INTERNAL


getPost :
    String
    -> String
    -> String
    -> Bool
    -> BackendTask { fatal : FatalError, recoverable : FileReadError Decode.Error } Post
getPost year month slug isHidden =
    BackendTask.File.bodyWithFrontmatter (postDecoder { year = year, month = month, slug = slug })
        ("data/posts/{year}/{month}-{post}{hidden}.md"
            |> String.replace "{year}" year
            |> String.replace "{month}" month
            |> String.replace "{post}" slug
            |> String.replace "{hidden}"
                (if isHidden then
                    hiddenFlag

                 else
                    ""
                )
        )


globMatchList : BackendTask FatalError (List GlobMatch)
globMatchList =
    Glob.succeed GlobMatch
        |> Glob.match (Glob.literal "data/posts/")
        -- Path
        |> Glob.captureFilePath
        -- Year
        |> Glob.capture Glob.digits
        |> Glob.match (Glob.literal "/")
        -- Month
        |> Glob.capture Glob.digits
        |> Glob.match (Glob.literal "-")
        -- Slug
        |> Glob.capture Glob.wildcard
        -- Hidden post flag
        |> Glob.capture
            (Glob.oneOf
                ( ( hiddenFlag, True )
                , [ ( "", False ) ]
                )
            )
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask
        |> BackendTask.allowFatal


globMatchToPost : GlobMatch -> BackendTask FatalError Post
globMatchToPost { yearString, monthString, slug } =
    BackendTask.File.bodyWithFrontmatter
        (postDecoder
            { year = yearString
            , month = monthString
            , slug = slug
            }
        )
        ("data/posts/{year}/{month}-{post}.md"
            |> String.replace "{year}" yearString
            |> String.replace "{month}" monthString
            |> String.replace "{post}" slug
        )
        |> BackendTask.allowFatal


addFrontmatterToGlobMatch : GlobMatch -> BackendTask FatalError ( GlobMatch, Frontmatter )
addFrontmatterToGlobMatch match =
    BackendTask.File.onlyFrontmatter frontmatterDecoder match.path
        |> BackendTask.allowFatal
        |> BackendTask.map
            (\frontmatter -> ( match, frontmatter ))


globMatchWithFrontmatterToGist : ( GlobMatch, Frontmatter ) -> Result String PostGist
globMatchWithFrontmatterToGist ( globMatch, frontmatter ) =
    let
        yearMaybe =
            globMatch.yearString
                |> String.toInt

        monthMaybe =
            globMatch.monthString
                |> String.toInt
                |> Maybe.map Date.intToMonth
    in
    case ( yearMaybe, monthMaybe ) of
        ( Just year, Just month ) ->
            let
                date =
                    Date.fromPosixTzCl frontmatter.dateTime
            in
            if Date.year date == year && Date.month date == month then
                Result.Ok
                    { id = frontmatter.id
                    , title = frontmatter.title
                    , slug = globMatch.slug
                    , language = frontmatter.language
                    , categories = frontmatter.categories
                    , tags = frontmatter.tags
                    , dateTime = frontmatter.dateTime
                    , mastodonStatusId = frontmatter.mastodonStatusId
                    , devToSlug = frontmatter.devToSlug
                    }

            else
                Result.Err "Post path year and month don't match frontmatter date."

        _ ->
            Result.Err "Post path year or month is formatted incorrectly."



-- DECODERS


postDecoder :
    { year : String, month : String, slug : String }
    -> String
    -> Decoder Post
postDecoder { year, month, slug } markdown =
    let
        processFrontmatter : Frontmatter -> Decoder PostGist
        processFrontmatter frontmatter =
            case
                globMatchWithFrontmatterToGist
                    ( { path = ""
                      , yearString = year
                      , monthString = month
                      , slug = slug
                      , isHidden = False
                      }
                    , frontmatter
                    )
            of
                Result.Ok gist ->
                    Decode.succeed gist

                Result.Err err ->
                    Decode.fail err
    in
    frontmatterDecoder
        |> Decode.andThen processFrontmatter
        |> Decode.map (Post markdown)


frontmatterDecoder : Decoder Frontmatter
frontmatterDecoder =
    Decode.succeed Frontmatter
        |> Decode.optional "id" (Decode.maybe Decode.int) Nothing
        |> Decode.required "title" Decode.string
        |> Decode.required "language"
            (Decode.oneOf
                [ Language.decoder |> Decode.map (\language -> ( language, [] ))
                , Language.listDecoder
                    |> Decode.andThen
                        (\languages ->
                            case languages of
                                [] ->
                                    Decode.fail "No languages."

                                first :: rest ->
                                    Decode.succeed ( first, rest )
                        )
                ]
            )
        |> Decode.required "categories" (Decode.list Category.decoder)
        |> Decode.required "tags" (Decode.list Tag.decoder)
        |> Decode.required "date"
            (Decode.string
                |> Decode.andThen
                    (\string ->
                        case Date.wordpressToPosix string of
                            Just dateTime ->
                                Decode.succeed dateTime

                            Nothing ->
                                Decode.fail "Couldn't parse date."
                    )
            )
        |> Decode.optionalAt [ "external", "mastodon-toot-id" ] (Decode.maybe Decode.string) Nothing
        |> Decode.optionalAt [ "external", "devto-slug" ] (Decode.maybe Decode.string) Nothing
