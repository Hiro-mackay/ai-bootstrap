import { useActionState } from 'react';
import * as z from 'zod';

export type FormState<TFields extends string = string> = {
  fieldErrors: Partial<Record<TFields, string>>;
  serverError?: string;
};

export function initialFormState<TFields extends string = string>(): FormState<TFields> {
  return { fieldErrors: {} };
}

export function fieldErrorProps<TFields extends string>(state: FormState<TFields>, field: TFields) {
  if (!state.fieldErrors[field]) return {};
  return {
    'aria-invalid': true as const,
    'aria-describedby': `${field}-error`,
  };
}

export function validateFormData<T extends z.ZodType>(
  schema: T,
  formData: FormData,
): { success: true; data: z.infer<T> } | { success: false; state: FormState<string> } {
  const raw = Object.fromEntries(formData);
  const result = schema.safeParse(raw);

  if (result.success) {
    return { success: true, data: result.data };
  }

  const flat = z.flattenError(result.error);
  const fieldErrors: Record<string, string> = {};
  for (const [key, messages] of Object.entries(flat.fieldErrors)) {
    if (Array.isArray(messages) && messages.length > 0) {
      fieldErrors[key] = messages[0];
    }
  }

  return { success: false, state: { fieldErrors } };
}

export function useFormAction<S extends z.ZodObject<z.ZodRawShape>>(
  schema: S,
  onSubmit: (data: z.infer<S>) => Promise<void>,
): [FormState<Extract<keyof z.infer<S>, string>>, (payload: FormData) => void, boolean] {
  type Fields = Extract<keyof z.infer<S>, string>;
  return useActionState(
    async (_prev: FormState<Fields>, formData: FormData): Promise<FormState<Fields>> => {
      const result = validateFormData(schema, formData);
      if (!result.success) return result.state as FormState<Fields>;
      try {
        await onSubmit(result.data);
        return initialFormState<Fields>();
      } catch (err) {
        return {
          fieldErrors: {},
          serverError: err instanceof Error ? err.message : 'An error occurred',
        };
      }
    },
    initialFormState<Fields>(),
  );
}
