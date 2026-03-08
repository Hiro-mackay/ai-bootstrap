package repository

import (
	"context"

	"github.com/google/uuid"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
)

// TodoRepository defines persistence operations for Todo aggregates.
type TodoRepository interface {
	Create(ctx context.Context, todo *entity.Todo) error
	FindByID(ctx context.Context, id uuid.UUID) (*entity.Todo, error)
	FindAll(ctx context.Context) ([]*entity.Todo, error)
	Update(ctx context.Context, todo *entity.Todo) error
	Delete(ctx context.Context, id uuid.UUID) error
}
