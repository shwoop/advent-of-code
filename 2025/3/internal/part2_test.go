package internal

import "testing"

func TestPart2Examples(t *testing.T) {
	cases := []struct {
		input       string
		expectedAcc int
	}{
		{input: "987654321111111", expectedAcc: 987654321111},
		{input: "811111111111119", expectedAcc: 811111111119},
		{input: "234234234234278", expectedAcc: 434234234278},
		{input: "818181911112111", expectedAcc: 888911112111},
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

	input := `987654321111111
811111111111119
234234234234278
818181911112111`
	expectedAcc := 3121910778619
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}
