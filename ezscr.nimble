# Package

version       = "0.1.0"
author        = "Thiago Navarro"
description   = "Easy Nimscript runner. Nim compiler not needed"
license       = "MIT"
srcDir        = "src"
bin           = @["ezscr"]

binDir = "build"

# Dependencies

requires "nim >= 1.6.4"
requires "nimscripter"
