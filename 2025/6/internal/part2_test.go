package internal

import "testing"

func TestPart2Example(t *testing.T) {
	input := `123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  `
	expectedAcc := 3263827
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestPart2Basic1(t *testing.T) {
	input := `64 
23 
314
+  `
	expectedAcc := 1058
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestPart2Basic2(t *testing.T) {
	input := ` 51 
387 
215 
*   `
	expectedAcc := 3253600
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestPart2Basic3(t *testing.T) {
	input := `328 
64  
98  
+   `
	expectedAcc := 625
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}

func TestPart2Basic4(t *testing.T) {
	input := `123 
 45 
  6 
*   `
	expectedAcc := 8544
	acc := Part2(input)
	if acc != expectedAcc {
		t.Logf("expected %d, got %d", expectedAcc, acc)
		t.Fail()
	}
}
