import ttmathuint
export ttmathuint
import strutils
from os import DirSep

const ttmathPath = currentSourcePath.rsplit(DirSep, 1)[0]
{.passC: "-I" & ttmathPath.}

const TTMATH_HEADER = ttmathPath & DirSep & "headers" & DirSep & "ttmath.h"

type
  Int256* {.importc: "ttmath::Int<4>", header: TTMATH_HEADER.} = object
    table: array[4, int]

  stdString {.importc: "std::string", header: "<string.h>".} = object

#var tmp256* {.exportc: "tmp256".}: Int256

# var tmpString256* {.exportc: "tmpString256", importcpp: "(char*)malloc(sizeof(char) * 256)".}: cstring

proc `+`*(a: Int256, b: Int256): Int256 {.importcpp: "(# + #)".}

proc `-`*(a: Int256, b: Int256): Int256 {.importcpp: "(# - #)".}

proc `*`*(a: Int256, b: Int256): Int256 {.importcpp: "(# * #)".}

proc `/`*(a: Int256, b: Int256): Int256 {.importcpp: "(# / #)".}

proc `div`*(a: Int256, b: Int256): Int256 {.importcpp: "(# / #)".}

proc `==`*(a: Int256, b: Int256): bool {.importcpp: "(# == #)".}

proc `<`*(a: Int256, b: Int256): bool {.importcpp: "(# < #)".}

proc `<=`*(a: Int256, b: Int256): bool {.importcpp: "(# <= #)".}

proc `+=`*(a: var Int256, b: Int256) {.importcpp: "# += #".}

proc `-=`*(a: var Int256, b: Int256) {.importcpp: "# -= #".}

proc `*=`*(a: var Int256, b: Int256) {.importcpp: "# *= #".}

proc `/=`*(a: var Int256, b: Int256) {.importcpp: "# /= #".}

template `-`*(a: Int256): Int256 =
  0.i256 - a

proc `and`*(a: Int256, b: Int256): Int256 {.importcpp: "(# & #)".}

proc `or`*(a: Int256, b: Int256): Int256 {.importcpp: "(# | #)".}

proc `xor`*(a: Int256, b: Int256): Int256 {.importcpp: "(# ^ #)".}

proc i256*(a: int): Int256 {.importcpp: "ttmath::Int<4>((int)#)".}

proc i256*(a: cstring): Int256 {.importcpp: "ttmath::Int<4>(#)".}

proc i256*(a: string): Int256 =
  cstring(a).i256

proc inplacePow(a: var Int256, b: Int256) {.importcpp: "(#.Pow(#))".}

proc inplaceDiv(a: var Int256, b: Int256, c: var Int256) {.importcpp: "(#.Div(#, #))".}

proc pow*(a: Int256, b: int): Int256 =
  var tmp = a
  tmp.inplacePow(b.i256)
  result = tmp

proc `mod`*(a: Int256, b: Int256): Int256 =
  var tmp = a
  tmp.inplaceDiv(b, result)

proc ToString(a: Int256, s: stdString | cstring) {.importcpp: "#.ToString(#)", header: TTMATH_HEADER.}

proc strcpy(c: cstring, s: cstring) {.importc: "strcpy", header: "<cstring>".}

proc c_str(s: stdString): cstring {.importcpp: "#.c_str()", header: "<string.h>".}

#proc toCString*(a: Int256): cstring =

proc `shl`*(a: Int256, b: int): Int256 {.importcpp: "(# << #)".}

proc `shr`*(a: Int256, b: int): Int256 {.importcpp: "(# >> #)".}

proc getInt*(a: Int256): int =
  a.table[0]

proc `$`*(a: Int256): string =
  var tmp: stdString
  # TODO: something smarter
  {.emit: "tmp = \"                                                                                \";".}
  var s: cstring
  {.emit: "s = new char[256];".}
  a.ToString(tmp)
  strcpy(s, tmp.c_str())
  result = $s
  {.emit: "delete[] s;".}
