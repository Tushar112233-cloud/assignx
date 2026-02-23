# AssignX Theme Implementation Document

## Executive Summary

This document outlines the complete theme overhaul for AssignX, transitioning from a generic blue-accented design to a warm, professional brand identity using the established color palette.

---

## Brand Identity

### Color Palette

| Color | Hex | HSL | Role |
|-------|-----|-----|------|
| **Pitch Black** | `#14110F` | `8 11% 7%` | Dark backgrounds, primary text |
| **Graphite** | `#34312D` | `12 7% 19%` | Secondary surfaces, muted elements |
| **Coffee Bean** | `#765341` | `20 28% 36%` | **Primary accent** - CTAs, links, highlights |
| **Vanilla Cream** | `#E4E1C7` | `51 31% 84%` | Light accents, warm backgrounds |

### Typography

- **Font Family**: Sora (Google Fonts)
- **Weights**: 400 (body), 500 (medium), 600 (semibold), 700-800 (headings)
- **Letter Spacing**: -0.02em for headings, normal for body

---

## Design Principles

### 1. Warmth Over Coldness
- Replace all blue accents with Coffee Bean brown
- Use Vanilla Cream for subtle warmth in backgrounds
- Maintain earthy, approachable feel

### 2. Professional Trust
- Pitch Black for authority and sophistication
- Clean whitespace with warm tints
- Consistent visual hierarchy

### 3. Accessibility First
- All color combinations meet WCAG AA standards
- Coffee Bean on white: 5.6:1 contrast ratio
- Pitch Black on white: 18.5:1 contrast ratio

---

## Current State Analysis

### Already Implemented (colors.css)
- Brand color tokens defined
- Light/dark mode variables set
- Sidebar using brand colors
- Chart colors configured

### Needs Implementation
1. **Font Change**: Inter → Sora
2. **Landing Page**: Complete redesign with new theme
3. **Auth Pages**: Update onboarding CSS hover effects
4. **Dashboard**: Update component hover states
5. **UI Components**: Remove blue hover effects, use Coffee Bean
6. **Page-specific CSS**: Update all 7 CSS files

---

## Implementation Phases

### Phase 1: Foundation (Priority: Critical)
1. Add Sora font to layout.tsx
2. Update globals.css with font-family
3. Verify colors.css is being imported correctly

### Phase 2: Landing Page (Priority: High)
1. Update landing.css with brand colors
2. Update hero section styling
3. Update navigation hover states
4. Update buttons and CTAs
5. Update footer styling

### Phase 3: Auth Pages (Priority: High)
1. Update onboarding.css (already partially done)
2. Update login.css
3. Update signup page styling
4. Update form-layout.css

### Phase 4: Dashboard (Priority: High)
1. Update home.css
2. Update projects.css
3. Update connect.css
4. Update project-detail.css
5. Update workspace.css components

### Phase 5: Components (Priority: Medium)
1. Update upload-sheet.tsx hover effects
2. Update dashboard-pro.tsx Quick Actions
3. Update all card hover effects
4. Update button variants in workspace.css

### Phase 6: QA & Polish (Priority: High)
1. Visual regression testing
2. Dark mode verification
3. Accessibility audit
4. Cross-browser testing

---

## File-by-File Changes

### 1. app/layout.tsx
```tsx
// Change from Inter to Sora
import { Sora } from "next/font/google";

const sora = Sora({
  subsets: ["latin"],
  variable: "--font-sora",
  weight: ["400", "500", "600", "700", "800"],
});
```

### 2. app/globals.css
```css
/* Update font-family references */
body {
  font-family: var(--font-sora), system-ui, sans-serif;
}
```

### 3. app/landing.css
- Replace all `blue-*` color references with Coffee Bean equivalents
- Update gradient definitions
- Update hover states

### 4. styles/workspace.css
- Update `.ws-btn-primary` to use Coffee Bean
- Update hover effects on cards
- Update focus rings

### 5. app/(auth)/onboarding/onboarding.css
- Already updated with Coffee Bean hover effects
- Verify consistency

### 6. components/dashboard/upload-sheet.tsx
- Replace blue hover with Coffee Bean gradient
- Update icon hover colors

