# React Reference Architecture

> Mandatory rules. Deviations require an ADR in docs/decisions/.

## Directory Structure

```
src/
  gen/                              # (gitignored) protobuf generated code
  routeTree.gen.ts                  # (auto-generated) TanStack Router route tree
  app/
    router.tsx              # createRouter, QueryClient, router context
  routes/
    __root.tsx              # Root layout, DevTools, RouterContext definition
    index.tsx               # / route
    {name}.tsx              # Static routes (/about, /login, etc.)
    {name}/
      index.tsx             # Nested index (/posts)
      $paramId.tsx          # Dynamic routes (/posts/:paramId)
  components/
    layout/                 # App shells (root, auth, main)
    ui/                     # Shared UI primitives (shadcn/Radix)
  features/{feature}/
    pages/                  # Page components (one per route)
      {feature}-page.tsx
      __tests__/
    components/             # Feature-scoped UI components
      {component}.tsx
      __tests__/
    api/
      queries.ts            # connect-query useQuery hooks
      mutations.ts          # connect-query useMutation hooks
      __tests__/
    hooks/                  # Feature-scoped custom hooks
    validation.ts           # Feature-level Zod schemas
    error-messages.ts       # Server error -> user message map (if needed)
    types.ts                # Feature-local type definitions
    __tests__/              # Feature-level tests (validation, etc.)
  lib/
    api/
      transport.ts          # Connect transport (single instance)
      queries.ts            # connect-query usage patterns (documentation)
    validation/
      schemas.ts            # Reusable Zod primitives (email, password, etc.)
      form-helpers.ts       # useFormAction, fieldErrorProps, FormState
  stores/
    {name}-store.ts         # Zustand stores (auth, UI, domain-specific)
    __tests__/
  test/
    setup.ts                # @testing-library/jest-dom import
    test-utils.tsx          # createTestQueryClient, createWrapper
  index.html                        # HTML entry point (Bun bundler)
  env.ts                            # Type-safe environment variables (t3-env)
  main.tsx
```

### Key Differences from REST Architecture

- No `lib/errors/` directory -- `ConnectError` from `@connectrpc/connect` replaces custom error hierarchy
- No `lib/api/client.ts` -- `transport.ts` replaces openapi-fetch client
- No `lib/api/errors.ts` -- `ConnectError` used directly
- No manual query key factories -- connect-query auto-manages keys from proto service definitions
- Types generated from protobuf, not OpenAPI

## Feature Rules

### Mandatory

