import { useActionState } from 'react';
import * as z from 'zod';

export type FormState = {
  fieldErrors: Record<string, string>;
  serverError?: string;
};

export const initialFormState: FormState = { fieldErrors: {} };

export function fieldErrorProps(state: FormState, field: string) {
  if (!state.fieldErrors[field]) return {};
  return {
    'aria-invalid': true as const,
    'aria-describedby': `${field}-error`,
  };
}

export function validateFormData<T extends z.ZodType>(
  schema: T,
  formData: FormData,
): { success: true; data: z.infer<T> } | { success: false; state: FormState } {
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

export function useFormAction<S extends z.ZodType>(
  schema: S,
  onSubmit: (data: z.infer<S>) => Promise<void>,
) {
  return useActionState(async (_prev: FormState, formData: FormData): Promise<FormState> => {
    const result = validateFormData(schema, formData);
    if (!result.success) return result.state;
    try {
      await onSubmit(result.data);
      return initialFormState;
    } catch (err) {
      return {
        fieldErrors: {},
        serverError: err instanceof Error ? err.message : 'An error occurred',
      };
    }
  }, initialFormState);
}
