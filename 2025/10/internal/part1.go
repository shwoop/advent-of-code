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
	joltages           []int
	buttonsArrays      [][]int
}

func (d Doc) String() string {
	binaryPattern := fmt.Sprintf("%%0%db", d.lenIndicatorLights)
	buttonPattern := "(" + binaryPattern + ", %v)"

	b := strings.Builder{}

	b.WriteRune('[')
	b.WriteString(fmt.Sprintf(binaryPattern, d.indicatorLights))
	b.WriteRune(']')
	b.WriteString(fmt.Sprintf(" %d ", d.lenIndicatorLights))

	buttons := make([]string, len(d.buttons))
	for i, button := range d.buttons {
		buttons[i] = fmt.Sprintf(buttonPattern, button, d.buttonsArrays[i])
	}

	b.WriteString(strings.Join(buttons, ", "))

	joltages := []string{}
	for _, j := range d.joltages {
		joltages = append(joltages, fmt.Sprintf("%d", j))
	}
	b.WriteString(fmt.Sprintf(" {%s}", strings.Join(joltages, ",")))

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

	doc := Doc{int(indicatorLights), len(indicatorString), []int{}, []int{}, [][]int{}}

	buttons := buttonRegexp.FindAllString(line, -1)
	for _, buttonString := range buttons {
		var button int
		buttonArray := make([]int, doc.lenIndicatorLights)

		for num := range strings.SplitSeq(buttonString[1:len(buttonString)-1], ",") {
			n, _ := strconv.Atoi(num)
			shift := (doc.lenIndicatorLights - 1 - n)
			button |= 1 << shift

			buttonArray[n] = 1
		}

		doc.buttons = append(doc.buttons, button)

		doc.buttonsArrays = append(doc.buttonsArrays, buttonArray)
	}

	joltageStrings := strings.Split(line[strings.Index(line, "{")+1:len(line)-1], ",")
	for _, js := range joltageStrings {
		n, _ := strconv.Atoi(js)
		doc.joltages = append(doc.joltages, n)
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
