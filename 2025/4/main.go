package main

import (
	"day4/internal"
	_ "embed"
	"log/slog"
	"os"
)

func main() {
	if os.Getenv("DEBUG") == "true" {
		slog.SetLogLoggerLevel(slog.LevelDebug)
	}

	internal.Part1(input)
	internal.Part2(input)
}

//go:embed input.txt
var input string
