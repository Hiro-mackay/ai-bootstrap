package handler_test

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/google/uuid"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
	todov1 "github.com/Hiro-mackay/ai-bootstrap/backend/internal/gen/todo/v1"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/interface/handler"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/usecase/todo/command"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/usecase/todo/query"
)

// Mock repository for use cases
type mockTodoRepo struct {
	todos []*entity.Todo
	err   error
}

func (m *mockTodoRepo) Create(_ context.Context, todo *entity.Todo) error {
	if m.err != nil {
		return m.err
	}
	m.todos = append(m.todos, todo)
	return nil
}

func (m *mockTodoRepo) FindByID(_ context.Context, id uuid.UUID) (*entity.Todo, error) {
	if m.err != nil {
		return nil, m.err
	}
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

type mockTxManager struct{}

func (m *mockTxManager) WithTransaction(ctx context.Context, fn func(context.Context) error) error {
	return fn(ctx)
}

func newTestHandler(repo *mockTodoRepo) *handler.TodoHandler {
	tx := &mockTxManager{}
	return handler.NewTodoHandler(
		command.NewCreateTodoCommand(repo),
		command.NewUpdateTodoCommand(repo, tx),
		command.NewDeleteTodoCommand(repo),
		query.NewGetTodoQuery(repo),
		query.NewListTodosQuery(repo),
	)
}

func TestCreateTodoHandler(t *testing.T) {
	repo := &mockTodoRepo{}
	h := newTestHandler(repo)

	resp, err := h.CreateTodo(context.Background(), connect.NewRequest(&todov1.CreateTodoRequest{
		Title:       "Test todo",
		Description: "Test description",
	}))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.Msg.Todo.Title != "Test todo" {
		t.Fatalf("expected 'Test todo', got %q", resp.Msg.Todo.Title)
	}
	if resp.Msg.Todo.Status != todov1.TodoStatus_TODO_STATUS_PENDING {
		t.Fatalf("expected TODO_STATUS_PENDING, got %v", resp.Msg.Todo.Status)
	}
}

func TestGetTodoHandlerNotFound(t *testing.T) {
	repo := &mockTodoRepo{}
	h := newTestHandler(repo)

	_, err := h.GetTodo(context.Background(), connect.NewRequest(&todov1.GetTodoRequest{
		Id: uuid.New().String(),
	}))
	if err == nil {
		t.Fatal("expected error for non-existent todo")
	}

	var connectErr *connect.Error
	if !errors.As(err, &connectErr) {
		t.Fatalf("expected connect.Error, got %T", err)
	}
	if connectErr.Code() != connect.CodeNotFound {
		t.Fatalf("expected CodeNotFound, got %v", connectErr.Code())
	}
}

func TestListTodosHandler(t *testing.T) {
	title, _ := valueobject.NewTodoTitle("Item 1")
	todo := entity.NewTodo(title, "desc")

	repo := &mockTodoRepo{todos: []*entity.Todo{todo}}
	h := newTestHandler(repo)

	resp, err := h.ListTodos(context.Background(), connect.NewRequest(&todov1.ListTodosRequest{}))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(resp.Msg.Todos) != 1 {
		t.Fatalf("expected 1 todo, got %d", len(resp.Msg.Todos))
	}
	if resp.Msg.Todos[0].Title != "Item 1" {
		t.Fatalf("expected 'Item 1', got %q", resp.Msg.Todos[0].Title)
	}
}

func TestGetTodoHandlerInvalidID(t *testing.T) {
	repo := &mockTodoRepo{}
	h := newTestHandler(repo)

	_, err := h.GetTodo(context.Background(), connect.NewRequest(&todov1.GetTodoRequest{
		Id: "not-a-uuid",
	}))
	if err == nil {
		t.Fatal("expected error for invalid UUID")
	}

	var connectErr *connect.Error
	if !errors.As(err, &connectErr) {
		t.Fatalf("expected connect.Error, got %T", err)
	}
	if connectErr.Code() != connect.CodeInvalidArgument {
		t.Fatalf("expected CodeInvalidArgument, got %v", connectErr.Code())
	}
}
