package internal

import (
	"bufio"
	"fmt"
	"strings"
)

type Device struct {
	name        string
	connections []*Device
}

func LinkDevices(s *bufio.Scanner) map[string]*Device {
	deviceLinks := map[string][]string{"out": nil}
	deviceMap := map[string]*Device{"out": {name: "out"}}

	for s.Scan() {
		parts := strings.Split(s.Text(), ":")
		name := parts[0]
		linkedDeviceNames := strings.Fields(parts[1])
		deviceLinks[name] = linkedDeviceNames
		deviceMap[name] = &Device{name: name}
	}

	for name, links := range deviceLinks {
		d := deviceMap[name]
		for _, link := range links {
			d.connections = append(d.connections, deviceMap[link])
		}
	}

	return deviceMap
}

func TraverseNetwork(start, end *Device) int {
	state := TraversalState{
		target:  end,
		history: nil,
		seen:    make(map[*Device]struct{}),
		score:   0,
		scored:  make(map[*Device]int),
	}

	traverseNetwork(start, &state)

	return state.score
}

func traverseNetwork(d *Device, state *TraversalState) int {
	state.history = state.history.Push(d)
	defer func() {
		state.history = state.history.Pop()
	}()

	if score, ok := state.scored[d]; ok {
		state.score += score
		return score
	}

	if d == state.target {
		state.score++
		state.scored[d] = 1
		return 1
	}

	// avoid loops
	if _, ok := state.seen[d]; ok {
		return 0
	}
	state.seen[d] = struct{}{}
	defer func() {
		delete(state.seen, d)
	}()

	var score int
	for _, connection := range d.connections {
		score += traverseNetwork(connection, state)
	}

	state.scored[d] = score
	return score
}

type TraversalState struct {
	target  *Device
	history *History
	seen    map[*Device]struct{}
	score   int
	scored  map[*Device]int
}

type History struct {
	device *Device
	next   *History
}

func (h *History) Push(d *Device) *History {
	return &History{
		device: d,
		next:   h,
	}
}

func (h *History) Pop() *History {
	return h.next
}

func (h *History) String() string {
	w := strings.Builder{}
	w.WriteString("History")
	printHistory(&w, h)
	return w.String()
}

func printHistory(w *strings.Builder, h *History) *strings.Builder {
	if h.next != nil {
		printHistory(w, h.next)
	}

	fmt.Fprintf(w, " -> %s", h.device.name)

	return w
}
