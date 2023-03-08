proc main*(params: seq[string]): bool =
  ## This example fetches a json and write into a file
  result = true
  "product.json".writeToFile("https://dummyjson.com/products/1".httpGet.body)
