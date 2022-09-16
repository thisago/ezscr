from compiler/nimeval import findNimStdLibCompileTime
from std/tables import Table, `[]=`
from std/os import `/`, walkDir, splitFile, getHomeDir, dirExists, pcFile,
                    pcLinkToDir, pcDir
from std/strutils import multiReplace

proc `//`(a, b: string): string =
  ## Dirty trick to cross compilation for windows in unix work
  when defined posix:
    result = a / b
  else:
    result = multiReplace(a & "/" & b, {
      "\\": "/",
      "//": "/"
    })

proc getNimLibPath: string =
  try:
    result = findNimStdLibCompileTime()
  except:
    result = getHomeDir()
    if result.len > 1:
      result = result // ".choosenim/toolchains/nim-#head/lib"

const stdLibPath {.strdefine.} = getNimLibPath()

when stdLibPath == "":
  {.fatal: "Error when getting the lib path, please provide manually passing: -d:stdLibPath=/path/to/nim/lib".}

when not dirExists stdLibPath:
  {.fatal: "The std lib path doesn't exists: " & stdLibPath.}

iterator walkDirRec(dir: string,
                     yieldFilter = {pcFile}, followFilter = {pcDir},
                     relative = false, checkDir = false): string =
  ## Dirty trick to crosscompilation for windows in unix work
  var stack = @[""]
  var checkDir = checkDir
  while stack.len > 0:
    let d = stack.pop()
    for k, p in walkDir(dir // d, relative = true, checkDir = checkDir):
      let rel = d // p
      if k in {pcDir, pcLinkToDir} and k in followFilter:
        stack.add rel
      if k in yieldFilter:
        yield if relative: rel else: dir // rel
    checkDir = false

proc getNimLib: seq[string] {.compileTime.} =
  for f in walkDirRec stdLibPath:
    let file = splitFile f
    if file.ext in [".nim", ".nimble"]:
      result.add f[stdLibPath.len..^1]

const modules = getNimLib()

proc readNimLib*: Table[string, string] {.compileTime.} =
  ## Read std lib modules and returns their contents
  for module in modules:
    result[module] = staticRead stdLibPath // module 
