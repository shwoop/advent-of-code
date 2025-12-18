package internal

import "context"

type Comparer[T any] interface {
	Compare(other T) int
}

type Node[T Comparer[T]] struct {
	Value T
	Left  *Node[T]
	Right *Node[T]
}

func Insert[T Comparer[T]](root *Node[T], value T) *Node[T] {
	if root == nil {
		return &Node[T]{Value: value}
	}

	if value.Compare(root.Value) < 0 {
		root.Left = Insert(root.Left, value)
	} else if value.Compare(root.Value) > 0 {
		root.Right = Insert(root.Right, value)
	}

	return root
}

func Descend[T Comparer[T]](ctx context.Context, root *Node[T], out chan T) {
	select {
		case <-ctx.Done():
		return
		default:
	}

	if root.Right != nil {
		Descend(ctx, root.Right, out)
	}

	select {
		case <-ctx.Done():
		case out <- root.Value:
	}

	if root.Left != nil {
		Descend(ctx, root.Left, out)
	}
}