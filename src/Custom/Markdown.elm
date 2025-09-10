module Custom.Markdown exposing (getSummary)

import Doc.FromMarkdown
import Doc.ToPlainText


{-| Generates a plain-text summary of the passed Markdown content, by taking
only the first bit and elliding the rest.
-}
getSummary : String -> String
getSummary markdown =
    markdown
        |> Doc.FromMarkdown.parse { audioPlayer = Nothing }
        |> Doc.ToPlainText.view
        |> String.lines
        |> List.filter ((/=) "")
        |> String.join " ¶ "
        |> String.words
        |> List.take 30
        |> String.join " "
        |> String.left 200
        |> (\s -> s ++ "…")
