#> staticDownload "https://raw.githubusercontent.com/thisago/htmlAntiCopy/master/src/htmlAntiCopy.nim"
import htmlAntiCopy
from std/strformat import fmt
from std/os import nil

proc main*(params: seq[string]): bool =
  ## This example will import a remote nim file
  ##
  ## Run with: ezscr run remoteModule out.html
  result = true
  if params.len < 1:
    echo "Please provide the output html file"
    return false
  let
    file = params[0]
    message = "This is a copyrighted content, please do not copy."
    obfuscated = toHtml shuffle message

  writeToFile(file, obfuscated)

  echo "Opening in browser"
  var browsers = @["firefox", "chrome", "chromium"]
  while browsers.len > 0:
    if gorgeEx(fmt"{browsers[0]} {file}").exitCode == 0:
      break
    browsers.delete 0
      
  if browsers.len == 0:
    echo "Cannot find any browser"
    return false
