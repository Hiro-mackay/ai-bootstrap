package entity_test

import (
	"errors"
	"testing"
	"time"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
)

func newTestTodo(t *testing.T) *entity.Todo {
	t.Helper()
	title, err := valueobject.NewTodoTitle("Test todo")
	if err != nil {
		t.Fatalf("unexpected error creating title: %v", err)
	}
	return entity.NewTodo(title, "Test description")
}

func TestNewTodo(t *testing.T) {
	todo := newTestTodo(t)

	if todo.ID.String() == "" {
		t.Fatal("expected non-empty ID")
	}
	if todo.Title.String() != "Test todo" {
		t.Fatalf("expected 'Test todo', got %q", todo.Title.String())
	}
	if todo.Description != "Test description" {
		t.Fatalf("expected 'Test description', got %q", todo.Description)
	}
	if todo.Status != valueobject.TodoStatusPending {
		t.Fatalf("expected pending status, got %s", todo.Status)
	}
	if todo.CreatedAt.IsZero() {
		t.Fatal("expected non-zero CreatedAt")
	}
	if todo.UpdatedAt.IsZero() {
		t.Fatal("expected non-zero UpdatedAt")
	}
}

func TestTodoComplete(t *testing.T) {
	todo := newTestTodo(t)
	before := time.Now()

	if err := todo.Complete(); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if todo.Status != valueobject.TodoStatusCompleted {
		t.Fatalf("expected completed status, got %s", todo.Status)
	}
	if todo.UpdatedAt.Before(before) {
		t.Fatal("expected UpdatedAt to advance")
	}
}

func TestTodoCompleteAlreadyCompleted(t *testing.T) {
	todo := newTestTodo(t)
	_ = todo.Complete()

	err := todo.Complete()
	if err == nil {
		t.Fatal("expected error when completing already completed todo")
	}
	if !errors.Is(err, entity.ErrTodoAlreadyCompleted) {
		t.Fatalf("expected ErrTodoAlreadyCompleted, got %v", err)
	}
}

func TestTodoReopen(t *testing.T) {
	todo := newTestTodo(t)
	_ = todo.Complete()

	if err := todo.Reopen(); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if todo.Status != valueobject.TodoStatusPending {
		t.Fatalf("expected pending status, got %s", todo.Status)
	}
}

func TestTodoReopenNotCompleted(t *testing.T) {
	todo := newTestTodo(t)

	err := todo.Reopen()
	if err == nil {
		t.Fatal("expected error when reopening non-completed todo")
	}
	if !errors.Is(err, entity.ErrTodoNotCompleted) {
		t.Fatalf("expected ErrTodoNotCompleted, got %v", err)
	}
}

func TestTodoUpdateTitle(t *testing.T) {
	todo := newTestTodo(t)
	before := time.Now()

	newTitle, _ := valueobject.NewTodoTitle("Updated title")
	todo.UpdateTitle(newTitle)

	if todo.Title.String() != "Updated title" {
		t.Fatalf("expected 'Updated title', got %q", todo.Title.String())
	}
	if todo.UpdatedAt.Before(before) {
		t.Fatal("expected UpdatedAt to advance")
	}
}

func TestTodoUpdateDescription(t *testing.T) {
	todo := newTestTodo(t)
	before := time.Now()

	todo.UpdateDescription("New description")

	if todo.Description != "New description" {
		t.Fatalf("expected 'New description', got %q", todo.Description)
	}
	if todo.UpdatedAt.Before(before) {
		t.Fatal("expected UpdatedAt to advance")
	}
}
