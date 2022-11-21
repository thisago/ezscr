from std/strutils import split, strip
from std/strformat import fmt
from std/os import getCurrentDir, extractFilename, `/`

from pkg/util/forStr import between

from ezscr/vmProcs import downloadTo

proc parseStaticDownload*(script: string): seq[string] =
  ## Parses the script by removing, downloading and extracting the needed files
  ## for remote import
  ##
  ## It just downloads the specified file, so if you need to download more files
  ## before script interpretation, specify one by one
  ## 
  ## The call needs to be inside a comment, and it's not Nim code, is just a
  ## replacing algorithm
  ## 
  ## Returns the path of downloaded files
  ## 
  ## Example:
  ## .. code-block::
  ##   # Note the mandatory space after `>`
  ##   #> staticDownload "https://git.ozzuu.com/thisago/util/raw/branch/master/src/util/forStr.nim"
  ##   import forStr
  ##
  ##   proc main*(params: seq[string]): bool =
  ##     echo "Hello John Doe!".between("llo ", " Do") # -> John
  const callSyntax = "#> staticDownload"
  for l in script.split "\n":
    let line = strip l
    if line.len > callSyntax.len and line[0..<callSyntax.len] == callSyntax:
        let
          url = line.between("\"", "\"")
          destination = getCurrentDir() / url.extractFilename
          error = url.downloadTo destination
        if error.len == 0:
          result.add destination
        else:
          raise newException(IOError, fmt"Download error: '{error}' when downloading file: '{url}'")
          
