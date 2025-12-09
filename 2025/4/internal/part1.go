package internal

import (
	"bufio"
	"fmt"
	"strings"
)

type PaperMap [][]int

func (p PaperMap) String() string {
	b := strings.Builder{}
	for y := 0; y < len(p); y++ {
		for x := 0; x < len(p[0]); x++ {
			if p[y][x] == 1 {
				b.WriteRune('@')
			} else if p[y][x] == -1 {
				b.WriteRune('x')
			} else {
				b.WriteRune('.')
			}
		}
		b.WriteRune('\n')
	}
	return b.String()
}

func (p PaperMap) Process() int {
	var accessible int

	for y := 0; y < len(p); y++ {
		for x := 0; x < len(p[0]); x++ {
			if p[y][x] == 0 {
				continue
			}
			if p.adjascentCount(x, y) < 4 {
				p[y][x] = -1
				accessible++
			}
		}
	}

	return accessible
}

func (p PaperMap) adjascentCount(x, y int) int {
	var cnt int

	if x != 0 && y != 0 {
		/*
			x..
			.*.
			...
		*/
		if p[y-1][x-1] != 0 {
			cnt++
		}
	}
	if y != 0 {
		/*
			.x.
			.*.
			...
		*/
		if p[y-1][x] != 0 {
			cnt++
		}
	}
	if x != len(p[y])-1 && y != 0 {
		/*
			..x
			.*.
			...
		*/
		if p[y-1][x+1] != 0 {
			cnt++
		}
	}

	if x != 0 {
		/*
			...
			x*.
			...
		*/
		if p[y][x-1] != 0 {
			cnt++
		}
	}
	if x != len(p[y])-1 {
		/*
			...
			.*x
			...
		*/
		if p[y][x+1] != 0 {
			cnt++
		}
	}

	if x != 0 && y != len(p)-1 {
		/*
			...
			.*.
			x..
		*/
		if p[y+1][x-1] != 0 {
			cnt++
		}
	}

	if y != len(p)-1 {
		/*
			...
			.*.
			.x.
		*/
		if p[y+1][x] != 0 {
			cnt++
		}
	}
	if x != len(p[y])-1 && y != len(p)-1 {
		/*
			...
			.*.
			..x
		*/
		if p[y+1][x+1] != 0 {
			cnt++
		}
	}

	return cnt
}

const paper = '@'

func Part1(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))

	paperMap := PaperMap{}

	for s.Scan() {
		paperRow := []int{}
		for _, pos := range s.Text() {
			if pos == paper {
				paperRow = append(paperRow, 1)
			} else {
				paperRow = append(paperRow, 0)
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
