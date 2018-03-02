import ttmathuint
export ttmathuint
import strutils
from os import DirSep

const ttmathPath = currentSourcePath.rsplit(DirSep, 1)[0]
{.passC: "-I" & ttmathPath.}

const TTMATH_HEADER = ttmathPath & DirSep & "headers" & DirSep & "ttmath.h"

type
  Int* {.importcpp: "ttmath::Int<'0>", header: TTMATH_HEADER.} [N: static[int]] = object

  Int256* = Int[4]
  Int512* = Int[8]
  Int1024* = Int[16]
  Int2048* = Int[32]

  stdString {.importc: "std::string", header: "<string.h>".} = object

proc `+`*[N](a, b: Int[N]): Int[N] {.importcpp: "(# + #)".}
proc `-`*[N](a, b: Int[N]): Int[N] {.importcpp: "(# - #)".}
proc `*`*[N](a, b: Int[N]): Int[N] {.importcpp: "(# * #)".}
proc `/`*[N](a, b: Int[N]): Int[N] {.importcpp: "(# / #)".}
proc `div`*[N](a, b: Int[N]): Int[N] {.importcpp: "(# / #)".}

proc `==`*[N](a, b: Int[N]): bool {.importcpp: "(# == #)".}
proc `<`*[N](a, b: Int[N]): bool {.importcpp: "(# < #)".}
proc `<=`*[N](a, b: Int[N]): bool {.importcpp: "(# <= #)".}

proc `+=`*[N](a: var Int[N], b: Int[N]) {.importcpp: "# += #".}
proc `-=`*[N](a: var Int[N], b: Int[N]) {.importcpp: "# -= #".}
proc `*=`*[N](a: var Int[N], b: Int[N]) {.importcpp: "# *= #".}
proc `/=`*[N](a: var Int[N], b: Int[N]) {.importcpp: "# /= #".}

proc `and`*[N](a, b: Int[N]): Int[N] {.importcpp: "(# & #)".}
proc `or`*[N](a, b: Int[N]): Int[N] {.importcpp: "(# | #)".}
proc `xor`*[N](a, b: Int[N]): Int[N] {.importcpp: "(# ^ #)".}

proc `|=`*[N](a: var Int[N], b: Int[N]) {.importcpp: "(# |= #)".}
proc `&=`*[N](a: var Int[N], b: Int[N]) {.importcpp: "(# &= #)".}
proc `^=`*[N](a: var Int[N], b: Int[N]) {.importcpp: "(# ^= #)".}

proc initInt[T](a: int): T {.importcpp: "'0((int)#)".}
proc initInt[T](a: cstring): T {.importcpp: "'0(#)".}

template defineConstructor(typ: typedesc, name: untyped{nkIdent}) =
  template name*(a: int): typ = initInt[typ](a)
  template name*(a: cstring): typ = initInt[typ](a)

defineConstructor(Int256, i256)
defineConstructor(Int512, i512)
defineConstructor(Int1024, i1024)
defineConstructor(Int2048, i2048)

template `-`*[N](a: Int[N]): Int[N] =
  initInt[Int[N]](0) - a

proc inplacePow[N](a: var Int[N], b: Int[N]) {.importcpp: "(#.Pow(#))".}
proc inplaceDiv[N](a: var Int[N], b: Int[N], c: var Int[N]) {.importcpp: "(#.Div(#, #))".}

proc pow*[N](a: Int[N], b: int): Int[N] =
  var tmp = a
  tmp.inplacePow(b.i256)
  result = tmp

proc `mod`*[N](a, b: Int[N]): Int[N] =
  var tmp = a
  tmp.inplaceDiv(b, result)

proc ToString(a: Int, s: stdString | cstring) {.importcpp: "#.ToString(#)", header: TTMATH_HEADER.}

proc `shl`*[N](a: Int[N], b: int): Int[N] {.importcpp: "(# << #)".}
proc `shr`*[N](a: Int[N], b: int): Int[N] {.importcpp: "(# >> #)".}

proc isZero*[N](a: Int[N]): bool {.importcpp: "IsZero", header: TTMATH_HEADER.}
proc getInt*[N](a: Int[N]): int {.importcpp: "ToInt", header: TTMATH_HEADER.}

proc `$`*(a: Int): string =
  var tmp: stdString
  a.ToString(tmp)
  var tmps: cstring
  {.emit: """
  `tmps` = const_cast<char*>(`tmp`.c_str());
  """.}
  result = $tmps
