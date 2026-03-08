package valueobject

import (
	"fmt"
	"strings"
)

const maxTodoTitleLength = 200

// TodoTitle represents a validated todo title.
type TodoTitle struct {
	value string
}

// NewTodoTitle creates a TodoTitle after validation.
func NewTodoTitle(v string) (TodoTitle, error) {
	v = strings.TrimSpace(v)
	if v == "" {
		return TodoTitle{}, fmt.Errorf("todo title must not be empty")
	}
	if len(v) > maxTodoTitleLength {
		return TodoTitle{}, fmt.Errorf("todo title must not exceed %d characters, got %d", maxTodoTitleLength, len(v))
	}
	return TodoTitle{value: v}, nil
}

// String returns the title value.
func (t TodoTitle) String() string { return t.value }

// Equals checks equality with another TodoTitle.
func (t TodoTitle) Equals(other TodoTitle) bool { return t.value == other.value }
