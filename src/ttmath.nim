import strutils
from os import DirSep

const ttmathPath = currentSourcePath.rsplit(DirSep, 1)[0]
{.passC: "-I" & ttmathPath.}

const TTMATH_HEADER = ttmathPath & DirSep & "headers" & DirSep & "ttmath.h"

type
  UInt* {.importcpp: "ttmath::UInt<'0>", header: TTMATH_HEADER.} [N: static[int]] = object
    table*: array[N, uint64] # TODO: This should likely be private, but it's used in nimbus...

  Int* {.importcpp: "ttmath::Int<'0>", header: TTMATH_HEADER.} [N: static[int]] = object

  Int256* = Int[4]
  Int512* = Int[8]
  Int1024* = Int[16]
  Int2048* = Int[32]

  UInt256* = UInt[4]
  UInt512* = UInt[8]
  UInt1024* = UInt[16]
  UInt2048* = UInt[32]

  stdString {.importc: "std::string", header: "<string.h>".} = object

proc inplacePow[T](a: var T, b: T) {.importcpp: "(#.Pow(#))".}
proc inplaceDiv[T](a: var T, b: T, c: var T) {.importcpp: "(#.Div(#, #))".}

template defineSharedProcs(TTInt: untyped) =
  # These procs are legit for both Int and UInt

  proc `+`*[N](a, b: TTInt[N]): TTInt[N] {.importcpp: "(# + #)".}
  proc `-`*[N](a, b: TTInt[N]): TTInt[N] {.importcpp: "(# - #)".}
  proc `*`*[N](a, b: TTInt[N]): TTInt[N] {.importcpp: "(# * #)".}
  proc `/`*[N](a, b: TTInt[N]): TTInt[N] {.importcpp: "(# / #)".}
  proc `div`*[N](a, b: TTInt[N]): TTInt[N] {.importcpp: "(# / #)".}

  proc `==`*[N](a, b: TTInt[N]): bool {.importcpp: "(# == #)".}
  proc `<`*[N](a, b: TTInt[N]): bool {.importcpp: "(# < #)".}
  proc `<=`*[N](a, b: TTInt[N]): bool {.importcpp: "(# <= #)".}

  proc `+=`*[N](a: var TTInt[N], b: TTInt[N]) {.importcpp: "# += #".}
  proc `-=`*[N](a: var TTInt[N], b: TTInt[N]) {.importcpp: "# -= #".}
  proc `*=`*[N](a: var TTInt[N], b: TTInt[N]) {.importcpp: "# *= #".}
  proc `/=`*[N](a: var TTInt[N], b: TTInt[N]) {.importcpp: "# /= #".}

  proc `and`*[N](a, b: TTInt[N]): TTInt[N] {.importcpp: "(# & #)".}
  proc `or`*[N](a, b: TTInt[N]): TTInt[N] {.importcpp: "(# | #)".}
  proc `xor`*[N](a, b: TTInt[N]): TTInt[N] {.importcpp: "(# ^ #)".}

  proc `|=`*[N](a: var TTInt[N], b: TTInt[N]) {.importcpp: "(# |= #)".}
  proc `&=`*[N](a: var TTInt[N], b: TTInt[N]) {.importcpp: "(# &= #)".}
  proc `^=`*[N](a: var TTInt[N], b: TTInt[N]) {.importcpp: "(# ^= #)".}

  proc isZero*[N](a: TTInt[N]): bool {.importcpp: "IsZero", header: TTMATH_HEADER.}

  proc pow*[N](a, b: TTInt[N]): TTInt[N] =
    var tmp = a
    tmp.inplacePow(b)
    result = tmp

  proc `mod`*[N](a, b: TTInt[N]): TTInt[N] =
    var tmp = a
    tmp.inplaceDiv(b, result)

  proc ToString[N](a: TTInt[N], s: stdString) {.importcpp, header: TTMATH_HEADER.}

defineSharedProcs(Int)
defineSharedProcs(UInt)

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

template `-`*[N](a: Int[N]): Int[N] =
  initInt[Int[N]](0) - a

proc pow*[N](a: Int[N], b: int): Int[N] =
  var tmp = a
  tmp.inplacePow(initInt[Int[N]](b))
  result = tmp

proc pow*[N](a: UInt[N], b: int): UInt[N] =
  var tmp = a
  tmp.inplacePow(initUInt[UInt[N]](b))
  result = tmp

proc `shl`*[N](a: Int[N], b: int): Int[N] {.importcpp: "(# << #)".}
proc `shr`*[N](a: Int[N], b: int): Int[N] {.importcpp: "(# >> #)".}
proc `shl`*[N](a: UInt[N], b: uint64): UInt[N] {.importcpp: "(# << #)".}
proc `shr`*[N](a: UInt[N], b: uint64): UInt[N] {.importcpp: "(# >> #)".}

proc getInt*(a: Int): int {.importcpp: "ToInt", header: TTMATH_HEADER.}
proc getUInt*(a: UInt): uint64 {.importcpp: "ToUInt", header: TTMATH_HEADER.}

proc `$`*(a: Int or UInt): string =
  var tmp: stdString
  a.ToString(tmp)
  var tmps: cstring
  {.emit: """
  `tmps` = const_cast<char*>(`tmp`.c_str());
  """.}
  result = $tmps
