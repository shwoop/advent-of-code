package main

import (
	"day8/internal"
	_ "embed"
	"log/slog"
	"os"
)

func main() {
	if os.Getenv("DEBUG") == "true" {
		slog.SetLogLoggerLevel(slog.LevelDebug)
	}

	internal.Part1(input, 1000)
}

//go:embed input.txt
var input string
