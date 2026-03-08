import { useQuery, useSuspenseQuery } from '@connectrpc/connect-query';
import { TodoService } from '@/gen/todo/v1/todo_pb';

export const useTodoList = () => useSuspenseQuery(TodoService.method.listTodos);

export const useTodo = (id: string) => useQuery(TodoService.method.getTodo, { id });
