package database

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type ctxKey struct{}

// TxManager manages database transactions with context propagation.
type TxManager struct {
	pool *pgxpool.Pool
}

// NewTxManager creates a new TxManager backed by the given pool.
func NewTxManager(pool *pgxpool.Pool) *TxManager {
	return &TxManager{pool: pool}
}

// WithTransaction runs fn inside a database transaction. If fn returns an
// error the transaction is rolled back; otherwise it is committed. The
// transaction is stored in the context so that GetQuerier can retrieve it.
func (m *TxManager) WithTransaction(ctx context.Context, fn func(ctx context.Context) error) error {
	tx, err := m.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("database: begin tx: %w", err)
	}

	txCtx := context.WithValue(ctx, ctxKey{}, tx)

	if err := fn(txCtx); err != nil {
		if rbErr := tx.Rollback(ctx); rbErr != nil {
			return fmt.Errorf("database: rollback failed (%v) after: %w", rbErr, err)
		}
		return err
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("database: commit tx: %w", err)
	}

	return nil
}

// Querier returns the transaction from ctx if present, otherwise the pool.
// Both *pgxpool.Pool and pgx.Tx satisfy the DBTX interface.
func (m *TxManager) Querier(ctx context.Context) DBTX {
	if tx, ok := ctx.Value(ctxKey{}).(pgx.Tx); ok {
		return tx
	}
	return m.pool
}
