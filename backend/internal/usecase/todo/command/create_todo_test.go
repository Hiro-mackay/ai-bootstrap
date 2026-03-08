package command_test

import (
	"context"
	"errors"
	"testing"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/usecase/todo/command"
	"github.com/google/uuid"
)

type mockTodoRepo struct {
	created []*entity.Todo
	todos   []*entity.Todo
	err     error
}

func (m *mockTodoRepo) Create(_ context.Context, todo *entity.Todo) error {
	if m.err != nil {
		return m.err
	}
	m.created = append(m.created, todo)
	return nil
}

func (m *mockTodoRepo) FindByID(_ context.Context, id uuid.UUID) (*entity.Todo, error) {
	for _, t := range m.todos {
		if t.ID == id {
			return t, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (m *mockTodoRepo) FindAll(_ context.Context) ([]*entity.Todo, error) {
	return m.todos, m.err
}

func (m *mockTodoRepo) Update(_ context.Context, _ *entity.Todo) error { return m.err }
func (m *mockTodoRepo) Delete(_ context.Context, _ uuid.UUID) error    { return m.err }

func TestCreateTodoSuccess(t *testing.T) {
	repo := &mockTodoRepo{}
	cmd := command.NewCreateTodoCommand(repo)

	out, err := cmd.Execute(context.Background(), command.CreateTodoInput{
		Title:       "Buy groceries",
		Description: "Milk, eggs, bread",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if out.Todo.Title.String() != "Buy groceries" {
		t.Fatalf("expected 'Buy groceries', got %q", out.Todo.Title.String())
	}
	if out.Todo.Status != valueobject.TodoStatusPending {
		t.Fatalf("expected pending status, got %s", out.Todo.Status)
	}
	if len(repo.created) != 1 {
		t.Fatalf("expected 1 created todo, got %d", len(repo.created))
	}
}

func TestCreateTodoEmptyTitle(t *testing.T) {
	repo := &mockTodoRepo{}
	cmd := command.NewCreateTodoCommand(repo)

	_, err := cmd.Execute(context.Background(), command.CreateTodoInput{
		Title: "",
	})
	if err == nil {
		t.Fatal("expected error for empty title")
	}
	if !errors.Is(err, domain.ErrValidation) {
		t.Fatalf("expected ErrValidation, got %v", err)
	}
}

func TestCreateTodoLongTitle(t *testing.T) {
	repo := &mockTodoRepo{}
	cmd := command.NewCreateTodoCommand(repo)

	longTitle := make([]byte, 201)
	for i := range longTitle {
		longTitle[i] = 'a'
	}

	_, err := cmd.Execute(context.Background(), command.CreateTodoInput{
		Title: string(longTitle),
	})
	if err == nil {
		t.Fatal("expected error for title exceeding 200 characters")
	}
	if !errors.Is(err, domain.ErrValidation) {
		t.Fatalf("expected ErrValidation, got %v", err)
	}
}
