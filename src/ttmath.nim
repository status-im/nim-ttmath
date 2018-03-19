import strutils
from os import DirSep

const ttmathPath = currentSourcePath.rsplit(DirSep, 1)[0]
{.passC: "-I" & ttmathPath.}

const TTMATH_HEADER = ttmathPath & DirSep & "headers" & DirSep & "ttmath.h"

type
  UInt* {.importcpp: "ttmath::UInt<'0 / sizeof(ttmath::uint)>", header: TTMATH_HEADER.} [NumBytes: static[int]] = object
    table*: array[NumBytes div sizeof(uint), uint] # TODO: This should likely be private, but it's used in nimbus...

  Int* {.importcpp: "ttmath::Int<'0 / sizeof(ttmath::uint)>", header: TTMATH_HEADER.} [NumBytes: static[int]] = object

  Int256* = Int[32]
  Int512* = Int[64]
  Int1024* = Int[128]
  Int2048* = Int[256]

  UInt256* = UInt[32]
  UInt512* = UInt[64]
  UInt1024* = UInt[128]
  UInt2048* = UInt[256]

  TTInt = Int or UInt

  stdString {.importc: "std::string", header: "<string.h>".} = object

proc inplacePow[T](a: var T, b: T) {.importcpp: "(#.Pow(#))".}
proc inplaceDiv[T](a: var T, b: T, c: var T) {.importcpp: "(#.Div(#, #))".}

proc `+`*(a, b: TTInt): TTInt {.importcpp: "(# + #)".}
proc `-`*(a, b: TTInt): TTInt {.importcpp: "(# - #)".}
proc `*`*(a, b: TTInt): TTInt {.importcpp: "(# * #)".}
proc `/`*(a, b: TTInt): TTInt {.importcpp: "(# / #)".}
proc `div`*(a, b: TTInt): TTInt {.importcpp: "(# / #)".}

proc `==`*(a, b: TTInt): bool {.importcpp: "(# == #)".}
proc `<`*(a, b: TTInt): bool {.importcpp: "(# < #)".}
proc `<=`*(a, b: TTInt): bool {.importcpp: "(# <= #)".}

proc `+=`*(a: var TTInt, b: TTInt) {.importcpp: "# += #".}
proc `-=`*(a: var TTInt, b: TTInt) {.importcpp: "# -= #".}
proc `*=`*(a: var TTInt, b: TTInt) {.importcpp: "# *= #".}
proc `/=`*(a: var TTInt, b: TTInt) {.importcpp: "# /= #".}

proc `and`*(a, b: TTInt): TTInt {.importcpp: "(# & #)".}
proc `or`*(a, b: TTInt): TTInt {.importcpp: "(# | #)".}
proc `xor`*(a, b: TTInt): TTInt {.importcpp: "(# ^ #)".}

proc `|=`*(a: var TTInt, b: TTInt) {.importcpp: "(# |= #)".}
proc `&=`*(a: var TTInt, b: TTInt) {.importcpp: "(# &= #)".}
proc `^=`*(a: var TTInt, b: TTInt) {.importcpp: "(# ^= #)".}

proc isZero*(a: TTInt): bool {.importcpp: "IsZero", header: TTMATH_HEADER.}

proc pow*(a, b: TTInt): TTInt =
  var tmp = a
  tmp.inplacePow(b)
  result = tmp

proc `mod`*(a, b: TTInt): TTInt =
  var tmp = a
  tmp.inplaceDiv(b, result)

proc ToString(a: TTInt, base: uint): stdString {.importcpp, header: TTMATH_HEADER.}

proc toString*(a: TTInt, base: int = 10): string =
  let tmp = a.ToString(uint(base))
  var tmps: cstring
  {.emit: """
  `tmps` = const_cast<char*>(`tmp`.c_str());
  """.}
  result = $tmps

proc initInt[T](a: int64): T {.importcpp: "'0((int)#)".}
proc initUInt[T](a: uint64): T {.importcpp: "'0((int)#)".}
proc initInt[T](a: cstring): T {.importcpp: "'0(#)".}

template defineIntConstructor(typ: typedesc, name: untyped{nkIdent}) =
  template name*(a: int64): typ = initInt[typ](a)
  template name*(a: cstring): typ = initInt[typ](a)

defineIntConstructor(Int256, i256)
defineIntConstructor(Int512, i512)
defineIntConstructor(Int1024, i1024)
defineIntConstructor(Int2048, i2048)

template defineUIntConstructor(typ: typedesc, name: untyped{nkIdent}) =
  template name*(a: uint64): typ = initUInt[typ](a)
  template name*(a: cstring): typ = initInt[typ](a)

defineUIntConstructor(UInt256, u256)
defineUIntConstructor(UInt512, u512)
defineUIntConstructor(UInt1024, u1024)
defineUIntConstructor(UInt2048, u2048)

template `-`*(a: Int): Int =
  initInt[Int](0) - a

proc pow*(a: Int, b: int): Int =
  var tmp = a
  tmp.inplacePow(initInt[Int](b))
  result = tmp

proc pow*(a: UInt, b: int): UInt =
  var tmp = a
  tmp.inplacePow(initUInt[UInt](b))
  result = tmp

proc `shl`*(a: Int, b: int): Int {.importcpp: "(# << #)".}
proc `shr`*(a: Int, b: int): Int {.importcpp: "(# >> #)".}
proc `shl`*(a: UInt, b: uint64): UInt {.importcpp: "(# << #)".}
proc `shr`*(a: UInt, b: uint64): UInt {.importcpp: "(# >> #)".}

proc getInt*(a: Int): int {.importcpp: "ToInt", header: TTMATH_HEADER.}
proc getUInt*(a: UInt): uint64 {.importcpp: "ToUInt", header: TTMATH_HEADER.}

proc setZero*(a: var TTInt) {.importcpp: "SetZero", header: TTMATH_HEADER.}
proc setOne*(a: var TTInt) {.importcpp: "SetOne", header: TTMATH_HEADER.}
proc setMin*(a: var TTInt) {.importcpp: "SetMin", header: TTMATH_HEADER.}
proc setMax*(a: var TTInt) {.importcpp: "SetMax", header: TTMATH_HEADER.}
proc clearFirstBits*(a: var TTInt, n: uint) {.importcpp: "ClearFirstBits", header: TTMATH_HEADER.}

proc `$`*(a: Int or UInt): string {.inline.} = a.toString()
