# UX Psychology Principles

> 7 cognitive principles for design review. Reference checklist for /design-review and /qa.

## The 7 Principles

### 1. Reduce Choices (Hick's Law)
More options = slower decisions = more abandonment.
- Max 7 items in navigation menus
- Forms: 5-7 fields max per step (use multi-step for more)
- One primary CTA per view
- **Test:** Can the user complete the main action without scrolling past options?

### 2. Follow Conventions (Jakob's Law)
Users spend most of their time on OTHER sites. Match their expectations.
- Standard dialog patterns for forms (title, fields, actions)
- Tables for tabular data (not creative card layouts)
- Left sidebar for navigation, top bar for global actions
- **Test:** Would a first-time user know where to click without instructions?

### 3. Easy Targets (Fitts's Law)
Small targets = slow + error-prone interactions.
- **Minimum 44x44px** touch targets (buttons, links, checkboxes)
- Primary actions should be larger than secondary actions
- Destructive actions should NOT be adjacent to confirm actions
- **Test:** Can you tap every interactive element on mobile without zooming?

### 4. Group Related (Law of Proximity)
Elements close together are perceived as related.
- Related form fields grouped with consistent spacing
- Cards with internal padding < external margins
- Section headers visually closer to their content than to previous section
- **Test:** Cover the labels — can you still tell which fields belong together?

### 5. Make Important Stand Out (Von Restorff Effect)
Different = memorable. Use contrast strategically.
- One primary color per page (don't dilute attention)
- Destructive actions = red (always, universally)
- Important status changes need visual distinction (not just text)
- **Test:** Squint at the page — does the most important element jump out?

### 6. Respect User Effort (Zeigarnik Effect)
Users remember incomplete tasks. Don't waste their progress.
- Response times < 400ms (or show loading indicator)
- Preserve unsaved form data on navigation
- Show progress indicators for multi-step flows
- Never: `window.confirm()`, `window.alert()`, full-page spinners
- **Test:** Accidentally navigate away — is my work preserved?

### 7. Accept Flexible Input (Postel's Law)
Be liberal in what you accept, conservative in what you produce.
- Fuzzy search (typo-tolerant)
- Case-insensitive input
- Multiple date formats accepted
- Phone numbers with or without country code
- **Test:** Type the input "wrong" in 3 ways — does it still work?

## Non-Negotiable Implementation Rules

- Success/error toasts for all mutations
- Query invalidation after mutations (no stale data)
- Skeleton loaders, not spinners
- Empty states with CTA (not blank pages)
- Responsive tables (hide non-essential columns on mobile)

## Scoring (for /design-review)

Each principle scored 0-10. Overall UX Score = weighted average:
- Conventions (2x weight — most common violation)
- Targets + Grouping (1.5x — affects usability)
- Others (1x)

Score < 6 on any principle = flagged for revision.
