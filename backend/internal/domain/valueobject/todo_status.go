package valueobject

import "fmt"

// TodoStatus represents the completion state of a todo.
type TodoStatus string

const (
	TodoStatusPending   TodoStatus = "pending"
	TodoStatusCompleted TodoStatus = "completed"
)

// NewTodoStatus validates and returns a TodoStatus.
func NewTodoStatus(s string) (TodoStatus, error) {
	switch TodoStatus(s) {
	case TodoStatusPending, TodoStatusCompleted:
		return TodoStatus(s), nil
	default:
		return "", fmt.Errorf("invalid todo status: %s", s)
	}
}

// String returns the status as a string.
func (s TodoStatus) String() string { return string(s) }
