module Route.Tag exposing (ActionData, Data, Model, Msg, route)

import AppUrl exposing (AppUrl, QueryParameters)
import BackendTask exposing (BackendTask)
import Custom.Bool exposing (ifElse)
import Custom.List as List
import Data.Post exposing (PostGist)
import Data.PostList
import Data.Tag as Tag exposing (Tag)
import Dict exposing (Dict)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Html exposing (Html)
import Html.Attributes exposing (class, href)
import Html.Attributes.Extra exposing (attributeIf)
import Html.Events exposing (onClick)
import Html.Extra exposing (viewIf)
import Icon
import List.Extra as List
import PagesMsg exposing (PagesMsg)
import Ports
import Result.Extra as Result
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Site
import Url
import UrlPath exposing (UrlPath)
import View exposing (View)
import View.Card
import View.ColumnsLayout
import View.LanguageToggle
import View.PageBody exposing (PageBody)
import View.Snippets


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildWithSharedState
            { init = init
            , update = update
            , subscriptions = subscriptions
            , view = view
            }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init app shared =
    let
        query : Dict String (List String)
        query =
            app.url
                |> Maybe.map .query
                |> Maybe.withDefault Dict.empty
    in
    ( { queryTags = getTagsFromQueryParams query
      , showAllRelatedTags = False
      }
    , Effect.none
    )



-- DATA


type alias Data =
    {}


type alias ActionData =
    {}


data : BackendTask FatalError Data
data =
    BackendTask.succeed {}



-- UPDATE


type alias Model =
    { queryTags : List Tag
    , showAllRelatedTags : Bool
    }


type Msg
    = OnClick String
    | QueryParamsChanged QueryParameters
    | ShowAllRelatedTagsStatusChanged Bool
    | SharedMsg Shared.Msg
    | NoOp


type alias RouteParams =
    {}


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg, Maybe Shared.Msg )
update app shared msg model =
    case msg of
        OnClick urlString ->
            let
                urlMaybe : Maybe AppUrl
                urlMaybe =
                    -- Plain paths don't get parsed, so we need to add something on the front.
                    Url.fromString ("http://x.x" ++ urlString)
                        |> Maybe.map AppUrl.fromUrl
            in
            case urlMaybe of
                Just url ->
                    ( { model | queryTags = getTagsFromQueryParams url.queryParameters }
                    , Effect.none
                    , Nothing
                    )

                Nothing ->
                    ( model, Effect.none, Nothing )

        QueryParamsChanged queryParams ->
            ( { model | queryTags = getTagsFromQueryParams queryParams }
            , Effect.none
            , Nothing
            )

        ShowAllRelatedTagsStatusChanged newStatus ->
            ( { model | showAllRelatedTags = newStatus }
            , Effect.none
            , Nothing
            )

        SharedMsg sharedMsg ->
            ( model, Effect.none, Just sharedMsg )

        NoOp ->
            ( model, Effect.none, Nothing )


getTagsFromQueryParams : Dict String (List String) -> List Tag
getTagsFromQueryParams queryParams =
    queryParams
        |> Dict.get "t"
        |> Maybe.withDefault []
        |> List.map Tag.fromSlug
        |> List.filter Result.isOk
        |> Result.combine
        |> Result.withDefault []



-- SUBSCRIPTIONS


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Ports.listen
        |> Sub.map
            (\msg ->
                case msg of
                    Ports.QueryParamsChanged queryParams ->
                        QueryParamsChanged queryParams

                    _ ->
                        NoOp
            )



-- VIEW


title : String
title =
    Site.windowTitle "Tags"


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    Site.pageMeta title


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app shared model =
    let
        postsShown : List PostGist
        postsShown =
            app.sharedData.posts
                |> List.filter (shouldShowPost model.queryTags)

        showPosts : Bool
        showPosts =
            List.length model.queryTags > 0

        subtitle : Html Msg
        subtitle =
            Html.p []
                View.Snippets.backToIndex

        content : Html Msg
        content =
            if showPosts then
                View.ColumnsLayout.view2
                    { main =
                        Data.PostList.viewGists shared.languages
                            (postsShown |> List.map (\p -> { gist = p, summary = Nothing }))
                    , side = sideColumn
                    }

            else
                sideColumn

        sideColumn : Html Msg
        sideColumn =
            Html.aside
                [ class "flex flex-col gap-2"
                , attributeIf showPosts (class "md:order-last md:flex-col")
                ]
                [ View.LanguageToggle.viewCard
                    { onSelectionChange = \languages -> SharedMsg (Shared.ChangedLanguages languages)
                    , selectedLanguages = shared.languages
                    }
                , viewTagsCard
                    { tags = model.queryTags
                    , postsShown = postsShown
                    , allPosts = app.sharedData.posts
                    , showAllTags = model.showAllRelatedTags
                    , showingPosts = showPosts
                    }
                ]

        withRssFeedLinkMaybe : PageBody Msg -> PageBody Msg
        withRssFeedLinkMaybe pageBody =
            case feedUrls model.queryTags of
                Just { rssUrl, atomUrl } ->
                    pageBody
                        |> View.PageBody.withFeeds
                            (View.PageBody.FeedUrls
                                { rssFeedUrl = rssUrl
                                , atomFeedUrl = atomUrl
                                }
                            )

                Nothing ->
                    pageBody
                        |> View.PageBody.withFeeds
                            (View.PageBody.NoFeedsWithExplanation
                                "Syndication feeds are available for single tags only. You currently have multiple tags selected."
                            )
    in
    { title = title
    , body =
        View.PageBody.fromContent
            { theme = shared.theme
            , onRequestedChangeTheme = SharedMsg Shared.SelectedChangeTheme
            }
            content
            |> View.PageBody.withTitleAndSubtitle (viewTitle model) subtitle
            |> withRssFeedLinkMaybe
            |> View.PageBody.view
    }


