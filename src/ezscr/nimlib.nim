from compiler/nimeval import findNimStdLibCompileTime
from std/tables import Table, `[]=`
from std/os import `/`, walkDirRec, splitFile

proc getNimLibPath: string =
  try: findNimStdLibCompileTime()
  except: ""

const stdLibPath {.strdefine.} = getNimLibPath()

when stdLibPath == "":
  {.fatal: "Error when getting the lib path, please provide manually passing: -d:stdLibPath=/path/to/nim/lib".}

proc getNimLib: seq[string] {.compileTime.} =
  for f in walkDirRec stdLibPath:
    let file = splitFile f
    if file.ext in [".nim", ".nimble"]:
      result.add f[stdLibPath.len+1..^1]

const modules = getNimLib()

proc readNimLib*: Table[string, string] {.compileTime.} =
  ## Read std lib modules and returns their contents
  for module in modules:
    result[module] = staticRead stdLibPath / module 
