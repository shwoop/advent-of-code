package internal

import (
	"bufio"
	"fmt"
	"strings"
)

type SquareStatus int

const (
	SquareStatusEmpty   SquareStatus = 0
	SquareStatusPaper   SquareStatus = 1
	SquareStatusRemoved SquareStatus = 2
)

type SquareState struct {
	state              SquareStatus
	changedOnIteration int
}

type PaperMap2 [][]SquareState

func (p PaperMap2) String() string {
	b := strings.Builder{}
	for y := 0; y < len(p); y++ {
		for x := 0; x < len(p[0]); x++ {
			if p[y][x].state == SquareStatusPaper {
				b.WriteRune('@')
			} else if p[y][x].state == SquareStatusRemoved {
				b.WriteString(fmt.Sprintf("%d", p[y][x].changedOnIteration))
			} else {
				b.WriteRune('.')
			}
		}
		b.WriteRune('\n')
	}
	return b.String()
}

func (p PaperMap2) Process() int {
	var acc int
	iteration := 1
	for {
		changed := p.iteration(iteration)
		if changed == 0 {
			break
		}
		acc += changed
		iteration++

		fmt.Printf("%s\n", p.String())
	}
	return acc
}

func (p PaperMap2) iteration(it int) int {
	var accessible int

	for y := 0; y < len(p); y++ {
		for x := 0; x < len(p[0]); x++ {
			if p[y][x].state == SquareStatusEmpty {
				continue
			}
			if p[y][x].state == SquareStatusRemoved {
				continue
			}
			if p.adjascentCount(x, y, it) < 4 {
				p[y][x].state = SquareStatusRemoved
				p[y][x].changedOnIteration = it

				accessible++
			}
		}
	}

	return accessible
}

func (p PaperMap2) adjascentCount(x, y, it int) int {
	var cnt int

	shouldCount := func(p SquareState) bool {
		return p.state == SquareStatusPaper || (p.changedOnIteration == it && p.state == SquareStatusRemoved)
	}

	if x != 0 && y != 0 {
		/*
			x..
			.*.
			...
		*/
		if shouldCount(p[y-1][x-1]) {
			cnt++
		}
	}
	if y != 0 {
		/*
			.x.
			.*.
			...
		*/
		if shouldCount(p[y-1][x]) {
			cnt++
		}
	}
	if x != len(p[y])-1 && y != 0 {
		/*
			..x
			.*.
			...
		*/
		if shouldCount(p[y-1][x+1]) {
			cnt++
		}
	}

	if x != 0 {
		/*
			...
			x*.
			...
		*/
		if shouldCount(p[y][x-1]) {
			cnt++
		}
	}
	if x != len(p[y])-1 {
		/*
			...
			.*x
			...
		*/
		if shouldCount(p[y][x+1]) {
			cnt++
		}
	}

	if x != 0 && y != len(p)-1 {
		/*
			...
			.*.
			x..
		*/
		if shouldCount(p[y+1][x-1]) {
			cnt++
		}
	}

	if y != len(p)-1 {
		/*
			...
			.*.
			.x.
		*/
		if shouldCount(p[y+1][x]) {
			cnt++
		}
	}
	if x != len(p[y])-1 && y != len(p)-1 {
		/*
			...
			.*.
			..x
		*/
		if shouldCount(p[y+1][x+1]) {
			cnt++
		}
	}

	return cnt
}

func Part2(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))

	paperMap := PaperMap2{}

	for s.Scan() {
		paperRow := []SquareState{}
		for _, pos := range s.Text() {
			if pos == paper {
				paperRow = append(paperRow, SquareState{SquareStatusPaper, 0})
			} else {
				paperRow = append(paperRow, SquareState{SquareStatusEmpty, 0})
			}
		}
		paperMap = append(paperMap, paperRow)
	}

	fmt.Printf("%s\n", paperMap.String())

	accessible := paperMap.Process()

	fmt.Printf("%s\n", paperMap.String())

	fmt.Printf("answer: %d\n", accessible)

	return accessible
}
