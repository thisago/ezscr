switch("path", "$projectDir/../src")
switch("path", "$nim")
switch("define", "ssl")

when defined windows:
  switch("app", "gui")
