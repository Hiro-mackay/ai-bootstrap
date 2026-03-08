import { useDeleteTodo, useUpdateTodo } from '@/features/todo/api/mutations';
import { TodoStatus } from '@/gen/todo/v1/todo_pb';
import { cn } from '@/lib/utils';

interface TodoItemProps {
  id: string;
  title: string;
  description: string;
  status: TodoStatus;
}

const STATUS_LABEL: Record<TodoStatus, string> = {
  [TodoStatus.UNSPECIFIED]: 'unknown',
  [TodoStatus.PENDING]: 'pending',
  [TodoStatus.COMPLETED]: 'completed',
};

export function TodoItem({ id, title, description, status }: TodoItemProps) {
  const updateTodo = useUpdateTodo();
  const deleteTodo = useDeleteTodo();
  const isCompleted = status === TodoStatus.COMPLETED;

  const handleToggle = () => {
    updateTodo.mutate({
      id,
      status: isCompleted ? TodoStatus.PENDING : TodoStatus.COMPLETED,
    });
  };

  const handleDelete = () => {
    deleteTodo.mutate({ id });
  };

  return (
    <div className="flex items-start gap-3 rounded-lg border p-4">
      <button
        aria-label={isCompleted ? 'Mark as pending' : 'Mark as completed'}
        className={cn(
          'mt-0.5 h-5 w-5 shrink-0 rounded-full border-2',
          isCompleted ? 'border-green-500 bg-green-500' : 'border-neutral-300',
        )}
        onClick={handleToggle}
        type="button"
      />
      <div className="min-w-0 flex-1">
        <p className={cn('font-medium', isCompleted && 'text-muted-foreground line-through')}>
          {title}
        </p>
        {description && <p className="mt-1 text-sm text-muted-foreground">{description}</p>}
        <span
          className={cn(
            'mt-2 inline-block rounded-full px-2 py-0.5 text-xs font-medium',
            isCompleted ? 'bg-green-100 text-green-700' : 'bg-neutral-100 text-neutral-700',
          )}
        >
          {STATUS_LABEL[status]}
        </span>
      </div>
      <button
        aria-label="Delete todo"
        className="shrink-0 text-sm text-muted-foreground hover:text-red-600"
        onClick={handleDelete}
        type="button"
      >
        Delete
      </button>
    </div>
  );
}
