# Removes diacritics from some text.
export def remove-diacritics [text: string] : any -> string {
  let diacritics_map = {
    "á": "a",
    "é": "e",
    "í": "i",
    "ó": "o",
    "ú": "u",
    "ü": "u",
  }
  $text
  | split chars
  | each {|char| $diacritics_map | get --optional $char | default $char }
  | str join ''
}

# Places a value in between every value in a list.
export def intersperse [toIntersperse : any] : list<any> -> list<any> {
  let list = $in
  if ($list | length) > 1 {
    [$list.0, $toIntersperse, ...($list | skip 1 | intersperse $toIntersperse)]
  } else {
    $list
  }
}

# Converts a datetime into the format used in posts.
export def formatPostDate []: datetime -> string {
  format date '%Y-%m-%d %H:%M:00'
}

# Converst a record to YAML, fixing the date conversion bug.
export def toYaml []: record -> string {
  to yaml
  | split row "\n"
  | str replace --regex '^date: (.+)$' 'date: "$1"'
  | str join "\n"
}
