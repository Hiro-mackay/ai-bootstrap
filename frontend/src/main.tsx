import '@/styles/globals.css';
import { TransportProvider } from '@connectrpc/connect-query';
import { QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider } from '@tanstack/react-router';
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { queryClient, router } from '@/app/router';
import { transport } from '@/lib/api/transport';

const rootElement = document.getElementById('root');
if (!rootElement) throw new Error('Root element not found');

const app = (
  <StrictMode>
    <TransportProvider transport={transport}>
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
      </QueryClientProvider>
    </TransportProvider>
  </StrictMode>
);

createRoot(rootElement).render(app);
