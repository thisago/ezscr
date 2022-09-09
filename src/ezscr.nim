from std/os import commandLineParams, existsOrCreateDir, `/`, getAppDir,
                    walkDirRec, splitFile, fileExists, dirExists
from std/strformat import fmt
from std/strutils import replace, `%`
from std/tables import Table, `[]`, hasKey
from std/json import `$`, `%`, `%*`, parseJson, to
from std/streams import newFileStream, close
import std/with
import pkg/nimscripter
import pkg/nimscripter/vmconversion
import pkg/nimscripter/vmops
import pkg/yaml/serialization
from pkg/util/forFs import escapeFs


when defined release:
  import ezscr/strenc

  const debugging = false
else:
  const debugging = true

when debugging:
  from std/json import pretty


addVmops(buildpackModule)
addCallable(buildpackModule):
  proc main: bool
const addins = implNimscriptModule(buildpackModule)

proc runNimscript(script: string): bool =
  loadScript(NimScriptFile script).
    invoke(main, returnType = bool)

const
  configDir {.strdefine.} = "config"
  secretScriptsDir {.strdefine.} = "secret"
  configFile {.strdefine.} = "config.yaml"
  packedFile {.strdefine.} = "data.enc"
  noSecret {.strdefine.} = "__NO_SECRET__"
  exampleScript = """
proc main*: bool =
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
  Data = object
    scripts: seq[Script]
    secret: string
  Script = object
    name: string
    content: string
    alias: string
    secret: bool

proc writeBlankConfig(file: string) =
  ## Generates a blank yaml config
  var content = dump YamlConfig()
  with content:
    `=`content[67..^1]
    `=`content.replace("aliases: ", "aliases: \l  testScript: newName")
  file.writeFile content & "\l"

proc newCmd(names: seq[string]; secret = false): int =
  ## Creates a new script files
  result = 0
  block setupStructure:
    if not existsOrCreateDir configDirFullPath:
      echo fmt"Creating dir {configDirFullPath}"

      writeBlankConfig configFileFullPath
      echo fmt"Creating file {configFileFullPath}"

      if not existsOrCreateDir secretScriptsDirFullPath:
        echo fmt"Creating dir {secretScriptsDirFullPath}"

  for name in names:
    if name != escapeFs name:
      stderr.write fmt"Invalid name: '{name}'"
      return 1
    let file =
      (if secret: secretScriptsDirFullPath else: configDirFullPath) / fmt"{name}.nims"
    if not fileExists file:
      echo fmt"Creating script {file}"
      file.writeFile exampleScript % [
        name,
        if secret: "true" else: "false"
      ]
    else:
      stderr.write fmt"File {file} already exists"

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

proc writeData(path: string; config: Data) =
  ## Writes the packed data into a file
  when not debugging:
    echo "Encoding data"
    let data = encode $(%*config)
  else:
    echo "Writing pretty data"
    let data = pretty %*config
  path.writeFile data

proc readData(path: string): Data =
  ## Reads the packed data and decodes
  var data = readFile path
  when not debugging:
    data = decode data
  result = data.parseJson.to Data
  

func configFromYaml(yaml: YamlConfig): Data =
  ## Saves the yaml config into the data
  result.secret = yaml.secret

proc packCmd: int =
  ## Get all scripts and packs into a encrypted data file
  result = 0
  if dirExists configDirFullPath:
    let yamlConfig = yamlConfig configFileFullPath
    var data = configFromYaml yamlConfig

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
    stderr.write "Config dir not exists, create it by running:\l\tezscr new newScript"
    return 1

proc runCmd(scripts: seq[string]; secret = noSecret): int =
  ## Run the specified scripts
  result = 0
  let
    isSecret = secret != noSecret
    data = readData packedFileFullPath
  if isSecret and secret != data.secret:
    stderr.write "Wrong secret"
    return 1
  for name in scripts:
    block thisScript:
      for script in data.scripts:
        if script.name == name and script.secret == isSecret:
          if not runNimscript script.content:
            return 1
          break thisScript
      stderr.write "The " &
                    (if isSecret: "secret " else: "") &
                      fmt"script '{name}' doesn't exists"
      return 1


when isMainModule:
  import pkg/cligen

  block setVersion:
    const nimbleFile = staticRead "../ezscr.nimble"
    clCfg.version = nimbleFile.fromNimble "version"

  dispatchMulti([
    newCmd,
    cmdName = "new",
  ], [
    packCmd,
    cmdName = "pack"
  ], [
    runCmd,
    cmdName = "run"
  ])
