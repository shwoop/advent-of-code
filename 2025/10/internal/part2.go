package internal

import (
	"bufio"
	"fmt"
	"math"
	"strings"
)

type History struct {
	modification []int
	to           []int
	next         *History
}

func (h *History) Push(modification, to []int) *History {
	return &History{
		modification: modification,
		to:           to,
		next:         h,
	}
}

func (h *History) Pop() *History {
	return h.next
}

func (h *History) String() string {
	w := strings.Builder{}
	w.WriteString("History")
	printHistory(&w, h)
	return w.String()
}

func printHistory(w *strings.Builder, h *History) *strings.Builder {
	if h.next != nil {
		printHistory(w, h.next)
	}

	fmt.Fprintf(w, " -> applied %v to get %v", h.modification, h.to)

	return w
}

type Accumulator struct {
	masks         [][]int
	shortestDepth int

	history *History
}

func (d Doc) SolvePart2() int {
	acc := Accumulator{
		masks:         d.buttonsArrays,
		shortestDepth: math.MaxInt,
	}

	solvePart2(0, d.joltages, make([]int, d.lenIndicatorLights), &acc)

	return acc.shortestDepth
}

func solvePart2(depth int, pattern, mask []int, acc *Accumulator) {
	if depth >= acc.shortestDepth {
		return
	}

	acc.history = acc.history.Push(mask, pattern)
	defer func() {
		acc.history = acc.history.Pop()
	}()

	zeroes, cont := applyMask(pattern, mask)
	defer reverseMask(pattern, mask)
	if !cont {
		return
	}

	if zeroes == len(pattern) {
		fmt.Println(acc.history)
		acc.shortestDepth = depth
		return
	}

	for _, mask := range acc.masks {
		solvePart2(depth+1, pattern, mask, acc)
	}
}

func applyMask(pattern, mask []int) (int, bool) {
	var zeroes int
	for i := range len(pattern) {
		pattern[i] -= mask[i]
		if pattern[i] < 0 {
			return 0, false
		}
		if pattern[i] == 0 {
			zeroes++
		}
	}
	return zeroes, true
}

func reverseMask(pattern, mask []int) {
	for i := range len(pattern) {
		pattern[i] += mask[i]
	}
}

func Part2(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))

	var acc int

	for s.Scan() {
		doc := ParseDoc(s.Text())
		fmt.Printf("%s\n", doc)
		acc += doc.SolvePart2()
	}

	fmt.Printf("part1 acc: %d\n", acc)

	return acc
}
