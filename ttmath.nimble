packageName   = "ttmath"
version       = "0.5.0"
author        = "Status Research & Development GmbH"
description   = "A Nim wrapper for ttmath: big numbers with fixed size"
license       = "Apache License 2.0"
srcDir        = "src"

### Dependencies
requires "nim >= 0.18.1"

proc test(name: string, lang = "cpp") =
  if not dirExists "build":
    mkDir "build"
  if not dirExists "nimcache":
    mkDir "nimcache"
  --run
  --nimcache: "nimcache"
  switch("out", ("./build/" & name))
  setCommand lang, "tests/" & name & ".nim"

task test, "Run tests":
  test "test1"
