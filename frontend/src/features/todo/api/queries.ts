import type { Transport } from '@connectrpc/connect';
import { createQueryOptions, useQuery, useSuspenseQuery } from '@connectrpc/connect-query';
import { TodoService } from '@/gen/todo/v1/todo_pb';

export const listTodosQueryOptions = (transport: Transport) =>
  createQueryOptions(TodoService.method.listTodos, {}, { transport });

export const useTodoList = () => useSuspenseQuery(TodoService.method.listTodos);

export const useTodo = (id: string) => useQuery(TodoService.method.getTodo, { id });
