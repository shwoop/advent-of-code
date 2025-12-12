package internal

import (
	"context"
)

func Combinations(ctx context.Context, set []int) chan []int {
	out := make(chan []int)

	go func() {
		defer close(out)

		for subsetBits := 1; subsetBits < (1 << uint(len(set))); subsetBits++ {
			var subset []int

			for object := uint(0); object < uint(len(set)); object++ {
				if (subsetBits>>object)&1 == 1 {
					subset = append(subset, set[object])
				}
			}
			select {
			case <-ctx.Done():
				return
			case out <- subset:
			}
		}
	}()

	return out
}
