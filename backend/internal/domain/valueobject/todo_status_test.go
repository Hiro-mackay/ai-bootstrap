package valueobject_test

import (
	"testing"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
)

func TestNewTodoStatusPending(t *testing.T) {
	status, err := valueobject.NewTodoStatus("pending")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if status != valueobject.TodoStatusPending {
		t.Fatalf("expected pending, got %s", status)
	}
}

func TestNewTodoStatusCompleted(t *testing.T) {
	status, err := valueobject.NewTodoStatus("completed")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if status != valueobject.TodoStatusCompleted {
		t.Fatalf("expected completed, got %s", status)
	}
}

func TestNewTodoStatusInvalid(t *testing.T) {
	_, err := valueobject.NewTodoStatus("invalid")
	if err == nil {
		t.Fatal("expected error for invalid status")
	}
}

func TestTodoStatusString(t *testing.T) {
	if valueobject.TodoStatusPending.String() != "pending" {
		t.Fatal("expected 'pending'")
	}
	if valueobject.TodoStatusCompleted.String() != "completed" {
		t.Fatal("expected 'completed'")
	}
}
