export function HomePage() {
  return (
    <div>
      <h2 className="mb-4 text-2xl font-semibold">Welcome to Your Project</h2>
      <p className="mb-4 text-muted-foreground">
        Your React application is ready. Start building by editing the files in{' '}
        <code className="rounded bg-neutral-100 px-1.5 py-0.5 text-sm">src/</code>.
      </p>
      <ul className="list-inside list-disc leading-relaxed text-muted-foreground">
        <li>
          Routes are defined in <code className="text-sm">src/routes/</code>
        </li>
        <li>
          Feature pages go in <code className="text-sm">src/features/</code>
        </li>
        <li>
          Shared components go in <code className="text-sm">src/components/</code>
        </li>
        <li>
          API client is configured in <code className="text-sm">src/lib/api/</code>
        </li>
      </ul>
    </div>
  );
}
