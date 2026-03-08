import { describe, expect, it } from 'bun:test';
import { render, screen } from '@testing-library/react';
import { HomePage } from '@/features/home/pages/home-page';

describe('HomePage', () => {
  it('should render welcome heading', () => {
    render(<HomePage />);
    expect(screen.getByText('Welcome to Your Project')).toBeInTheDocument();
  });
});
