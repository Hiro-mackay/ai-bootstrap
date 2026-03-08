import { describe, expect, it } from 'bun:test';
import { createRouterTransport } from '@connectrpc/connect';
import { renderHook, waitFor } from '@testing-library/react';
import { useTodoList } from '@/features/todo/api/queries';
import { TodoService, TodoStatus } from '@/gen/todo/v1/todo_pb';
import { createWrapper } from '@/test/test-utils';

const mockTransport = createRouterTransport(({ service }) => {
  service(TodoService, {
    listTodos: () => ({
      todos: [
        {
          id: '1',
          title: 'Test Todo',
          description: 'desc',
          status: TodoStatus.PENDING,
        },
      ],
    }),
  });
});

describe('useTodoList', () => {
  it('should fetch todo list', async () => {
    const { result } = renderHook(() => useTodoList(), { wrapper: createWrapper(mockTransport) });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.todos).toHaveLength(1);
    expect(result.current.data?.todos[0]?.title).toBe('Test Todo');
  });
});
