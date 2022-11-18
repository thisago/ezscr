# EzScr

Portable and easy Nimscript runner.

With this tool, you can bundle a lot of scripts and run it everywhere

No extra binary needed

## Installation

First install [Nim](https://nim-lang.org), then run:
```bash
nimble install ezscr
```
And the command `ezscr` will be available in your terminal. (Make sure that
Nimble bin dir is on your PATH)

## Usage

The usage is very simple and there's just 4 commands that you need to learn!

See some [examples here](examples/)

### `new`: Create new script (and setup structure)

Run

```bash
ezscr new <SCRIPT NAMES...> [-s]
```

-s makes the script secret, and needs to provide the secret (password) that can
be configured at `config.yaml` (that is created with command `new`)

Example:

```bash
ezscr new helloWorld
```

Returns:

```
Creating dir /full/path/to/config
Creating file /full/path/to/config/config.yaml
Creating dir /full/path/to/config/secret
Creating script /full/path/to/config/helloWorld.nims
```

## Configs

To edit the secret and aliases, just open the `config.yaml` file.

## `pack`: Pack the scripts

After you finished the scripting, you need to pack all the scripts into a encrypted JSON (default name is `data.enc`)

To do that, just run

```bash
ezscr pack
```

Returns:

```
Packing /full/path/to/config/helloWorld.nims
Encoding data
```

## `run`: Run script

To run the script you will need:

- exscr binary
- `data.enc` with script(s) inside

The configs dir you cannot delete because there's no decrypt command.

To run a script just:

```bash
ezscr run helloWorld
```

## `cleanLib`: Delete all the lib created (in temp)

```bash
ezscr clean_lib
```

## Features

### Full access to all std lib (supported by Nimscript)

Thanks to the [nimscripter](https://github.com/beef331/nimscripter) lib, the
scripts has full support to Nim's std lib

Example working with json

```nim
from std/json import parseJson, `{}`, getStr

proc main*(params: seq[string]): bool =
  ## This example fetches a json, parse it and get specific value
  let
    node = parseJson "https://dummyjson.com/products/1".httpGet.body
    title = node{"title"}.getStr
    description = node{"description"}.getStr

  echo title
  echo description

  result = title.len > 0 # Return success if there's a title
```

### Extended lib (undocumented yet)

There's more procs than just std, you can download files with just one command, encrypt and decrypt strings (using same algorithm that is encoded the `data.enc`) and more

Soon I will finish the documentation

### Static download

Want to import some remote file? No problems!

Just download it by using this syntax:

```nim
# Note the mandatory space after `>`
#> staticDownload "https://example.com/file.txt"
```

and import it, see the full example:

```nim
#> staticDownload "https://raw.githubusercontent.com/thisago/util/master/src/util/forStr.nim"
import forStr

proc main*(params: seq[string]): bool =
  echo "Hello John Doe!".between("llo ", " Do") # -> John
```

Limitations:
- You cannot specify the destination
- The URL cannot contains double quotes (`"`)
- One download per line
- Ignores any download error and proceeds

## TODO

- [ ] Add possibility to add multiple aliases to same script
- [ ] Add a possibility to reuse same encryption key (instead compilation time),
  maybe provide in nimble file
- [ ] Add option to run again x times until the raised exception stop to be
  raise in `run` command
- [ ] Add option to process the `main` return (bool) `false` as a raised error
  and run the script until returns true
- [ ] Add optional custom destination fot `staticDownload` downloads
- [ ] Add possibility to import pkg modules from nimble package list

## License

MIT
