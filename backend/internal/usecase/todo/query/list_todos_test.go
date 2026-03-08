package query_test

import (
	"context"
	"testing"

	"github.com/google/uuid"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/usecase/todo/query"
)

type mockTodoRepo struct {
	todos []*entity.Todo
	err   error
}

func (m *mockTodoRepo) Create(_ context.Context, _ *entity.Todo) error { return m.err }
func (m *mockTodoRepo) FindByID(_ context.Context, _ uuid.UUID) (*entity.Todo, error) {
	return nil, m.err
}
func (m *mockTodoRepo) FindAll(_ context.Context) ([]*entity.Todo, error) { return m.todos, m.err }
func (m *mockTodoRepo) Update(_ context.Context, _ *entity.Todo) error    { return m.err }
func (m *mockTodoRepo) Delete(_ context.Context, _ uuid.UUID) error       { return m.err }

func TestListTodosReturnsAll(t *testing.T) {
	title, _ := valueobject.NewTodoTitle("Test")
	todo := entity.NewTodo(title, "desc")

	repo := &mockTodoRepo{todos: []*entity.Todo{todo}}
	q := query.NewListTodosQuery(repo)

	out, err := q.Execute(context.Background(), query.ListTodosInput{})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(out.Todos) != 1 {
		t.Fatalf("expected 1 todo, got %d", len(out.Todos))
	}
}

func TestListTodosEmpty(t *testing.T) {
	repo := &mockTodoRepo{todos: []*entity.Todo{}}
	q := query.NewListTodosQuery(repo)

	out, err := q.Execute(context.Background(), query.ListTodosInput{})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(out.Todos) != 0 {
		t.Fatalf("expected 0 todos, got %d", len(out.Todos))
	}
}
