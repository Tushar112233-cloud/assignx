# Resources Page Redesign - Implementation Plan

## Executive Summary
Give the Resources page a distinct landing identity while preserving the dashboard typography hierarchy and color system. The new layout uses a left navigation rail + right content workspace, with a hero deck, quick-launch controls, and structured lanes for tools, guides, and training.

---

## 1. Visual Analysis (Reference Pages)

### Typography Hierarchy
- Display: `text-4xl lg:text-5xl font-bold tracking-tight`
- Subhead: `text-lg text-gray-500`
- Section title: `text-lg font-semibold text-[#1C1C1C]`
- Labels: `text-xs font-medium text-gray-500`

### Color System
- Primary text: `#1C1C1C`
- Accent: `#F97316` (hover `#EA580C`)
- Background: `bg-gray-50`
- Cards: `bg-white` + `border-gray-200`
- Status accents: emerald / amber / purple / violet

---

## 2. New Layout Structure (Unique Identity)

```
┌──────────────────────────────────────────────────────────────┐
│ LEFT RAIL                  │ RIGHT WORKSPACE                 │
│ ┌──────────────┐           │ ┌────────────────────────────┐ │
│ │ Resource     │           │ │ Hero Deck + Quick Launch   │ │
│ │ Index        │           │ │ (illustration + snapshot)  │ │
│ └──────────────┘           │ └────────────────────────────┘ │
│ ┌──────────────┐           │ ┌────────────────────────────┐ │
│ │ Quick Access │           │ │ Featured Tools             │ │
│ └──────────────┘           │ └────────────────────────────┘ │
│                            │ ┌─────────────┐ ┌────────────┐ │
│                            │ │ Guides      │ │ Playbook   │ │
│                            │ └─────────────┘ └────────────┘ │
│                            │ ┌─────────────┐ ┌────────────┐ │
│                            │ │ Training    │ │ Activity   │ │
│                            │ └─────────────┘ └────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

Distinct from dashboard by using a rail + workspace layout, not a top-only hero + pills pattern.

---

## 3. Component Strategy

### 3.1 Hero Deck (Custom, in page)
- Label: "Resource Studio"
- H1 + subhead from dashboard hierarchy
- CTA buttons: "Run Quality Check" + "Open Training"
- Quick launch row (Plagiarism / AI / Grammar / Pricing)
- Right column: illustration + "Resource Snapshot" progress bars

### 3.2 Left Rail
- Resource Index with grouped navigation (Quality Tools, Guides & Training)
- Quick Access Panel below (reuse `QuickAccessPanel`)
- Sticky on desktop

### 3.3 Workspace Lanes
- FeaturedTools: keep V2 component
- Guides & Playbook: `ToolCategoryGrid` + custom playbook card
- Training & Activity: `ToolCategoryGrid` + `ActivityFeed`

### 3.4 Tool Views
- Maintain existing tool views
- Add a compact heading using `viewTitles[activeView]`
- Keep Back button and ToolWrapper layout

---

## 4. Files to Change

- Update: `superviser-web/app/(dashboard)/resources/page.tsx`
- Update: `superviser-web/docs/redesign/resources-implementation-plan.md`

---

## 5. QA Checklist

### Visual
- Same typography hierarchy as dashboard
- Orange/charcoal palette consistent
- Layout is distinct from dashboard/projects/users
- Cards and shadows consistent

### Functional
- All resource tool views still open
- Back navigation works
- Quick launch buttons route to correct views
- Responsive: rail stacks on mobile

---

## 6. Success Criteria
- Unique landing experience while retaining system hierarchy
- Clear navigation and quick actions
- Feels as polished as Projects/Doers/Users pages
