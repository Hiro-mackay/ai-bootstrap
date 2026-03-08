import { useTodoList } from '@/features/todo/api/queries';
import { TodoForm } from '@/features/todo/components/todo-form';
import { TodoItem } from '@/features/todo/components/todo-item';

export function TodoListPage() {
  const { data } = useTodoList();

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <h2 className="text-2xl font-semibold">Todos</h2>
      <TodoForm />
      {data.todos.length > 0 ? (
        <div className="space-y-2">
          {data.todos.map((todo) => (
            <TodoItem
              description={todo.description}
              id={todo.id}
              key={todo.id}
              status={todo.status}
              title={todo.title}
            />
          ))}
        </div>
      ) : (
        <p className="text-sm text-muted-foreground">No todos yet. Create one above!</p>
      )}
    </div>
  );
}
