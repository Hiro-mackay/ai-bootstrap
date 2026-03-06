import { createEnv } from '@t3-oss/env-core';
import { z } from 'zod';

export const env = createEnv({
  clientPrefix: 'BUN_PUBLIC_',
  client: {
    BUN_PUBLIC_API_BASE_URL: z.string().min(1),
  },
  runtimeEnv: {
    BUN_PUBLIC_API_BASE_URL: process.env.BUN_PUBLIC_API_BASE_URL,
  },
  emptyStringAsUndefined: true,
});
