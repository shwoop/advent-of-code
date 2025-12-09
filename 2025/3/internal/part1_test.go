package internal

import "testing"

func TestExamples(t *testing.T) {
	cases := []struct {
		input       string
		expectedAcc int
	}{
		{input: "987654321111111", expectedAcc: 98},
		{input: "811111111111119", expectedAcc: 89},
		{input: "234234234234278", expectedAcc: 78},
		{input: "818181911112111", expectedAcc: 92},
		{
			input:       "4346343235149456543445233353534244533333333343433259333326337334334333438332533343452433223352443324",
			expectedAcc: 99,
		},
		{
			input: "2325322342223323333212331323133233234323333144333234113323362324321333522232233333432323222213253331",
			expectedAcc: 65,
		},
	}

	for _, tc := range cases {
		t.Run(tc.input, func(t *testing.T) {
			acc := Part1(tc.input)
			if acc != tc.expectedAcc {
				t.Logf("expected %d, got %d", tc.expectedAcc, acc)
				t.Fail()
			}
		})
	}
}

func TestExample(t *testing.T) {

	input := `987654321111111
811111111111119
234234234234278
818181911112111`
	expectedAcc := 357
	acc := Part1(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}
