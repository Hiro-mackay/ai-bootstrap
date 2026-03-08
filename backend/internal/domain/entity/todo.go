package entity

import (
	"errors"
	"time"

	"github.com/google/uuid"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
)

var (
	ErrTodoAlreadyCompleted = errors.New("todo is already completed")
	ErrTodoNotCompleted     = errors.New("todo is not completed")
)

// Todo is the aggregate root for a todo item.
type Todo struct {
	ID          uuid.UUID
	Title       valueobject.TodoTitle
	Description string
	Status      valueobject.TodoStatus
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// NewTodo creates a new Todo with validated title and pending status.
func NewTodo(title valueobject.TodoTitle, description string) *Todo {
	now := time.Now()
	return &Todo{
		ID:          uuid.New(),
		Title:       title,
		Description: description,
		Status:      valueobject.TodoStatusPending,
		CreatedAt:   now,
		UpdatedAt:   now,
	}
}

// ReconstructTodo rebuilds a Todo from persistence without validation.
func ReconstructTodo(
	id uuid.UUID,
	title valueobject.TodoTitle,
	description string,
	status valueobject.TodoStatus,
	createdAt, updatedAt time.Time,
) *Todo {
	return &Todo{
		ID:          id,
		Title:       title,
		Description: description,
		Status:      status,
		CreatedAt:   createdAt,
		UpdatedAt:   updatedAt,
	}
}

// Complete transitions the todo to completed status.
func (t *Todo) Complete() error {
	if t.Status == valueobject.TodoStatusCompleted {
		return ErrTodoAlreadyCompleted
	}
	t.Status = valueobject.TodoStatusCompleted
	t.UpdatedAt = time.Now()
	return nil
}

// Reopen transitions a completed todo back to pending.
func (t *Todo) Reopen() error {
	if t.Status != valueobject.TodoStatusCompleted {
		return ErrTodoNotCompleted
	}
	t.Status = valueobject.TodoStatusPending
	t.UpdatedAt = time.Now()
	return nil
}

// UpdateTitle changes the todo title.
func (t *Todo) UpdateTitle(title valueobject.TodoTitle) {
	t.Title = title
	t.UpdatedAt = time.Now()
}

// UpdateDescription changes the todo description.
func (t *Todo) UpdateDescription(description string) {
	t.Description = description
	t.UpdatedAt = time.Now()
}
