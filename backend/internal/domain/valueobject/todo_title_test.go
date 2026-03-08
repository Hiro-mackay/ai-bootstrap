package valueobject_test

import (
	"strings"
	"testing"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
)

func TestNewTodoTitle(t *testing.T) {
	title, err := valueobject.NewTodoTitle("Buy groceries")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if title.String() != "Buy groceries" {
		t.Fatalf("expected 'Buy groceries', got %q", title.String())
	}
}

func TestNewTodoTitleEmpty(t *testing.T) {
	_, err := valueobject.NewTodoTitle("")
	if err == nil {
		t.Fatal("expected error for empty title")
	}
}

func TestNewTodoTitleWhitespaceOnly(t *testing.T) {
	_, err := valueobject.NewTodoTitle("   ")
	if err == nil {
		t.Fatal("expected error for whitespace-only title")
	}
}

func TestNewTodoTitleTooLong(t *testing.T) {
	long := strings.Repeat("a", 201)
	_, err := valueobject.NewTodoTitle(long)
	if err == nil {
		t.Fatal("expected error for title exceeding 200 characters")
	}
}

func TestNewTodoTitleTrimsWhitespace(t *testing.T) {
	title, err := valueobject.NewTodoTitle("  hello  ")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if title.String() != "hello" {
		t.Fatalf("expected 'hello', got %q", title.String())
	}
}

func TestTodoTitleEquals(t *testing.T) {
	a, _ := valueobject.NewTodoTitle("test")
	b, _ := valueobject.NewTodoTitle("test")
	c, _ := valueobject.NewTodoTitle("other")

	if !a.Equals(b) {
		t.Fatal("expected equal titles to be equal")
	}
	if a.Equals(c) {
		t.Fatal("expected different titles to not be equal")
	}
}
