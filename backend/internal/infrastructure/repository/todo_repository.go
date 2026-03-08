package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
	domainrepo "github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/repository"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/infrastructure/database"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/infrastructure/database/sqlcgen"
)

// compile-time check
var _ domainrepo.TodoRepository = (*TodoRepository)(nil)

// TodoRepository implements domain TodoRepository using SQLC.
type TodoRepository struct {
	database.BaseRepository
}

// NewTodoRepository creates a new TodoRepository.
func NewTodoRepository(txManager *database.TxManager) *TodoRepository {
	return &TodoRepository{
		BaseRepository: database.NewBaseRepository(txManager),
	}
}

func (r *TodoRepository) Create(ctx context.Context, todo *entity.Todo) error {
	q := sqlcgen.New(r.Querier(ctx))
	err := q.CreateTodo(ctx, sqlcgen.CreateTodoParams{
		ID:          toPgUUID(todo.ID),
		Title:       todo.Title.String(),
		Description: todo.Description,
		Status:      todo.Status.String(),
		CreatedAt:   toPgTimestamptz(todo.CreatedAt),
		UpdatedAt:   toPgTimestamptz(todo.UpdatedAt),
	})
	if err != nil {
		return r.HandleError(err)
	}
	return nil
}

func (r *TodoRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.Todo, error) {
	q := sqlcgen.New(r.Querier(ctx))
	row, err := q.GetTodoByID(ctx, toPgUUID(id))
	if err != nil {
		return nil, r.HandleError(err)
	}
	return toEntity(row)
}

func (r *TodoRepository) FindAll(ctx context.Context) ([]*entity.Todo, error) {
	q := sqlcgen.New(r.Querier(ctx))
	rows, err := q.ListTodos(ctx)
	if err != nil {
		return nil, r.HandleError(err)
	}

	todos := make([]*entity.Todo, 0, len(rows))
	for _, row := range rows {
		todo, err := toEntity(row)
		if err != nil {
			return nil, err
		}
		todos = append(todos, todo)
	}
	return todos, nil
}

func (r *TodoRepository) Update(ctx context.Context, todo *entity.Todo) error {
	q := sqlcgen.New(r.Querier(ctx))
	err := q.UpdateTodo(ctx, sqlcgen.UpdateTodoParams{
		ID:          toPgUUID(todo.ID),
		Title:       todo.Title.String(),
		Description: todo.Description,
		Status:      todo.Status.String(),
		UpdatedAt:   toPgTimestamptz(todo.UpdatedAt),
	})
	if err != nil {
		return r.HandleError(err)
	}
	return nil
}

func (r *TodoRepository) Delete(ctx context.Context, id uuid.UUID) error {
	q := sqlcgen.New(r.Querier(ctx))
	if err := q.DeleteTodo(ctx, toPgUUID(id)); err != nil {
		return r.HandleError(err)
	}
	return nil
}

func toEntity(row sqlcgen.Todo) (*entity.Todo, error) {
	id, err := fromPgUUID(row.ID)
	if err != nil {
		return nil, fmt.Errorf("infrastructure: invalid todo id: %w", err)
	}

	title, err := valueobject.NewTodoTitle(row.Title)
	if err != nil {
		return nil, fmt.Errorf("infrastructure: invalid todo title: %w", err)
	}

	status, err := valueobject.NewTodoStatus(row.Status)
	if err != nil {
		return nil, fmt.Errorf("infrastructure: invalid todo status: %w", err)
	}

	return entity.ReconstructTodo(
		id,
		title,
		row.Description,
		status,
		row.CreatedAt.Time,
		row.UpdatedAt.Time,
	), nil
}

func toPgUUID(id uuid.UUID) pgtype.UUID {
	return pgtype.UUID{Bytes: id, Valid: true}
}

func fromPgUUID(id pgtype.UUID) (uuid.UUID, error) {
	if !id.Valid {
		return uuid.Nil, fmt.Errorf("null uuid")
	}
	return uuid.UUID(id.Bytes), nil
}

func toPgTimestamptz(t time.Time) pgtype.Timestamptz {
	return pgtype.Timestamptz{Time: t, Valid: !t.IsZero()}
}
