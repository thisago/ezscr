import std/macros
import pkg/fusion/matching

{.experimental: "caseStmtMacros".}
macro listMethods(modulepath: string, typename): untyped =
  let module = parseStmt(staticRead(modulepath))
  var procs: seq[string]
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
            IdentDefs[ #first parameter
          _, #paramname
          (typename |        #Foo
          VarTy[typename] |  #var Foo
          PtrTy[typename] |  #ptr Foo
          RefTy[typename]),  #ref Foo
          _],
            .._], #other params
          .._]: procs.add($name)
  result = newLit(procs)
 

const modules = [
  "json",
  "strutils"
]

macro importAll(modules: static openArray[string]): untyped =
  result = newNimNode(nnkImportStmt)
  for module in modules:
    result.add(ident(module))
expandMacros:
  importAll modules

template addVmstd*(module: untyped) =
  for m in modules:
    let exports = m.listMethods(any)
    echo exports
    # exportTo(module,

    # )
addVmstd(test)
