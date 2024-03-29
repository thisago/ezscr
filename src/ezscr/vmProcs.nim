## Add docs for this procs
from std/httpclient import newHttpClient, close, get, body, code, newHttpHeaders,
                            post, downloadFile, HttpRequestError,
                            newMultipartData, `[]=`
from std/os import getAppDir, removeFile, removeDir, createDir, putEnv,
  existsEnv, delEnv
from std/strutils import join
import std/osproc except execProcess
from std/sha1 import secureHashFile, secureHash, `$`
import std/strtabs

from ezscr/strenc import nil

# from pkg/util/forOs import getEnv
from std/os import getEnv

proc writeToFile(file, content: string) =
  writeFile(file, content)

proc httpGet(
  url: string;
  headers = newSeq[(string, string)]();
  timeout = -1
): tuple[code: int; body: string] =
  let
    client = newHttpClient(timeout = timeout, headers = newHttpHeaders headers)
    res = client.get url
  close client
  result.code = int res.code
  result.body = res.body

proc httpPost(
  url, body: string;
  headers = newSeq[(string, string)]();
  timeout = -1
): tuple[code: int; body: string] =
  let
    client = newHttpClient(timeout = timeout, headers = newHttpHeaders headers)
    res = client.post(url, body)
  close client
  result.code = int res.code
  result.body = res.body

type PostFile = tuple
  inputName, filename, mimeType, content: string

proc httpPostFiles(
  url: string;
  files: seq[PostFile];
  headers = newSeq[(string, string)]()
): tuple[code: int; body: string] =
  ## To send POST paremeters, just fill a `PostFile` without `filename` and `mimeType`
  var data = newMultipartData()
  for (inputName, filename, mimeType, content) in files:
    data[inputName] = (filename, mimeType, content)
  let
    client = newHttpClient(headers = newHttpHeaders headers)
    res = client.post(url, multipart = data)
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

proc execProc(
  command: string;
  workingDir = "";
  args = newSeq[string]();
  env: seq[(string, string)] = newSeq[(string, string)]();
  options: set[ProcessOption] = {poStdErrToStdOut, poUsePath, poEvalCommand};
  wait = false
): (string, int) =
  let envTable = if env.len == 0: nil else: newStringTable env
  var process = startProcess(
    command,
    workingDir = workingDir,
    args = args,
    env = envTable,
    options = options
  )
  if wait or poDaemon notin options:
    let res = process.readLines
    result = (res[0].join "\l", res[1])
    close process
  else:
    result = ("**Ran as daemon**", 0)

proc execDaemonProc(
  command: string;
  workingDir = "";
  env: seq[(string, string)] = newSeq[(string, string)]();
  wait = false
): (string, int) =
  result = execProc(
    command,
    workingDir,
    @[],
    env,
    {poStdErrToStdOut, poUsePath, poEvalCommand, poDaemon},
    wait
  )

proc sha1(s: string): string =
  $secureHash s
proc sha1File(file: string): string =
  $secureHashFile file

template addVmProcs*(module: untyped) =
  exportTo(module,
    readFile,
    writeToFile,
    httpGet,
    thisDir,
    httpPost,
    encrypt,
    decrypt,
    downloadTo,
    httpPostFiles,
    PostFile,
    removeFile,
    removeDir,
    createDir,
    getEnv,
    putEnv,
    existsEnv,
    delEnv,
    execProc,
    execDaemonProc,
    ProcessOption,
    sha1File,
    sha1
  )
