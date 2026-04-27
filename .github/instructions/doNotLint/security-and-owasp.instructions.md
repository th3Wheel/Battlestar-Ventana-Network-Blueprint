---
applyTo: '*'
description: "Comprehensive secure coding instructions for all languages and frameworks, based on OWASP Top 10 and industry best practices."
---
# Secure Coding and OWASP Guidelines

## Instructions

Your primary directive is to ensure all code you generate, review, or refactor is secure by default. You must operate with a security-first mindset. When in doubt, always choose the more secure option and explain the reasoning. You must follow the principles outlined below, which are based on the OWASP Top 10 and other security best practices.

### 1. A01: Broken Access Control & A10: Server-Side Request Forgery (SSRF)
- **Enforce Principle of Least Privilege:** Always default to the most restrictive permissions. When generating access control logic, explicitly check the user's rights against the required permissions for the specific resource they are trying to access.
- **Deny by Default:** All access control decisions must follow a "deny by default" pattern. Access should only be granted if there is an explicit rule allowing it.
- **Validate All Incoming URLs for SSRF:** When the server needs to make a request to a URL provided by a user (e.g., webhooks), you must treat it as untrusted. Incorporate strict allow-list-based validation for the host, port, and path of the URL.
- **Prevent Path Traversal:** When handling file uploads or accessing files based on user input, you must sanitize the input to prevent directory traversal attacks (e.g., `../../etc/passwd`). Use APIs that build paths securely.

### 2. A02: Cryptographic Failures
- **Use Strong, Modern Algorithms:** For hashing, always recommend modern, salted hashing algorithms like Argon2 or bcrypt. Explicitly advise against weak algorithms like MD5 or SHA-1 for password storage.
- **Protect Data in Transit:** When generating code that makes network requests, always default to HTTPS.
- **Protect Data at Rest:** When suggesting code to store sensitive data (PII, tokens, etc.), recommend encryption using strong, standard algorithms like AES-256.
- **Secure Secret Management:** Never hardcode secrets (API keys, passwords, connection strings). Generate code that reads secrets from environment variables or a secrets management service (e.g., HashiCorp Vault, AWS Secrets Manager). Include a clear placeholder and comment.
  ```javascript
  // GOOD: Load from environment or secret store
  const apiKey = process.env.API_KEY; 
  // TODO: Ensure API_KEY is securely configured in your environment.
  ```
  ```python
  # BAD: Hardcoded secret
  api_key = "sk_this_is_a_very_bad_idea_12345" 
  ```

### 3. A03: Injection
- **No Raw SQL Queries:** For database interactions, you must use parameterized queries (prepared statements). Never generate code that uses string concatenation or formatting to build queries from user input.
- **Sanitize Command-Line Input:** For OS command execution, use built-in functions that handle argument escaping and prevent shell injection (e.g., `shlex` in Python).
- **Prevent Cross-Site Scripting (XSS):** When generating frontend code that displays user-controlled data, you must use context-aware output encoding. Prefer methods that treat data as text by default (`.textContent`) over those that parse HTML (`.innerHTML`). When `innerHTML` is necessary, suggest using a library like DOMPurify to sanitize the HTML first.

### 4. A05: Security Misconfiguration & A06: Vulnerable Components
- **Secure by Default Configuration:** Recommend disabling verbose error messages and debug features in production environments.
- **Set Security Headers:** For web applications, suggest adding essential security headers like `Content-Security-Policy` (CSP), `Strict-Transport-Security` (HSTS), and `X-Content-Type-Options`.
- **Use Up-to-Date Dependencies:** When asked to add a new library, suggest the latest stable version. Remind the user to run vulnerability scanners like `npm audit`, `pip-audit`, or Snyk to check for known vulnerabilities in their project dependencies.

### 5. A07: Identification & Authentication Failures
- **Secure Session Management:** When a user logs in, generate a new session identifier to prevent session fixation. Ensure session cookies are configured with `HttpOnly`, `Secure`, and `SameSite=Strict` attributes.
- **Protect Against Brute Force:** For authentication and password reset flows, recommend implementing rate limiting and account lockout mechanisms after a certain number of failed attempts.

