package internal

import (
	"log/slog"
	"strconv"
	"strings"
)

type Operation int

const (
	OperationNil      Operation = 0
	OperationAdd      Operation = 1
	OperationMultiply Operation = 2
)

type CephalopodMathProcessor struct {
	numericStreams []string
	OperatorStream string
	cache          []int
	acc            int
}

func NewCephalopodMathProcessor(lines []string) *CephalopodMathProcessor {
	return &CephalopodMathProcessor{
		numericStreams: lines[:len(lines)-1],
		OperatorStream: lines[len(lines)-1],
		cache:          []int{},
		acc:            0,
	}
}

func (c *CephalopodMathProcessor) lineAt(lineNumber int) (int, Operation) {
	var op Operation

	nb := strings.Builder{}
	for _, stream := range c.numericStreams {
		nb.WriteByte(stream[lineNumber])
	}
	num, _ := strconv.Atoi(strings.Trim(nb.String(), " "))

	switch string(c.OperatorStream[lineNumber]) {
	case "*":
		op = OperationMultiply
	case "+":
		op = OperationAdd
	}

	return num, op
}

func (c *CephalopodMathProcessor) Process() {
	var operation func(int, int) int

	for i := len(c.numericStreams[0]) - 1; i >= 0; i-- {
		n, op := c.lineAt(i)
		c.cache = append(c.cache, n)

		switch op {
		case OperationNil:
			continue
		case OperationAdd:
			operation = add
		case OperationMultiply:
			operation = mult
		}

		var acc int
		for _, val := range c.cache {
			acc = operation(acc, val)
		}

		c.acc += acc
		c.cache = nil
	}
}

func mult(acc, n int) int {
	if acc == 0 {
		return n
	}
	return acc * n
}

func add(acc, n int) int {
	return acc + n
}

func Part2(in string) int {
	processor := NewCephalopodMathProcessor(strings.Split(in, "\n"))
	processor.Process()
	slog.Info("part2", "score", processor.acc)
	return processor.acc
}
