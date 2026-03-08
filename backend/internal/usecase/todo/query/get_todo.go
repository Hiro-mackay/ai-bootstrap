package query

import (
	"context"

	"github.com/google/uuid"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/repository"
)

// GetTodoInput holds the ID of the todo to retrieve.
type GetTodoInput struct {
	ID uuid.UUID
}

// GetTodoOutput holds the retrieved todo.
type GetTodoOutput struct {
	Todo *entity.Todo
}

// GetTodoQuery retrieves a single todo by ID.
type GetTodoQuery struct {
	todoRepo repository.TodoRepository
}

// NewGetTodoQuery returns a new GetTodoQuery.
func NewGetTodoQuery(todoRepo repository.TodoRepository) *GetTodoQuery {
	return &GetTodoQuery{todoRepo: todoRepo}
}

// Execute finds a todo by ID.
func (q *GetTodoQuery) Execute(ctx context.Context, input GetTodoInput) (*GetTodoOutput, error) {
	todo, err := q.todoRepo.FindByID(ctx, input.ID)
	if err != nil {
		return nil, err
	}
	return &GetTodoOutput{Todo: todo}, nil
}
