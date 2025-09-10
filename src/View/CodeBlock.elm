module View.CodeBlock exposing
    ( CodeBlock
    , fromBody
    , view
    )

import Html exposing (Html)
import SyntaxHighlight


type CodeBlock
    = CodeBlock
        { body : String
        , language : Maybe String
        }


fromBody : Maybe String -> String -> CodeBlock
fromBody language body =
    CodeBlock { body = body, language = language }


view : CodeBlock -> Html msg
view (CodeBlock { body, language }) =
    let
        highlighter =
            case language of
                Just "elm" ->
                    SyntaxHighlight.elm

                Just "js" ->
                    SyntaxHighlight.javascript

                Just "ts" ->
                    SyntaxHighlight.javascript

                Just "json" ->
                    SyntaxHighlight.json

                Just "html" ->
                    SyntaxHighlight.xml

                Just "xml" ->
                    SyntaxHighlight.xml

                Just "css" ->
                    SyntaxHighlight.css

                Just "py" ->
                    SyntaxHighlight.python

                Just "sql" ->
                    SyntaxHighlight.sql

                Just "nix" ->
                    SyntaxHighlight.nix

                Just "kotlin" ->
                    SyntaxHighlight.kotlin

                Just "go" ->
                    SyntaxHighlight.go

                _ ->
                    SyntaxHighlight.noLang
    in
    highlighter body
        |> Result.map (SyntaxHighlight.toBlockHtml (Just 1))
        |> Result.withDefault
            (Html.div []
                [ Html.text "[COULDN'T PARSE CODE BLOCK]" ]
            )
