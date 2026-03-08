import { createFileRoute } from '@tanstack/react-router';
import { Suspense } from 'react';
import { listTodosQueryOptions } from '@/features/todo/api/queries';
import { TodoListPage } from '@/features/todo/pages/todo-list-page';

function TodosRoute() {
  return (
    <Suspense fallback={<p className="text-sm text-muted-foreground">Loading...</p>}>
      <TodoListPage />
    </Suspense>
  );
}

export const Route = createFileRoute('/todos/')({
  loader: ({ context: { queryClient, transport } }) =>
    queryClient.prefetchQuery(listTodosQueryOptions(transport)),
  component: TodosRoute,
});
