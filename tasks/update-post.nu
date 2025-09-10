use shared.nu *

# Constants.
let hiddenFlag = "-HIDDEN"

# Source data.
let sourceFilename = ls --all data/posts/**/*.md | sort-by --reverse modified | get 0.name
let postData = $sourceFilename | open
let postLines = $postData | split row "\n" | split list "---"
let frontmatter = $postLines | get 1 | str join "\n" | from yaml
let isHidden = $sourceFilename | str ends-with $"($hiddenFlag).md"

# Update the post's slug and path.
let date = date now | date to-timezone 'UTC'
let year = $date | format date '%Y'
let month = $date | format date '%m'
let titleSlug = $frontmatter.title | str trim | str downcase | str kebab-case | remove-diacritics $in
let hiddenFlagIfNecessary = if $isHidden { $hiddenFlag } else { "" }
let updatedFilename = $"data/posts/($year)/($month)-($titleSlug)($hiddenFlagIfNecessary).md"

# Update the date in the frontmatter.
let updatedDate = $date | formatPostDate
let updatedFrontmatter = $frontmatter | update date $updatedDate
let updatedFrontmatterLines = $updatedFrontmatter | toYaml

let updatedPostLines = [
    $postLines.0,
    $updatedFrontmatterLines,
    ...($postLines | skip 2)
  ] | intersperse ["---"] | flatten

# Save the updated post data in its new path.
$updatedPostLines | str join "\n" | save --force $updatedFilename

# Delete the old file.
if ($sourceFilename != $updatedFilename) {
  rm $sourceFilename
}

# Format the new file.
prettier --write $updatedFilename

