import ttmath, unittest, strutils

suite "ttmath":
  test "Ints":
    let a = i256"12345678910111213141516"
    let b = i256"16151413121110987654321"
    check:
      sizeof(a) == 32
      $(a + b) == "28497092031222200795837"
      a + b == "28497092031222200795837".i256
      a + b != "28497092031222200795838".i256
      a + b < "28497092031222200795838".i256
      -a == "-12345678910111213141516".i256

  test "Ints - syntactic sugar":
    var a = i256"12345678910111213141516"
    inc a
    var b = i256"16151413121110987654321"
    dec b
    var c = a
    c += 1 # test implicit converter
    check:
      a == i256"12345678910111213141517"
      b == i256"16151413121110987654320"
      c == i256"12345678910111213141518"

  test "UInts":
    let a = u256"12345678910111213141516"
    let b = u256"16151413121110987654321"
    check:
      sizeof(a) == 32
      $(a + b) == "28497092031222200795837"
      a + b == "28497092031222200795837".u256
      a + b != "28497092031222200795838".u256
      a + b < "28497092031222200795838".u256
      pow(2.u256, 3) == 8.u256
      pow(2.u256, 3'u64) == 8.u256

  test "UInts - syntactic sugar":
    var a = u256"12345678910111213141516"
    inc a
    var b = u256"16151413121110987654321"
    dec b
    var c = a
    c += 1 # test implicit converter
    check:
      a == u256"12345678910111213141517"
      b == u256"16151413121110987654320"
      c == u256"12345678910111213141518"

suite "Testing conversion functions: Hex, Bytes, Endianness":
  let
    SECPK1_N_HEX = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141".toLowerAscii
    SECPK1_N = "115792089237316195423570985008687907852837564279074904382605163141518161494337".u256
    SECPK1_N_BYTES = [byte(255), 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 186, 174, 220, 230, 175, 72, 160, 59, 191, 210, 94, 140, 208, 54, 65, 65]

  test "hex -> uint256":
    check: hexToUInt[256](SECPK1_N_HEX) == SECPK1_N

  test "uint256 -> hex":
    check: SECPK1_N.toHex == SECPK1_N_HEX

  test "hex -> big-endian array -> uint256":
    check: readUIntBE[256](SECPK1_N_BYTES) == SECPK1_N

  test "uint256 -> big-endian array -> hex":
    check: SECPK1_N.toByteArrayBE == SECPK1_N_BYTES

suite "Confirming consistency: hex vs decimal conversion":
  # Conversion done through https://www.mobilefish.com/services/big_number/big_number.php

  test "Alice signature":
    check:
      hexToUInt[256]("B20E2EA5D3CBAA83C1E0372F110CF12535648613B479B64C1A8C1A20C5021F38") ==
        "80536744857756143861726945576089915884233437828013729338039544043241440681784".u256
      hexToUInt[256]("0434D07EC5795E3F789794351658E80B7FAF47A46328F41E019D7B853745CDFD") ==
        "1902566422691403459035240420865094128779958320521066670269403689808757640701".u256

  test "Bob signature":
    check:
      hexToUInt[512]("5C48EA4F0F2257FA23BD25E6FCB0B75BBE2FF9BBDA0167118DAB2BB6E31BA76E") ==
        "41741612198399299636429810387160790514780876799439767175315078161978521003886".u512
      hexToUInt[512]("691DBDAF2A231FC9958CD8EDD99507121F8184042E075CF10F98BA88ABFF1F36") ==
        "47545396818609319588074484786899049290652725314938191835667190243225814114102".u512

  test "Eve signature":
    check:
      hexToUInt[1024]("BABEEFC5082D3CA2E0BC80532AB38F9CFB196FB9977401B2F6A98061F15ED603") ==
        "84467545608142925331782333363288012579669270632210954476013542647119929595395".u1024
      hexToUInt[1024]("603D0AF084BF906B2CDF6CDDE8B2E1C3E51A41AF5E9ADEC7F3643B3F1AA2AADF") ==
        "43529886636775750164425297556346136250671451061152161143648812009114516499167".u1024
