package internal

import (
	"bufio"
	"fmt"
	"log/slog"
	"strconv"
	"strings"
)

type Doc struct {
	indicatorLights    int
	lenIndicatorLights int
	buttons            []int
}

func (d Doc) String() string {
	b := strings.Builder{}
	b.WriteString(fmt.Sprintf("%b, %d, ", d.indicatorLights, d.lenIndicatorLights))
	buttons := make([]string, len(d.buttons))
	for i, button := range d.buttons {
		buttons[i] = fmt.Sprintf("%b", button)
	}
	b.WriteString(strings.Join(buttons, ", "))
	return b.String()
}

func ParseDoc(line string) Doc {
	indicatorString := line[1:strings.Index(line, "]")]
	indicatorString = strings.ReplaceAll(indicatorString, ".", "0")
	indicatorString = strings.ReplaceAll(indicatorString, "#", "1")
	indicatorLights, _ := strconv.ParseInt(indicatorString, 2, 32)

	buttonString := line[strings.Index(line, "]")+1:strings.Index(line, "{")]
	fmt.Printf("buttonString: %s\n", buttonString)

	return Doc{int(indicatorLights), len(indicatorString), []int{}}
}

func Part1(in string) int {
	s := bufio.NewScanner(strings.NewReader(in))
	documents := []Doc{}

	var maxArea int

	for s.Scan() {
		doc := ParseDoc(s.Text())
		fmt.Printf("%s\n", doc)
		documents = append(documents, doc)

	}

	slog.Info("finishec part1", "area", maxArea)

	return maxArea
}
