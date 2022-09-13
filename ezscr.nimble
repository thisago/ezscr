# Package

version       = "2.1.1"
author        = "Thiago Navarro"
description   = "Portable and easy Nimscript runner. Nim compiler not needed"
license       = "gpl-3.0-only"
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

task buildRelease, "Builds the release version":
  echo "Compiling for the current platform"
  exec fmt"nimble -d:danger --opt:speed {args} build"
  exec fmt"strip {binDir / bin[0]}"

task buildWinRelease, "Builds the release version for Windows":
  echo "Compiling for windows"
  exec fmt"nimble -d:danger --opt:speed -d:mingw {args} build"
  exec fmt"strip {binDir / bin[0]}.exe"

task buildAllRelease, "Builds the release version for Windows and Linux":
  buildReleaseTask()
  buildWinReleaseTask()
