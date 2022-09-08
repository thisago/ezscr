from std/os import commandLineParams
import pkg/nimscripter
import pkg/nimscripter/vmops

const script = """
proc main*(params: seq[string]): bool =
  echo params
  echo getCurrentDir()
  echo "done"
  true
"""
addVmops(buildpackModule)
addCallable(buildpackModule):
  proc main(params: seq[string]): bool
const addins = implNimscriptModule(buildpackModule)
let intr = loadScript(NimScriptFile(script), addins)

intr.invoke(main, commandLineParams()) # Calls `fancyStuff(10)` in vm
