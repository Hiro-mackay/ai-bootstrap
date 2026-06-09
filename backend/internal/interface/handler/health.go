package handler

import (
	"context"

	"connectrpc.com/connect"

	healthv1 "github.com/your-org/your-project/backend/internal/gen/health/v1"
)

// DBPinger abstracts database health checking.
type DBPinger interface {
	Ping(ctx context.Context) error
}

// HealthHandler implements the HealthService Connect RPC handler.
type HealthHandler struct {
	db DBPinger
}

// NewHealthHandler creates a HealthHandler with a database pinger for health checks.
func NewHealthHandler(db DBPinger) *HealthHandler {
	return &HealthHandler{db: db}
}

func (h *HealthHandler) Check(
	ctx context.Context,
	req *connect.Request[healthv1.CheckRequest],
) (*connect.Response[healthv1.CheckResponse], error) {
	if h.db != nil {
		if err := h.db.Ping(ctx); err != nil {
			return connect.NewResponse(&healthv1.CheckResponse{Status: "unhealthy"}), nil
		}
	}
	return connect.NewResponse(&healthv1.CheckResponse{Status: "ok"}), nil
}
