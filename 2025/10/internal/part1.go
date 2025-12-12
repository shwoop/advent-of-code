package internal

import (
	"bufio"
	"context"
	"fmt"
	"math"
	"regexp"
	"strconv"
	"strings"
)

var buttonRegexp, _ = regexp.Compile(`\([,\d]+\)`)

type Doc struct {
	indicatorLights    int
	lenIndicatorLights int
	buttons            []int
}

func (d Doc) String() string {
	binaryPattern := fmt.Sprintf("%%0%db", d.lenIndicatorLights)
	buttonPattern := "(" + binaryPattern + ")"

	b := strings.Builder{}

	b.WriteRune('[')
	b.WriteString(fmt.Sprintf(binaryPattern, d.indicatorLights))
	b.WriteRune(']')
	b.WriteString(fmt.Sprintf(" %d ", d.lenIndicatorLights))

	buttons := make([]string, len(d.buttons))
	for i, button := range d.buttons {
		buttons[i] = fmt.Sprintf(buttonPattern, button)
	}

	b.WriteString(strings.Join(buttons, ", "))

	return b.String()
}

func (d Doc) Solve() int {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	combinations := Combinations(ctx, d.buttons)
	shortestCombination := math.MaxInt

	for combination := range combinations {
		if len(combination) > shortestCombination {
			continue
		}

		var mask int
		for _, button := range combination {
			mask ^= button
		}
		if mask == d.indicatorLights {
			if len(combination) < shortestCombination {
				shortestCombination = len(combination)
			}
		}
	}

	return shortestCombination
}

func ParseDoc(line string) Doc {
	indicatorString := line[1:strings.Index(line, "]")]
	indicatorString = strings.ReplaceAll(indicatorString, ".", "0")
	indicatorString = strings.ReplaceAll(indicatorString, "#", "1")
	indicatorLights, _ := strconv.ParseInt(indicatorString, 2, 32)

	doc := Doc{int(indicatorLights), len(indicatorString), []int{}}

	buttons := buttonRegexp.FindAllString(line, -1)
	for _, buttonString := range buttons {
		var button int
		for num := range strings.SplitSeq(buttonString[1:len(buttonString)-1], ",") {
			n, _ := strconv.Atoi(num)
			shift := (doc.lenIndicatorLights - 1 - n)
			button |= 1 << shift
		}
		doc.buttons = append(doc.buttons, button)
	}

	return doc

}

func Part1(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))

	var acc int

	for s.Scan() {
		doc := ParseDoc(s.Text())
		fmt.Printf("%s\n", doc)
		acc += doc.Solve()
	}

	fmt.Printf("part1 acc: %d\n", acc)

	return acc
}
