package main

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/cors"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/gen/health/v1/healthv1connect"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/interface/handler"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/interface/interceptor"
	"github.com/Hiro-mackay/ai-bootstrap/backend/pkg/config"
	"github.com/Hiro-mackay/ai-bootstrap/backend/pkg/logger"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

func main() {
	cfg := config.Load()
	log := logger.New(cfg.LogLevel)

	interceptors := connect.WithInterceptors(
		interceptor.RequestIDInterceptor(),
		interceptor.Recovery(log),
		interceptor.Logging(log),
	)

	mux := http.NewServeMux()
	mux.Handle(healthv1connect.NewHealthServiceHandler(&handler.HealthHandler{}, interceptors))

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
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := srv.Shutdown(ctx); err != nil {
			log.Error("graceful shutdown failed", "error", err)
			os.Exit(1)
		}
	case err := <-errCh:
		if err != nil {
			log.Error("server error", "error", err)
			os.Exit(1)
		}
	}
}
