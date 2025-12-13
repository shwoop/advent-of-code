package internal

import (
	"bufio"
	"fmt"
	"strings"
)

func Part1(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))

	var acc int

	deviceMap := LinkDevices(s)

	acc = TraverseNetwork(deviceMap["you"], deviceMap["out"])

	fmt.Printf("part 1 score: %d\n", acc)

	return acc
}
