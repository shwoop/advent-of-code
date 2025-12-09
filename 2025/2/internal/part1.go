package internal

import (
	"bufio"
	"bytes"
	"log/slog"
	"math"
	"strconv"
	"strings"
)

func Part1(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))
	s.Split(splitOnComma)

	var acc int

	for s.Scan() {
		idRange := strings.Split(s.Text(), "-")
		minLength := len(idRange[0])
		maxLength := len(idRange[1])

		min, _ := strconv.Atoi(idRange[0])
		max, _ := strconv.Atoi(idRange[1])
		if min >= max {
			continue
		}

		slog.Info(s.Text(), "minLength", minLength, "maxLength", maxLength, "min", min, "max", max)

		i := min
		for {
			l := numDigits(i)
			if l%2 != 0 {
				oldI := i
				i = tenToPowerOf(l)
				slog.Info("uneven id length cannot repeat", "id", oldI, "next_id", i)
				continue
			}
			repLength := l / 2
			ttporl := tenToPowerOf(repLength)
			pattern := (i / ttporl)
			repID := (pattern * ttporl) + (pattern % ttporl)
			if repID > max {
				break
			}
			if repID <= max && repID >= min {
				slog.Info("repeating id", "id", repID)
				acc += repID
			}
			i += ttporl
		}
	}
	slog.Info("finished", "acc", acc)
	return acc
}

func splitOnComma(data []byte, atEOF bool) (advance int, token []byte, err error) {
	if atEOF && len(data) == 0 {
		return 0, nil, nil
	}

	if i := bytes.IndexByte(data, ','); i >= 0 {
		return i + 1, data[0:i], nil
	}

	if atEOF {
		return len(data), data, nil
	}

	return 0, nil, nil
}

func numDigits(x int) int {
	return int(math.Log10(float64(x))) + 1
}

func toPowerOf(base, x int) int {
	return int(math.Pow(float64(base), float64(x)))
}
func tenToPowerOf(x int) int {
	return toPowerOf(10, x)
}