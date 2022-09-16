## Add docs for this procs
from std/httpclient import newHttpClient, close, get, body, code, newHttpHeaders,
                            post, downloadFile, HttpRequestError
from std/os import getAppDir

from ezscr/strenc import nil

proc writeToFile(file, content: string) =
  writeFile(file, content)

proc httpGet(
  url: string;
  headers = newSeq[(string, string)]()
): tuple[code: int; body: string] =
  let
    client = newHttpClient(headers = newHttpHeaders headers)
    res = client.get url
  close client
  result.code = int res.code
  result.body = res.body

proc httpPost(
  url, body: string;
  headers = newSeq[(string, string)]()
): tuple[code: int; body: string] =
  let
    client = newHttpClient(headers = newHttpHeaders headers)
    res = client.post(url, body)
  close client
  result.code = int res.code
  result.body = res.body

proc thisDir: string =
  getAppDir()

proc encrypt(str: string): string =
  ## Encrypts the string by using the strenc algorithms
  strenc.encrypt str

proc decrypt(str: string): string =
  ## Decrypts the string by using the strenc algorithms
  strenc.decrypt str

proc downloadTo*(url, destination: string): string =
  ## Downloads the file to the destination and returns the error message
  result = ""
  let client = newHttpClient()
  try:
    client.downloadFile(url, destination)
  except HttpRequestError:
    result = getCurrentExceptionMsg()
  close client


template addVmProcs*(module: untyped) =
  exportTo(module,
    readFile,
    writeToFile,
    httpGet,
    thisDir,
    httpPost,
    encrypt,
    decrypt,
    downloadTo
  )
