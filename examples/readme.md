# Examples

To run any of this examples, run:

```bash
ezscr pack_and_run <script name>
```

## [readDataEnc](./config/readDataEnc.nims)

This script reads all encoded scripts and prints all the scripts (JSON)

## [remoteModule](./config/remoteModule.nims)

This example will import a remote nim file
and open a file in browser

This is a example of how use parameters too

Run with:

```
ezscr run remoteModule out.html
```

## [downloadFile](./config/downloadFile.nims)

This example fetches a json and write into a file

## [httpGet](./config/httpGet.nims)

This example fetches a json, parse it and get specific value

## [remoteModule](./config/remoteModule.nims)

This example will import a remote nim file

Run with: ezscr run remoteModule out.html

## [staticDownloadFile](./config/staticDownloadFile.nims)

This example will download a file before script run and move the file to prevent delete
