export function HomePage() {
  return (
    <div>
      <h2 style={{ fontSize: '1.5rem', fontWeight: 600, marginBottom: '1rem' }}>
        Welcome to Your Project
      </h2>
      <p style={{ color: '#6b7280', marginBottom: '1rem' }}>
        Your React application is ready. Start building by editing the files in{' '}
        <code
          style={{ background: '#f3f4f6', padding: '0.125rem 0.375rem', borderRadius: '0.25rem' }}
        >
          src/
        </code>
        .
      </p>
      <ul style={{ color: '#6b7280', lineHeight: 1.8 }}>
        <li>
          Routes are defined in <code>src/routes/</code>
        </li>
        <li>
          Feature pages go in <code>src/features/</code>
        </li>
        <li>
          Shared components go in <code>src/components/</code>
        </li>
        <li>
          API client is configured in <code>src/lib/api/</code>
        </li>
      </ul>
    </div>
  );
}
