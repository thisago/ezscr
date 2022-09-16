from std/os import commandLineParams, existsOrCreateDir, `/`, getCurrentDir,
                    walkDirRec, splitFile, fileExists, dirExists, removeFile,
                    getTempDir, parentDir, createDir, removeDir
from std/strformat import fmt
from std/strutils import replace, `%`
from std/tables import Table, `[]`, hasKey, pairs
from std/json import `$`, `%`, `%*`, parseJson, to
from std/streams import newFileStream, close
import std/with
import pkg/nimscripter
import pkg/nimscripter/vmconversion
import pkg/nimscripter/vmops
import pkg/yaml/serialization
from pkg/util/forFs import escapeFs

import ezscr/vmProcs
import ezscr/staticDownload
import ezscr/nimlib

when defined release:
  import ezscr/strenc
  const debugging = false
else:
  const debugging = true

when debugging:
  from std/json import pretty

const
  configDir {.strdefine.} = "config"
  secretScriptsDir {.strdefine.} = "secret"
  configFile {.strdefine.} = "config.yaml"
  packedFile {.strdefine.} = "data.enc"
  noSecret {.strdefine.} = "__NO_SECRET__"
  libDir {.strdefine.} = getTempDir() / "ezscr"
  exampleScript = """
proc main*(params: seq[string]): bool =
  ## The EzScr will run this automatically
  result = true
  echo "Script '$1' ran!"
  let secret = $2
  if secret:
    echo "It's secret! Shhh"
"""

let
  currentDir = getCurrentDir()
  configDirFullPath = currentDir / configDir
  configFileFullPath = configDirFullPath / configFile
  secretScriptsDirFullPath = configDirFullPath / secretScriptsDir
  packedFileFullPath = currentDir / packedFile
  nimStdLibDir = libDir / "nim"


proc runNimscript(script: string; params: seq[string]): bool =
  result = true
  addVmops(buildpackModule)
  addVmProcs(buildpackModule)
  addCallable(buildpackModule):
    proc main(params: seq[string]): bool
  const addins = implNimscriptModule(buildpackModule)

  exportTo(readFile, writeFile)

  var downloadedFiles: seq[string]

  try:
    downloadedFiles = parseStaticDownload script
  except IoError:
    stderr.write "staticDownload: " & getCurrentExceptionMsg() & "\l"
    return false

  try:
    let intr = loadScript(
      NimScriptFile script,
      addins,
      stdPath = nimStdLibDir
    )
    result = intr.invoke(main, params, returnType = bool)
  except:
    echo getCurrentExceptionMsg()

  for file in downloadedFiles:
    removeFile file


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
      stderr.write fmt"Invalid name: '{name}'{'\l'}"
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
      stderr.write fmt"File {file} already exists{'\l'}"

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
    let data = encrypt $(%*config)
  else:
    echo "Writing pretty data"
    let data = pretty %*config
  path.writeFile data

proc readData(path: string): Data =
  ## Reads the packed data and decrypt
  if not fileExists path:
    stderr.write fmt"The file '{path}' doesn't exists{'\l'}"
    quit 1
  var data = readFile path
  when not debugging:
    data = decrypt data
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
    stderr.write "Config dir not exists, create it by running:\l\tezscr new newScript\l"
    return 1

const nimStdLib = readNimLib()

proc writeFileRec(file, content: string) =
  createDir(file.parentDir)
  file.writeFile content

proc setupLibCmd(): int =
  ## setup the lib
  result = 0
  if dirExists libDir:
    stderr.write "The lib already exists\l"
    return 1
  echo "Writing Nim Std lib"
  for (module, content) in nimStdLib.pairs:
    writeFileRec(nimStdLibDir / module, content)

proc cleanLibCmd(): int =
  ## clean the lib
  result = 0
  if not dirExists libDir:
    stderr.write "The lib not exists\l"
    return 1
  echo "Deleting the lib"
  removeDir libDir

proc runCmd(scriptAndParams: seq[string]; secret = noSecret): int =
  ## Run the specified scripts
  result = 0
  if not dirExists libDir:
    if setupLibCmd() != 0:
      stderr.write "Cannot setup lib"
      return 1
  let
    isSecret = secret != noSecret
    data = readData packedFileFullPath
  if isSecret and secret != data.secret:
    stderr.write "Wrong secret\l"
    return 1
  let name = scriptAndParams[0]
  var params: seq[string]
  if scriptAndParams.len > 1:
    params = scriptAndParams[1..^1]
  for script in data.scripts:
    if script.name == name or script.alias == name:
      if script.secret == isSecret:
        if runNimscript(script.content, params):
          return 0
        return 1
  stderr.write "The " &
                (if isSecret: "secret " else: "") &
                  fmt"script '{name}' doesn't exists{'\l'}"
  return 1

proc packAndRunCmd(scriptAndParams: seq[string]; secret = noSecret): int =
  ## Packs the scripts and run
  result = 0
  echo "Packing..."
  result = packCmd()
  if result > 0: return
  echo "Running..."
  result = runCmd(scriptAndParams, secret)

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
  ], [
    packAndRunCmd,
    cmdName = "packAndRun"
  ], [
    setupLibCmd,
    cmdName = "setupLib"
  ], [
    cleanLibCmd,
    cmdName = "cleanLib"
  ])
