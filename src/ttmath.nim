import strutils
from os import DirSep

const ttmathPath = currentSourcePath.rsplit(DirSep, 1)[0]
{.passC: "-I" & ttmathPath.}

when defined(windows):
  # See https://github.com/status-im/nim-ttmath/issues/14
  {.passC: "-DTTMATH_NOASM".}

const TTMATH_HEADER = ttmathPath & DirSep & "headers" & DirSep & "ttmath.h"

type
  UInt* {.importcpp: "ttmath::UInt<'0 / 8 / sizeof(ttmath::uint)>", header: TTMATH_HEADER.} [NumBits: static[int]] = object
    table*: array[NumBits div 8 div sizeof(uint), uint] # TODO: This should likely be private, but it's used in nimbus...

  Int* {.importcpp: "ttmath::Int<'0 / 8 / sizeof(ttmath::uint)>", header: TTMATH_HEADER.} [NumBits: static[int]] = object

  Int256* = Int[256]
  Int512* = Int[512]
  Int1024* = Int[1024]
  Int2048* = Int[2048]

  UInt256* = UInt[256]
  UInt512* = UInt[512]
  UInt1024* = UInt[1024]
  UInt2048* = UInt[2048]

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
proc FromString(a: var TTInt, s: cstring, base: uint) {.importcpp, header: TTMATH_HEADER.}

proc toString*(a: TTInt, base: int = 10): string =
  let tmp = a.ToString(uint(base))
  var tmps: cstring
  {.emit: """
  `tmps` = const_cast<char*>(`tmp`.c_str());
  """.}
  result = $tmps

proc fromString*(a: var TTInt, s: cstring, base: int = 10) = a.FromString(s, uint(base))
proc fromHex*(a: var TTInt, s: string) {.inline.} = a.fromString(s, 16)

proc initInt[T](a: int64): T {.importcpp: "'0((int)#)".}
proc initUInt[T](a: uint64): T {.importcpp: "'0((int)#)".}
proc initInt[T](a: cstring): T {.importcpp: "'0(#)".}

template defineIntConstructor(typ: typedesc, name: untyped{nkIdent}) =
  template name*(a: int64): typ = initInt[typ](a)
  template name*(a: cstring): typ = initInt[typ](a)

defineIntConstructor(Int256, i256)
converter toInt256*(a: int{lit}): Int256 = a.i256 # Todo, add it to constructor template https://github.com/nim-lang/Nim/issues/7524
defineIntConstructor(Int512, i512)
defineIntConstructor(Int1024, i1024)
defineIntConstructor(Int2048, i2048)

template defineUIntConstructor(typ: typedesc, name: untyped{nkIdent}) =
  template name*(a: uint64): typ = initUInt[typ](a)
  template name*(a: cstring): typ = initInt[typ](a)

defineUIntConstructor(UInt256, u256)
converter toUInt256*(a: int{lit}): UInt256 = a.uint.u256 # Todo, add it to constructor template https://github.com/nim-lang/Nim/issues/7524
defineUIntConstructor(UInt512, u512)
defineUIntConstructor(UInt1024, u1024)
defineUIntConstructor(UInt2048, u2048)

proc `-`*(a: Int): Int {.importcpp: "(- #)".}

proc pow*(a: Int, b: int): Int =
  var tmp = a
  tmp.inplacePow(initInt[Int](b))
  result = tmp

proc pow*(a: UInt, b: uint64): UInt =
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

template max*[T: TTint]: TTInt =
  var r = initInt[T](0)
  r.setMax()
  r

proc `$`*(a: Int or UInt): string {.inline.} = a.toString()

proc hexToUInt*[N](hexStr: string): UInt[N] {.inline.} = result.fromHex(hexStr)
proc toHex*(a: TTInt): string {.inline.} = a.toString(16)

proc toByteArrayBE*[N](num: UInt[N]): array[N div 8, byte] {.noSideEffect, noInit, inline.} =
  ## Convert a TTInt (in native host endianness) to a big-endian byte array
  const N = result.len
  for i in 0 ..< N:
    {.unroll: 4.}
    result[i] = byte getUInt(num shr uint((N-1-i) * 8))

proc readUintBE*[N](ba: openarray[byte]): UInt[N] {.noSideEffect, inline.} =
  ## Convert a big-endian array of Bytes to an UInt256 (in native host endianness)
  const sz = N div 8
  assert(ba.len >= sz)
  for i in 0 ..< sz:
    {.unroll: 4.}
    result = result shl 8 or initUInt[UInt[N]](ba[i])

proc inc*(a: var TTInt, n = 1) {.inline.} =
  when a is Int:
    a += initInt[type a](n)
  else:
    a += initUInt[type a](n.uint)

proc dec*(a: var TTInt, n = 1) {.inline.} =
  when a is Int:
    a -= initInt[type a](n)
  else:
    a -= initUInt[type a](n.uint)
