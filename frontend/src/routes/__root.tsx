import type { Transport } from '@connectrpc/connect';
import type { QueryClient } from '@tanstack/react-query';
import { createRootRouteWithContext, Outlet } from '@tanstack/react-router';
import { lazy, Suspense } from 'react';
import { RootLayout } from '@/components/layout/root-layout';

export interface RouterContext {
  queryClient: QueryClient;
  transport: Transport;
}

const TanStackRouterDevtools =
  process.env.NODE_ENV === 'production'
    ? () => null
    : lazy(() =>
        import('@tanstack/router-devtools').then((m) => ({
          default: m.TanStackRouterDevtools,
        })),
      );

const ReactQueryDevtools =
  process.env.NODE_ENV === 'production'
    ? () => null
    : lazy(() =>
        import('@tanstack/react-query-devtools').then((m) => ({
          default: m.ReactQueryDevtools,
        })),
      );

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootComponent,
});

function RootComponent() {
  return (
    <>
      <RootLayout>
        <Outlet />
      </RootLayout>
      <Suspense>
        <ReactQueryDevtools buttonPosition="bottom-left" initialIsOpen={false} />
        <TanStackRouterDevtools position="bottom-right" />
      </Suspense>
    </>
  );
}
