import std/macros
import pkg/fusion/matching
from compiler/nimeval import findNimStdLibCompileTime
from std/os import walkDirRec, pcFile, extractFilename
from std/sequtils import toSeq
include std/tables

{.experimental: "caseStmtMacros".}
const stdLibPaths = toSeq(walkDirRec(findNimStdLibCompileTime(), {pcFile}))
macro listMethods(modules: static openArray[string]): untyped =
  var procs: Table[string, seq[string]]
  var i = 0
  for moduleName in modules:
    for path in walkDirRec(findNimStdLibCompileTime(), {pcFile}):
      if moduleName & ".nim" == extractFilename path:
        procs[moduleName] = newSeq[string]()
        let module = parseStmt(staticRead(path))
        for stmt in module:
          case stmt
            of (kind: in {nnkFuncDef,nnkProcDef..nnkIteratorDef}):#any kind of methody thing
              case stmt
              of [
                PostFix[_, @name],#only exported procs
                _,
                _,
                FormalParams[
                  _, #return type
                  .._], #other params
                .._]: procs[moduleName].add($name)
  result = newLit(procs)
 

const modules = [
  "os", "strutils", "json"
]
# const modules = [
#   "macros", "os", "strutils", "math", "distros", "sugar", "algorithm", "base64",
#   "bitops", "chains", "colors", "complex", "htmlgen", "httpcore", "lenientops",
#   "mersenne", "options", "parseutils", "punycode", "random", "stats",
#   "strformat", "strmisc", "strscans", "unicode", "uri", "parsecsv", "parsecfg",
#   "parsesql", "xmlparser", "htmlparser", "ropes", "json", "parsejson",
#   "strtabs", "unidecode"
# ]


macro importAll(modules: static openArray[string]): untyped =
  result = newNimNode(nnkStmtList)
  for module in modules:
    # result.add(newNimNode(nnkImportStmt).add(ident(module)))
    result.add quote do:
      import `module`
      export `module`

expandMacros:
  importAll modules

macro addVmStdi*(module: untyped): untyped =
  result = newNimNode(nnkStmtList)
  for (stdModule, procs) in listMethods(modules).pairs:
    for name in procs:
      let a = ident name
      result.add quote do:
        exportTo(module, `a`)

template addVmStd*(a: untyped) =
  addVmStdi(a)
