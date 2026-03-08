import { MutationCache, QueryClient } from '@tanstack/react-query';
import { createRouter } from '@tanstack/react-router';
import { transport } from '@/lib/api/transport';
import { routeTree } from '@/routeTree.gen';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60_000,
      retry: 1,
    },
  },
  mutationCache: new MutationCache({
    onError: (_error) => {
      // Global mutation error handler
      // Wire up a toast notification here (e.g. sonner, react-hot-toast)
    },
  }),
});

export const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  defaultPreloadStaleTime: 0,
  context: {
    queryClient,
    transport,
  },
});

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
