package main

import (
	"day10/internal"
	_ "embed"
	"log/slog"
	"os"
)

func main() {
	if os.Getenv("DEBUG") == "true" {
		slog.SetLogLoggerLevel(slog.LevelDebug)
	}

	// if os.Getenv("PART") == "2" {
	// 	internal.Part2(input)
	// 	return
	// }
	internal.Part1(input)
}

//go:embed input.txt
var input string
