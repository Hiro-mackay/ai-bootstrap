package command

import (
	"context"

	"github.com/google/uuid"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/repository"
)

// DeleteTodoInput holds the ID of the todo to delete.
type DeleteTodoInput struct {
	ID uuid.UUID
}

// DeleteTodoCommand orchestrates todo deletion.
type DeleteTodoCommand struct {
	todoRepo repository.TodoRepository
}

// NewDeleteTodoCommand returns a new DeleteTodoCommand.
func NewDeleteTodoCommand(todoRepo repository.TodoRepository) *DeleteTodoCommand {
	return &DeleteTodoCommand{todoRepo: todoRepo}
}

// Execute deletes a todo by ID.
func (c *DeleteTodoCommand) Execute(ctx context.Context, input DeleteTodoInput) error {
	return c.todoRepo.Delete(ctx, input.ID)
}
