// connect-query auto-manages query keys from proto service definitions.
// No manual key factories needed.
//
// Usage pattern:
//
// import { useQuery } from '@connectrpc/connect-query';
// import { HealthService } from '@/gen/health/v1/health_pb';
//
// export const useHealthCheck = () =>
//   useQuery(HealthService.method.check);
