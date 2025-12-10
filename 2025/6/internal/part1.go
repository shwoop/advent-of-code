package internal

import (
	"bufio"
	"log/slog"
	"strconv"
	"strings"
)

type Consumer interface {
	Process(string)
	Value() int
}

var _ Consumer = (*Adder)(nil)
var _ Consumer = (*Multiplier)(nil)

type Adder struct {
	value int
}

func (a *Adder) Process(x string) {
	n, _ := strconv.Atoi(x)
	a.value += n
}

func (a Adder) Value() int {
	return a.value
}

type Multiplier struct {
	value int
}

func (m *Multiplier) Process(x string) {
	n, _ := strconv.Atoi(x)
	if m.value == 0 {
		m.value = n
		return
	}
	m.value *= n
}

func (a Multiplier) Value() int {
	return a.value
}

func toOperator(op string) Consumer {
	switch op {
	case "+":
		return &Adder{}
	case "*":
		return &Multiplier{}
	default:
		panic(op)
	}
}

func Part1(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))
	lines := []string{}
	for s.Scan() {
		lines = append(lines, s.Text())
	}

	slog.Debug("imported", "n lines", len(lines))

	consumers := []Consumer{}
	for _, op := range strings.Fields(lines[len(lines)-1]) {
		consumers = append(consumers, toOperator(op))
	}

	for _, line := range lines[:len(lines)-1] {
		for i, n := range strings.Fields(line) {
			consumers[i].Process(n)
		}
	}

	var acc int
	for i, c := range consumers {
		slog.Debug("aaa", "i", i, "value", c.Value())
		acc += c.Value()
	}

	slog.Info("part1", "score", acc)

	return acc
}
