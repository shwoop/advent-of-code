package internal

import (
	"bufio"
	"log/slog"
	"strconv"
	"strings"
)

func Part1(in string) int {

	s := bufio.NewScanner(strings.NewReader(in))

	var acc int

	for s.Scan() {
		bankMaxJoltage := maxJoltageForBank(s.Text())
		acc += bankMaxJoltage
	}

	slog.Info("part1 finished", "max joltage", acc)
	return acc
}

func maxJoltageForBank(bank string) int {
	joltages := strings.Split(bank, "")
	j1, _ := strconv.Atoi(joltages[len(joltages)-2])
	j2, _ := strconv.Atoi(joltages[len(joltages)-1])
	for index := len(joltages) - 3; index >= 0; index-- {
		j, _ := strconv.Atoi(joltages[index])
		if j >= j1 {
			if j1 > j2 {
				j2 = j1
			}
			j1 = j
			slog.Debug("updated", "j1", j1, "j2", j2)
		} else {
			continue
		}
		if j1 == 9 && j2 == 9 {
			// maximum joltage
			slog.Debug("max joltage", "bank", bank, "j1", j1, "j2", j2)
			return (j1 * 10) + j2
		}
	}
	slog.Debug("iteration", "bank", bank, "j1", j1, "j2", j2)
	return (j1 * 10) + j2
}
