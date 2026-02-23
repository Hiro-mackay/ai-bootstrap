# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | Yes                |

Update this table as your project evolves to reflect which versions
receive security patches.

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability,
please report it responsibly.

### How to Report

1. **Do NOT open a public issue.** Security vulnerabilities must be
   reported privately.
2. Send an email to: **[SECURITY_EMAIL]**
3. Include the following in your report:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within
  48 hours.
- **Assessment**: We will assess the vulnerability and determine its
  severity within 5 business days.
- **Resolution**: We aim to release a fix for critical vulnerabilities
  within 14 days of confirmation.
- **Disclosure**: We will coordinate public disclosure with you after
  the fix is released.

## Security Update Policy

- Critical vulnerabilities: patched and released as soon as possible
- High severity: included in the next scheduled release
- Medium/Low severity: addressed in regular maintenance cycles

## Security Best Practices

This project follows these security practices:

- **No hardcoded secrets**: All secrets use environment variables
- **Dependency scanning**: Automated checks for known vulnerabilities
- **Pre-commit hooks**: Secret detection prevents accidental commits
- **Least privilege**: Minimal permissions for all service accounts

## Responsible Disclosure

We support responsible disclosure. If you follow the reporting process
above, we commit to:

- Not pursuing legal action against good-faith security researchers
- Working with you to understand and resolve the issue
- Crediting you in the security advisory (unless you prefer anonymity)

## Contact

- Security reports: **[SECURITY_EMAIL]**
- General questions: Open a GitHub Discussion