viewTitle : { a | queryTags : List Tag } -> List (Html Msg)
viewTitle model =
    if List.length model.queryTags > 0 then
        [ Html.text "Tags: "
        , Html.i []
            (model.queryTags
                |> List.map (viewTitleTag model)
                |> List.intersperse (Html.text ", ")
            )
        ]

    else
        [ Html.text "Tags" ]


viewTitleTag : { a | queryTags : List Tag } -> Tag -> Html Msg
viewTitleTag { queryTags } tag =
    let
        url =
            case List.remove tag queryTags of
                otherTag1 :: otherTagsRest ->
                    Tag.toUrl otherTag1 otherTagsRest

                [] ->
                    Tag.baseUrl
    in
    Html.span [ class "relative" ]
        [ Html.a
            [ href url
            , Html.Events.onClick (OnClick url)
            , class "hover:decoration-layout-90 peer hover:line-through"
            ]
            [ Html.text (Tag.getName tag) ]
        , Html.div
            [ class "text-layout-50 pointer-events-none absolute top-2 inline-block"
            , class "peer-hover:text-primary-50"
            ]
            [ Icon.xMark Icon.Medium ]
        ]


viewTagsCard :
    { tags : List Tag
    , showAllTags : Bool
    , postsShown : List PostGist
    , allPosts : List PostGist
    , showingPosts : Bool
    }
    -> Html Msg
viewTagsCard { tags, showAllTags, postsShown, allPosts, showingPosts } =
    let
        subTags : List Tag
        subTags =
            postsShown
                |> List.andThen .tags
                |> List.unique
                |> List.filter (List.memberOf tags >> not)

        relatedTagEls : List (Html Msg)
        relatedTagEls =
            Tag.listView
                { onClick = Just OnClick
                , selectedTags = tags
                , posts = allPosts
                }
                subTags

        tagViews =
            relatedTagEls
                |> List.indexedMap
                    (\index el ->
                        Html.li
                            [ class "max-w-full"
                            , attributeIf (index >= 15 && not showAllTags && showingPosts)
                                (class "hidden md:block")
                            ]
                            [ el ]
                    )

        showHideTagsButton =
            viewIf showingPosts
                (Html.button
                    [ onClick (ShowAllRelatedTagsStatusChanged (not showAllTags))
                    , class "button bg-layout-20 gap-1 px-1 py-0.5 text-xs"
                    , attributeIf showingPosts (class "md:hidden")
                    ]
                    (if showAllTags then
                        [ Icon.foldLeft Icon.Small
                        , Html.text "Hide tags"
                        ]

                     else
                        [ Icon.foldRight Icon.Small
                        , Html.text "More tags"
                        ]
                    )
                )
    in
    View.Card.view
        { title = Just (Html.text "More tags")
        , class = ifElse showingPosts (Just "md:flex-col") Nothing
        , content =
            Html.ul
                [ class "flex flex-row flex-wrap content-start gap-x-2 text-sm leading-relaxed"
                , attributeIf showingPosts (class "md:order-last md:flex-col")
                ]
                (List.concat [ tagViews, [ showHideTagsButton ] ])
        }


feedUrls : List Tag -> Maybe { rssUrl : String, atomUrl : String }
feedUrls tags =
    case tags of
        [ tag ] ->
            Just
                { rssUrl = feedUrl "rss" tag
                , atomUrl = feedUrl "atom" tag
                }

        _ ->
            Nothing


feedUrl : String -> Tag -> String
feedUrl feedName tag =
    "/tag/{tagSlug}/{feedName}.xml"
        |> String.replace "{feedName}" feedName
        |> String.replace "{tagSlug}" (Tag.getSlug tag)


shouldShowPost : List Tag -> PostGist -> Bool
shouldShowPost queryTags post =
    queryTags |> List.all (List.memberOf post.tags)
