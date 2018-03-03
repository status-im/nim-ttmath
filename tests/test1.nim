import ttmath, unittest

suite "ttmath":
    test "Ints":
        let a = i256"12345678910111213141516"
        let b = i256"16151413121110987654321"
        check $(a + b) == "28497092031222200795837"

    test "UInts":
        let a = u256"12345678910111213141516"
        let b = u256"16151413121110987654321"
        check $(a + b) == "28497092031222200795837"
