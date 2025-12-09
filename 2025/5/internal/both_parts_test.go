package internal

import "testing"

func TestPart1Example(t *testing.T) {

	input := `3-5
10-14
16-20
12-18

1
5
8
11
17
32`
	expectedAcc := 3
	part1, _ := Do(input)
	if part1 != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, part1)
		t.Fail()
	}
}

func TestPart2Example(t *testing.T) {

	input := `3-5
10-14
16-20
12-18

1
5
8
11
17
32`
	expectedAcc := 14
	_, part2 := Do(input)
	if part2 != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, part2)
		t.Fail()
	}
}
