# Changelog

## Version 2.0.0 (Sep 11, 2022)

- Added to `vmprocs`
  - `httpPost`
- Added to request procs in `vmProcs` a parameter to set the headers
- Added `packAndRun` command
- [CRITICAL] Fixed script loading 3 times
- Added static downloading that downloads the file before run the script, it can
  download Nim files and import it
- Implemented script alias

---

## Version 1.1.0 (Sep 9, 2022)

- Added `vmprocs` module that adds some missing procs in nimscript VM, like
  - `readFile`
  - `writeToFile`
  - `httpGet` request
  - `thisDir`

---

## Version 1.0.0 (Sep 9, 2022)

- Added `run` command
- Added nimble build tasks

---

## Version 0.2.0 (Sep 9, 2022)

- Added `pack` command
- Added yaml configuration
- Added data packing
- Edited the script example, added variables to it
- Added dynamic example yaml config

---

## Version 0.1.0 (Sep 9, 2022)

- Added `add` command
