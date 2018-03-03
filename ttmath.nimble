packageName   = "ttmath"
version       = "0.5.0"
author        = "Status Research & Development GmbH"
description   = "A Nim wrapper for ttmath: big numbers with fixed size"
license       = "Apache License 2.0"
srcDir        = "src"

### Dependencies
requires "nim >= 0.17.2"

task test, "Run tests":
  --run
  setCommand "cpp", "tests/test1.nim"
