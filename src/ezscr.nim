from std/os import commandLineParams, existsOrCreateDir, `/`, getAppDir,
                    walkDirRec, splitFile, fileExists, dirExists
from std/strformat import fmt
from std/strutils import replace, `%`
from std/tables import Table, `[]`, hasKey
from std/json import `$`, `%`, `%*`
from std/streams import newFileStream, close
import std/with
import pkg/nimscripter
import pkg/nimscripter/vmops
import pkg/yaml/serialization

import ezscr/strenc

when defined release:
  const debugging = false
else:
  const debugging = true
  
when debugging:
  from std/json import pretty

addVmops(buildpackModule)
addCallable(buildpackModule):
  proc main(params: seq[string]): bool
const addins = implNimscriptModule(buildpackModule)

proc run(script: string; params: seq[string]) =
  loadScript(NimScriptFile(script), addins).
    invoke(main, params)

const
  configDir {.strdefine.} = "config"
  secretScriptsDir {.strdefine.} = "secret"
  configFile {.strdefine.} = "config.yaml"
  packedFile {.strdefine.} = "data.enc"
  exampleScript = """
proc main(params: seq[string]): bool =
  ## The EzScr will run this automatically
  result = true
  echo "Script '$1' ran!"
  let secret = $2
  if secret:
    echo "It's secret! Shhh"
"""

let
  appDir = getAppDir()
  configDirFullPath = appDir / configDir
  configFileFullPath = configDirFullPath / configFile
  secretScriptsDirFullPath = configDirFullPath / secretScriptsDir
  packedFileFullPath = appDir / packedFile

type
  YamlConfig = object
    secret: string
    aliases: Table[string, string]
  Config = object
    scripts: seq[Script]
  Script = object
    name: string
    content: string
    alias: string
    secret: bool

proc writeBlankConfig(file: string) =
  ## Generates a blank yaml config
  var content = dump YamlConfig()
  with content:
     `=` content[67..^1]
     `=` content.replace("aliases: ", "aliases: \l  testScript: newName")
  file.writeFile content & "\l"

proc new(names: seq[string]; secret = false) =
  ## Creates a new script files
  block setupStructure:
    if not existsOrCreateDir configDirFullPath:
      echo fmt"Creating {configDirFullPath}"

      writeBlankConfig configFileFullPath
      echo fmt"Creating {configFileFullPath}"

      if not existsOrCreateDir secretScriptsDirFullPath:
        echo fmt"Creating {secretScriptsDirFullPath}"

  for name in names:
    let file =
      (if secret: secretScriptsDirFullPath else: configDirFullPath) / fmt"{name}.nims"
    if not fileExists file:
      echo fmt"Creating {file}"
      file.writeFile exampleScript % [
        name,
        if secret: "true" else: "false"
      ]
    else:
      echo fmt"File {file} already exists"

proc yamlConfig(file: string): YamlConfig =
  ## Convert the yaml to Config
  var s = newFileStream(file)
  s.load result
  close s

proc initScript(
  file: tuple[dir, name, ext: string];
  alias: string
): Script =
  ## Adds the script file
  Script(
    name: file.name,
    content: readFile(file.dir / fmt"{file.name}{file.ext}"),
    secret: file.dir == secretScriptsDirFullPath,
    alias: alias
  )

proc writeData(path: string; config: Config) =
  ## Writes the packed data into a file
  when not debugging:
    echo "Encoding data"
    let data = encode $ %*config
  else:
    echo "Writing pretty data"
    let data = pretty %*config
  path.writeFile data

proc pack =
  ## Get all scripts and packs into a encrypted data file
  if dirExists configDirFullPath:
    let yamlConfig = yamlConfig configFileFullPath
    var data: Config
    for filePath in walkDirRec configDirFullPath:
      let file = splitFile filePath
      if file.ext == ".nims":
        echo fmt"Packing {filepath}"
        let alias = if yamlConfig.aliases.hasKey file.name:
                      yamlConfig.aliases[file.name]
                    else:
                      ""
        data.scripts.add initScript(file, alias)
    packedFileFullPath.writeData data
  else:
    quit "Config dir not exists, create it by running:\l\tezscr new newScript"

when isMainModule:
  import pkg/cligen
  dispatchMulti([
    ezscr.new
  ], [
    ezscr.pack
  ])
