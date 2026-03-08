package query

import (
	"context"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/repository"
)

// ListTodosOutput holds the list of todos.
type ListTodosOutput struct {
	Todos []*entity.Todo
}

// ListTodosQuery retrieves all todos.
type ListTodosQuery struct {
	todoRepo repository.TodoRepository
}

// NewListTodosQuery returns a new ListTodosQuery.
func NewListTodosQuery(todoRepo repository.TodoRepository) *ListTodosQuery {
	return &ListTodosQuery{todoRepo: todoRepo}
}

// ListTodosInput holds optional filters for listing todos.
type ListTodosInput struct{}

// Execute returns all todos.
func (q *ListTodosQuery) Execute(ctx context.Context, _ ListTodosInput) (*ListTodosOutput, error) {
	todos, err := q.todoRepo.FindAll(ctx)
	if err != nil {
		return nil, err
	}
	return &ListTodosOutput{Todos: todos}, nil
}
