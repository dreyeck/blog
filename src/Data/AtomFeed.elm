module Data.AtomFeed exposing (generate, linkNode)

import Custom.Markdown
import Data.Category as Category exposing (Category)
import Data.Post as Post exposing (Post)
import Head
import Regex
import Rfc3339
import Time


{-| Atom XML feed generated according to
[this specification](https://validator.w3.org/feed/docs/atom.html).
-}
generate :
    { title : String
    , url : String
    , description : String
    , atomFeedUrl : String
    }
    -> List Post
    -> String
generate config posts =
    """<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <id>{url}</id>
  <updated>{updated}</updated>
  <link href="{url}" />
  <title><![CDATA[{title}]]></title>
  <author>
    <name>agj</name>
  </author>
  <link rel="self" type="application/atom+xml" href="{atomFeedUrl}" />
{entries}
</feed>
    """
        |> String.replace "{title}" config.title
        |> String.replace "{url}" (ensureUrlIsCanonical config.url)
        |> String.replace "{updated}"
            (posts
                |> List.head
                |> Maybe.map (\post -> post.gist.dateTime)
                |> Maybe.withDefault (Time.millisToPosix 0)
                |> posixToRfc3339
            )
        |> String.replace "{atomFeedUrl}" config.atomFeedUrl
        |> String.replace "{entries}"
            (posts
                |> List.map
                    (\post ->
                        generateEntry
                            { title = post.gist.title
                            , url = Post.gistToCanonicalUrl post.gist
                            , summary = Custom.Markdown.getSummary post.markdown
                            , published = post.gist.dateTime
                            , categories = post.gist.categories
                            }
                    )
                |> String.join ""
            )


{-| Creates a `<link>` node that points to an Atom feed, to place in
the HTML head.
-}
linkNode : String -> Head.Tag
linkNode url =
    Head.nonLoadingNode "link"
        [ ( "rel", Head.raw "alternate" )
        , ( "href", Head.raw url )
        , ( "type", Head.raw "application/atom+xml" )
        ]



-- INTERNAL


generateEntry :
    { title : String
    , url : String
    , summary : String
    , published : Time.Posix
    , categories : List Category
    }
    -> String
generateEntry c =
    """
  <entry>
    <id>{url}</id>
    <published>{published}</published>
    <updated>{updated}</updated>
    <link href="{url}" />
    <title><![CDATA[{title}]]></title>
    <summary><![CDATA[{summary}]]></summary>
    {categories}
  </entry>
    """
        |> String.replace "{title}" c.title
        |> String.replace "{url}" c.url
        |> String.replace "{published}" (posixToRfc3339 c.published)
        |> String.replace "{updated}" (posixToRfc3339 c.published)
        |> String.replace "{summary}" c.summary
        |> String.replace "{categories}"
            (List.map generateCategory c.categories
                |> String.join " "
            )


generateCategory : Category -> String
generateCategory category =
    """<category term="{slug}" label="{name}" />"""
        |> String.replace "{slug}" (Category.getSlug category)
        |> String.replace "{name}" (Category.getName category)


posixToRfc3339 : Time.Posix -> String
posixToRfc3339 dateTime =
    Rfc3339.DateTimeOffset
        { instant = dateTime
        , offset = { hour = 0, minute = 0 }
        }
        |> Rfc3339.toString


{-| Adds a `/` to the end of a URL if it ends in the domain, and has no path.
-}
ensureUrlIsCanonical : String -> String
ensureUrlIsCanonical url =
    let
        isUrlWithoutPath =
            Regex.fromString "^[^:]+://[^/]+$"
                |> Maybe.map (\re -> Regex.contains re url)
                |> Maybe.withDefault False
    in
    if isUrlWithoutPath then
        url ++ "/"

    else
        url