- Components MUST live in `features/{feature}/components/`
- `components/ui/` is ONLY for design system primitives (shadcn/Radix)
- `components/layout/` is ONLY for app shell components (root, auth, main layouts)
- Feature-specific business logic MUST NOT live in `components/`, `lib/`, or `stores/` (these host shared infrastructure and cross-cutting state only)
- No cross-feature internal imports (import only from feature's public files)
- No barrel exports (`index.ts`) -- all imports use direct file paths

### Feature Structure

Every feature MUST have:
- `pages/` -- at least one page component
- `api/queries.ts` -- when feature reads server data
- `api/mutations.ts` -- when feature writes server data

Optional: `components/`, `hooks/`, `validation.ts`, `types.ts`, `error-messages.ts`, `__tests__/`

## Data Layer

### Connect Transport

Single transport instance for all RPC calls.

```typescript
// lib/api/transport.ts
import { createConnectTransport } from '@connectrpc/connect-web';
import { env } from '@/env';

export const transport = createConnectTransport({
  baseUrl: env.BUN_PUBLIC_API_BASE_URL,
});
```

### connect-query (Auto-managed Keys)

connect-query generates query keys from proto service definitions. No manual key factories needed.

Page components that display server data MUST use `useSuspenseQuery` (not `useQuery`). This pairs with the route `loader` pattern to eliminate loading flicker.

```typescript
// features/files/api/queries.ts
import { useSuspenseQuery } from '@connectrpc/connect-query';
import { FileService } from '@/gen/file/v1/file_pb';

// useSuspenseQuery for page-level data (paired with route loader)
export const useFolderContents = (folderId: string) =>
  useSuspenseQuery(FileService.method.listFiles, { folderId });
```

```typescript
// features/auth/api/queries.ts
import { useQuery } from '@connectrpc/connect-query';
import { AuthService } from '@/gen/auth/v1/auth_pb';

// useQuery (non-suspense) for optional/secondary data
export const useMeQuery = () =>
  useQuery(AuthService.method.getMe);
```

Rules:
- `useSuspenseQuery` for primary page data (loader ensures cache is warm before render)
- `useQuery` for optional, secondary, or conditionally-fetched data
- Never use `callUnaryMethod` in queries -- use `createQueryOptions` + `ensureQueryData` for non-hook contexts (see Route Data Loading below)

### Feature Mutations

```typescript
// features/files/api/mutations.ts
import { useMutation } from '@connectrpc/connect-query';
import { useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { FileService } from '@/gen/file/v1/file_pb';
import { createConnectQueryKey } from '@connectrpc/connect-query';

export function useCreateFolderMutation() {
  const queryClient = useQueryClient();
  return useMutation(FileService.method.createFolder, {
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: createConnectQueryKey(FileService.method.listFiles),
      });
      toast.success('Folder created');
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });
}
```

Rules:
- `onSuccess` MUST invalidate related queries
- Use `createConnectQueryKey` for targeted invalidation
- Toast notifications for user-facing mutations (create, update, delete)
- Auth mutations throw errors for form-level display (no toasts)

## Error Handling

Use `ConnectError` directly. No wrapper classes.

```typescript
import { ConnectError, Code } from '@connectrpc/connect';

// In mutation onError:
onError: (error) => {
  if (error instanceof ConnectError) {
    if (error.code === Code.NotFound) {
      // handle not found
    }
    toast.error(error.rawMessage);
  }
}

// Utility (inline where needed, or export from transport.ts):
export function getErrorMessage(error: unknown): string {
  if (error instanceof ConnectError) return error.rawMessage;
  if (error instanceof Error) return error.message;
  return 'An unexpected error occurred';
}
```

## State Management (Zustand)

Zustand for client-only state. TanStack Query (via connect-query) for server state. Never mix the two.

| State Type | Tool | Example |
|-----------|------|---------|
| Server data | connect-query (TanStack Query) | User profile, file list, permissions |
| Auth session | Zustand | Login status, current user |
| UI preferences | Zustand + persist | Sidebar state, view mode, sort order |
| Ephemeral UI | Zustand | Upload progress, multi-select |
| Component-local | useState | Dialog open/close, form input |

### Store Pattern

```typescript
// stores/auth-store.ts
import { create } from 'zustand';

type AuthStatus = 'initializing' | 'authenticated' | 'unauthenticated';

interface AuthUser {
  id: string;
  email: string;
  name: string;
}

export const useAuthStore = create<{
  status: AuthStatus; user: AuthUser | null;
  setUser: (user: AuthUser) => void; clearAuth: () => void;
}>((set) => ({
  status: 'initializing',
  user: null,
  setUser: (user) => set({ status: 'authenticated', user }),
  clearAuth: () => set({ status: 'unauthenticated', user: null }),
}));
```

### Persisted Store

```typescript
// stores/ui-store.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useUIStore = create<{
  sidebarOpen: boolean; viewMode: 'list' | 'grid';
  toggleSidebar: () => void; setViewMode: (mode: 'list' | 'grid') => void;
}>()(
  persist(
    (set) => ({
      sidebarOpen: true, viewMode: 'list',
      toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
      setViewMode: (viewMode) => set({ viewMode }),
    }),
    { name: 'app-ui-settings' },
  ),
);
```

Rules:
- State + Actions in a single `create()` call (no slices)
- `persist` middleware only for user preferences (UI settings)
- Collections: `Map` or `Set` with immutable copy-on-write updates
- Imperative access outside React: `useAuthStore.getState()` (for API middleware, router guards)

## Validation (Zod)

### Shared Primitives

```typescript
// lib/validation/schemas.ts
import * as z from 'zod';

export const emailSchema = z.email('Invalid email address');

export const strongPasswordSchema = z.string()
  .min(8, 'Password must be at least 8 characters')
  .refine((val) => [/[A-Z]/, /[a-z]/, /[0-9]/].filter((r) => r.test(val)).length >= 2,
    { message: 'Use at least 2 of: uppercase, lowercase, number' });

export const nameSchema = z.string().min(1, 'Name is required').max(100);
```

### Feature Schemas (Composed from Primitives)

```typescript
// features/auth/validation.ts
import * as z from 'zod';
import { emailSchema, strongPasswordSchema } from '@/lib/validation/schemas';

export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, 'Password is required'),
});
```

### Form Helpers

```typescript
// lib/validation/form-helpers.ts
import { useActionState } from 'react';
import * as z from 'zod';

export type FormState = { fieldErrors: Record<string, string>; serverError?: string };
export const initialFormState: FormState = { fieldErrors: {} };

export function fieldErrorProps(state: FormState, field: string) {
  if (!state.fieldErrors[field]) return {};
  return { 'aria-invalid': true as const, 'aria-describedby': `${field}-error` };
}

export function validateFormData<T extends z.ZodType>(schema: T, formData: FormData):
  | { success: true; data: z.infer<T> }
  | { success: false; state: FormState } {
  const result = schema.safeParse(Object.fromEntries(formData));
  if (result.success) return { success: true, data: result.data };
  const flat = z.flattenError(result.error);
  const fieldErrors: Record<string, string> = {};
  for (const [key, msgs] of Object.entries(flat.fieldErrors)) {
    if (Array.isArray(msgs) && msgs.length > 0) fieldErrors[key] = msgs[0];
  }
  return { success: false, state: { fieldErrors } };
}

export function useFormAction<S extends z.ZodType>(
  schema: S, onSubmit: (data: z.infer<S>) => Promise<void>,
) {
  return useActionState(async (_prev: FormState, formData: FormData): Promise<FormState> => {
    const result = validateFormData(schema, formData);
    if (!result.success) return result.state;
    try { await onSubmit(result.data); return initialFormState; }
    catch (err) {
      return { fieldErrors: {}, serverError: err instanceof Error ? err.message : 'An error occurred' };
    }
  }, initialFormState);
}
```

Usage: `<form action={dispatch}>` with native form submission (React 19 pattern).

## Routing & Layouts

File-based routing via `@tanstack/router-cli`. Route files live in `src/routes/`.

### Router Setup

```typescript
// app/router.tsx
import { QueryClient } from '@tanstack/react-query';
import { createRouter } from '@tanstack/react-router';
import { transport } from '@/lib/api/transport';
import { routeTree } from '@/routeTree.gen';

export const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 60_000, retry: 1 } },
});

export const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  defaultPreloadStaleTime: 0,
  context: { queryClient, transport },
});

declare module '@tanstack/react-router' {
  interface Register { router: typeof router; }
}
```

### Provider Nesting (main.tsx)

```typescript
// Providers wrap RouterProvider from the OUTSIDE
<TransportProvider transport={transport}>
  <QueryClientProvider client={queryClient}>
    <RouterProvider router={router} />
  </QueryClientProvider>
</TransportProvider>
```

### Root Route

```typescript
// routes/__root.tsx
import { createRootRouteWithContext, Outlet } from '@tanstack/react-router';
import type { QueryClient } from '@tanstack/react-query';
import type { Transport } from '@connectrpc/connect';

export interface RouterContext {
  queryClient: QueryClient;
  transport: Transport;
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootComponent,
});
```

### Route Data Loading (CRITICAL)

Every route that displays server data MUST define a `loader` using `createQueryOptions` + `ensureQueryData`. This prefetches data into TanStack Query cache before the component renders, eliminating loading flicker.

```typescript
// routes/todos/index.tsx -- list route (no params)
import { createQueryOptions } from '@connectrpc/connect-query';
import { createFileRoute } from '@tanstack/react-router';
import { Suspense } from 'react';
import { TodoListPage } from '@/features/todo/pages/todo-list-page';
import { TodoService } from '@/gen/todo/v1/todo_pb';

export const Route = createFileRoute('/todos/')({
  loader: ({ context: { queryClient, transport } }) =>
    queryClient.ensureQueryData(
      createQueryOptions(TodoService.method.listTodos, {}, { transport }),
    ),
  component: TodosRoute,
});

function TodosRoute() {
  return (
    <Suspense fallback={<p className="text-sm text-muted-foreground">Loading...</p>}>
      <TodoListPage />
    </Suspense>
  );
}
```

```typescript
// routes/posts/$postId.tsx -- detail route (with params)
import { createQueryOptions } from '@connectrpc/connect-query';
import { createFileRoute } from '@tanstack/react-router';
import { Suspense } from 'react';
import { PostDetailPage } from '@/features/post/pages/post-detail-page';
import { PostService } from '@/gen/post/v1/post_pb';

export const Route = createFileRoute('/posts/$postId')({
  loader: ({ context: { queryClient, transport }, params }) =>
    queryClient.ensureQueryData(
      createQueryOptions(PostService.method.getPost, { id: params.postId }, { transport }),
    ),
  component: () => (
    <Suspense fallback={<p className="text-sm text-muted-foreground">Loading...</p>}>
      <PostDetailPage />
    </Suspense>
  ),
});
```

Rules:
- `createQueryOptions` generates the same query key as `useSuspenseQuery` -- cache is shared automatically
- `ensureQueryData` returns cached data if fresh, fetches if stale or missing
- `<Suspense>` wraps the page component as a safety net (cache miss on client navigation)
- `defaultPreload: 'intent'` in router config triggers the loader on link hover, making navigation near-instant
- NEVER use `callUnaryMethod` or manual `queryKey` in loaders -- `createQueryOptions` ensures key consistency with hooks

### Protected Routes (auth guard)

```typescript
// routes/_authenticated/route.tsx (pathless layout)
import { createFileRoute, redirect } from '@tanstack/react-router';

export const Route = createFileRoute('/_authenticated')({
  beforeLoad: ({ location }) => {
    if (useAuthStore.getState().status === 'unauthenticated') {
      throw redirect({ to: '/login', search: { redirect: location.href } });
    }
  },
});
```

### Route Generation

```bash
bun run routes:generate   # One-time generation
bun run routes:watch      # Watch mode (run alongside dev when adding routes)
```

Generated `routeTree.gen.ts` is auto-maintained -- do not edit manually.

## Component Patterns

### Page Components

Page components are route entry points. They use `useSuspenseQuery` for primary data (loader guarantees cache is warm). No manual loading/error branching needed -- Suspense and Error Boundaries handle it at the route level.

```typescript
// features/files/pages/file-browser-page.tsx
export function FileBrowserPage() {
  const params = useParams({ strict: false });
  const folderId = (params as { folderId?: string }).folderId ?? null;
  const { viewMode } = useUIStore();
  const [createFolderOpen, setCreateFolderOpen] = useState(false);

  // useSuspenseQuery -- data is guaranteed by route loader, no loading/error checks needed
  const { data } = useFolderContents(folderId);

  return (
    <div>
      <FileBreadcrumb folderId={folderId} />
      <FileToolbar onCreateFolder={() => setCreateFolderOpen(true)} />
      {viewMode === 'grid' ? <FolderGrid items={data} /> : <FolderList items={data} />}
      <CreateFolderDialog open={createFolderOpen} onOpenChange={setCreateFolderOpen} />
    </div>
  );
}
```

### Form Pages

```typescript
// features/auth/pages/login-page.tsx
export function LoginPage() {
  const navigate = useNavigate();
  const search = useSearch({ strict: false }) as { redirect?: string };
  const { mutateAsync } = useLoginMutation();

  const [state, dispatch, isPending] = useFormAction(loginSchema, async (data) => {
    await mutateAsync(data);
    navigate({ to: search.redirect ?? '/files' });
  });

  return (
    <form action={dispatch}>
      {state.serverError && <Alert variant="destructive">{state.serverError}</Alert>}
      <Input name="email" {...fieldErrorProps(state, 'email')} />
      <FieldError message={state.fieldErrors.email} id="email-error" />
      <Input name="password" type="password" {...fieldErrorProps(state, 'password')} />
      <FieldError message={state.fieldErrors.password} id="password-error" />
      <Button type="submit" disabled={isPending}>{isPending ? 'Logging in...' : 'Log in'}</Button>
    </form>
  );
}
```

Rules:
- One page component per route
- `useSuspenseQuery` for primary data -- no `isLoading`/`error` branching in the component
- Suspense boundary in the route file wraps the page component (fallback for cache miss)
- Dialog state is local `useState`, not global store
- No business logic in page components

## Testing

### Test Utilities

```typescript
// test/test-utils.tsx
import { createConnectTransport } from '@connectrpc/connect-web';
import { TransportProvider } from '@connectrpc/connect-query';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { ReactNode } from 'react';

export function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  });
}

export function createTestTransport() {
  return createConnectTransport({ baseUrl: 'http://localhost:8080' });
}

export function createWrapper() {
  const client = createTestQueryClient();
  const transport = createTestTransport();
  return ({ children }: { children: ReactNode }) => (
    <TransportProvider transport={transport}>
      <QueryClientProvider client={client}>{children}</QueryClientProvider>
    </TransportProvider>
  );
}
```

### API Hook Tests

```typescript
// features/auth/api/__tests__/mutations.test.ts
import { createRouterTransport } from '@connectrpc/connect';
import { AuthService } from '@/gen/auth/v1/auth_pb';

const mockTransport = createRouterTransport(({ service }) => {
  service(AuthService, {
    login: () => ({ user: { id: '1', email: 'a@b.com', name: 'Test' } }),
  });
});

// Use mockTransport in test wrapper
```

### Store Tests

```typescript
// stores/__tests__/auth-store.test.ts -- no wrapper needed, plain object testing
beforeEach(() => useAuthStore.setState({ status: 'initializing', user: null }));

it('should set authenticated status when setUser called', () => {
  useAuthStore.getState().setUser(mockUser);
  expect(useAuthStore.getState().status).toBe('authenticated');
});
```

Rules:
- Use `createRouterTransport` from `@connectrpc/connect` for mocking Connect services
- Reset Zustand stores in `beforeEach` via `setState()`
- Use `createWrapper()` for hooks that need TransportProvider + QueryClientProvider
- Store tests need no wrapper (plain object testing)

## Anti-Patterns (Prohibited)

| Anti-Pattern | Why | Correct Approach |
|---|---|---|
| Barrel exports (index.ts) | Circular deps, broken tree-shaking | Direct file path imports |
| SWR, raw useEffect + fetch | Inconsistent cache/loading/error | connect-query for all server state |
| Manual query key factories | connect-query auto-manages keys | Use connect-query's built-in key management |
| Custom error class hierarchy | Duplicates `ConnectError` | Use `ConnectError` and `Code` directly |
| Manual API type definitions | Type drift from backend | Protobuf generates types via `buf generate` |
| Server state in Zustand | No cache invalidation, stale data | connect-query for server state, Zustand for client state |
| Feature-specific components in `components/ui/` | Pollutes shared primitives | Feature components in `features/{feature}/components/` |
| Mutation without query invalidation | Stale data shown to user | Always invalidate related queries in onSuccess |
| Route without `loader` for server data | Loading flicker, client-side waterfall | `loader` + `createQueryOptions` + `ensureQueryData` |
| `useQuery` for primary page data | Manual loading/error branching, no Suspense | `useSuspenseQuery` paired with route `loader` |
| `callUnaryMethod` or manual `queryKey` in loader | Key mismatch with hooks, cache miss | `createQueryOptions` for consistent keys |
| Business logic in page components | Hard to test, violates SRP | Extract to hooks, validation, or component logic |
| Manual form validation | Inconsistent, no schema reuse | Zod schemas + `useFormAction` |
| Global store for dialog open/close | Over-engineering, unnecessary coupling | Local `useState` in page component |
| Cross-feature internal imports | Tight coupling between features | Import from feature's public API files only |
