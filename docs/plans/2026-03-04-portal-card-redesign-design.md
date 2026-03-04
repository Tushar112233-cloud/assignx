# Portal Card Redesign — Design Document

**Date:** 2026-03-04
**Scope:** `user-web/components/portals/job-portal.tsx`, `user-web/components/portals/business-portal.tsx`
**Goal:** Elevate the job and investor card grids to match the visual richness of the student Campus Connect portal.

---

## Problem

The `JobPortal` and `BusinessPortal` components have:
- A uniform 2-column CSS grid with fixed-height cards
- Plain white/muted card backgrounds with no type-based color differentiation
- Minimal visual hierarchy — title, company, and description all feel equal weight
- No hover interactivity beyond a bottom-aligned "Apply Now" button
- Filters use generic `bg-primary` active state

The student `CampusConnectPage` achieves visual richness through: a masonry grid, 12-category color system with gradient icon squares, frosted-glass chips, and hover bookmark overlays.

---

## Approach: Category-Tinted Glassmorphism

Each card gets a gradient tint and border derived from its type (job type or primary funding stage). Cards use frosted-glass skill/sector chips and a gradient company/investor avatar. Layout switches to masonry.

---

## Layout

Replace `grid gap-4 sm:grid-cols-2` with a JavaScript column-distribution masonry (same technique as `masonry-grid.tsx`):

| Breakpoint | Columns |
|---|---|
| ≥ 1024px | 3 |
| ≥ 640px | 2 |
| < 640px | 1 |

Items are distributed sequentially across columns. Card height varies naturally from description length, tag count, and metadata.

---

## Job Card Color System

Keyed to `JobType`:

| Type | Card tint | Card border | Avatar gradient |
|---|---|---|---|
| `full-time` | `from-emerald-500/10` | `border-emerald-500/20` | `from-emerald-500 to-teal-500` |
| `internship` | `from-violet-500/10` | `border-violet-500/20` | `from-violet-500 to-purple-500` |
| `contract` | `from-amber-500/10` | `border-amber-500/20` | `from-amber-500 to-orange-500` |
| `part-time` | `from-blue-500/10` | `border-blue-500/20` | `from-blue-500 to-cyan-500` |
| `freelance` | `from-rose-500/10` | `border-rose-500/20` | `from-rose-500 to-pink-500` |

### Job Card Anatomy (top → bottom)

1. **Avatar row** — gradient circle (40×40) with company name initial, colored per type; job-type pill with matching color; remote badge if `isRemote`
2. **Title** — `font-bold`, 2-line clamp; `hover:text-{type}` color shift
3. **Company · Location** — muted secondary row
4. **Salary** — type-accent text with `DollarSign` icon
5. **Description** — 3-line clamp, muted
6. **Skill chips** — `bg-white/5 border border-white/10 backdrop-blur-sm` (dark) / `bg-muted/60` (light) frosted pills
7. **Footer** — posted time (left); "Apply Now" button (right, `opacity-0 group-hover:opacity-100` on desktop, always visible on mobile)

**Card container:**
```
rounded-2xl bg-gradient-to-br from-{type}/10 to-transparent
border border-{type}/20 shadow-sm
hover:shadow-md hover:shadow-{type}/10 hover:-translate-y-1
transition-all duration-300 group p-5 break-inside-avoid mb-4
```

---

## Investor Card Color System

Keyed to first element of `fundingStages[]`:

| Stage | Card tint | Avatar gradient |
|---|---|---|
| `pre-seed` | `from-violet-500/10` | `from-violet-500 to-purple-600` |
| `seed` | `from-emerald-500/10` | `from-emerald-500 to-teal-600` |
| `series-a` | `from-blue-500/10` | `from-blue-500 to-indigo-600` |
| `series-b` | `from-amber-500/10` | `from-amber-500 to-orange-600` |
| `series-c` | `from-rose-500/10` | `from-rose-500 to-red-600` |
| `growth` | `from-cyan-500/10` | `from-cyan-500 to-blue-600` |

### Investor Card Anatomy (top → bottom)

1. **Avatar row** — large gradient circle (44×44) with investor name initials; deal count badge (`{n} deals`) top-right
2. **Name + Firm** — bold name, muted firm subtitle
3. **Funding stage pills** — each stage as existing colored badge
4. **Sector chips** — frosted glass pills (same style as job skills)
5. **Ticket size** — stage-accent text with ticket icon
6. **Bio** — 3-line clamp, muted
7. **Footer** — full-width "Connect" button, gradient matching primary stage color

---

## Pitch Deck Section Upgrade (Business portal)

- Upload zone: `border-dashed border-orange-500/30 bg-orange-500/5`, `Rocket` icon, copy "Drop your deck, pitch to 1,240+ investors"
- Deck status rows: colored left-border stripe (`border-l-2 border-{status-color}`) instead of plain icon+text

---

## Filter Chips

Active chip uses portal-themed gradient instead of generic `bg-primary`:
- Job portal active: `bg-gradient-to-r from-indigo-600 to-blue-600 text-white border-transparent`
- Business portal active: `bg-gradient-to-r from-orange-600 to-amber-600 text-white border-transparent`

---

## Empty State

Gradient icon container (56×56, `rounded-2xl`) with colored blurred glow behind it:
- Job portal: indigo/blue gradient icon
- Business portal: orange/amber gradient icon

---

## What Does Not Change

- Filter row layout and logic
- Search bar
- Remote toggle (job portal)
- All existing state, filtering, and `useMemo` logic
- Hero sections (already approved and shipped)
- TypeScript types

---

## Files Modified

| File | Change |
|---|---|
| `user-web/components/portals/job-portal.tsx` | Replace card grid with masonry; redesign `JobCard` render |
| `user-web/components/portals/business-portal.tsx` | Replace card grid with masonry; redesign investor card render; upgrade pitch deck section |