### 7. app/(dashboard)/home/dashboard-pro.tsx
- Update Quick Actions hover effects
- Use Coffee Bean accent

---

## Color Mapping Reference

### Blue → Coffee Bean Conversions

| Old (Blue) | New (Coffee Bean) |
|------------|-------------------|
| `blue-50` | `hsl(20 25% 96%)` or `#F7F4F2` |
| `blue-100` | `hsl(20 20% 92%)` or `#EDE8E5` |
| `blue-200` | `hsl(20 22% 82%)` or `#D4C8C1` |
| `blue-500` | `hsl(20 28% 36%)` / `#765341` (Coffee Bean) |
| `blue-600` | `hsl(20 30% 30%)` / `#5D4233` |
| `blue-700` | `hsl(20 32% 25%)` / `#4A3428` |
| `blue-800` | `hsl(20 34% 20%)` / `#3D2A1F` |
| `blue-900` | `hsl(20 36% 15%)` / `#2E1F17` |

### Tailwind Class Mappings

| Old Class | New Class |
|-----------|-----------|
| `text-blue-500` | `text-primary` or `text-brand-coffee` |
| `bg-blue-50` | `bg-primary/10` or custom |
| `border-blue-200` | `border-primary/30` |
| `hover:bg-blue-100` | `hover:bg-primary/15` |
| `ring-blue-500` | `ring-primary` |

---

## Component Hover Effect Standard

### Card Hover (Consistent Pattern)
```css
/* Default state */
.card {
  border: 2px solid hsl(var(--border));
  background: hsl(var(--card));
  transition: all 0.2s ease;
}

/* Hover state */
.card:hover {
  border-color: hsl(20 28% 36% / 0.5); /* Coffee Bean 50% */
  background: linear-gradient(
    to right,
    hsl(20 28% 36% / 0.1),
    hsl(30 35% 55% / 0.1)
  );
  box-shadow: 0 10px 15px -3px hsl(20 20% 10% / 0.1);
  transform: translateY(-2px);
}

/* Icon on hover */
.card:hover .icon {
  background: hsl(20 28% 36%); /* Coffee Bean solid */
  color: white;
}
```

---

## Testing Checklist

### Visual Testing
- [ ] Landing page renders correctly
- [ ] All buttons use Coffee Bean color
- [ ] Hover effects are warm brown, not blue
- [ ] Dark mode maintains brand colors
- [ ] Typography uses Sora font

### Accessibility Testing
- [ ] Color contrast meets WCAG AA
- [ ] Focus states are visible
- [ ] Text is readable on all backgrounds

### Functional Testing
- [ ] All links work
- [ ] Forms submit correctly
- [ ] Navigation functions properly
- [ ] Theme toggle works

---

## Rollback Plan

If issues arise:
1. Git revert to pre-theme commit
2. Individual file restoration from backup
3. CSS variable override in globals.css

---

## Success Metrics

1. **Brand Consistency**: All pages use Coffee Bean as primary accent
2. **No Blue Remnants**: Zero blue color references in production
3. **Accessibility**: All contrast ratios pass WCAG AA
4. **Performance**: No CSS bloat, efficient variable usage
5. **User Feedback**: Warm, professional, trustworthy perception

---

## Appendix: All Files to Modify

### Critical CSS Files (7)
1. `app/globals.css`
2. `app/landing.css`
3. `app/(auth)/onboarding/onboarding.css`
4. `app/(auth)/login/login.css`
5. `app/(dashboard)/home/home.css`
6. `app/(dashboard)/projects/projects.css`
7. `styles/workspace.css`

### Component Files (4)
1. `app/layout.tsx` (font)
2. `components/dashboard/upload-sheet.tsx`
3. `app/(dashboard)/home/dashboard-pro.tsx`
4. `app/(auth)/signup/page.tsx`

### Additional CSS Files (4)
1. `app/(dashboard)/connect/connect.css`
2. `app/project/[id]/project-detail.css`
3. `components/add-project/form-layout.css`
4. `styles/tokens/spacing.css` (shadow colors)

**Total: 15 files require modifications**
