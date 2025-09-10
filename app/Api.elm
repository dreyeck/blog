module Api exposing (routes)

import ApiRoute exposing (ApiRoute)
import BackendTask exposing (BackendTask)
import Consts
import Custom.Markdown
import Data.AtomFeed as AtomFeed
import Data.Category as Category exposing (Category)
import Data.Post as Post exposing (Post)
import Data.Tag as Tag exposing (Tag)
import FatalError exposing (FatalError)
import Html exposing (Html)
import LanguageTag exposing (emptySubtags)
import LanguageTag.Language
import Pages
import Pages.Manifest as Manifest
import Route exposing (Route)
import Rss


routes :
    BackendTask FatalError (List Route)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes getStaticRoutes htmlToString =
    [ manifest

    -- Global RSS feed.
    , ApiRoute.succeed
        (Post.list
            |> BackendTask.map
                (rss
                    { title = Consts.siteName
                    , description = Consts.siteDescription
                    , url = Consts.siteCanonicalUrl
                    }
                )
        )
        |> ApiRoute.literal "rss.xml"
        |> ApiRoute.single

    -- Global Atom feed.
    , ApiRoute.succeed
        (Post.list
            |> BackendTask.map
                (AtomFeed.generate
                    { title = Consts.siteName
                    , description = Consts.siteDescription
                    , url = Consts.siteCanonicalUrl
                    , atomFeedUrl = Consts.siteCanonicalUrl ++ "/" ++ "atom.xml"
                    }
                )
        )
        |> ApiRoute.literal "atom.xml"
        |> ApiRoute.single

    -- Category RSS feeds.
    , categoryFeeds "rss.xml"
        (\category ->
            rss
                { title = categoryFeedName category
                , description = Consts.siteDescription
                , url = Category.toCanonicalUrl category
                }
        )

    -- Category Atom feeds.
    , categoryFeeds "atom.xml"
        (\category ->
            AtomFeed.generate
                { title = categoryFeedName category
                , description = Consts.siteDescription
                , url = Category.toCanonicalUrl category
                , atomFeedUrl = Category.toCanonicalUrl category ++ "/" ++ "atom.xml"
                }
        )

    -- Tag RSS feeds.
    , tagFeeds "rss.xml"
        (\tag ->
            rss
                { title = tagFeedName tag
                , description = Consts.siteDescription
                , url = Tag.toCanonicalUrl tag []
                }
        )

    -- Tag Atom feeds.
    , tagFeeds "atom.xml"
        (\tag ->
            AtomFeed.generate
                { title = tagFeedName tag
                , description = Consts.siteDescription
                , url = Tag.toCanonicalUrl tag []
                , atomFeedUrl = Tag.toCanonicalUrl tag [] ++ "/" ++ "atom.xml"
                }
        )
    ]


{-| `manifest.json` file, describing this website to use as a “progressive web app”.

See: <https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Manifest>

    { title = String
    , description = String
    , url = String
    , lastBuildTime = Time.Posix
    , generator = Maybe String
    , items = List Item
    , siteUrl = String
    }

-}
manifest : ApiRoute ApiRoute.Response
manifest =
    Manifest.init
        { name = Consts.siteName
        , description = Consts.siteDescription
        , startUrl = Route.Index |> Route.toPath
        , icons = []
        }
        |> Manifest.withLang
            (LanguageTag.Language.en
                |> LanguageTag.build emptySubtags
            )
        |> BackendTask.succeed
        |> Manifest.generator Consts.siteCanonicalUrl


categoryFeeds : String -> (Category -> List Post -> String) -> ApiRoute ApiRoute.Response
categoryFeeds filename postsToFeed =
    ApiRoute.succeed
        (\categorySlug ->
            case Category.fromSlug categorySlug of
                Result.Ok category ->
                    Post.list
                        |> BackendTask.map
                            (\posts ->
                                posts
                                    |> List.filter
                                        (\post -> List.member categorySlug (List.map Category.getSlug post.gist.categories))
                                    |> postsToFeed category
                            )

                Result.Err err ->
                    BackendTask.fail (FatalError.fromString err)
        )
        |> ApiRoute.literal "category"
        |> ApiRoute.slash
        -- Category slug.
        |> ApiRoute.capture
        |> ApiRoute.slash
        |> ApiRoute.literal filename
        |> ApiRoute.preRender
            (\route ->
                Category.all
                    |> List.map (\category -> route (Category.getSlug category))
                    |> BackendTask.succeed
            )


tagFeeds : String -> (Tag -> List Post -> String) -> ApiRoute ApiRoute.Response
tagFeeds filename postsToFeed =
    ApiRoute.succeed
        (\tagSlug ->
            case Tag.fromSlug tagSlug of
                Result.Ok tag ->
                    Post.list
                        |> BackendTask.map
                            (\posts ->
                                posts
                                    |> List.filter
                                        (\post -> List.member tagSlug (List.map Tag.getSlug post.gist.tags))
                                    |> postsToFeed tag
                            )

                Result.Err err ->
                    BackendTask.fail (FatalError.fromString err)
        )
        |> ApiRoute.literal "tag"
        |> ApiRoute.slash
        -- Tag slug.
        |> ApiRoute.capture
        |> ApiRoute.slash
        |> ApiRoute.literal filename
        |> ApiRoute.preRender
            (\route ->
                Tag.all
                    |> List.map (\tag -> route (Tag.getSlug tag))
                    |> BackendTask.succeed
            )


rss :
    { title : String
    , url : String
    , description : String
    }
    -> List Post
    -> String
rss config posts =
    let
        items : List Rss.Item
        items =
            posts
                |> List.map postToItem

        postToItem : Post -> Rss.Item
        postToItem post =
            { title = post.gist.title
            , description = Custom.Markdown.getSummary post.markdown
            , url = Post.gistToUrl post.gist
            , categories = List.map Category.getSlug post.gist.categories
            , author = "agj"
            , pubDate = Rss.DateTime post.gist.dateTime
            , content = Nothing
            , contentEncoded = Nothing
            , enclosure = Nothing
            }
    in
    Rss.generate
        { title = config.title
        , description = config.description
        , url = config.url
        , lastBuildTime = Pages.builtAt
        , generator = Nothing
        , items = items
        , siteUrl = Consts.siteCanonicalUrl
        }


tagFeedName : Tag -> String
tagFeedName tag =
    "{siteName} / Tag: {tagName}"
        |> String.replace "{siteName}" Consts.siteName
        |> String.replace "{tagName}" (Tag.getName tag)


categoryFeedName : Category -> String
categoryFeedName category =
    "{siteName} / Category: {categoryName}"
        |> String.replace "{siteName}" Consts.siteName
        |> String.replace "{categoryName}" (Category.getName category)
