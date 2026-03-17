# CLAUDE.md — PRISM Playbook (Web App)

## How to Work

1. **ASK before doing** — Don't jump to code. Ask: "What are you trying to achieve? Who uses this page?"
2. **Design before build** — Present component structure, data flow, UI layout. Wait for approval.
3. **Plan before execute** — Break into micro-tasks (2-10 min each). Type GO to start.
4. **Small tasks → just do it** — Bug fixes, style tweaks, copy changes: no planning needed (GSD mode).

## Project Context

**What**: [e.g., E-commerce storefront / SaaS dashboard / Personal blog]
**Why**: [Why does it exist? What user problem does it solve?]
**Who**: [Primary users + their context — mobile? desktop? technical? non-technical?]
**Stack**: [e.g., Next.js 14 / React + Vite / Vue 3 / Svelte]
**Styling**: [e.g., Tailwind CSS / CSS Modules / styled-components]
**State**: [e.g., React Query + Zustand / Redux / Pinia]
**API**: [e.g., REST via fetch / GraphQL via Apollo / tRPC]
**Testing**: [e.g., Vitest + Testing Library / Jest + Cypress]
**Deploy**: [e.g., Vercel / Netlify / Docker + VPS]

## Web App Standards

### UI/UX
- Mobile-first — design for 375px, then scale up
- Semantic HTML — use `nav`, `main`, `article`, `section`, not div soup
- Accessibility — keyboard navigation, ARIA labels, color contrast
- Loading states for async operations — never show blank screens
- Error states with helpful messages — not just "Something went wrong"

### Performance
- No N+1 API calls in loops — batch requests
- Images: lazy load, proper sizing, WebP/AVIF when possible
- Bundle: no unnecessary large dependencies
- Server components / SSR where appropriate

### Security
- Validate all user input (client AND server)
- No `dangerouslySetInnerHTML` with user data
- Auth checks on every protected route (not just frontend guards)
- No secrets in client-side code

## Knowledge

- Read `.prism/knowledge/` before starting — patterns and traps from previous sessions.
- After learning something new, append to:
  - `RULES.md` — component patterns, styling conventions
  - `GOTCHAS.md` — browser quirks, SSR issues, hydration mismatches
  - `TECH_DECISIONS.md` — why we chose library X over Y

## Session Handoff

If conversation gets long: write state to `.prism/STAGING.md`, start fresh session.
