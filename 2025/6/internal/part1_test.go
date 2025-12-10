package internal

import "testing"

func TestPart1Example(t *testing.T) {

	input := `123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +`
	expectedAcc := 4277556
	acc := Part1(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}