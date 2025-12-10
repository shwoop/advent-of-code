package internal

import (
	"bufio"
	"log/slog"
	"strings"
)

type Stream struct {
	present   bool
	converged int
}

type modification interface {
	ModifyStreams([]Stream)
}

type ConvergeStream struct {
	index  int
	stream Stream
}

func (a ConvergeStream) ModifyStreams(streams []Stream) {
	if a.index == len(streams) || a.index < 0 {
		return
	}
	streams[a.index].present = true
	streams[a.index].converged += a.stream.converged
}

type RemoveStream struct {
	index int
}

func (a RemoveStream) ModifyStreams(streams []Stream) {
	if a.index == len(streams) || a.index < 0 {
		return
	}
	streams[a.index].present = false
	streams[a.index].converged = 0
}

func Do(in string) (int, int) {
	s := bufio.NewScanner(strings.NewReader(in))

	s.Scan()
	line := s.Text()
	activeStreams := make([]Stream, len(line))
	activeStreams[strings.Index(line, "S")].present = true
	activeStreams[strings.Index(line, "S")].converged = 1

	modifications := []modification{}
	var splitCount int

	for s.Scan() {
		line := s.Text()
		splitterIndexes := splitterLocations(line)
		if len(splitterIndexes) == 0 {
			continue
		}

		for _, si := range splitterIndexes {
			if as := activeStreams[si]; as.present {
				modifications = append(modifications,
					ConvergeStream{index: si - 1, stream: as},
					RemoveStream{si},
					ConvergeStream{index: si + 1, stream: as},
				)
				splitCount++
			}
		}

		for _, mod := range modifications {
			mod.ModifyStreams(activeStreams)
		}
		modifications = nil

	}

	var convergedSum int
	for _, stream := range activeStreams {
		convergedSum += stream.converged
	}

	slog.Info("part1", "split_count", splitCount)
	slog.Info("part2", "converged_streams", convergedSum)

	return splitCount, convergedSum
}

func splitterLocations(line string) []int {
	indexes := []int{}
	for i, v := range line {
		if v == '^' {
			indexes = append(indexes, i)
		}
	}
	return indexes
}
