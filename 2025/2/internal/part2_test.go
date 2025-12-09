package internal

import (
	"testing"
)

func TestPart2Examples(t *testing.T) {
	cases := []struct {
		input       string
		expectedAcc int
	}{
		{
			input:       "11-22",
			expectedAcc: 11 + 22,
		},
		{
			input:       "95-115",
			expectedAcc: 99 + 111,
		},
		{
			input:       "998-1012",
			expectedAcc: 999 + 1010,
		},
		{
			input:       "1188511880-1188511890",
			expectedAcc: 1188511885,
		},
		{input: "222220-222224", expectedAcc: 222222},
		{input: "1698522-1698528", expectedAcc: 0},
		{input: "446443-446449", expectedAcc: 446446},
		{input: "38593856-38593862", expectedAcc: 38593859},
		{input: "565653-565659", expectedAcc: 565656},
		{input: "824824821-824824827", expectedAcc: 824824824},
		{input: "2121212118-2121212124", expectedAcc: 2121212121},
	}
	for _, tc := range cases {
		t.Run(tc.input, func(t *testing.T) {
			acc := Part2(tc.input)
			if acc != tc.expectedAcc {
				t.Logf("expected %d, got %d", tc.expectedAcc, acc)
				t.Fail()
			}
		})
	}
}

func TestPart2Example(t *testing.T) {
	input := "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
	expectedAcc := 4174379265
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}
