package internal

import (
	"testing"
)

func TestPart2Example(t *testing.T) {
	input := `svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out`
	expectedAcc := 2
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestPart2Basic1(t *testing.T) {
	input := `svr: fft
fft: dac
dac: out`
	expectedAcc := 1
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestPart2Basic2(t *testing.T) {
	input := `svr: dac
fft: out
dac: fft`
	expectedAcc := 1
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestPart2Basic3(t *testing.T) {
	input := `svr: aaa bbb
aaa: dac
bbb: dac
fft: out
dac: fft`
	expectedAcc := 2
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}
