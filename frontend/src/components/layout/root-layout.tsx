import { Link } from '@tanstack/react-router';
import type { ReactNode } from 'react';

interface RootLayoutProps {
  children: ReactNode;
}

export function RootLayout({ children }: RootLayoutProps) {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="border-b px-6 py-4">
        <nav className="flex items-center gap-6">
          <h1 className="text-lg font-semibold">Your Project</h1>
          <div className="flex gap-4">
            <Link
              className="text-sm text-muted-foreground hover:text-foreground [&.active]:font-medium [&.active]:text-foreground"
              to="/"
            >
              Home
            </Link>
          </div>
        </nav>
      </header>
      <main className="p-6">{children}</main>
    </div>
  );
}
