package main

import (
	"bufio"
	_ "embed"
	"fmt"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

func main() {
	part1()
	part2()
}

func part1() {
	s := bufio.NewScanner(strings.NewReader(input))
	n := 50
	var x, score int
	var err error
	for s.Scan() {
		line := s.Text()
		x, err = strconv.Atoi(line[1:])
		if err != nil {
			panic(err)
		}
		switch line[0] {
		case 'L':
			n -= x
		case 'R':
			n += x
		default:
			panic("invalid input")
		}
		if n%100 == 0 {
			score++
		}
	}
	fmt.Printf("Part1 score: %d\n", score)
}

func part2() {
	s := bufio.NewScanner(strings.NewReader(input))
	n := 50
	var x, score, oldn int
	var err error

	for s.Scan() {
		line := s.Text()

		x, err = strconv.Atoi(line[1:])
		if err != nil {
			panic(err)
		}

		score += x / 100
		x = x % 100

		if line[0] == 'R' {
			n += x

			if n > 99 {
				score++
				n -= 100
			}
		} else {
			oldn = n

			n -= x

			if n < 0 {
				if oldn != 0 {
					score++
				}
				n += 100
			}

			if n == 0 {
				score++
			}
		}
	}

	fmt.Printf("Part2 score: %d\n", score)
}