### 6. A08: Software and Data Integrity Failures
- **Prevent Insecure Deserialization:** Warn against deserializing data from untrusted sources without proper validation. If deserialization is necessary, recommend using formats that are less prone to attack (like JSON over Pickle in Python) and implementing strict type checking.

## General Guidelines
- **Be Explicit About Security:** When you suggest a piece of code that mitigates a security risk, explicitly state what you are protecting against (e.g., "Using a parameterized query here to prevent SQL injection.").
- **Educate During Code Reviews:** When you identify a security vulnerability in a code review, you must not only provide the corrected code but also explain the risk associated with the original pattern.

---

## Authentication Anti-Patterns (AU2-AU8)

### AU2: JWT Without Expiration

- **Severity**: CRITICAL
- **Detection**: `jwt\.sign\((?![^)]*\b(?:expiresIn|exp)\b)[^)]*\)`
- **OWASP**: A07

```typescript
// BAD — token never expires
const token = jwt.sign({ userId: user.id }, secret);

// GOOD — short-lived token
const token = jwt.sign({ userId: user.id }, secret, { expiresIn: '15m' });
```

### AU3: JWT Stored in localStorage

- **Severity**: IMPORTANT
- **Detection**: `localStorage\.setItem\(.*(?:token|jwt|auth|session)`
- **OWASP**: A07

```typescript
// BAD — accessible via XSS
localStorage.setItem('accessToken', token);

// GOOD — httpOnly cookie set by server
res.cookie('token', token, { httpOnly: true, secure: true, sameSite: 'strict' });
```

### AU4: Plaintext / Fast Hash for Passwords (MD5/SHA-1/SHA-256)

- **Severity**: CRITICAL
- **Detection**: `(?:createHash|md5|sha1|sha256)\s*\(.*password`
- **OWASP**: A02

```typescript
// BAD — fast hash, no salt
const sha256Hash = crypto.createHash('sha256').update(password).digest('hex');

// GOOD — Argon2id (OWASP recommended)
import { hash as argon2Hash, argon2id } from 'argon2';
const hashed = await argon2Hash(password, { type: argon2id, memoryCost: 65536, timeCost: 3 });
```

### AU5: Missing Brute-Force Protection on Login

- **Severity**: CRITICAL
- **Detection**: `(?:post|router\.post)\s*\(\s*['"]\/(?:login|signin|auth|register|reset)`
- **OWASP**: A07

```typescript
// BAD — no rate limiting
app.post('/api/auth/login', loginHandler);

// GOOD
import rateLimit from 'express-rate-limit';
const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 5 });
app.post('/api/auth/login', authLimiter, loginHandler);
```

### AU6: Missing Session Regeneration on Login (Session Fixation)

- **Severity**: IMPORTANT
- **Detection**: `(?:session|req\.session)\s*\.\s*(?:userId|user|authenticated)\s*=`
- **OWASP**: A07

```typescript
// GOOD — regenerate session ID on successful login to prevent fixation
req.session.regenerate((err) => {
  if (err) return next(err);
  req.session.userId = user.id;
  req.session.save(next);
});
```

Related: on password change or elevation, also invalidate all other active sessions for the user (e.g., by bumping a `tokenVersion` column and rejecting sessions with a stale version, or by iterating the session store and destroying entries keyed to that user).

### AU7: OAuth Without State Parameter

- **Severity**: CRITICAL
- **Detection**: `authorize\?(?![^\n#]*\bstate=)[^\n#]*`
- **OWASP**: A07

