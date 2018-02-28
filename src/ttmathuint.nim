from os import DirSep
from strutils import rsplit
const ttmathPath = currentSourcePath.rsplit(DirSep, 1)[0]
const TTMATH_HEADER = ttmathPath & DirSep & "headers" & DirSep & "ttmath.h"

type
  UInt256* {.importc: "ttmath::UInt<4>", header: TTMATH_HEADER.} = object
    table*: array[4, uint64]

  stdString {.importc: "std::string", header: "<string.h>".} = object

proc `+`*(a: UInt256, b: UInt256): UInt256 {.importcpp: "(# + #)".}

proc `-`*(a: UInt256, b: UInt256): UInt256 {.importcpp: "(# - #)".}

proc `*`*(a: UInt256, b: UInt256): UInt256 {.importcpp: "(# * #)".}

proc `/`*(a: UInt256, b: UInt256): UInt256 {.importcpp: "(# / #)".}

proc `div`*(a: UInt256, b: UInt256): UInt256 {.importcpp: "(# / #)".}

proc `==`*(a: UInt256, b: UInt256): bool {.importcpp: "(# == #)".}

proc `<`*(a: UInt256, b: UInt256): bool {.importcpp: "(# < #)".}

proc `<=`*(a: UInt256, b: UInt256): bool {.importcpp: "(# <= #)".}

proc `+=`*(a: var UInt256, b: UInt256) {.importcpp: "# += #".}

proc `-=`*(a: var UInt256, b: UInt256) {.importcpp: "# -= #".}

proc `*=`*(a: var UInt256, b: UInt256) {.importcpp: "# *= #".}

proc `/=`*(a: var UInt256, b: UInt256) {.importcpp: "# /= #".}

proc `and`*(a: UInt256, b: UInt256): UInt256 {.importcpp: "(# & #)".}

proc `or`*(a: UInt256, b: UInt256): UInt256 {.importcpp: "(# | #)".}

proc `xor`*(a: UInt256, b: UInt256): UInt256 {.importcpp: "(# ^ #)".}

proc u256*(a: uint64): UInt256 {.importcpp: "ttmath::UInt<4>((ttmath::uint)#)".}

proc u256*(a: cstring): UInt256 {.importcpp: "ttmath::UInt<4>(#)".}

proc u256*(a: string): UInt256 =
  cstring(a).u256

proc inplacePow(a: var UInt256, b: UInt256) {.importcpp: "(#.Pow(#))".}

proc inplaceDiv(a: var UInt256, b: UInt256, c: var UInt256) {.importcpp: "(#.Div(#, #))".}

proc pow*(a: UInt256, b: uint64): UInt256 =
  var tmp = a
  tmp.inplacePow(b.u256)
  result = tmp

proc pow*(a: UInt256, b: UInt256): UInt256 =
  var tmp = a
  tmp.inplacePow(b)
  result = tmp

proc `mod`*(a: UInt256, b: UInt256): UInt256 =
  var tmp = a
  tmp.inplaceDiv(b, result)

proc ToString(a: UInt256, s: stdString | cstring) {.importcpp: "#.ToString(#)", header: TTMATH_HEADER.}

proc strcpy(c: cstring, s: cstring) {.importc: "strcpy", header: "<cstring>".}

proc c_str(s: stdString): cstring {.importcpp: "#.c_str()", header: "<string.h>".}

#proc toCString*(a: UInt256): cstring =

proc `shl`*(a: UInt256, b: uint64): UInt256 {.importcpp: "(# << #)".}

proc `shr`*(a: UInt256, b: uint64): UInt256 {.importcpp: "(# >> #)".}

proc getUInt*(a: UInt256): uint64 =
  a.table[0]

proc `$`*(a: UInt256): string =
  var tmp: stdString
  # TODO: something smarter
  {.emit: "tmp = \"                                                                                \";".}
  var s: cstring
  {.emit: "s = new char[256];".}
  a.ToString(tmp)
  strcpy(s, tmp.c_str())
  result = $s
  {.emit: "delete[] s;".}
