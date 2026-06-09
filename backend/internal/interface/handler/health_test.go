package handler_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"

	healthv1 "github.com/your-org/your-project/backend/internal/gen/health/v1"
	"github.com/your-org/your-project/backend/internal/interface/handler"
)

func TestHealthCheckWithoutPool(t *testing.T) {
	h := handler.NewHealthHandler(nil)

	resp, err := h.Check(context.Background(), connect.NewRequest(&healthv1.CheckRequest{}))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.Msg.Status != "ok" {
		t.Fatalf("expected 'ok', got %q", resp.Msg.Status)
	}
}
