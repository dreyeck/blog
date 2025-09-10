module Site exposing
    ( config
    , pageMeta
    , postMeta
    , windowTitle
    )

import BackendTask exposing (BackendTask)
import Consts
import Data.Category as Category exposing (Category)
import Data.Tag as Tag exposing (Tag)
import DateOrDateTime
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Pages.Url
import SiteConfig exposing (SiteConfig)
import Time
import UrlPath


config : SiteConfig
config =
    { canonicalUrl = "https://blog.agj.cl"
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.sitemapLink "/sitemap.xml"
    ]
        |> BackendTask.succeed



-- CUSTOMIZED


windowTitle : String -> String
windowTitle pageTitle =
    "{pageTitle} [{siteName}]"
        |> String.replace "{pageTitle}" pageTitle
        |> String.replace "{siteName}" Consts.siteName


pageMeta : String -> List Head.Tag
pageMeta title =
    metaBase { title = title, description = Nothing }
        |> Seo.website


postMeta :
    { title : String
    , description : String
    , publishedDate : Time.Posix
    , mainCategory : Maybe Category
    , tags : List Tag
    }
    -> List Head.Tag
postMeta info =
    metaBase
        { title = info.title
        , description = Just info.description
        }
        |> Seo.article
            { publishedTime = Just (DateOrDateTime.DateTime info.publishedDate)
            , modifiedTime = Nothing
            , section =
                info.mainCategory
                    |> Maybe.map Category.getSlug
            , tags =
                info.tags
                    |> List.map Tag.getSlug
            , expirationTime = Nothing
            }


metaBase : { title : String, description : Maybe String } -> Seo.Common
metaBase info =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = Consts.siteName
        , image =
            { url = Pages.Url.fromPath (UrlPath.fromString "/avatar.svg")
            , alt = Consts.siteName
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = info.description |> Maybe.withDefault Consts.siteDescription
        , locale = Nothing
        , title = info.title
        }
