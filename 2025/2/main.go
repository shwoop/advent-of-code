package main

import (

	_ "embed"
	"day2/internal"
)

func main() {
	// internal.Part1(input)
	internal.Part2(input)
}

//go:embed input.txt
var input string


