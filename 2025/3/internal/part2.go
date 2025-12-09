package internal

import (
	"bufio"
	"log/slog"
	"strconv"
	"strings"
)

func Part2(in string) int {

	s := bufio.NewScanner(strings.NewReader(in))

	var acc int

	for s.Scan() {
		bankMaxJoltage := maxJoltage12ForBank(s.Text())
		acc += bankMaxJoltage
	}

	slog.Info("part2 finished", "max joltage", acc)
	return acc
}

func maxJoltage12ForBank(bank string) int {
	joltages := strings.Split(bank, "")
	maxJoltage := [12]int{9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9}
	maxJoltages := [12]int{}
	for i := 1; i < 12; i++ {
		maxJoltages[len(maxJoltages)-i], _ = strconv.Atoi(joltages[len(joltages)-i])
	}
	for index := len(joltages) - 12; index >= 0; index-- {
		j, _ := strconv.Atoi(joltages[index])
		for index, value := range maxJoltages {
			if j < value {
				break
			}
			maxJoltages[index] = j
			j = value
		}
		if maxJoltages == maxJoltage {
			// maximum joltage
			slog.Debug("max joltage")
			break
		}
	}

	acc := maxJoltages[11]
	mult := 10
	for i := 10; i >= 0; i-- {
		acc += maxJoltages[i] * mult
		mult *= 10
	}

	return acc
}
