package internal

import (
	"bufio"
	"fmt"
	"strings"
)

func Part2(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))

	var acc int

	deviceMap := LinkDevices(s)

	fmt.Println("starting")
	stoF := TraverseNetwork(deviceMap["svr"], deviceMap["fft"])
	stoD := TraverseNetwork(deviceMap["svr"], deviceMap["dac"])
	dtoF := TraverseNetwork(deviceMap["dac"], deviceMap["fft"])
	ftoD := TraverseNetwork(deviceMap["fft"], deviceMap["dac"])
	ftoO := TraverseNetwork(deviceMap["fft"], deviceMap["out"])
	dtoO := TraverseNetwork(deviceMap["dac"], deviceMap["out"])

	acc += (stoF * ftoD * dtoO)
	acc += (stoD * dtoF * ftoO)

	fmt.Printf("part 2 score: %d\n", acc)

	return acc
}
