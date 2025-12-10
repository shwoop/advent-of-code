package main

import (
	"day7/internal"
	_ "embed"
	"log/slog"
	"os"
)

func main() {
	if os.Getenv("DEBUG") == "true" {
		slog.SetLogLoggerLevel(slog.LevelDebug)
	}

	internal.Do(input)
}

//go:embed input.txt
var input string
