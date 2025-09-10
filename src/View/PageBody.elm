module View.PageBody exposing
    ( Feeds(..)
    , PageBody
    , fromContent
    , view
    , withFeeds
    , withFooter
    , withTitle
    , withTitleAndSubtitle
    , withoutAboutLink
    )

import Custom.Html
import Custom.Html.Attributes exposing (ariaDescribedBy, roleTooltip, tabIndex)
import Html exposing (Html)
import Html.Attributes exposing (class, href, id)
import Html.Events
import Html.Extra
import Icon
import PagesMsg exposing (PagesMsg)
import Theme exposing (Theme)


type PageBody msg
    = PageBody
        { content : Html msg
        , title : PageTitle msg
        , footer : Maybe (Html msg)
        , theme : Theme
        , feeds : Feeds msg
        , showAboutLink : Bool
        , onRequestedChangeTheme : msg
        }


type PageTitle msg
    = NoPageTitle
    | PageTitleOnly (List (Html msg))
    | PageTitleAndSubtitle (List (Html msg)) (Html msg)


type Feeds msg
    = FeedUrls { rssFeedUrl : String, atomFeedUrl : String }
    | NoFeedsWithExplanation String
    | NoFeeds


fromContent :
    { theme : Theme
    , onRequestedChangeTheme : msg
    }
    -> Html msg
    -> PageBody msg
fromContent config content =
    PageBody
        { content = content
        , title = NoPageTitle
        , footer = Nothing
        , theme = config.theme
        , onRequestedChangeTheme = config.onRequestedChangeTheme
        , feeds = NoFeeds
        , showAboutLink = True
        }


withTitle : List (Html msg) -> PageBody msg -> PageBody msg
withTitle titleInlines (PageBody config) =
    PageBody { config | title = PageTitleOnly titleInlines }


withTitleAndSubtitle : List (Html msg) -> Html msg -> PageBody msg -> PageBody msg
withTitleAndSubtitle titleInlines subtitleBlock (PageBody config) =
    PageBody { config | title = PageTitleAndSubtitle titleInlines subtitleBlock }


withFooter : Html msg -> PageBody msg -> PageBody msg
withFooter footer (PageBody config) =
    PageBody { config | footer = Just footer }


withFeeds : Feeds msg -> PageBody msg -> PageBody msg
withFeeds feeds (PageBody config) =
    PageBody { config | feeds = feeds }


withoutAboutLink : PageBody msg -> PageBody msg
withoutAboutLink (PageBody config) =
    PageBody { config | showAboutLink = False }


view : PageBody msg -> Html (PagesMsg msg)
view (PageBody config) =
    let
        pageMaxWidth =
            "max-w-[40rem]"

        titleEl : List (Html msg) -> Html msg
        titleEl text =
            Html.h1 [ class "text-layout-90 w-full text-4xl font-light leading-[1.1]" ]
                text

        title : Maybe (Html msg)
        title =
            case config.title of
                NoPageTitle ->
                    Nothing

                PageTitleOnly title_ ->
                    titleEl title_
                        |> Just

                PageTitleAndSubtitle title_ subtitle ->
                    Html.div [ class "flex flex-col gap-3" ]
                        [ titleEl title_
                        , Html.div [ class "text-sm" ]
                            [ subtitle ]
                        ]
                        |> Just

        aboutLink : Html msg
        aboutLink =
            if config.showAboutLink then
                Html.a [ href "/about" ]
                    [ Html.text "About" ]

            else
                Custom.Html.none

        header : Html msg
        header =
            case title of
                Just title_ ->
                    Html.div [ class "w-full p-2 pb-0" ]
                        [ Html.header [ class "text-layout-50 bg-layout-20 flex w-full flex-col items-center rounded-lg" ]
                            [ Html.div [ class "flex w-full flex-row items-center justify-end gap-4 px-4 pt-2 text-sm", class pageMaxWidth ]
                                [ aboutLink
                                , viewFeedLinks config.feeds
                                , changeThemeButtonView config
                                ]
                            , Html.div [ class "w-full flex-grow px-4 pb-2", class pageMaxWidth ]
                                [ title_ ]
                            ]
                        ]

                Nothing ->
                    Html.Extra.nothing

        content : Html msg
        content =
            Html.main_ [ class "w-full px-6 pt-10 sm:pt-16", class pageMaxWidth ]
                [ config.content ]

        footer : Html msg
        footer =
            case config.footer of
                Just footerEl ->
                    Html.div [ class "w-full px-6 pt-20", class pageMaxWidth ]
                        [ Html.hr [ class "bg-layout-20 mb-8 h-4 w-full border-0" ] []
                        , Html.footer [ class "w-full" ]
                            [ footerEl ]
                        ]

                Nothing ->
                    Html.Extra.nothing
    in
    Html.div [ class "text-layout-90 flex w-full flex-col items-center pb-32" ]
        [ header
        , content
        , footer
        ]
        |> Html.map PagesMsg.fromMsg


viewFeedLinks : Feeds msg -> Html msg
viewFeedLinks feed =
    case feed of
        FeedUrls { rssFeedUrl, atomFeedUrl } ->
            let
                feedsListId =
                    "feeds-list"
            in
            Html.div []
                [ Html.button
                    [ class "button gap-1 px-1 py-0.5"
                    , Custom.Html.Attributes.popoverTarget feedsListId
                    ]
                    [ Icon.rss Icon.Medium
                    , Html.text "Feeds"
                    ]
                , Html.node "custom-dropdown"
                    [ Html.Attributes.id feedsListId
                    , Custom.Html.Attributes.popoverAuto
                    , class "card"
                    ]
                    [ Html.ul [ class "flex flex-col gap-2" ]
                        [ Html.li []
                            [ Html.a [ href atomFeedUrl ]
                                [ Html.text "Atom feed" ]
                            ]
                        , Html.li []
                            [ Html.a [ href rssFeedUrl ]
                                [ Html.text "RSS feed" ]
                            ]
                        ]
                    ]
                ]

        NoFeedsWithExplanation explanation ->
            let
                tooltipId =
                    "no-rss-feed-explanation"
            in
            Html.div
                [ class "group relative flex flex-col items-end"
                , tabIndex 0
                ]
                [ Html.div
                    [ ariaDescribedBy [ tooltipId ]
                    , class "decoration-primary-20 flex cursor-help flex-row items-center gap-1 underline decoration-dotted decoration-2 underline-offset-4"
                    ]
                    [ Html.text "No feeds" ]
                , Html.div
                    [ roleTooltip
                    , id tooltipId
                    , class "card text-layout-50 w-max max-w-60 text-xs leading-normal"
                    , class "popup pointer-events-none absolute top-8 z-10"
                    ]
                    [ Html.text explanation ]
                ]

        NoFeeds ->
            Custom.Html.none


changeThemeButtonView :
    { a
        | theme : Theme
        , onRequestedChangeTheme : msg
    }
    -> Html msg
changeThemeButtonView config =
    let
        nextTheme =
            Theme.change config.theme
    in
    Html.button
        [ class "button size-6"
        , Html.Events.onClick config.onRequestedChangeTheme
        ]
        [ (case ( nextTheme.set, nextTheme.default ) of
            ( Just Theme.Dark, _ ) ->
                Icon.moon

            ( Just Theme.Light, _ ) ->
                Icon.sun

            ( Nothing, _ ) ->
                Icon.minus
          )
            Icon.Small
        ]
