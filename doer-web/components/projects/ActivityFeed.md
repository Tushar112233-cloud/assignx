# ActivityFeed Component

A vertical scrollable activity feed component that displays recent project activities with time-based grouping, glassmorphism design, and smooth animations.

## Features

- ✅ **Time-based grouping**: Activities grouped into "Today", "Yesterday", "This Week", and "Older"
- ✅ **Activity types with icons**:
  - Project assigned (Briefcase icon)
  - Status changed (ArrowRight icon)
  - Revision requested (AlertTriangle icon)
  - Payment received (IndianRupee icon)
- ✅ **Glassmorphism cards**: Modern card design with soft shadows
- ✅ **Hover effects**: Smooth transitions and scale animations
- ✅ **Empty state**: Informative message when no activities exist
- ✅ **Loading state**: Skeleton loading animation
- ✅ **Responsive design**: Works on all screen sizes
- ✅ **Metadata display**: Shows payment amounts and status transitions

## Installation

The component is already integrated into the project. Simply import it:

```tsx
import { ActivityFeed } from '@/components/projects'
import type { Activity } from '@/components/projects'
```

## Props

| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `activities` | `Activity[]` | Yes | - | Array of activity objects to display |
| `isLoading` | `boolean` | No | `false` | Shows loading skeleton when true |

## Activity Type

```typescript
interface Activity {
  /** Unique identifier */
  id: string
  /** Type of activity */
  type: 'project_assigned' | 'status_changed' | 'revision_requested' | 'payment_received'
  /** Activity description */
  description: string
  /** Related project title */
  projectTitle: string
  /** Activity timestamp (ISO 8601 format) */
  timestamp: string
  /** Optional additional metadata */
  metadata?: {
    /** Old status for status changes */
    oldStatus?: string
    /** New status for status changes */
    newStatus?: string
    /** Payment amount */
    amount?: number
    /** Revision reason */
    reason?: string
  }
}
```

## Usage Examples

### Basic Usage

```tsx
import { ActivityFeed } from '@/components/projects'
import type { Activity } from '@/components/projects'

const activities: Activity[] = [
  {
    id: '1',
    type: 'project_assigned',
    description: 'New project assigned to you',
    projectTitle: 'Research Paper: Climate Change Impact',
    timestamp: new Date().toISOString(),
  },
  {
    id: '2',
    type: 'payment_received',
    description: 'Payment received for completed project',
    projectTitle: 'Thesis: AI in Healthcare',
    timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
    metadata: {
      amount: 2500,
    },
  },
]

export function Dashboard() {
  return <ActivityFeed activities={activities} />
}
```

### With Loading State

```tsx
'use client'

import { useState, useEffect } from 'react'
import { ActivityFeed } from '@/components/projects'
import type { Activity } from '@/components/projects'

export function ActivityFeedContainer() {
  const [activities, setActivities] = useState<Activity[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    async function fetchActivities() {
      try {
        const response = await fetch('/api/activities')
        const data = await response.json()
        setActivities(data)
      } catch (error) {
        console.error('Failed to fetch activities:', error)
      } finally {
        setIsLoading(false)
      }
    }

    fetchActivities()
  }, [])

  return <ActivityFeed activities={activities} isLoading={isLoading} />
}
```

### Sidebar Layout

```tsx
export function DashboardLayout() {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-[1fr_400px] gap-6">
      {/* Main content */}
      <main className="space-y-6">
        {/* Your main content here */}
      </main>

      {/* Activity feed sidebar */}
      <aside className="space-y-6">
        <ActivityFeed activities={activities} />
      </aside>
    </div>
  )
}
```

## Converting Project Data to Activities

Here's a helper function to transform project status changes into activities:

```typescript
import type { Project } from '@/types/database'
import type { Activity, ActivityType } from '@/components/projects'

/**
 * Convert project to activity based on status
 */
function projectToActivity(project: Project): Activity {
  const activityType = getActivityType(project.status)

  return {
    id: `activity-${project.id}-${project.status_updated_at}`,
    type: activityType,
    description: getActivityDescription(project.status),
    projectTitle: project.title,
    timestamp: project.status_updated_at || project.updated_at,
    metadata: {
      newStatus: project.status,
      amount: project.status === 'completed' ? project.doer_payout : undefined,
    },
  }
}

/**
 * Map project status to activity type
 */
function getActivityType(status: string): ActivityType {
  switch (status) {
    case 'assigned':
      return 'project_assigned'
    case 'revision_requested':
      return 'revision_requested'
    case 'completed':
      return 'payment_received'
    default:
      return 'status_changed'
  }
}

/**
 * Generate user-friendly description
 */
function getActivityDescription(status: string): string {
  switch (status) {
    case 'assigned':
      return 'New project assigned to you'
    case 'in_progress':
      return 'Started working on project'
    case 'submitted_for_qc':
      return 'Project submitted for QC review'
    case 'revision_requested':
      return 'Revision requested by supervisor'
    case 'delivered':
      return 'Project delivered to client'
    case 'completed':
      return 'Payment received for completed project'
    default:
      return 'Project status updated'
  }
}

// Usage
const activities = projects.map(projectToActivity)
```

## Design System

### Colors

The component uses the following color schemes from the design system:

- **Project Assigned**: Blue (`#5B86FF`)
- **Status Changed**: Emerald/Green
- **Revision Requested**: Orange (`#FF8B6A`)
- **Payment Received**: Teal

### Components Used

- `Card`, `CardContent`, `CardDescription`, `CardHeader`, `CardTitle` from `@/components/ui/card`
- Icons from `lucide-react`
- `motion` from `framer-motion` for animations
- `formatDistanceToNow` from `date-fns` for time formatting

### Styling Features

- **Rounded corners**: `rounded-2xl` for modern look
- **Glassmorphism**: Soft gradient backgrounds with transparency
- **Hover effects**: Scale and shadow transitions
- **Smooth scrolling**: Custom scrollbar styling
- **Responsive spacing**: Proper padding and gaps

## Accessibility

- Semantic HTML structure
- Proper heading hierarchy
- Descriptive labels and icons
- Keyboard navigation support
- Screen reader friendly

## Performance

- Activities sorted by timestamp efficiently
- Time-based grouping with O(n) complexity
- Memoized date calculations
- Optimized animations with Framer Motion

## Browser Support

Works on all modern browsers that support:
- CSS Grid
- CSS Flexbox
- CSS Custom Properties
- ES2015+

## Related Components

- `ProjectGridCard` - Project cards in grid layout
- `QuickFilters` - Filter system for projects
- `WorkspaceView` - Individual project workspace

## Future Enhancements

Potential improvements for future versions:

- Click handlers for activity items
- Filter by activity type
- Real-time updates via WebSocket
- Infinite scroll for large activity lists
- Export activity log
- Activity search

## Contributing

When modifying this component:

1. Maintain TypeScript strict mode compliance
2. Follow existing code style and patterns
3. Update documentation for any new props or features
4. Test with various activity counts and types
5. Ensure responsive design on all breakpoints
