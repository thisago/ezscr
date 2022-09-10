## Add docs for this procs

from std/httpclient import newHttpClient, close, get, body, code
from std/os import getAppDir

proc writeToFile(file, content: string) =
  writeFile(file, content)

proc httpGet(url: string): tuple[code: int; body: string] =
  let
    client = newHttpClient()
    res = client.get url
  close client
  result.code = int res.code
  result.body = res.body

proc thisDir: string =
  getAppDir()

template addVmProcs*(module: untyped) =
  exportTo(module,
    readFile,
    writeToFile,
    httpGet,
    thisDir
  )
