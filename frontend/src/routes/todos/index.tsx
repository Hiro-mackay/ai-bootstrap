import { createQueryOptions } from '@connectrpc/connect-query';
import { createFileRoute } from '@tanstack/react-router';
import { Suspense } from 'react';
import { TodoListPage } from '@/features/todo/pages/todo-list-page';
import { TodoService } from '@/gen/todo/v1/todo_pb';

function TodosRoute() {
  return (
    <Suspense fallback={<p className="text-sm text-muted-foreground">Loading...</p>}>
      <TodoListPage />
    </Suspense>
  );
}

export const Route = createFileRoute('/todos/')({
  loader: ({ context: { queryClient, transport } }) =>
    queryClient.ensureQueryData(
      createQueryOptions(TodoService.method.listTodos, {}, { transport }),
    ),
  component: TodosRoute,
});
