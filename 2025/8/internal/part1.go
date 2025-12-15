package internal

import (
	"bufio"
	"cmp"
	"fmt"
	"math"
	"slices"
	"strconv"
	"strings"
)

type Circuit struct {
	id int
}

type JunctionBox struct {
	X, Y, Z int
	circuit *Circuit
}

func Do(in string, limit int) int {
	s := bufio.NewScanner(strings.NewReader(in))

	points := []*JunctionBox{}

	for s.Scan() {
		points = append(points, parsePoint(s.Text()))
	}
	connections := NewUniqueConnectionCollection()
	for i, pointA := range points {
		for _, pointB := range points[i:] {
			if pointA != pointB {
				connections.Add(NewConnection(pointA, pointB))
			}
		}
	}

	connections.Sort()

	nb := NewNetworkBuilder(limit, 0, points, connections.connections)
	nb.ApplyConnections()

	if limit == -1 {
		result := nb.Part2()
		fmt.Printf("part 2 solution: %d\n", result)
		return result
	}

	circuitCount := nb.Count()
	slices.Sort(circuitCount)
	fmt.Println(circuitCount)
	fmt.Println(len(circuitCount))

	lowerBound := len(circuitCount) - 3
	if lowerBound < 0 {
		lowerBound = 0
	}

	acc := 1
	for _, val := range circuitCount[lowerBound:] {
		acc *= val
	}

	fmt.Printf("part 1 solution: %d\n", acc)
	return acc
}

func parsePoint(line string) *JunctionBox {
	parts := strings.Split(line, ",")
	if len(parts) != 3 {
		panic("bad line")
	}

	x, _ := strconv.Atoi(parts[0])
	y, _ := strconv.Atoi(parts[1])
	z, _ := strconv.Atoi(parts[2])

	return &JunctionBox{x, y, z, nil}
}

type Connection struct {
	a, b *JunctionBox
	dist float64
}

func (k Connection) String() string {
	return fmt.Sprintf("[(%d, %d, %d) - (%d, %d, %d), %f]",
		k.a.X,
		k.a.Y,
		k.a.Z,
		k.b.X,
		k.b.Y,
		k.b.Z,
		k.dist,
	)
}

func NewConnection(a, b *JunctionBox) Connection {
	dist := math.Pow(float64(a.X)-float64(b.X), 2)
	dist += math.Pow(float64(a.Y)-float64(b.Y), 2)
	dist += math.Pow(float64(a.Z)-float64(b.Z), 2)
	return Connection{
		a:    a,
		b:    b,
		dist: math.Sqrt(dist),
	}
}

type ConnectionCollector struct {
	knownSignatures map[string]struct{}
	connections     []Connection
}

func NewUniqueConnectionCollection() *ConnectionCollector {
	return &ConnectionCollector{
		knownSignatures: map[string]struct{}{},
		connections:     nil,
	}
}

func (u *ConnectionCollector) Add(c Connection) {
	first, second := c.a, c.b
	for _, diff := range []int{c.a.X - c.b.X, c.a.Y - c.b.Y, c.a.Z - c.b.Z} {
		if diff == 0 {
			continue
		}
		if diff < 0 {
			first, second = c.a, c.b
			break
		}
		first, second = c.b, c.a
		break
	}

	sig := fmt.Sprintf("%d-%d-%d-%d-%d-%d",
		first.X,
		first.Y,
		first.Z,
		second.X,
		second.Y,
		second.Z,
	)

	if _, ok := u.knownSignatures[sig]; !ok {
		u.knownSignatures[sig] = struct{}{}
		u.connections = append(u.connections, c)
	}
}

func (u *ConnectionCollector) Sort() {
	slices.SortFunc(u.connections, func(a, b Connection) int {
		return cmp.Compare(a.dist, b.dist)
	})
}

func (u *ConnectionCollector) String() string {
	b := strings.Builder{}
	for _, con := range u.connections {
		b.WriteString(con.String())
	}
	return b.String()
}

type NetworkBuilder struct {
	limit          int
	cnt            int
	boxes          []*JunctionBox
	connections    []Connection
	finalConnectin *Connection
}

func NewNetworkBuilder(limit, cnt int, boxes []*JunctionBox, connections []Connection) *NetworkBuilder {
	return &NetworkBuilder{
		limit:       limit,
		cnt:         cnt,
		boxes:       boxes,
		connections: connections,
	}
}

func (c *NetworkBuilder) ApplyConnections() {
	circuits := map[int]*Circuit{}
	for i, box := range c.boxes {
		box.circuit = &Circuit{id: i}
		circuits[i] = box.circuit
	}

LoopConnections:
	for i, conn := range c.connections {
		if c.limit != -1 && i >= c.limit {
			return
		}

		if conn.a.circuit == conn.b.circuit {
			continue
		}

		switch true {
		case conn.a.circuit.id < conn.b.circuit.id:
			// fmt.Printf("C %d - BRIDGED INTO %d\n", conn.b.circuit.id, conn.a.circuit.id)

			if _, ok := circuits[conn.a.circuit.id]; !ok {
				panic("ffs")
			}

			from := conn.b.circuit

			for _, box := range c.boxes {
				if box.circuit != nil && box.circuit == from {
					box.circuit = conn.a.circuit
				}
			}

			delete(circuits, from.id)

			if len(circuits) == 1 {
				c.finalConnectin = &conn
				break LoopConnections
			}
		case conn.a.circuit.id > conn.b.circuit.id:
			// fmt.Printf("C %d - BRIDGED INTO %d\n", conn.a.circuit.id, conn.b.circuit.id)
			from := conn.a.circuit

			for _, box := range c.boxes {
				if box.circuit != nil && box.circuit == from {
					box.circuit = conn.b.circuit
				}
			}

			delete(circuits, from.id)

			if len(circuits) == 1 {
				c.finalConnectin = &conn
				break LoopConnections
			}
		default:
			panic("...")
		}
	}
}

func (c *NetworkBuilder) Count() []int {
	uniqueCircuitCounts := map[*Circuit]int{}
	counts := []int{}

	for _, box := range c.boxes {
		if box.circuit == nil {
			counts = append(counts, 1)
			continue
		}
		uniqueCircuitCounts[box.circuit]++
	}

	for _, val := range uniqueCircuitCounts {
		counts = append(counts, val)
	}

	return counts
}

func (c *NetworkBuilder) Part2() int {
	return c.finalConnectin.a.X * c.finalConnectin.b.X
}
