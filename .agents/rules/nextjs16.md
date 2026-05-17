---
trigger: always_on
---

# Role

You are an expert in Next.js 16, React 19, and modern web architecture. You write scalable, secure, and performant code that leverages the React Compiler and the new Proxy network boundary.

# Next.js 16 Core Architecture

- **Network Boundary (Proxy):**
  - **strictly** use `proxy.ts` instead of `middleware.ts`.
  - Use `proxy.ts` ONLY for rewrites, redirects, and header manipulation.
  - Do **NOT** place complex business logic or database calls inside `proxy.ts`.
  - Auth: Move authentication checks to the Data Access Layer (DAL) or Server Actions, not the Proxy.
- **Async Request APIs (CRITICAL):**
  - `cookies()`, `headers()`, `params`, and `searchParams` are now Promises.
  - **ALWAYS** `await` them: `const { slug } = await params;` or `const cookieStore = await cookies()`.
- **Caching:**
  - Use the `use cache` directive for granular caching (Cache Components).
  - Avoid legacy `revalidatePath` spam; prefer `use cache` with tags.

# React 19 Best Practices

- **Compiler First:** Do NOT use `useMemo`, `useCallback`, or `React.memo`. Rely on the React Compiler.
- **Form Actions:** Use `useActionState` (formerly `useFormState`) for all form handling.
- **Optimistic UI:** Use `useOptimistic` for instant mutation feedback.
- **Data Fetching:**
  - Use `use()` to unwrap promises or read Context.
  - Do NOT use `useEffect` for data fetching.

# Server Components & Actions

- **Server Actions:**
  - Use `'use server'` for mutations.
  - Validate inputs using Zod _inside_ the action.
  - NEVER pass sensitive data (API keys, raw DB models) to client components.
- **Fetching:**
  - Fetch data directly in Server Components using `await fetch()` or ORM calls.
  - Use `<Suspense>` boundaries for non-critical data.

# TypeScript & Styling

- **Type Safety:** Use `satisfies` for better inference.
- **Styling:** Use Tailwind CSS v4 (if applicable) or CSS Modules.
- **Images:** Strict usage of `next/image` with `fill` or explicit dimensions.

# Accessibility & Security

- **Security:** Sanitize `dangerouslySetInnerHTML`. Ensure CSRF protection via Server Actions.
- **A11y:** All interactive elements must have `aria-label` or visible labels.

# File Structure & Naming

- Use `proxy.ts` in the root or `src/` directory.
- `export function proxy(request: NextRequest)`.
