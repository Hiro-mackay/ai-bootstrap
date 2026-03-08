import type { Transport } from '@connectrpc/connect';
import { createQueryOptions, useTransport } from '@connectrpc/connect-query';
import { useSuspenseQuery, useQuery } from '@tanstack/react-query';
import { TodoService } from '@/gen/todo/v1/todo_pb';

export const listTodosQueryOptions = (transport: Transport) =>
  createQueryOptions(TodoService.method.listTodos, {}, { transport });

export const getTodoQueryOptions = (id: string, transport: Transport) =>
  createQueryOptions(TodoService.method.getTodo, { id }, { transport });

export const useTodoList = () => {
  const transport = useTransport();
  return useSuspenseQuery(listTodosQueryOptions(transport));
};

export const useTodo = (id: string) => {
  const transport = useTransport();
  return useQuery(getTodoQueryOptions(id, transport));
};
