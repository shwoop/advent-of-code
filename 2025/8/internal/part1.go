package internal

import (
	"bufio"
	"cmp"
	"fmt"
	"math"
	"slices"
	"strconv"
	"strings"

	"github.com/kyroy/kdtree"
	kdpoints "github.com/kyroy/kdtree/points"
)

func Part1(in string, limit int) int {
	s := bufio.NewScanner(strings.NewReader(in))

	points := []kdtree.Point{}

	for s.Scan() {
		points = append(points, parsePoint(s.Text()))
	}
	connections := NewUniqueConnectionCollection()
	for i, pointA := range points {
		for _, pointB := range points[i:] {
			if pointA != pointB {
				connections.Add(NewKDConnection(pointA, pointB))
			}
		}
	}

	fmt.Printf("brute force: %d\n", len(connections.connections))

	connections.Sort()

	circuits := NewCircuits(points, limit)
	circuits.ApplyConnections(connections.connections)

	circuitCount := circuits.Count()
	slices.Sort(circuitCount)
	fmt.Println(circuitCount)
	acc := 1
	for _, val := range circuitCount[len(circuitCount)-3:] {
		// fmt.Printf("acc: %d, val %d\n", acc, val)
		acc *= val
	}

	fmt.Printf("part 1 solution: %d\n", acc)
	return acc
}

func parsePoint(line string) kdtree.Point {
	parts := strings.Split(line, ",")
	if len(parts) != 3 {
		panic("bad line")
	}

	x, _ := strconv.Atoi(parts[0])
	y, _ := strconv.Atoi(parts[1])
	z, _ := strconv.Atoi(parts[2])

	return kdpoints.NewPoint([]float64{float64(x), float64(y), float64(z)}, nil)

}

type KDConnection struct {
	a, b kdtree.Point
	dist float64
}

func (k KDConnection) String() string {
	return fmt.Sprintf("[(%f, %f, %f) - (%f, %f, %f), %f]",
		k.a.Dimension(0),
		k.a.Dimension(1),
		k.a.Dimension(2),
		k.b.Dimension(0),
		k.b.Dimension(1),
		k.b.Dimension(2),
		k.dist,
	)
}

func NewKDConnection(a, b kdtree.Point) KDConnection {
	sum := 0.
	for i := 0; i < a.Dimensions(); i++ {
		sum += math.Pow(a.Dimension(i)-b.Dimension(i), 2.0)
	}
	return KDConnection{
		a:    a,
		b:    b,
		dist: math.Sqrt(sum),
	}
}

type ConnectionCollector struct {
	knownSignatures map[string]struct{}
	connections     []KDConnection
}

func NewUniqueConnectionCollection() *ConnectionCollector {
	return &ConnectionCollector{
		knownSignatures: map[string]struct{}{},
		connections:     nil,
	}
}

func (u *ConnectionCollector) Add(c KDConnection) {
	first, second := c.a, c.b
	for i := range 3 {
		diff := c.a.Dimension(i) - c.b.Dimension(i)
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

	sig := fmt.Sprintf("%f-%f-%f-%f-%f-%f",
		first.Dimension(0),
		first.Dimension(1),
		first.Dimension(2),
		second.Dimension(0),
		second.Dimension(1),
		second.Dimension(2),
	)

	if _, ok := u.knownSignatures[sig]; !ok {
		u.knownSignatures[sig] = struct{}{}
		u.connections = append(u.connections, c)
	}
}

func (u *ConnectionCollector) Sort() {
	slices.SortFunc(u.connections, func(a, b KDConnection) int {
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

type Circuits struct {
	junctionBoxCircuits map[kdtree.Point]int
	limit               int
	cnt                 int
}

func NewCircuits(points []kdtree.Point, limit int) Circuits {
	jbc := make(map[kdtree.Point]int, len(points))
	for i, point := range points {
		jbc[point] = i + 1
	}
	return Circuits{jbc, limit, 0}
}

func (c *Circuits) ApplyConnections(connections []KDConnection) {
	for i, con := range connections {
		if i > c.limit {
			return
		}
		c.applyConnection(con)
	}
}

func (c *Circuits) applyConnection(con KDConnection) {
	var from, to int
	if c.junctionBoxCircuits[con.a] == c.junctionBoxCircuits[con.b] {
		return
	} else if c.junctionBoxCircuits[con.a] < c.junctionBoxCircuits[con.b] {
		from = c.junctionBoxCircuits[con.b]
		to = c.junctionBoxCircuits[con.a]
		c.junctionBoxCircuits[con.b] = to
	} else {
		from = c.junctionBoxCircuits[con.a]
		to = c.junctionBoxCircuits[con.b]
		c.junctionBoxCircuits[con.a] = to
	}

	fmt.Printf("from %d to %d\n", from, to)

	// bridge circuits
	for i, val := range c.junctionBoxCircuits {
		if val == from {
			if c.junctionBoxCircuits[i] != to {
				fmt.Printf("bridging\n")
				c.junctionBoxCircuits[i] = to
			}
		}
	}
}

func (c *Circuits) Count() []int {
	count := map[int]int{}
	for _, circuitID := range c.junctionBoxCircuits {
		count[circuitID]++
	}
	fmt.Println(count)
	result := []int{}
	for _, val := range count {
		result = append(result, val)
	}
	return result
}
