package internal

import (
	"testing"
)

func TestExample(t *testing.T) {
	input := "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
	expectedAcc := 1227775554
	acc := Part1(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestMissingID(t *testing.T) {
	input := "3095-4389"
	expectedAcc := 48581
	acc := Part1(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}