import { createConnectTransport } from '@connectrpc/connect-web';
import { env } from '@/env';

export const transport = createConnectTransport({
  baseUrl: env.BUN_PUBLIC_API_BASE_URL,
});
