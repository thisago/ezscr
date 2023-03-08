#> staticDownload "https://dummyjson.com/products/1"

proc main*(params: seq[string]): bool =
  ## This example will download a file before script run and move the file to prevent delete
  result = true
  "1".mvFile "product.json"
