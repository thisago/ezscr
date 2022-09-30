# Package

version       = "3.4.0"
author        = "Thiago Navarro"
description   = "Portable and easy Nimscript runner. Nim compiler not needed"
license       = "mit"
srcDir        = "src"
bin           = @["ezscr"]

binDir = "build"

# Dependencies

requires "nim >= 1.6.4"
requires "nimscripter"
requires "cligen"
requires "yaml"
requires "util"

from std/strformat import fmt
from std/os import `/`
from std/hashes import hash

const
  encodedCounter = hash(CompileTime & CompileDate) and 0x7FFFFFFF
  args = fmt"-d:encodedCounter={encodedCounter}"

let
  nimLibPath = "/data/os/config/.choosenim/toolchains/nim-#head/lib/" # **PLACE HERE YOU NIM LIB DIR**
  winArgs = fmt"-d:stdLibPath={nimLibPath}"

task buildRelease, "Builds the release version":
  echo "Compiling for the current platform"
  exec fmt"nimble -d:danger --opt:speed {args} build"
  exec fmt"strip {binDir / bin[0]}"

task buildWinRelease, "Builds the release version for Windows":
  echo "Compiling x64 for windows"
  exec fmt"nimble -d:danger --opt:speed -d:mingw {winArgs} {args} build"
  exec fmt"strip {binDir / bin[0]}.exe"
  withDir binDir:
    mvFile fmt"{bin[0]}.exe", fmt"{bin[0]}_x64.exe"

# task buildReleaseX86, "Builds the release version x86":
#   echo "Compiling x86 for the current platform"
#   exec fmt"nimble -d:danger --cpu:i386 --opt:speed {args} build"
#   exec fmt"strip {binDir / bin[0]}"
#   withDir binDir:
#     mvFile bin[0], fmt"{bin[0]}_x86"

task buildWinReleaseX86, "Builds the release version x86 for Windows":
  echo "Compiling x86 for windows"
  exec fmt"nimble -d:danger --cpu:i386 --opt:speed -d:mingw {winArgs} {args} build"
  exec fmt"strip {binDir / bin[0]}.exe"
  withDir binDir:
    mvFile fmt"{bin[0]}.exe", fmt"{bin[0]}_x86.exe"

task buildAllRelease, "Builds the release version for Windows and Linux":
  buildReleaseTask()
  buildWinReleaseTask()
  # buildReleaseX86Task()
  buildWinReleaseX86Task()
