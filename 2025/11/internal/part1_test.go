package internal

import (
	"testing"
)

func TestPart1Example(t *testing.T) {
	input := `aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out`
	expectedAcc := 5
	acc := Part1(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestPart1Partial1(t *testing.T) {
	input := `you: out`
	expectedAcc := 1
	acc := Part1(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestPart1Partial2(t *testing.T) {
	input := `aaa: out
you: aaa`
	expectedAcc := 1
	acc := Part1(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestPart1Partial3(t *testing.T) {
	input := `aaa: out
you: aaa bbb
bbb: out`
	expectedAcc := 2
	acc := Part1(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}
