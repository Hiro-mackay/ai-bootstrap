package interceptor

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log/slog"
	"runtime/debug"
	"time"

	"connectrpc.com/connect"
)

type requestIDKey struct{}

// RequestID returns the request ID from the context, or empty string if absent.
func RequestID(ctx context.Context) string {
	if id, ok := ctx.Value(requestIDKey{}).(string); ok {
		return id
	}
	return ""
}

// Recovery returns an interceptor that recovers from panics and returns
// a connect.CodeInternal error.
func Recovery(log *slog.Logger) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (resp connect.AnyResponse, err error) {
			defer func() {
				if r := recover(); r != nil {
					log.ErrorContext(ctx, "panic recovered",
						"panic", r,
						"stack", string(debug.Stack()),
						"procedure", req.Spec().Procedure,
					)
					err = connect.NewError(connect.CodeInternal, fmt.Errorf("internal error"))
				}
			}()
			return next(ctx, req)
		}
	}
}

// Logging returns an interceptor that logs procedure name, duration,
// and any error on completion.
func Logging(log *slog.Logger) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			start := time.Now()
			resp, err := next(ctx, req)
			attrs := []any{
				"procedure", req.Spec().Procedure,
				"duration", time.Since(start).String(),
			}
			if rid := RequestID(ctx); rid != "" {
				attrs = append(attrs, "request_id", rid)
			}
			if err != nil {
				attrs = append(attrs, "error", err)
				log.ErrorContext(ctx, "rpc failed", attrs...)
			} else {
				log.InfoContext(ctx, "rpc completed", attrs...)
			}
			return resp, err
		}
	}
}

// RequestIDInterceptor returns an interceptor that propagates or generates
// an X-Request-Id header.
func RequestIDInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			id := req.Header().Get("X-Request-Id")
			if id == "" {
				id = generateID()
			}
			ctx = context.WithValue(ctx, requestIDKey{}, id)
			resp, err := next(ctx, req)
			if resp != nil {
				resp.Header().Set("X-Request-Id", id)
			}
			return resp, err
		}
	}
}

func generateID() string {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "00000000000000000000000000000000"
	}
	return hex.EncodeToString(b)
}
