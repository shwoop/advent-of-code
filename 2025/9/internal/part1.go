package internal

import (
	"bufio"
	"log/slog"
	"strconv"
	"strings"
)

type Pos struct {
	X, Y int
}

func ParsePos(s string) Pos {
	parts := strings.Split(s, ",")
	x, _ := strconv.Atoi(parts[0])
	y, _ := strconv.Atoi(parts[1])
	return Pos{x, y}
}

func Area(a, b Pos) int {
	x := abs(a.X-b.X) + 1
	y := abs(a.Y-b.Y) + 1
	return x * y
}

func abs(x int) int {
	if x < 0 {
		return x * -1
	}
	return x
}

func Part1(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))
	positions := []Pos{}

	var maxArea int

	for s.Scan() {
		pos := ParsePos(s.Text())
		slog.Debug("added pos", "pos", pos)

		for _, knownPos := range positions {
			a := Area(pos, knownPos)
			slog.Debug("calculated area", "area", a, "a", pos, "b", knownPos)
			if a > maxArea {
				maxArea = a
			}
		}

		positions = append(positions, pos)
	}

	slog.Info("finishec part1", "area", maxArea)

	return maxArea
}
