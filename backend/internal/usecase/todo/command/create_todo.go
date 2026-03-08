package command

import (
	"context"
	"fmt"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/repository"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
)

// CreateTodoInput holds the data needed to create a todo.
type CreateTodoInput struct {
	Title       string
	Description string
}

// CreateTodoOutput holds the result of creating a todo.
type CreateTodoOutput struct {
	Todo *entity.Todo
}

// CreateTodoCommand orchestrates todo creation.
type CreateTodoCommand struct {
	todoRepo repository.TodoRepository
}

// NewCreateTodoCommand returns a new CreateTodoCommand.
func NewCreateTodoCommand(todoRepo repository.TodoRepository) *CreateTodoCommand {
	return &CreateTodoCommand{todoRepo: todoRepo}
}

// Execute validates input and persists a new todo.
func (c *CreateTodoCommand) Execute(ctx context.Context, input CreateTodoInput) (*CreateTodoOutput, error) {
	title, err := valueobject.NewTodoTitle(input.Title)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", domain.ErrValidation, err)
	}

	todo := entity.NewTodo(title, input.Description)

	if err := c.todoRepo.Create(ctx, todo); err != nil {
		return nil, err
	}

	return &CreateTodoOutput{Todo: todo}, nil
}
