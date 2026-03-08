package repository

import "context"

// TransactionManager abstracts transaction handling so use cases
// can coordinate cross-entity operations without infrastructure coupling.
type TransactionManager interface {
	WithTransaction(ctx context.Context, fn func(ctx context.Context) error) error
}