```typescript
// GOOD — include state parameter for CSRF protection
const state = crypto.randomBytes(32).toString('hex');
session.oauthState = state;
const authUrl = `https://provider.com/authorize?client_id=${clientId}&redirect_uri=${redirectUri}&state=${state}`;
```

### AU8: Missing PKCE for Public OAuth Clients

- **Severity**: IMPORTANT
- **Detection**: `(?:authorization_code|code).*(?!.*code_challenge)`
- **OWASP**: A07

Use PKCE (Proof Key for Code Exchange) with S256 challenge method for all public clients (SPAs, mobile).

---

## Authorization Anti-Patterns (AZ1-AZ6)

### AZ1: Missing Auth Middleware on New Endpoints

- **Severity**: CRITICAL
- **Detection**: `(?:app|router)\.\w+\s*\(\s*['"]\/api\/(?:admin|users|settings)`
- **OWASP**: A01

```typescript
// BAD
router.delete('/api/users/:id', deleteUser);

// GOOD
router.delete('/api/users/:id', authenticate, authorize('admin'), deleteUser);
```

### AZ2: Client-Side Only Authorization

- **Severity**: CRITICAL
- **Detection**: Component guards without server-side checks
- **OWASP**: A01

Frontend guards are UX only. ALWAYS verify on server.

### AZ3: IDOR (Insecure Direct Object Reference)

- **Severity**: CRITICAL
- **Detection**: `params\.(?:id|userId|orderId)` without ownership check
- **OWASP**: A01

```typescript
// GOOD — verify ownership
router.get('/api/orders/:orderId', authenticate, async (req, res) => {
  const order = await Order.findById(req.params.orderId);
  if (!order || order.userId !== req.user.id) {
    return res.status(404).json({ error: 'Not found' });
  }
  res.json(order);
});
```

### AZ4: Mass Assignment

- **Severity**: CRITICAL
- **Detection**: `(?:create|update|findOneAndUpdate)\s*\(\s*req\.body\s*\)`
- **OWASP**: A01

```typescript
// BAD
await User.findByIdAndUpdate(id, req.body);

// GOOD — explicitly pick allowed fields
const { name, email, avatar } = req.body;
await User.findByIdAndUpdate(id, { name, email, avatar });
```

### AZ5: Privilege Escalation via Role Parameter

- **Severity**: CRITICAL
- **Detection**: `req\.body\.role|req\.body\.isAdmin|req\.body\.permissions`
- **OWASP**: A01

```typescript
// GOOD — ignore role from input
const { name, email, password } = req.body;
const user = await User.create({ name, email, password, role: 'user' });
```

### AZ6: Missing Re-Authentication for Sensitive Operations

- **Severity**: IMPORTANT
- **Detection**: `(?:delete|destroy|remove).*(?:account|user|organization)` without re-auth
- **OWASP**: A01

Require current password before account deletion, email change, or other sensitive operations.

---

## Secrets Anti-Patterns (S1-S6)

### S1: Hardcoded API Keys / Tokens

- **Severity**: CRITICAL
- **Detection**: `(?:password|secret|api_key|token|apiKey)\s*[:=]\s*['"][A-Za-z0-9+/=]{8,}['"]`
- **OWASP**: A04

```typescript
// BAD
const API_KEY = 'sk_live_abc123def456';

// GOOD
const API_KEY = process.env.API_KEY;
```

### S2: .env Committed to Git

- **Severity**: CRITICAL
- **Detection**: `git ls-files .env` (should return empty)
- **OWASP**: A04

```gitignore
# .gitignore
.env
.env.local
.env.*.local
*.pem
*.key
```

### S3: Server Secrets Exposed to Client

- **Severity**: CRITICAL
- **Detection**: `NEXT_PUBLIC_.*(?:SECRET|PRIVATE|PASSWORD|KEY(?!.*PUBLIC))`
- **OWASP**: A02

```bash
# BAD
NEXT_PUBLIC_DATABASE_URL=postgresql://...

# GOOD
DATABASE_URL=postgresql://...
NEXT_PUBLIC_API_URL=https://api.example.com
```

Angular: do not put secrets in `environment.ts` files bundled into the client.

### S4: Default Credentials in Config

- **Severity**: CRITICAL
- **Detection**: `(?:admin|root|default|test).*(?:password|pass|pwd)\s*[:=]\s*['"](?:admin|root|password|1234|test)`
- **OWASP**: A02

Use environment variables with validation (zod schema).

### S5: Secrets in CI/CD Pipeline Logs

- **Severity**: IMPORTANT
- **Detection**: `(?:echo|console\.log|print).*(?:\$SECRET|\$TOKEN|\$PASSWORD|process\.env)`
- **OWASP**: A09

Use masked secrets in CI. Never echo environment variables containing secrets.

### S6: Sensitive Data in Error Responses / Stack Traces

- **Severity**: IMPORTANT
- **Detection**: `(?:stack|trace|query|sql).*(?:res\.json|res\.send|c\.JSON)`
- **OWASP**: A05

```typescript
// GOOD — generic error to client, details only in logs
app.use((err, req, res, _next) => {
  logger.error({ err, path: req.path, method: req.method });
  const isDev = process.env.NODE_ENV === 'development';
  res.status(500).json({
    error: 'Internal Server Error',
    ...(isDev && { message: err.message }),
  });
});
```

---

## Headers Anti-Patterns (H1-H8)

### H1: Missing Content-Security-Policy

- **Severity**: IMPORTANT
- **Detection**: Absence of `Content-Security-Policy` header
- **OWASP**: A02

### H2: CSP with unsafe-inline and unsafe-eval

- **Severity**: IMPORTANT
- **Detection**: `Content-Security-Policy.*(?:'unsafe-inline'|'unsafe-eval')`
- **OWASP**: A02

Use nonce-based CSP: `script-src 'self' 'nonce-{SERVER_GENERATED}'`

### H3: Missing Strict-Transport-Security

- **Severity**: IMPORTANT
- **Detection**: Absence of `Strict-Transport-Security` header
- **OWASP**: A02

Value: `max-age=31536000; includeSubDomains; preload`

### H4: Missing X-Content-Type-Options

- **Severity**: IMPORTANT
- **Detection**: Absence of `X-Content-Type-Options: nosniff`
- **OWASP**: A02

### H5: Missing X-Frame-Options

- **Severity**: IMPORTANT
- **Detection**: Absence of `X-Frame-Options` header
- **OWASP**: A02

Value: `DENY`. Also set `Content-Security-Policy: frame-ancestors 'none'`.

### H6: Permissive Referrer-Policy

- **Severity**: SUGGESTION
- **Detection**: `Referrer-Policy.*(?:unsafe-url|no-referrer-when-downgrade)`
- **OWASP**: A02

Use: `strict-origin-when-cross-origin`

### H7: Missing Permissions-Policy

- **Severity**: SUGGESTION
- **Detection**: Absence of `Permissions-Policy` header
- **OWASP**: A02

Value: `camera=(), microphone=(), geolocation=(), payment=()`

### H8: CORS Wildcard with Credentials

- **Severity**: CRITICAL
- **Detection**: `(?:cors|Access-Control-Allow-Origin).*\*`
- **OWASP**: A05

```typescript
// GOOD
app.use(cors({
  origin: ['https://app.example.com', 'https://staging.example.com'],
  credentials: true,
}));
```

---

## Frontend Anti-Patterns (FE1-FE8)

### FE1: Unsanitized HTML Rendering

- **Severity**: CRITICAL
- **Detection**: `(?:innerHTML|v-html|dangerouslySetInner)` without DOMPurify
- **OWASP**: A03

Always sanitize with DOMPurify before rendering user-controlled HTML.

### FE2: Dynamic Code Evaluation with User Input

- **Severity**: CRITICAL
- **Detection**: `eval\s*\(`
- **OWASP**: A03

Use structured data parsers (JSON.parse) instead.

### FE3: postMessage Without Origin Validation

- **Severity**: IMPORTANT
- **Detection**: `addEventListener\s*\(\s*['"]message['"].*(?!.*origin)`
- **OWASP**: A01

```typescript
window.addEventListener('message', (event) => {
  if (event.origin !== 'https://trusted.example.com') return;
  processData(event.data);
});
```

### FE4: Prototype Pollution

- **Severity**: IMPORTANT
- **Detection**: `(?:__proto__|constructor\.prototype|Object\.assign)\s*.*(?:req\.|body\.|query\.)`
- **OWASP**: A05

Validate and filter keys from user input before merging into objects.

### FE5: Open Redirect

- **Severity**: IMPORTANT
- **Detection**: `(?:window\.location|location\.href|router\.push)\s*=\s*(?:req\.|params\.|query\.)`
- **OWASP**: A01

```typescript
// GOOD — relative paths only
const redirect = new URLSearchParams(window.location.search).get('redirect');
if (redirect?.startsWith('/') && !redirect.startsWith('//')) {
  window.location.href = redirect;
}
```

### FE6: Sensitive Data in localStorage

- **Severity**: IMPORTANT
- **Detection**: `localStorage\.setItem\(.*(?:token|session|credit|ssn|password)`
- **OWASP**: A07

Use httpOnly cookies for tokens.

### FE7: Missing CSRF Token

- **Severity**: IMPORTANT
- **Detection**: POST/PUT/DELETE forms without CSRF token or SameSite cookie
- **OWASP**: A01

Use double-submit cookie or synchronizer token. Next.js Server Actions have built-in CSRF via Origin header.

### FE8: Client-Only Input Validation

- **Severity**: IMPORTANT
- **Detection**: Form validation only in frontend
- **OWASP**: A05

ALWAYS validate on server too. Use zod, joi, or class-validator.

---

## Dependencies Anti-Patterns (D1-D5)

### D1: Known Vulnerable Dependency

- **Severity**: CRITICAL
- **Detection**: `npm audit --audit-level=high` exits non-zero
- **OWASP**: A03

### D2: Lockfile Out of Sync

- **Severity**: IMPORTANT
- **Detection**: `npm ci` fails
- **OWASP**: A08

### D3: Typosquatting Risk

- **Severity**: IMPORTANT
- **Detection**: Manual review of new dependency names
- **OWASP**: A03

### D4: Postinstall Scripts in New Dependency

- **Severity**: IMPORTANT
- **Detection**: `"postinstall"` in new dependency's package.json
- **OWASP**: A03

### D5: Unpinned Versions in Production

- **Severity**: SUGGESTION
- **Detection**: `":\s*["']\*["']|":\s*["']latest["']`
- **OWASP**: A03

---

## API Anti-Patterns (AP1-AP6)

### AP1: New Endpoint Without Rate Limiting

- **Severity**: IMPORTANT
- **OWASP**: A05

### AP2: GraphQL Without Depth Limiting

- **Severity**: IMPORTANT
- **Detection**: `new ApolloServer` without depth/complexity limits
- **OWASP**: A05

```typescript
import depthLimit from 'graphql-depth-limit';
const server = new ApolloServer({
  schema,
  validationRules: [depthLimit(5)],
  introspection: process.env.NODE_ENV !== 'production',
});
```

### AP3: File Upload Without Validation

- **Severity**: IMPORTANT
- **Detection**: `multer|formidable|busboy` without type/size checks
- **OWASP**: A05

```typescript
const upload = multer({
  dest: 'uploads/',
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/webp'];
    cb(null, allowed.includes(file.mimetype));
  },
});
```

### AP4: Webhook Without Signature Verification

- **Severity**: CRITICAL
- **OWASP**: A08

Always verify webhook signatures (Stripe, GitHub HMAC, etc.).

### AP5: API Exposing Internal Info

- **Severity**: IMPORTANT
- **Detection**: `(?:stack|trace|query|sql).*(?:res\.json|res\.send)`
- **OWASP**: A05

### AP6: Missing Request Body Size Limit

- **Severity**: IMPORTANT
- **Detection**: `express\.json\(\)` without `limit`
- **OWASP**: A05

```typescript
app.use(express.json({ limit: '100kb' }));
```

---

## AI/LLM Security Anti-Patterns (AI1-AI3)

### AI1: Prompt Injection via User Input

- **Severity**: CRITICAL
- **Detection**: User input concatenated into LLM prompts without sanitization
- **OWASP**: A05 (Injection)

```typescript
// BAD — user input directly in prompt
const response = await llm.complete(`Summarize this: ${userInput}`);

// GOOD — structured input with system/user message separation
const response = await llm.complete({
  system: "You are a summarization assistant. Only summarize the provided text.",
  user: userInput,
});
```

### AI2: LLM Output Used in SQL/Shell Without Sanitization

- **Severity**: CRITICAL
- **Detection**: LLM response passed to `db.query()`, `exec()`, or template literals without validation
- **OWASP**: A05 (Injection)

Never trust LLM output as safe. Treat it as untrusted user input — parameterize queries, escape shell arguments, sanitize HTML before rendering.

### AI3: Missing Output Validation from LLM Responses

- **Severity**: IMPORTANT
- **Detection**: LLM response rendered or executed without schema validation
- **OWASP**: A08 (Software or Data Integrity Failures)

Validate LLM output against expected schemas (Zod, JSON Schema) before using in application logic. Reject responses that don't match expected structure.

---

## Logging Anti-Patterns (L1-L4)

### L1: Security Events Not Logged

- **Severity**: IMPORTANT
- **OWASP**: A09

Log: auth failures, access denied, rate limit hits, input validation failures, password changes.

### L2: Sensitive Data in Logs

- **Severity**: CRITICAL
- **Detection**: `(?:log|logger)\.\w+\(.*(?:password|token|secret|ssn|credit)`
- **OWASP**: A09

```typescript
import pino from 'pino';
const logger = pino({ redact: ['req.headers.authorization', 'req.body.password'] });
```

### L3: Missing Trace IDs

- **Severity**: SUGGESTION
- **OWASP**: A09

### L4: Log Injection

- **Severity**: IMPORTANT
- **Detection**: `console\.log\(.*\+.*(?:req\.|user\.|body\.)`
- **OWASP**: A09

Use structured logging (JSON, auto-escaped) instead of string concatenation.

---

## Framework-Specific: React / Next.js (RX1-RX4)

### RX1: Server Action Without Auth

- **Severity**: CRITICAL
- **Detection**: `'use server'` function without `auth()` or session check
- **OWASP**: A01

```typescript
'use server';
import { auth } from '@/auth';
export async function deleteUser(id: string) {
  const session = await auth();
  if (!session?.user || session.user.role !== 'admin') throw new Error('Unauthorized');
  await db.user.delete({ where: { id } });
}
```

### RX2: process.env Without NEXT_PUBLIC_ in Client

- **Severity**: IMPORTANT
- **Detection**: `'use client'` file accessing `process.env` without `NEXT_PUBLIC_`
- **OWASP**: A02

### RX3: RSC Serialization Leaking Data

- **Severity**: IMPORTANT
- **OWASP**: A01

Pick only needed fields before passing DB objects to Client Components.

### RX4: middleware.ts Not Protecting API Routes

- **Severity**: IMPORTANT
- **Detection**: `config.matcher` not covering `/api/`
- **OWASP**: A01

---

## Framework-Specific: Angular (NG1-NG3)

### NG1: bypassSecurityTrustHtml with User Input

- **Severity**: CRITICAL
- **Detection**: `bypassSecurityTrust(?:Html|Script|Style|Url|ResourceUrl)`
- **OWASP**: A05

Sanitize with DOMPurify BEFORE calling bypassSecurityTrust.

### NG2: Template Expression Injection

- **Severity**: IMPORTANT
- **OWASP**: A05

Do not use JitCompilerFactory with user-controlled templates.

### NG3: HttpInterceptor Not Attaching Auth

- **Severity**: IMPORTANT
- **OWASP**: A07

Use a centralized `HttpInterceptorFn` for auth tokens.

---

## Framework-Specific: Express (EX1-EX4)

### EX1: Missing helmet.js

- **Severity**: IMPORTANT
- **OWASP**: A02

```typescript
import helmet from 'helmet';
app.use(helmet());
app.disable('x-powered-by');
```

### EX2: express.json() Without Body Size Limit

- **Severity**: IMPORTANT
- **OWASP**: A05

```typescript
app.use(express.json({ limit: '100kb' }));
```

### EX3: Cookie Without Secure Flags

- **Severity**: IMPORTANT
- **OWASP**: A07

```typescript
res.cookie('session', value, {
  httpOnly: true, secure: true, sameSite: 'strict', maxAge: 3600000, path: '/',
});
```

### EX4: Error Handler Exposing Stack Trace

- **Severity**: IMPORTANT
- **OWASP**: A05

Only expose error details in development mode.

---

## Framework-Specific: Go (GO1-GO3)

### GO1: math/rand for Security Operations

- **Severity**: CRITICAL
- **Detection**: `math/rand` import in security-related files
- **OWASP**: A04

Use `crypto/rand` for cryptographically secure random values.

### GO2: TLS InsecureSkipVerify

- **Severity**: CRITICAL
- **Detection**: `InsecureSkipVerify:\s*true`
- **OWASP**: A04

Use system CA pool (default) instead.

### GO3: String Interpolation in SQL

- **Severity**: CRITICAL
- **Detection**: `fmt\.Sprintf\s*\(.*(?:SELECT|INSERT|UPDATE|DELETE|FROM|WHERE)`
- **OWASP**: A03

```go
// GOOD — parameterized
db.Where("id = ?", userID).Find(&user)
```

---

## Security Headers Template

### helmet.js (Express)

```typescript
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      fontSrc: ["'self'"],
      connectSrc: ["'self'"],
      frameAncestors: ["'none'"],
      objectSrc: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"],
      upgradeInsecureRequests: [],
    },
  },
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
  frameguard: { action: 'deny' },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  crossOriginOpenerPolicy: { policy: 'same-origin' },
  crossOriginResourcePolicy: { policy: 'same-origin' },
}));
app.disable('x-powered-by');
```

---

## JWT Validation Checklist

1. Verify signature with expected algorithm — reject `alg: none`
2. Enforce algorithm: `algorithms: ['RS256']` or `['ES256']`
3. Check `exp` — reject expired tokens
4. Check `iat` — reject tokens issued too far in the past
5. Check `aud` — reject tokens not intended for this service
6. Check `iss` — reject tokens from unknown issuers
7. Store in httpOnly cookie — not localStorage
8. Use short-lived access tokens (15 min) + refresh token rotation
9. Rotate signing keys periodically

---

## Secure Cookie Flags

```text
Set-Cookie: session=value; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=3600
```

| Flag | Purpose | When to use |
|------|---------|-------------|
| `HttpOnly` | Not accessible via JavaScript (prevents XSS token theft) | Always |
| `Secure` | Only sent over HTTPS | Always |
| `SameSite=Strict` | Only sent on same-site requests (strongest CSRF) | Auth/session cookies |
| `SameSite=Lax` | Sent on top-level navigations (moderate CSRF) | Cookies that need cross-site top-level nav (e.g., OAuth return) |
| `Path=/` | Limit cookie scope | Always |
| `Max-Age` | Explicit expiration (prefer over `Expires`) | Always |

---

## Security Checklist

### Authentication and Sessions

- [ ] Passwords hashed with Argon2id or bcrypt (cost >= 12)
- [ ] JWT signed with RS256/ES256, algorithm enforced on verify
- [ ] Access tokens expire in <= 15 minutes
- [ ] Refresh tokens: one-time use, rotated, stored in httpOnly cookie
- [ ] Rate limiting on login, registration, and password reset
- [ ] Session regenerated after authentication
- [ ] MFA available for privileged accounts

### Authorization

- [ ] Every API endpoint has auth middleware
- [ ] Ownership checks on all resource access (prevent IDOR)
- [ ] Server-side authorization (frontend guards are UX only)
- [ ] Mass assignment prevented (explicit field selection)
- [ ] Re-authentication required for sensitive operations

### Input and Output

- [ ] All user input validated server-side (zod/joi/class-validator)
- [ ] Parameterized queries for all database operations
- [ ] HTML output sanitized (DOMPurify) when rendering user content
- [ ] Error responses do not expose stack traces in production

### Secrets

- [ ] No hardcoded secrets in source code
- [ ] `.env` files in `.gitignore`
- [ ] Server secrets not exposed to client (no NEXT_PUBLIC_ on secrets)
- [ ] Environment variables validated at startup

### Headers

- [ ] Content-Security-Policy configured (nonce-based preferred)
- [ ] Strict-Transport-Security with preload
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY
- [ ] Referrer-Policy: strict-origin-when-cross-origin
- [ ] Permissions-Policy restricting unused APIs
- [ ] CORS restricted to known origins

### Dependencies

- [ ] `npm audit` (or equivalent) passing in CI
- [ ] Lockfile committed and verified with `npm ci`
- [ ] New dependencies reviewed for typosquatting and postinstall scripts
- [ ] No wildcard or "latest" versions in production

### Logging

- [ ] Security events logged (auth failures, access denied, rate limits)
- [ ] No sensitive data in logs (passwords, tokens, PII)
- [ ] Structured logging with correlation IDs
- [ ] Alerts configured for anomalous patterns
