import createClient from 'openapi-fetch';
import { env } from '@/env';

// TODO: Generate types from OpenAPI spec
// import type { paths } from '@/lib/api/schema';
// export const api = createClient<paths>({ baseUrl: env.VITE_API_BASE_URL });

// TODO: Wire OpenAPI generated types for compile-time API contract
export const api = createClient({
  baseUrl: env.VITE_API_BASE_URL,
});
