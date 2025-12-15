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

	limit := 1000
	if os.Getenv("PART") == "2" {
		slog.SetLogLoggerLevel(slog.LevelDebug)
		limit = -1
	}

	internal.Do(input, limit)
}

//go:embed input.txt
var input string
