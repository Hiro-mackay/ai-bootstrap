import { TransportProvider } from '@connectrpc/connect-query';
import { createConnectTransport } from '@connectrpc/connect-web';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { ReactNode } from 'react';

export function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
      mutations: { retry: false },
    },
  });
}

export function createTestTransport() {
  return createConnectTransport({ baseUrl: 'http://localhost:8080' });
}

export function createWrapper() {
  const client = createTestQueryClient();
  const testTransport = createTestTransport();
  return ({ children }: { children: ReactNode }) => (
    <TransportProvider transport={testTransport}>
      <QueryClientProvider client={client}>{children}</QueryClientProvider>
    </TransportProvider>
  );
}
