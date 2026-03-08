import { useCreateTodo } from '@/features/todo/api/mutations';
import { createTodoSchema } from '@/features/todo/validation';
import { fieldErrorProps, useFormAction } from '@/lib/validation/form-helpers';

export function TodoForm() {
  const createTodo = useCreateTodo();
  const [state, dispatch, isPending] = useFormAction(createTodoSchema, async (data) => {
    await createTodo.mutateAsync(data);
  });

  return (
    <form action={dispatch} className="space-y-3">
      {state.serverError && <p className="text-sm text-red-600">{state.serverError}</p>}
      <div>
        <input
          className="w-full rounded-md border px-3 py-2 text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-neutral-400"
          name="title"
          placeholder="What needs to be done?"
          {...fieldErrorProps(state, 'title')}
        />
        {state.fieldErrors.title && (
          <p className="mt-1 text-xs text-red-600" id="title-error">
            {state.fieldErrors.title}
          </p>
        )}
      </div>
      <div>
        <input
          className="w-full rounded-md border px-3 py-2 text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-neutral-400"
          name="description"
          placeholder="Description (optional)"
          {...fieldErrorProps(state, 'description')}
        />
        {state.fieldErrors.description && (
          <p className="mt-1 text-xs text-red-600" id="description-error">
            {state.fieldErrors.description}
          </p>
        )}
      </div>
      <button
        className="rounded-md bg-neutral-900 px-4 py-2 text-sm font-medium text-white hover:bg-neutral-800 disabled:opacity-50"
        disabled={isPending}
        type="submit"
      >
        {isPending ? 'Adding...' : 'Add Todo'}
      </button>
    </form>
  );
}
