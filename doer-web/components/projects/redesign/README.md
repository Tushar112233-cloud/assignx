# Projects Redesign Components

Stunning, interactive components for the projects page redesign following the dashboard design system.

## Components

### 1. ProjectCard

A modern, interactive project card with advanced features:

**Features:**
- Hover lift effect (`translateY(-4px)`) with smooth transitions
- Status badge with pulse animation for active states
- Gradient progress bar with color coding
- Action buttons appearing on hover
- Prominent earnings display with gradient text
- Deadline countdown with color-coded urgency
- Fully responsive design

**Usage:**
```tsx
import { ProjectCard } from '@/components/projects/redesign'

<ProjectCard
  project={projectData}
  onProjectClick={(id) => router.push(`/projects/${id}`)}
  onOpenWorkspace={(id) => window.open(`/workspace/${id}`)}
  onChatClick={(id) => setActiveChatId(id)}
/>
```

**Design Details:**
- **Hover Effect:** Card lifts 4px with enhanced shadow
- **Status Badge:** Includes pulse animation for in_progress, revision_requested states
- **Progress Bar:** Gradient from `#5A7CFF` to `#49C5FF`, changes to rose for urgent
- **Action Buttons:** Fade in on hover with smooth opacity transition
- **Color Coding:**
  - Urgent/Overdue: Rose colors
  - In Progress: Sky blue
  - Completed: Emerald green
  - Not Started: Amber

### 2. TimelineView

Horizontal timeline view displaying projects as connected nodes.

**Features:**
- Horizontal scrollable timeline layout
- Status-based node styling with icons
- Pulse animations for active states
- Connecting lines between nodes
- Compact project info cards
- Responsive design with gradient scroll indicators
- Status legend at bottom

**Usage:**
```tsx
import { TimelineView } from '@/components/projects/redesign'

<TimelineView
  projects={projectsList}
  onProjectClick={(id) => router.push(`/projects/${id}`)}
/>
```

**Design Details:**
- **Node Icons:**
  - Completed: CheckCircle2 (emerald)
  - In Progress: Circle with pulse (sky)
  - Revision: AlertCircle with pulse (rose)
  - Not Started: Clock (amber)
- **Connecting Lines:** Color-matched to source node status
- **Scroll Indicators:** Gradient fades on left/right edges
- **Node Spacing:** 32px on mobile, 40px tablet, 48px desktop

### 3. FilterControls

Advanced filtering and view controls with pill-style design.

**Features:**
- Pill-style filter buttons with gradient on active
- View mode toggle (Grid/List/Timeline)
- Status filters with color coding
- Urgency filter with flame icon
- Sort options (Deadline, Price, Status, Created)
- Sort direction toggle
- Active filter count badge
- Clear all filters button
- Smooth Framer Motion animations

**Usage:**
```tsx
import { FilterControls, type FilterState } from '@/components/projects/redesign'

const [filters, setFilters] = useState<FilterState>({
  statuses: [],
  urgent: null,
  sortBy: 'deadline',
  sortDirection: 'asc'
})

<FilterControls
  viewMode={viewMode}
  onViewModeChange={setViewMode}
  filters={filters}
  onFiltersChange={setFilters}
  totalProjects={50}
  filteredProjects={12}
/>
```

**Design Details:**
- **Active Filters:** Gradient background `from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF]`
- **Inactive Filters:** White background with hover effect
- **View Toggle:** Rounded pill container with active gradient button
- **Sort Dropdown:** Arrow indicators for direction
- **Clear Button:** Only appears when filters are active
- **Sticky:** Positioned sticky at top with backdrop blur

## Design System Adherence

All components follow the dashboard design system:

**Colors:**
- Primary Blues: `#4F6CF7`, `#5A7CFF`, `#5B86FF`
- Accent Cyan: `#49C5FF`, `#43D1C5`
- Coral/Orange: `#FF9B7A`, `#FF8B6A`
- Light Backgrounds: `#EEF2FF`, `#F3F5FF`, `#E9FAFA`

**Typography:**
- Headings: `font-semibold` with `tracking-tight`
- Labels: `text-xs font-semibold uppercase tracking-wide`
- Body: `text-sm` or `text-base`

**Effects:**
- Rounded corners: `rounded-2xl`, `rounded-full`
- Shadows: `shadow-[0_12px_30px_rgba(148,163,184,0.12)]`
- Gradients: `bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF]`
- Hover lift: `hover:-translate-y-1` or `group-hover:translate-y-[-4px]`

## Animations

All components use Framer Motion for smooth animations:

- **Card Entrance:** Fade in + slide up with staggered delays
- **Hover Effects:** Scale and translate transforms
- **Status Pulses:** Infinite ping animation for active states
- **Filter Changes:** Scale on tap, smooth transitions
- **Progress Bars:** Animated width changes

## Responsive Design

Components are fully responsive:

- **Mobile (< 640px):** Single column, compact spacing
- **Tablet (640px - 1024px):** Two columns, medium spacing
- **Desktop (> 1024px):** Full layout, optimal spacing

## Accessibility

All components include:

- Proper ARIA labels
- Keyboard navigation support (Enter, Space)
- Focus indicators with ring styles
- Screen reader friendly text
- Semantic HTML elements

## TypeScript

Fully typed with TypeScript:

- Exported types for all props
- Database types from `@/types/database`
- Proper type inference for callbacks

## Performance

Optimized for performance:

- Memoized calculations where appropriate
- Efficient re-renders with proper key props
- Lazy animations with Framer Motion
- Debounced filter changes
- Virtualization-ready structure

## Integration

These components integrate seamlessly with:

- Existing project data from Supabase
- Shadcn/ui component library
- Tailwind CSS utility classes
- Framer Motion animations
- Next.js app router

## Next Steps

See the implementation plan for integration tasks:
- Phase 2: Main page integration (Agent 4-5)
- Phase 3: Animations & polish (Agent 6)
- QA: Testing and validation (Agent 7-10)
