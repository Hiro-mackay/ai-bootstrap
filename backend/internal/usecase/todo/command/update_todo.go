package command

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/repository"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
)

// UpdateTodoInput holds partial update data for a todo.
type UpdateTodoInput struct {
	ID          uuid.UUID
	Title       *string
	Description *string
	Status      *string
}

// UpdateTodoOutput holds the result of updating a todo.
type UpdateTodoOutput struct {
	Todo *entity.Todo
}

// UpdateTodoCommand orchestrates todo updates.
type UpdateTodoCommand struct {
	todoRepo  repository.TodoRepository
	txManager repository.TransactionManager
}

// NewUpdateTodoCommand returns a new UpdateTodoCommand.
func NewUpdateTodoCommand(
	todoRepo repository.TodoRepository,
	txManager repository.TransactionManager,
) *UpdateTodoCommand {
	return &UpdateTodoCommand{todoRepo: todoRepo, txManager: txManager}
}

// Execute applies partial updates to a todo.
func (c *UpdateTodoCommand) Execute(ctx context.Context, input UpdateTodoInput) (*UpdateTodoOutput, error) {
	var todo *entity.Todo

	err := c.txManager.WithTransaction(ctx, func(ctx context.Context) error {
		var err error
		todo, err = c.todoRepo.FindByID(ctx, input.ID)
		if err != nil {
			return err
		}

		if input.Title != nil {
			title, err := valueobject.NewTodoTitle(*input.Title)
			if err != nil {
				return fmt.Errorf("%w: %v", domain.ErrValidation, err)
			}
			todo.UpdateTitle(title)
		}

		if input.Description != nil {
			todo.UpdateDescription(*input.Description)
		}

		if input.Status != nil {
			if err := applyStatusChange(todo, *input.Status); err != nil {
				return fmt.Errorf("%w: %v", domain.ErrValidation, err)
			}
		}

		return c.todoRepo.Update(ctx, todo)
	})
	if err != nil {
		return nil, err
	}

	return &UpdateTodoOutput{Todo: todo}, nil
}

func applyStatusChange(todo *entity.Todo, status string) error {
	newStatus, err := valueobject.NewTodoStatus(status)
	if err != nil {
		return err
	}

	// newStatus is guaranteed to be Pending or Completed by NewTodoStatus validation
	switch newStatus {
	case valueobject.TodoStatusCompleted:
		return todo.Complete()
	case valueobject.TodoStatusPending:
		return todo.Reopen()
	}
	panic("unreachable: NewTodoStatus returned unknown status " + newStatus.String())
}
