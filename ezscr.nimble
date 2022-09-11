# Package

version       = "2.0.0"
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

task buildRelease, "Builds the release version":
  exec "nimble -d:release --opt:speed build"
  exec "strip build/ezscr"

task buildWinRelease, "Builds the release version for Windows":
  exec "nimble -d:release --opt:speed -d:mingw build"
  exec "strip build/ezscr.exe"
