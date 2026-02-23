# Dashboard Changes List

## Overview
This document contains all requested changes for the Dashboard page in the user-web application.

---

## Change #1: Complete the Screen (Abrupt Cut Issue)
**Status:** Pending
**Priority:** High

### Description
The dashboard screen is currently cut off abruptly from the middle. The layout needs to be completed to show the full interface.

### Current Issue
- Screen appears incomplete with content being cut off
- Missing bottom sections or components
- Improper viewport/container height management

### Expected Outcome
- Full dashboard visible without any cutoffs
- Proper scrolling behavior if content exceeds viewport
- All sections properly contained and visible

### Files Likely Affected
- `app/(dashboard)/dashboard/page.tsx`
- `components/dashboard/*`
- Related layout components

---

## Change #2: Implement Animations
**Status:** Pending
**Priority:** High

### Description
Add animations to the dashboard components for better user experience and visual appeal.

### Expected Animations
- Card entrance animations
- Wallet card animations
- Button hover effects
- Transaction history animations
- Smooth transitions between states
- Cashback button interactions

### Technologies to Use
- Framer Motion (already in dependencies)
- GSAP (already in dependencies)
- CSS animations where appropriate

### Files Likely Affected
- All dashboard components
- Wallet components
- Button components

---

## Change #3: Smoother Scrolling on Wallet Page
**Status:** Pending
**Priority:** Medium

### Description
The animation on scrolling needs to be smoother on the wallet page. Current scrolling behavior is not smooth or feels janky.

### Current Issue
- Scrolling animations are choppy or not smooth
- Potential performance issues during scroll
- Scroll-triggered animations need refinement

### Expected Outcome
- Buttery smooth scroll animations
- Optimized scroll performance
- Proper scroll-triggered animation timing

### Technologies to Use
- Lenis (already in dependencies) for smooth scrolling
- GSAP ScrollTrigger
- Framer Motion scroll animations
- CSS `scroll-behavior: smooth`

### Files Likely Affected
- `app/(dashboard)/wallet/page.tsx`
- Wallet layout components
- Scroll container components

---

## Change #4: Update Expert Page Layout
**Status:** Pending - **Awaiting Layout Details**
**Priority:** High

### Description
Change the expert page layout as per the layout that will be provided by the user.

### Notes
- Layout specifications to be provided by user
- Design mockup or reference needed
- Specific requirements to be clarified

### Files Likely Affected
- `app/(dashboard)/expert/page.tsx` or similar
- Expert-related components

---

## Change #5: Update Layout Per Screenshot
**Status:** Pending
**Priority:** High

### Description
Change the layout as per the screenshot provided by the user.

### Screenshot Reference
- Screenshot shows: Dashboard with wallet card, transaction history, cashback buttons
- Key elements visible:
  - Top navigation (AssignX logo, Wallet tab)
  - Cashback buttons row (5 buttons)
  - Central black wallet card with "AssignX" branding
  - Card number: **** **** **** 4567
  - Four "Wallet Balance: 10,100" cards below
  - Action buttons: Send, Add money, Withdraw
  - Bottom navigation with icons
  - Transaction History section
  - Gradient background (purple/pink tones)

### Layout Requirements from Screenshot
1. **Header Section**
   - Logo on left
   - Wallet text/tab
   - Top-right controls

2. **Cashback Section**
   - Row of 5 cashback pill buttons
   - Horizontally scrollable if needed

3. **Wallet Card Section**
   - Centered black card with branding
   - Card number display
   - Proper spacing and sizing

4. **Balance Cards**
   - Four cards showing wallet balance (10,100)
   - Grid layout below main card
   - Consistent spacing

5. **Action Buttons**
   - Three buttons: Send, Add money, Withdraw
   - Centered below balance cards
   - Proper button styling

6. **Bottom Navigation**
   - Fixed bottom position
   - Icon-based navigation
   - Profile icon on right

7. **Transaction History**
   - Section below action buttons
   - Proper header
   - List layout

### Files Likely Affected
- `app/(dashboard)/dashboard/page.tsx`
- `app/(dashboard)/wallet/page.tsx`
- Dashboard layout components
- Wallet components

---

## Change #6: Move Gradient to Better Position
**Status:** Pending
**Priority:** Medium

### Description
The background gradient needs to be repositioned for better visual appeal and layout harmony.

### Current Issue
- Gradient position not optimal
- May be interfering with content readability
- Visual balance needs improvement

### Expected Outcome
- Gradient positioned to enhance the design
- Better visual hierarchy
- Improved content readability
- Maintains the purple/pink color scheme visible in screenshot

### Files Likely Affected
- Dashboard page layout
- Global styles
- Background component
- Tailwind CSS classes

---

## Implementation Priority Order

1. **Change #1**: Complete the screen (Foundation)
2. **Change #5**: Update layout per screenshot (Core layout)
3. **Change #6**: Move gradient (Visual refinement)
4. **Change #2**: Implement animations (Enhancement)
5. **Change #3**: Smoother scrolling (Polish)
6. **Change #4**: Expert page layout (Awaiting details)

---

## Notes
- All changes should maintain responsive design
- Ensure accessibility standards are met
- Test on multiple screen sizes
- Maintain existing functionality
- Follow existing code patterns and conventions
- Use existing dependencies (Framer Motion, GSAP, Lenis)

---

**Last Updated:** 2026-01-22
**Total Changes:** 6
**Status:** All Pending
