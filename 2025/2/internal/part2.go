package internal

import (
	"bufio"
	"log/slog"
	"strconv"
	"strings"
)

func Part2(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))
	s.Split(splitOnComma)

	var acc int

	for s.Scan() {
		idRange := strings.Split(s.Text(), "-")

		min, _ := strconv.Atoi(idRange[0])
		max, _ := strconv.Atoi(idRange[1])

		uniqueIDs := map[int]struct{}{}

		ranges := generateRanges(min, max)
		for _, r := range ranges {
			for repetitionDepth := 1; repetitionDepth <= r.len/2; repetitionDepth++ {
				foundIDs := repetitions(repetitionDepth, r)
				for _, foundID := range foundIDs {
					uniqueIDs[foundID] = struct{}{}
				}
			}
		}
		for foundID := range uniqueIDs {
			acc += foundID
		}
	}
	slog.Info("finished", "acc", acc)
	return acc
}

type Range struct {
	from, to, len int
}

func generateRanges(min, max int) []Range {
	newRanges := []Range{}
	newMin := min
	for {
		newMax := tenToPowerOf(numDigits(newMin)) - 1
		if newMax > max {
			newRanges = append(newRanges, Range{newMin, max, numDigits(newMin)})
			break
		}
		newRanges = append(newRanges, Range{newMin, newMax, numDigits(newMin)})
		newMin = tenToPowerOf(numDigits(newMin))
	}
	return newRanges
}

func repetitions(depth int, r Range) []int {
	log := slog.With("depth", depth, "range", r)
	reps := r.len / depth

	divisor := tenToPowerOf(r.len - depth)
	digit := r.from / divisor
	maxDigit := r.to / divisor

	var acc []int
	for digit <= maxDigit {
		sid := strings.Repeat(strconv.Itoa(digit), reps)
		id, _ := strconv.Atoi(sid)
		if id >= r.from && id <= r.to {
			acc = append(acc, id)
			log.Info("found id", "id", id)
		}
		digit++
	}
	return acc
}
