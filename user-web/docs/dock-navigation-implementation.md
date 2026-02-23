# Dock Navigation Implementation Plan

## Overview

This document outlines the complete implementation plan for replacing the traditional sidebar navigation with a modern, macOS-style dock positioned at the bottom of the screen. The dock will be the primary navigation method for all dashboard pages.

---

## Current State Analysis

### Existing Navigation Structure
- **Sidebar Component**: `components/app-sidebar.tsx` - Left-side collapsible sidebar
- **Layout**: `app/(dashboard)/layout.tsx` - Uses SidebarProvider with header
- **Nav User**: `components/nav-user.tsx` - Profile dropdown with logout
- **Mobile Nav**: `components/dashboard/mobile-nav.tsx` - Bottom floating nav for mobile

### Current Navigation Items
| Item | Route | Icon | Priority |
|------|-------|------|----------|
| Dashboard | `/home` | Home | Primary |
| Projects | `/projects` | FolderKanban | Primary |
| Campus Connect | `/connect` | Users | Primary |
| Wallet | `/wallet` | Wallet | Primary |
| Profile | `/profile` | User | Secondary |
| Settings | `/settings` | Settings | Secondary |
| Help & Support | `/support` | HelpCircle | Secondary |

---

## New Design Specification

### Dock Positioning
- **Position**: Fixed at bottom center of viewport
- **Bottom Offset**: 50px from the bottom edge
- **Z-Index**: 50 (above content, below modals)
- **Width**: Auto (based on content)

### Dock Appearance
- **Style**: Glass morphism with backdrop blur
- **Background**: `bg-background/80 backdrop-blur-xl`
- **Border**: Subtle border with rounded corners (2xl)
- **Shadow**: Soft elevation shadow

### Icon Configuration
- **Default Size**: 40px
- **Magnified Size**: 60px (on hover)
- **Distance**: 140px (magnification falloff)
- **Gap**: 8px between icons

### Navigation Items in Dock
Primary navigation (always visible in dock):
1. **Home** - Dashboard
2. **Projects** - Project management
3. **Connect** - Campus Connect
4. **Wallet** - Finance
5. **Profile** - User menu (with dropdown for Settings, Help, Logout)

### Dock Separator
- Visual separator between main nav and profile section
- Subtle vertical line or increased gap

---

## Animation Specifications

### Dock Icon Animations
- **Magnification**: Icons grow from 40px to 60px when hovered
- **Spring Physics**: `{ mass: 0.1, stiffness: 150, damping: 12 }`
- **Neighbor Effect**: Adjacent icons partially magnify based on distance

### Page Transition Animations
When navigating between pages:

1. **Exit Animation** (current page):
   - Opacity: 1 → 0
   - Y position: 0 → -10px
   - Duration: 200ms
   - Easing: ease-out

2. **Enter Animation** (new page):
   - Opacity: 0 → 1
   - Y position: 10px → 0
   - Duration: 300ms
   - Easing: ease-out
   - Delay: 100ms (after exit completes)

### Active State Indicator
- **Style**: Dot indicator below active icon
- **Animation**: Scale in with spring physics
- **Color**: Primary color

---

## Component Architecture

### New Components to Create

#### 1. `components/dock/dock-nav.tsx`
Main dock navigation component containing:
- All navigation icons
- Profile dropdown trigger
- Active state management
- Tooltip on hover (for accessibility)

#### 2. `components/dock/dock-profile.tsx`
Profile icon with dropdown menu:
- Avatar display
- Settings link
- Help & Support link
- Logout action

#### 3. `components/dock/dock-tooltip.tsx`
Custom tooltip for dock items:
- Shows item label on hover
- Positioned above the dock
- Fade in/out animation

### Modified Components

#### `app/(dashboard)/layout.tsx`
- Remove SidebarProvider
- Remove AppSidebar
- Remove SidebarInset wrapper
- Add DockNav component
- Add page transition wrapper
- Update content padding for dock clearance

---

## File Changes Summary

### Files to Create
```
components/dock/dock-nav.tsx       # Main dock component
components/dock/dock-profile.tsx   # Profile dropdown
components/dock/dock-tooltip.tsx   # Tooltip component
components/dock/index.ts           # Barrel export
```

### Files to Modify
```
app/(dashboard)/layout.tsx         # Remove sidebar, add dock
app/globals.css                    # Add dock-specific styles
```

### Files to Potentially Remove/Deprecate
```
components/app-sidebar.tsx         # No longer needed (keep for reference)
components/nav-user.tsx            # Will be replaced by dock-profile
components/dashboard/mobile-nav.tsx # Unified dock works on all screens
```

---

## CSS Specifications

### New CSS Classes

