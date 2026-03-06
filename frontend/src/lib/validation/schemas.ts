import * as z from 'zod';

// TODO: Adjust to match your ID format (UUID=36, ULID=26, ObjectId=24, nanoid=21)
export const idSchema = z.string().min(1);

export const emailSchema = z.email('Invalid email address');

export const strongPasswordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .refine((val) => [/[A-Z]/, /[a-z]/, /[0-9]/].filter((r) => r.test(val)).length >= 2, {
    message: 'Use at least 2 of: uppercase, lowercase, number',
  });

export const nameSchema = z.string().min(1, 'Name is required').max(100);

export const paginationSchema = z.object({
  page: z.number().int().positive().default(1),
  limit: z.number().int().positive().default(10),
});

export type PaginationSchema = z.infer<typeof paginationSchema>;
