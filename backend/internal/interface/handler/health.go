package handler

import (
	"context"

	"connectrpc.com/connect"
	healthv1 "github.com/Hiro-mackay/ai-bootstrap/backend/internal/gen/health/v1"
)

// HealthHandler implements the HealthService Connect RPC handler.
type HealthHandler struct{}

func (h *HealthHandler) Check(
	ctx context.Context,
	req *connect.Request[healthv1.CheckRequest],
) (*connect.Response[healthv1.CheckResponse], error) {
	return connect.NewResponse(&healthv1.CheckResponse{Status: "ok"}), nil
}
