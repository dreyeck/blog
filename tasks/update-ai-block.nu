# Updates robots.txt and .htaccess with fresh data from the ai.robots.txt
# project, to block AI crawlers.

let aiRobotsTxtBaseUrl = "https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/refs/heads/main"
let startMarkerLine = "# Start ai.robots.txt"
let endMarkerLine = "# End ai.robots.txt"

def splitLines [] {
  split row "\n"
}

def updateFile [$filename] {
  let localLines = open $"./public/($filename)" | splitLines
  let updateLines = http get $"($aiRobotsTxtBaseUrl)/($filename)" | splitLines

  let firstSplit = $localLines | split list $startMarkerLine
  let linesBeforeUpdate = $firstSplit | get 0
  let secondSplit = $firstSplit | get 1 | split list $endMarkerLine
  let linesAfterUpdate = $secondSplit | get 1

  let updatedLines = (
    $linesBeforeUpdate
    ++ [$startMarkerLine]
    ++ $updateLines
    ++ [$endMarkerLine]
    ++ $linesAfterUpdate
  )

  $updatedLines | str join "\n" | save --force $"./public/($filename)"
}

updateFile ".htaccess"
updateFile "robots.txt"
