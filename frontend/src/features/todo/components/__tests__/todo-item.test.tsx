import { describe, expect, it } from 'bun:test';
import { render, screen } from '@testing-library/react';
import { TodoItem } from '@/features/todo/components/todo-item';
import { TodoStatus } from '@/gen/todo/v1/todo_pb';
import { createWrapper } from '@/test/test-utils';

describe('TodoItem', () => {
  it('should render title and description', () => {
    const Wrapper = createWrapper();
    render(
      <Wrapper>
        <TodoItem
          description="Test description"
          id="1"
          status={TodoStatus.PENDING}
          title="Test Todo"
        />
      </Wrapper>,
    );
    expect(screen.getByText('Test Todo')).toBeInTheDocument();
    expect(screen.getByText('Test description')).toBeInTheDocument();
  });

  it('should render status badge', () => {
    const Wrapper = createWrapper();
    render(
      <Wrapper>
        <TodoItem description="" id="1" status={TodoStatus.COMPLETED} title="Test Todo" />
      </Wrapper>,
    );
    expect(screen.getByText('completed')).toBeInTheDocument();
  });

  it('should show completed state for completed todos', () => {
    const Wrapper = createWrapper();
    render(
      <Wrapper>
        <TodoItem description="" id="1" status={TodoStatus.COMPLETED} title="Done Todo" />
      </Wrapper>,
    );
    expect(screen.getByRole('button', { name: 'Mark as pending' })).toBeInTheDocument();
  });
});
