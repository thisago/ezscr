from std/os import commandLineParams, existsOrCreateDir, `/`, getAppDir
from std/strformat import fmt
import pkg/nimscripter
import pkg/nimscripter/vmops

addVmops(buildpackModule)
addCallable(buildpackModule):
  proc main(params: seq[string]): bool
const addins = implNimscriptModule(buildpackModule)

proc run(script: string; params: seq[string]) =
  loadScript(NimScriptFile(script), addins).
    invoke(main, params)

const
  configDir {.strdefine.} = "config"
  hiddenConfigDir {.strdefine.} = "hidden"
  configFile {.strdefine.} = "config.yaml"
  exampleScript = """
proc main(params: seq[string]): bool =
  ## The EzScr will run this automatically
  result = true
  echo "Hello World!"
"""
  exampleConfig = """# Example config
"""

proc new(names: seq[string]; hidden = false) =
  ## Creates a new script files
  let appDir = getAppDir()
  block setupStructure:
    var currFs = appDir / configDir
    if not existsOrCreateDir currFs:
      echo fmt"Creating {currFs}"
      
      currFs = appDir / configDir / configFile
      writeFile(currFs, exampleConfig)
      echo fmt"Creating {currFs}"

      currFs = appDir / configDir / hiddenConfigDir
      if not existsOrCreateDir currFs:
        echo fmt"Creating {currFs}"

  for name in names:
    var dir = appDir / configDir
    if hidden: dir = dir / hiddenConfigDir
    writeFile(dir / fmt"{name}.nims", exampleScript)

when isMainModule:
  import pkg/cligen
  dispatchMulti([
    ezscr.new
  ])
