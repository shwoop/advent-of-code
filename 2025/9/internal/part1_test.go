package internal

import "testing"

func TestPart1Example(t *testing.T) {

	input := `7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3`
	expectedAcc := 50
	acc := Part1(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}