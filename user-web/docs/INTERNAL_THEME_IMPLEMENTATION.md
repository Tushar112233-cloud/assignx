# Internal Pages Theme Implementation Plan

## Brand Color Palette - Coffee Bean

| Color Name | Hex | HSL | Purpose |
|------------|-----|-----|---------|
| **Pitch Black** | #14110F | 8 11% 7% | Backgrounds (dark), Primary text |
| **Graphite** | #34312D | 12 7% 19% | Secondary backgrounds, Muted elements |
| **Coffee Bean** | #765341 | 20 28% 36% | **PRIMARY ACCENT** |
| **Coffee Light** | #A07A65 | 20 25% 51% | Lighter accent variant |
| **Coffee Dark** | #5C4233 | 20 30% 28% | Darker accent for hover |
| **Vanilla Cream** | #E4E1C7 | 51 31% 84% | Soft accent, highlights |

---

## Files Requiring Updates

### 1. `styles/workspace.css` (CRITICAL)
**Current Issue:** Uses `#A9714B` (Cinnamon Wood) instead of Coffee Bean `#765341`

**Changes Required:**
- `--ws-primary: #A9714B` → `--ws-primary: #765341`
- `--ws-primary-hover: #8B5D3D` → `--ws-primary-hover: #5C4233`
- `--ws-primary-active: #744D33` → `--ws-primary-active: #4A3628`
- `--ws-primary-light: #F8F3EF` → `--ws-primary-light: #F5F0EB`
- `--ws-primary-muted: rgba(169, 113, 75, 0.12)` → `rgba(118, 83, 65, 0.12)`
- Update all shadow/glow references with new Coffee Bean rgba values
- Update mesh gradients to use Coffee Bean colors

### 2. `app/globals.css` (HIGH PRIORITY)
**Current Issue:** Uses monochromatic oklch colors, no brand identity

**Changes Required:**
- Update `--primary` to use Coffee Bean color
- Update gradient colors to use brand palette
- Update sidebar colors to use Coffee Bean accents
- Ensure chart colors align with brand palette

### 3. `app/(dashboard)/connect/connect.css` (MEDIUM)
**Dependency:** Will inherit from workspace.css variables, but may have hardcoded values

### 4. Component-Level Updates (MEDIUM)
Files using Tailwind classes with `primary`, `accent` colors:
- Sidebar components
- Dashboard cards
- Button states
- Form focus states

---

## Framer Motion Micro-Interactions Plan

### Components Requiring Animations

#### 1. **Cards & List Items**
- Hover lift effect with scale
- Staggered fade-in on page load
- Exit animations on removal

#### 2. **Navigation & Tabs**
- Active indicator slide animation
- Tab content crossfade
- Sidebar collapse/expand animation

#### 3. **Buttons**
- Subtle scale on press
- Loading state spinner
- Success/error state transitions

#### 4. **Modals & Sheets**
- Scale + fade entrance
- Backdrop blur animation
- Content stagger animation

#### 5. **Page Transitions**
- Fade + slight Y translate between routes
- Shared element transitions where possible

#### 6. **Data Loading**
- Skeleton shimmer animations
- Content reveal animations
- Progress indicators

---

## Implementation Order

### Phase 1: Core Styling (workspace.css, globals.css)
1. Update workspace.css primary colors to Coffee Bean
2. Update globals.css to use Coffee Bean palette
3. Verify color token consistency across files

### Phase 2: Component Animations
1. Create reusable animation components
2. Update existing components with Framer Motion
3. Add page-level transitions

### Phase 3: QA & Polish
1. Verify all pages render correctly
2. Test dark mode consistency
3. Check reduced motion support

---

## Color Reference Quick Guide

```css
/* Light Mode Coffee Bean Values */
--primary: #765341;
--primary-hover: #5C4233;
--primary-active: #4A3628;
--primary-light: rgba(118, 83, 65, 0.1);
--primary-muted: rgba(118, 83, 65, 0.12);

/* Dark Mode Coffee Bean Values */
--primary: #A07A65;  /* Lighter for visibility */
--primary-hover: #B89680;
--primary-light: rgba(118, 83, 65, 0.15);

/* Focus/Ring States */
--ring: #765341;
--shadow-focus: 0 0 0 3px rgba(118, 83, 65, 0.15);
--shadow-glow: 0 0 20px rgba(118, 83, 65, 0.1);
```

---

## Files Changed Summary

| File | Priority | Status |
|------|----------|--------|
| `styles/workspace.css` | CRITICAL | COMPLETED |
| `app/globals.css` | HIGH | COMPLETED |
| `app/(dashboard)/connect/connect.css` | MEDIUM | COMPLETED |
| `styles/tokens/colors.css` | REFERENCE | Already Correct |
| `components/profile/stats-card.tsx` | MEDIUM | COMPLETED (animations added) |
| `components/providers/page-transition.tsx` | HIGH | COMPLETED |
| `components/ui/filter-skeleton.tsx` | MEDIUM | COMPLETED |
| `components/marketplace/filter-bar.tsx` | MEDIUM | COMPLETED (animations added) |
| `components/connect/category-filter.tsx` | MEDIUM | COMPLETED (animations added) |

## Implementation Notes

### Colors Changed
- Primary: `#A9714B` (Cinnamon Wood) -> `#765341` (Coffee Bean)
- Secondary: `#E8985E` (Toasted Almond) -> `#A07A65` (Coffee Light)
- All rgba values updated with Coffee Bean RGB (118, 83, 65)
- All shadow/glow effects updated with new Coffee Bean values

### Animations Added
- Page transitions with Framer Motion
- Filter tab animations with stagger effects
- Card hover lift animations
- Skeleton loading states for filters and search
- Stats card micro-interactions
- Reduced motion support throughout
