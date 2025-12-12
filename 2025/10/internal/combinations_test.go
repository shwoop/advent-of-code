package internal

import "testing"



func TestCombinations(t *testing.T) {
	out := Combinations(t.Context(), []int{1, 2, 4, 8})

	var cnt int
	for range out {
		cnt++
	}

	if cnt != 15 {
		t.Fail()
	}
}