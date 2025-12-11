package internal

import (
	"bufio"
	"cmp"
	"context"
	"fmt"
	"log/slog"
	"strings"
	"sync"
)

type Rect struct {
	a, b Pos
	area int
}

func (r Rect) Intersects(lines []Line) bool {
	var minX, minY, maxX, maxY int
	if r.a.X < r.b.X {
		minX = r.a.X
		maxX = r.b.X
	} else {
		minX = r.b.X
		maxX = r.a.X
	}
	if r.a.Y < r.b.Y {
		minY = r.a.Y
		maxY = r.b.Y
	} else {
		minY = r.b.Y
		maxY = r.a.Y
	}

	for _, l := range lines {
		if l.a.X <= minX && l.b.X <= minX {
			continue
		}
		if l.a.X >= maxX && l.b.X >= maxX {
			continue
		}
		if l.a.Y <= minY && l.b.Y <= minY {
			continue
		}
		if l.a.Y >= maxY && l.b.Y >= maxY {
			continue
		}

		return true
	}
	return false

}

type Line struct {
	a, b Pos
}

func (r Rect) Compare(other Rect) int {
	return cmp.Compare(r.area, other.area)
}

func NewRect(a, b Pos) Rect {
	x := abs(a.X-b.X) + 1
	y := abs(a.Y-b.Y) + 1
	area := x * y

	return Rect{a, b, area}
}

func Part2(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))
	positions := []Pos{}

	var tree *Node[Rect]
	var maxArea int

	lines := []Line{}

	var firstPos, lastPos *Pos
	for s.Scan() {
		pos := ParsePos(s.Text())
		if firstPos == nil {
			firstPos = &pos
		} else {
			lines = append(lines, Line{*lastPos, pos})
		}
		lastPos = &pos

		slog.Debug("added pos", "pos", pos)

		for _, knownPos := range positions {
			r := NewRect(pos, knownPos)
			slog.Debug("calculated area", "rect", r, "a", pos, "b", knownPos)
			tree = Insert(tree, r)
		}

		positions = append(positions, pos)
	}

	lines = append(lines, Line{*firstPos, *lastPos})

	c := make(chan Rect)
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	wg := sync.WaitGroup{}
	wg.Add(1)
	wg.Go(func() {
		defer wg.Done()
		Descend(ctx, tree, c)
		close(c)
	})

	fmt.Println(lines)
	for r := range c {
		if r.Intersects(lines) {
			slog.Debug("intersects", "rect", r)
			continue
		}
		slog.Debug("doesn't intersect", "rect", r)
		maxArea = r.area
		break
	}

	cancel()
	wg.Wait()

	slog.Info("finishec part2", "area", maxArea)

	return maxArea
}
