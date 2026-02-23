# Experts Page Redesign - Implementation Document

## Overview

This document outlines the complete redesign of the Experts page with a focus on:
- Medical professionals (doctors) as the primary highlight
- Modern, production-ready UI/UX
- "My Bookings" tab for managing consultations
- Consistent design language with other pages (landing, projects, campus-connect)

## Design Philosophy

- **Medical-First Theme**: Teal/cyan/blue gradients representing healthcare
- **Glassmorphic Cards**: Blur backgrounds with gradient borders
- **Smooth Animations**: Framer Motion for all transitions
- **Responsive Bento Grid**: Asymmetric layout highlighting featured doctors
- **Wrapping Filters**: Category pills that wrap (not scroll horizontally)

---

## Color Palette

### Primary Gradient
```css
from-teal-500 via-cyan-500 to-blue-500
/* #14B8A6 → #06B6D4 → #3B82F6 */
```

### Accent Colors
- Success: `#10B981` (Emerald)
- Warning: `#F59E0B` (Amber)
- Error: `#EF4444` (Red)
- Info: `#6366F1` (Indigo)

### Card Backgrounds
- Light: `bg-white/90 backdrop-blur-xl`
- Dark: `bg-slate-900/90 backdrop-blur-xl`

---

## Component Architecture

### File Structure
```
app/(dashboard)/experts/
├── page.tsx                    # Main experts page (redesigned)
└── loading.tsx                 # Loading skeleton

components/experts/
├── experts-hero.tsx            # Hero section with stats
├── experts-tabs.tsx            # Tab navigation (Doctors/All/Bookings)
├── doctors-carousel.tsx        # Featured doctors carousel
├── specialization-filter.tsx   # Wrapping category pills
├── doctors-grid.tsx            # Bento-style grid layout
├── doctor-card.tsx             # Enhanced doctor card
├── my-bookings.tsx             # Bookings management tab
├── booking-card.tsx            # Individual booking card
└── expert-card.tsx             # Existing (for all experts tab)
```

---

## Component Specifications

### 1. ExpertsHero
**Purpose**: Hero section with medical theme, search, and stats

**Features**:
- Mesh gradient background (teal → cyan → blue)
- Animated heading with gradient text
- Search bar for doctors/specializations
- Glassmorphic stat cards (Doctors, Rating, Sessions, Availability)
- Floating decorative elements (stethoscope, pulse line)

**Props**: None (self-contained)

**Animations**:
- Staggered fade-in for content
- Pulse animation on decorative elements
- Counter animation for stats

### 2. ExpertsTabs
**Purpose**: Tab navigation between Doctors, All Experts, and My Bookings

**Features**:
- Three tabs with icons
- Badge showing booking count
- Animated underline indicator
- Content fade transitions

**Props**:
```typescript
interface ExpertsTabsProps {
  activeTab: "doctors" | "all" | "bookings";
  onTabChange: (tab: "doctors" | "all" | "bookings") => void;
  bookingsCount?: number;
}
```

### 3. DoctorsCarousel
**Purpose**: Featured doctors auto-sliding carousel

**Features**:
- 5-second auto-slide interval
- Pause on hover
- Direction-aware animations
- Progress dots with fill animation
- Manual navigation arrows

**Props**:
```typescript
interface DoctorsCarouselProps {
  doctors: Expert[];
  onBookClick?: (doctor: Expert) => void;
}
```

### 4. SpecializationFilter
**Purpose**: Wrapping pill buttons for medical specializations

**Features**:
- Wrapping layout (flex-wrap)
- Active state with foreground/background inversion
- Fade animation on selection change
- Icons for each specialization

**Props**:
```typescript
interface SpecializationFilterProps {
  selected: string | "all";
  onSelect: (specialization: string | "all") => void;
}
```

### 5. DoctorsGrid
**Purpose**: Bento-style grid with featured doctor larger

**Features**:
- First doctor spans 2x2
- Remaining doctors in standard cards
- Staggered fade-in animation
- Responsive breakpoints

**Props**:
```typescript
interface DoctorsGridProps {
  doctors: Expert[];
  onBookClick?: (doctor: Expert) => void;
}
```

### 6. DoctorCard
**Purpose**: Enhanced doctor card with medical styling

**Features**:
- Two variants: default and featured
- Verified badge with pulse
- Rating display
- Specialization tags
- Price and availability
- Book button with gradient

