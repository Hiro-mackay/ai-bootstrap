import { createConnectQueryKey, useMutation } from '@connectrpc/connect-query';
import { useQueryClient } from '@tanstack/react-query';
import { TodoService } from '@/gen/todo/v1/todo_pb';

const listTodosKey = createConnectQueryKey({
  schema: TodoService.method.listTodos,
  cardinality: undefined,
});

export function useCreateTodo() {
  const queryClient = useQueryClient();
  return useMutation(TodoService.method.createTodo, {
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: listTodosKey });
    },
  });
}

export function useUpdateTodo() {
  const queryClient = useQueryClient();
  return useMutation(TodoService.method.updateTodo, {
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: listTodosKey });
    },
  });
}

export function useDeleteTodo() {
  const queryClient = useQueryClient();
  return useMutation(TodoService.method.deleteTodo, {
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: listTodosKey });
    },
  });
}
