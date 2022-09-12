from std/json import parseJson, pretty
from std/os import `/`

proc main*(params: seq[string]): bool =
  ## This script reads all encoded scripts
  result = true
  let node = parseJson decrypt readFile getCurrentDir() / "data.enc"
  echo pretty node