**Props**:
```typescript
interface DoctorCardProps {
  doctor: Expert;
  variant?: "default" | "featured";
  onBookClick?: () => void;
}
```

### 7. MyBookings
**Purpose**: Tab content for managing user's bookings

**Features**:
- Sub-tabs: Upcoming, Completed, Cancelled
- Booking cards with status
- Action buttons (Message, Reschedule, Cancel)
- Empty state handling

**Props**:
```typescript
interface MyBookingsProps {
  bookings: ConsultationBooking[];
  onAction?: (action: string, bookingId: string) => void;
}
```

### 8. BookingCard
**Purpose**: Individual booking display card

**Features**:
- Doctor info with avatar
- Date/time display
- Status badge (color-coded)
- Countdown for upcoming
- Action buttons

**Props**:
```typescript
interface BookingCardProps {
  booking: ConsultationBooking;
  onMessage?: () => void;
  onReschedule?: () => void;
  onCancel?: () => void;
}
```

---

## Animation Specifications

### Page Load Sequence
| Element | Delay | Duration |
|---------|-------|----------|
| Hero | 0ms | 500ms |
| Stats Cards | 100ms stagger | 400ms |
| Tabs | 200ms | 300ms |
| Carousel | 300ms | 500ms |
| Grid | 400ms + 50ms stagger | 400ms |

### Carousel
- Auto-slide: 5000ms interval
- Transition: `spring({ stiffness: 300, damping: 30 })`
- Direction-aware enter/exit

### Cards
- Hover scale: 1.02
- Shadow transition: 200ms
- Border gradient fade: 150ms

### Tab Change
- Content fade: 150ms
- Indicator: `spring({ stiffness: 500, damping: 30 })`

---

## Responsive Breakpoints

| Breakpoint | Grid Columns | Carousel Cards | Layout |
|------------|--------------|----------------|--------|
| < 640px | 1 | 1 | Stack |
| 640-768px | 2 | 2 | 2-col |
| 768-1024px | 2 | 3 | 2-col |
| 1024-1280px | 3 | 3 | 3-col |
| > 1280px | 4 | 4 | 4-col |

---

## Data Types (from types/expert.ts)

### Expert Interface
```typescript
interface Expert {
  id: string;
  name: string;
  avatar: string | null;
  designation: string;
  bio: string;
  verified: boolean;
  rating: number;
  reviewCount: number;
  specializations: ExpertSpecialization[];
  pricePerSession: number;
  currency: string;
  availability: ExpertAvailability;
  sessionDuration: number;
  createdAt: string;
}
```

### ConsultationBooking Interface
```typescript
interface ConsultationBooking {
  id: string;
  expertId: string;
  expertName: string;
  expertAvatar: string | null;
  expertDesignation: string;
  userId: string;
  scheduledAt: string;
  duration: number;
  status: SessionStatus;
  amount: number;
  currency: string;
  meetingLink?: string;
  notes?: string;
  createdAt: string;
}
```

### SessionStatus
```typescript
type SessionStatus = "upcoming" | "in_progress" | "completed" | "cancelled" | "no_show";
```

---

## Implementation Phases

### Phase 1: Hero Section + Tab Navigation
- Create experts-hero.tsx with mesh gradient
- Create experts-tabs.tsx with animated indicator
- Update page.tsx structure

### Phase 2: Featured Carousel + Filters
- Create doctors-carousel.tsx with auto-slide
- Create specialization-filter.tsx with wrapping pills
- Add fade animation on filter change

### Phase 3: Doctor Cards + Bento Grid
- Create doctor-card.tsx with two variants
- Create doctors-grid.tsx with asymmetric layout
- Add staggered animations

### Phase 4: My Bookings Tab
- Create my-bookings.tsx with sub-tabs
- Create booking-card.tsx with actions
- Handle empty states

### Phase 5: Polish + QA
- Test all animations
- Verify responsive behavior
- Check dark mode
- Performance optimization

---

## Quality Checklist

- [ ] All animations smooth (60fps)
- [ ] Dark mode fully supported
- [ ] Mobile responsive
- [ ] Accessibility (ARIA labels)
- [ ] TypeScript types correct
- [ ] No console errors
- [ ] Loading states handled
- [ ] Empty states handled
- [ ] Error boundaries in place
- [ ] Performance optimized (memo, lazy)

---

## Dependencies

- framer-motion (existing)
- lucide-react (existing)
- @/components/ui/* (existing)
- tailwindcss (existing)

No new dependencies required.