```css
/* Dock Container */
.dock-container {
  position: fixed;
  bottom: 50px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 50;
}

/* Dock Glass Effect */
.dock-glass {
  background: hsl(var(--background) / 0.8);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid hsl(var(--border) / 0.3);
  box-shadow:
    0 8px 32px -8px rgba(0, 0, 0, 0.1),
    0 4px 16px -4px rgba(0, 0, 0, 0.05);
}

/* Active Indicator */
.dock-active-indicator {
  position: absolute;
  bottom: 4px;
  left: 50%;
  transform: translateX(-50%);
  width: 4px;
  height: 4px;
  border-radius: 50%;
  background: hsl(var(--primary));
}

/* Page Transition */
.page-transition-enter {
  opacity: 0;
  transform: translateY(10px);
}

.page-transition-enter-active {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 300ms ease-out, transform 300ms ease-out;
}

.page-transition-exit {
  opacity: 1;
  transform: translateY(0);
}

.page-transition-exit-active {
  opacity: 0;
  transform: translateY(-10px);
  transition: opacity 200ms ease-out, transform 200ms ease-out;
}
```

---

## Implementation Steps

### Phase 1: Create Dock Components

1. Create `components/dock/dock-nav.tsx`
   - Import Magic UI Dock and DockIcon
   - Define navigation items array
   - Render dock with all items
   - Add active state detection
   - Add tooltip support

2. Create `components/dock/dock-profile.tsx`
   - Avatar with user initials fallback
   - Dropdown menu with radix
   - Profile, Settings, Help links
   - Logout functionality (from nav-user.tsx)

3. Create barrel export `components/dock/index.ts`

### Phase 2: Add Styles

1. Add dock-specific CSS to globals.css
   - Container positioning
   - Glass morphism effect
   - Active indicator
   - Responsive adjustments

### Phase 3: Update Layout

1. Modify `app/(dashboard)/layout.tsx`
   - Remove all sidebar-related imports
   - Remove SidebarProvider wrapper
   - Remove AppSidebar component
   - Add DockNav at bottom
   - Add bottom padding for content (to not be hidden by dock)
   - Update header (remove sidebar trigger)

### Phase 4: Add Page Transitions

1. Create page transition wrapper component
2. Use Framer Motion AnimatePresence
3. Wrap children in layout with transition

### Phase 5: Testing & Cleanup

1. Test all navigation routes
2. Verify logout works
3. Test responsive behavior
4. Run build to check for errors
5. Remove deprecated components if confirmed working

---

## Responsive Behavior

### Desktop (lg+)
- Full dock with labels in tooltips
- Magnification effect enabled
- 50px bottom offset

### Tablet (md)
- Smaller icon sizes (36px default, 52px magnified)
- 40px bottom offset
- Same magnification effect

### Mobile (sm)
- Even smaller icons (32px default, 44px magnified)
- 30px bottom offset (accounting for home indicator)
- Slightly reduced gap between icons

---

## Accessibility Considerations

1. **Keyboard Navigation**
   - Tab through dock items
   - Enter/Space to activate
   - Arrow keys to move between items

2. **Screen Readers**
   - Proper aria-labels on all items
   - Role="navigation" on dock
   - aria-current="page" on active item

3. **Tooltips**
   - Show on focus for keyboard users
   - Sufficient contrast
   - Not just color-dependent

---

## Risk Mitigation

### Potential Issues
1. **Content hidden behind dock**: Add sufficient bottom padding
2. **Touch targets on mobile**: Ensure icons are at least 44px touch target
3. **Safari backdrop-filter**: Use webkit prefix
4. **Animation performance**: Use will-change and transform only

### Rollback Plan
- Keep original sidebar components (don't delete)
- Can revert layout.tsx to previous state
- CSS changes are additive (won't break existing)

---

## Success Criteria

- [ ] All navigation items accessible from dock
- [ ] Smooth magnification animation on hover
- [ ] Page transitions are smooth and not jarring
- [ ] Active state clearly visible
- [ ] Profile dropdown works with logout
- [ ] Build passes with no errors
- [ ] Works on desktop, tablet, and mobile
- [ ] No functionality regression

---

## Estimated Component Structure

```tsx
// dock-nav.tsx structure
<div className="dock-container">
  <Dock className="dock-glass" iconSize={40} iconMagnification={60}>
    <DockIcon> <Link href="/home"><Home /></Link> </DockIcon>
    <DockIcon> <Link href="/projects"><FolderKanban /></Link> </DockIcon>
    <DockIcon> <Link href="/connect"><Users /></Link> </DockIcon>
    <DockIcon> <Link href="/wallet"><Wallet /></Link> </DockIcon>
    <DockSeparator />
    <DockIcon> <DockProfile /> </DockIcon>
  </Dock>
</div>
```

---

## Next Steps

1. Read this document thoroughly
2. Begin implementation with Phase 1
3. Test incrementally after each phase
4. Document any deviations from plan
