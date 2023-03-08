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
