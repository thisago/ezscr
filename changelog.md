# Changelog

## Version 3.1.1 (Sep 16, 2022)

- On windows added `--app:gui`

---

## Version 3.1.0 (Sep 16, 2022)

- Fixed lib packing at windows compilation (dirty trick because os.`/` is buggy in cross compilation)

---

## Version 3.0.0 (Sep 16, 2022)

- Packed nim std lib to work without Nim installed
- Added 2 new commands, the `setupLib` and `cleanLib`

---

## Version 2.1.1 (Sep 13, 2022)

- Fixed wrong secret error message
- Fixed nimble build tasks

---

## Version 2.1.0 (Sep 12, 2022)

- Fixed staticDownload error handling
- Added info of what is doing now in `packAndRun` command
- Fixed build tasks, added for Windows too
- Now the `data.enc` needs to be relative to the dir where you are (not the exe)
  This will allow the easier selection of the `data.enc` file
- Added line breaks to all `stderr.write` calls
- Added a task to compile the Linux and Windows version using same encoding secret
- Added `readDataEnc` example

---

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
