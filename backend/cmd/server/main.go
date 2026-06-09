package main

import (
	"context"
	"errors"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/cors"

	"github.com/your-org/your-project/backend/internal/gen/health/v1/healthv1connect"
	"github.com/your-org/your-project/backend/internal/infrastructure/database"
	"github.com/your-org/your-project/backend/internal/interface/handler"
	"github.com/your-org/your-project/backend/internal/interface/interceptor"
	"github.com/your-org/your-project/backend/pkg/config"
	"github.com/your-org/your-project/backend/pkg/logger"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

func main() {
	if err := run(); err != nil {
		os.Exit(1)
	}
}

func run() error {
	cfg := config.Load()
	log := logger.New(cfg.LogLevel)

	ctx := context.Background()

	pool, err := database.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Error("failed to connect to database", "error", err)
		return err
	}
	defer pool.Close()

	healthHandler := handler.NewHealthHandler(pool)

	interceptors := connect.WithInterceptors(
		interceptor.RequestIDInterceptor(),
		interceptor.Recovery(log),
		interceptor.Logging(log),
	)

	mux := http.NewServeMux()
	mux.Handle(healthv1connect.NewHealthServiceHandler(healthHandler, interceptors))

	corsHandler := cors.New(cors.Options{
		AllowedOrigins: cfg.AllowedOrigins,
		AllowedMethods: []string{
			http.MethodGet,
			http.MethodPost,
		},
		AllowedHeaders: []string{
			"Content-Type",
			"Connect-Protocol-Version",
			"Connect-Timeout-Ms",
			"X-Request-Id",
		},
		ExposedHeaders: []string{
			"X-Request-Id",
		},
	}).Handler(mux)

	srv := &http.Server{
		Addr:    ":" + cfg.AppPort,
		Handler: h2c.NewHandler(corsHandler, &http2.Server{}),
	}

	errCh := make(chan error, 1)
	go func() {
		log.Info("server starting", "port", cfg.AppPort)
		errCh <- srv.ListenAndServe()
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	select {
	case <-quit:
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := srv.Shutdown(shutdownCtx); err != nil {
			log.Error("graceful shutdown failed", "error", err)
			return err
		}
		return nil
	case err := <-errCh:
		if err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Error("server error", "error", err)
			return err
		}
		return nil
	}
}
