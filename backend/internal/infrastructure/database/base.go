package database

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/your-org/your-project/backend/internal/domain"
)

// DBTX is the common interface satisfied by both *pgxpool.Pool and pgx.Tx.
// SQLC-generated code uses this interface for database access.
type DBTX interface {
	Exec(ctx context.Context, sql string, arguments ...any) (pgconn.CommandTag, error)
	Query(ctx context.Context, sql string, args ...any) (pgx.Rows, error)
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
}

// BaseRepository provides shared database helpers for concrete repositories.
type BaseRepository struct {
	txManager *TxManager
}

// NewBaseRepository creates a BaseRepository with the given TxManager.
func NewBaseRepository(txManager *TxManager) BaseRepository {
	return BaseRepository{txManager: txManager}
}

// Querier returns the appropriate DBTX (transaction or pool) from the context.
func (r *BaseRepository) Querier(ctx context.Context) DBTX {
	return r.txManager.Querier(ctx)
}

// HandleError translates pgx errors into domain errors.
func (r *BaseRepository) HandleError(err error) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.ErrNotFound
	}

	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		return domain.ErrConflict
	}

	return fmt.Errorf("database error: %w", err)
}
