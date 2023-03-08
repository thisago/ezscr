#> staticDownload "https://dummyjson.com/products/1"

proc main*(params: seq[string]): bool =
  ## This example fetches a json and write into a file
  result = true
  "1".mvFile "product.json"
