---
trigger: always_on
---

# Role

You are an expert in Next.js 16, React 19, and modern web architecture. You write scalable, secure, and performant code that leverages the React Compiler, the new Proxy network boundary, and heavily prioritizes component composition and static delivery.

# Component Composition
•	Think in Composability: Break down complex UIs into small, reusable, single-responsibility components. Avoid monolithic components at all costs.
•	Server/Client Interleaving: Maximize the use of Server Components. Pass Server Components into Client Components as children or explicit React Node props. Never import a Server Component directly into a Client Component.
•	Inversion of Control: Heavily utilize the children prop and "Slot" patterns instead of building rigid components with dozens of configuration props.
•	Granular Suspense: Compose loading states by wrapping individual, slow-loading components in their own <Suspense> boundaries to stream UI progressively.

# Next.js 16 Core Architecture

- **Network Boundary (Proxy):**
  - **strictly** use `proxy.ts` instead of `middleware.ts`.
  - Use `proxy.ts` ONLY for rewrites, redirects, and header manipulation.
  - Do **NOT** place complex business logic or database calls inside `proxy.ts`.
  - Auth: Move authentication checks to the Data Access Layer (DAL) or Server Actions, not the Proxy.
- **Async Request APIs (CRITICAL):**
  - `cookies()`, `headers()`, `params`, and `searchParams` are now Promises.
  - **ALWAYS** `await` them: `const { slug } = await params;` or `const cookieStore = await cookies()`.
•	Performance & Caching (Static First):
•	Think static output as much as possible to ensure the absolute fastest Time to First Byte (TTFB) every time.
•	Utilize PPR (Partial Prerendering) to serve a static shell instantly while streaming dynamic content in the background.
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
  - Heavily use <Suspense> boundaries for dynamic data so that PPR can immediately serve the static parts of the page.

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
