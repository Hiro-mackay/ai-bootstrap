package config

import (
	"os"
	"strings"
)

type Config struct {
	AppPort        string
	LogLevel       string
	AllowedOrigins []string
	DatabaseURL    string
}

func Load() *Config {
	return &Config{
		AppPort:        getEnv("APP_PORT", "8080"),
		LogLevel:       getEnv("LOG_LEVEL", "info"),
		AllowedOrigins: parseOrigins(getEnv("ALLOWED_ORIGINS", "http://localhost:3000")),
		DatabaseURL:    getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/app_dev?sslmode=disable"),
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func parseOrigins(s string) []string {
	parts := strings.Split(s, ",")
	origins := make([]string, 0, len(parts))
	for _, p := range parts {
		if trimmed := strings.TrimSpace(p); trimmed != "" {
			origins = append(origins, trimmed)
		}
	}
	return origins
}
