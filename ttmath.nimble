packageName   = "ttmath"
version       = "0.5.0"
author        = "Status Research & Development GmbH"
description   = "A Nim wrapper for ttmath: big numbers with fixed size"
license       = "Apache License 2.0"

### Dependencies
requires "nim >= 1.6.12"

proc test(args, path: string) =
  if not dirExists "build":
    mkDir "build"

  exec "nim cpp " & getEnv("NIMFLAGS") & " " & args &
    " --outdir:build -r --hints:off --warnings:off --skipParentCfg" &
    " --styleCheck:usages --styleCheck:error " & path
  if (NimMajor, NimMinor) > (1, 6):
    exec "nim cpp " & getEnv("NIMFLAGS") & " " & args &
      " --outdir:build -r --mm:refc --hints:off --warnings:off --skipParentCfg" &
      " --styleCheck:usages --styleCheck:error " & path

task test, "Run all tests":
  test "", "tests/test1"
