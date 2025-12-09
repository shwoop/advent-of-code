package internal

import (
	"bufio"
	"fmt"
	"log/slog"

	"sort"
	"strconv"
	"strings"
)

type Range struct {
	from, to int
}

type Ranges []Range

func (r Ranges) String() string {
	b := strings.Builder{}
	b.WriteString("Ranges{")
	for _, rr := range r {
		b.WriteString(fmt.Sprintf("%d-%d ", rr.from, rr.to))
	}
	b.WriteString("}")
	return b.String()
}

func (r Ranges) Len() int      { return len(r) }
func (r Ranges) Swap(i, j int) { r[i], r[j] = r[j], r[i] }
func (r Ranges) Less(i, j int) bool {
	if r[i].from < r[j].from {
		return true
	}
	if r[i].from > r[j].from {
		return false
	}
	return r[i].to < r[j].to
}

func (r *Ranges) Parse(x string) {
	parts := strings.Split(x, "-")
	from, _ := strconv.Atoi(parts[0])
	to, _ := strconv.Atoi(parts[1])

	*r = append(*r, Range{from, to})
}

func Do(in string) (int, int) {
	s := bufio.NewScanner(strings.NewReader(in))

	var rangeChecker *RangeChecker

	ranges := Ranges{}
	parser := ranges.Parse
	for s.Scan() {
		t := s.Text()
		slog.Debug("processing", "text", t)
		if t == "" {
			rangeChecker = NewRangeChecker(ranges)
			parser = rangeChecker.Check
			continue
		}
		parser(t)
	}
	slog.Info("fin", "part1", rangeChecker.checked, "part2", rangeChecker.CountNumbersWithinRanges())

	return rangeChecker.checked, rangeChecker.CountNumbersWithinRanges()
}

type RangeChecker struct {
	ranges  Ranges
	checked int
}

func NewRangeChecker(oldranges Ranges) *RangeChecker {
	sort.Sort(oldranges)
	ranges := Ranges{}
	start := oldranges[0].from
	finish := oldranges[0].to
	for _, rr := range oldranges[1:] {
		if rr.from > finish {
			ranges = append(ranges, Range{start, finish})
			start, finish = rr.from, rr.to
		}
		if rr.to <= finish {
			continue
		}
		finish = rr.to
	}
	if nr := ranges[len(ranges)-1]; nr.from != start && nr.to != finish {
		ranges = append(ranges, Range{start, finish})
	}

	return &RangeChecker{
		ranges:  ranges,
		checked: 0,
	}
}

func (rc *RangeChecker) Check(x string) {
	n, _ := strconv.Atoi(x)
	for _, r := range rc.ranges {
		if n < r.from {
			return
		}
		if n > r.to {
			continue
		}
		rc.checked++
		return
	}
}

func (rc *RangeChecker) CountNumbersWithinRanges() int {
	var acc int
	for _, r := range rc.ranges {
		acc += r.to - r.from + 1
	}
	return acc
}
