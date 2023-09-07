module Wiki exposing (Event(..), Page, Story(..), pageDecoder, pageEncoder, renderStory)

import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode


type alias Page =
    { title : String
    , story : List Story
    , journal : List Event
    }


pageDecoder : Decode.Decoder Page
pageDecoder =
    Decode.map3 Page
        (Decode.field "title" Decode.string)
        (Decode.field "story" (Decode.list storyDecoder))
        (Decode.field "journal" (Decode.list eventDecoder))


pageEncoder : Page -> Encode.Value
pageEncoder page =
    Encode.object
        [ ( "title", Encode.string page.title )
        , ( "story", Encode.list storyEncoder page.story )
        , ( "journal", Encode.list journalEncoder page.journal )
        ]



-- The "story" is a collection of paragraphs and paragraph-like items.


type Story
    = Future FutureItemAlias
    | Factory FactoryItemAlias
    | Paragraph ParagraphItemAlias
    | EmptyStory


renderStory : Story -> Html msg
renderStory story =
    case story of
        Paragraph paragraph ->
            case paragraph.type_ of
                "paragraph" ->
                    Html.p [] [ Html.text paragraph.text ]

                _ ->
                    Html.text "Unknown story type"

        Future future ->
            Html.div [] [ Html.text "Future: " ]

        Factory factory ->
            Html.div [] [ Html.text "Factory: " ]

        EmptyStory ->
            Html.text "Empty Story"


storyDecoder : Decode.Decoder Story
storyDecoder =
    Decode.oneOf
        [ Decode.map Future futureEventDecoder
        , Decode.map Paragraph paragraphItemDecoder
        , Decode.map Factory addFactoryItemDecoder
        , Decode.map (\_ -> EmptyStory) (Decode.succeed EmptyStory)
        ]


storyEncoder : Story -> Encode.Value
storyEncoder story =
    case story of
        Future alias ->
            Encode.object
                [ ( "id", Encode.string alias.id )
                , ( "type", Encode.string alias.type_ )
                , ( "text", Encode.string alias.text )
                , ( "title", Encode.string alias.title )
                ]

        Factory alias ->
            Encode.object
                [ ( "type", Encode.string alias.type_ )
                , ( "id", Encode.string alias.id )
                ]

        Paragraph alias ->
            Encode.object
                [ ( "type", Encode.string alias.type_ )
                , ( "id", Encode.string alias.id )
                , ( "text", Encode.string alias.text )
                ]

        -- Add encoders for other story variants as needed
        EmptyStory ->
            Encode.list identity []


type alias StoryItemAlias =
    { title : String
    , story : Story
    }


storyItemDecoder : Decode.Decoder StoryItemAlias
storyItemDecoder =
    Decode.map2 StoryItemAlias
        (Decode.field "title" Decode.string)
        (Decode.field "story" storyDecoder)


storyItemEncoder : StoryItemAlias -> Encode.Value
storyItemEncoder item =
    Encode.object
        [ ( "title", Encode.string item.title )
        , ( "story", storyEncoder item.story )
        ]


type alias ParagraphItemAlias =
    { type_ : String, id : String, text : String }


paragraphItemDecoder : Decode.Decoder ParagraphItemAlias
paragraphItemDecoder =
    Decode.map3 ParagraphItemAlias
        (Decode.field "type" Decode.string)
        (Decode.field "id" Decode.string)
        (Decode.field "text" Decode.string)


paragraphItemEncoder : ParagraphItemAlias -> Encode.Value
paragraphItemEncoder item =
    -- "type": "paragraph"
    Encode.object
        [ ( "type", Encode.string "paragraph" )
        , ( "id", Encode.string item.id )
        , ( "text", Encode.string item.text )
        ]


type alias FactoryItemAlias =
    { type_ : String, id : String }


addFactoryItemDecoder : Decode.Decoder AddFactoryItemAlias
addFactoryItemDecoder =
    Decode.map2 AddFactoryItemAlias
        (Decode.field "type" Decode.string)
        (Decode.field "id" Decode.string)


addFactoryItemEncoder : AddFactoryItemAlias -> Encode.Value
addFactoryItemEncoder item =
    -- "type": "factory"
    Encode.object
        [ ( "type", Encode.string "factory" )
        , ( "id", Encode.string item.id )
        ]


type alias FutureItemAlias =
    { id : String, type_ : String, text : String, title : String }


futureEventDecoder : Decode.Decoder FutureItemAlias
futureEventDecoder =
    Decode.map4 FutureItemAlias
        (Decode.field "id" Decode.string)
        (Decode.field "type" Decode.string)
        (Decode.field "text" Decode.string)
        (Decode.field "title" Decode.string)



-- The "journal" collects story edits.


type Event
    = Create CreateEvent
    | AddFactory AddFactoryEvent
    | Edit EditEvent


eventDecoder : Decode.Decoder Event
eventDecoder =
    Decode.oneOf
        [ Decode.map Create createEventDecoder
        , Decode.map Edit editEventDecoder
        , Decode.map AddFactory addFactoryEventDecoder

        -- Add decoders for other journal event variants as needed
        -- remove
        -- move
        -- fork
        ]


type alias CreateEvent =
    -- "type": "create"
    { type_ : String, item : StoryItemAlias, date : Int }


createEventDecoder : Decode.Decoder CreateEvent
createEventDecoder =
    Decode.map3 CreateEvent
        (Decode.field "type" Decode.string)
        (Decode.field "item" storyItemDecoder)
        (Decode.field "date" Decode.int)


type alias AddFactoryItemAlias =
    { type_ : String, id : String }


type alias AddFactoryEvent =
    -- "type": "add"
    { item : AddFactoryItemAlias, id : String, type_ : String, date : Int }


addFactoryEventDecoder : Decode.Decoder AddFactoryEvent
addFactoryEventDecoder =
    Decode.map4 AddFactoryEvent
        (Decode.field "item" addFactoryItemDecoder)
        (Decode.field "id" Decode.string)
        (Decode.field "type" Decode.string)
        (Decode.field "date" Decode.int)


type alias EditEvent =
    -- "type": "edit"
    { type_ : String, id : String, item : ParagraphItemAlias, date : Int }


editEventDecoder : Decode.Decoder EditEvent
editEventDecoder =
    Decode.map4 EditEvent
        (Decode.field "type" Decode.string)
        (Decode.field "id" Decode.string)
        (Decode.field "item" paragraphItemDecoder)
        (Decode.field "date" Decode.int)


journalEncoder : Event -> Encode.Value
journalEncoder event =
    case event of
        Create createEvent ->
            let
                eventItem : StoryItemAlias
                eventItem =
                    createEvent.item
            in
            Encode.object
                [ ( "type", Encode.string "create" )
                , ( "item", storyItemEncoder eventItem )
                , ( "date", Encode.int createEvent.date )
                ]

        AddFactory addFactoryEvent ->
            let
                eventItem : AddFactoryItemAlias
                eventItem =
                    addFactoryEvent.item
            in
            Encode.object
                [ ( "item", addFactoryItemEncoder eventItem )
                , ( "id", Encode.string addFactoryEvent.id )
                , ( "type", Encode.string "add" )
                , ( "date", Encode.int addFactoryEvent.date )
                ]

        Edit editEvent ->
            let
                eventItem : ParagraphItemAlias
                eventItem =
                    editEvent.item
            in
            Encode.object
                [ ( "type", Encode.string "edit" )
                , ( "id", Encode.string editEvent.id )
                , ( "item", paragraphItemEncoder eventItem )
                , ( "date", Encode.int editEvent.date )
                ]



-- Add encoders for other journal event variants as needed
