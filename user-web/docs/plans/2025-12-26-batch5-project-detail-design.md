# Batch 5: Project Detail Page - Design Document

> **Date:** 2025-12-26
> **Features:** U42-U55 (14 features)
> **Status:** Approved

---

## Design Decisions

| Question | Decision |
|----------|----------|
| Data Source | Extended Mock Data with deliverables, quality reports, attached files |
| Chat System | UI Shell Only with mock messages |
| Google Docs Viewer | Placeholder Card with "Track Progress Live" mockup |
| Quality Badges | Visual States Only (locked/passed/available) |

---

## File Structure

```
app/
└── project/
    └── [id]/
        └── page.tsx              # Project detail page

components/
└── project-detail/
    ├── index.ts                  # Barrel exports
    ├── project-detail-header.tsx # Sticky header + kebab menu
    ├── status-banner.tsx         # Colored status strip
    ├── deadline-countdown.tsx    # Real-time countdown
    ├── live-draft-tracker.tsx    # Google Docs placeholder card
    ├── project-brief-accordion.tsx # Collapsible brief section
    ├── attached-files.tsx        # User's uploaded files
    ├── deliverables-section.tsx  # Delivered files list
    ├── deliverable-item.tsx      # Single file row
    ├── quality-report-badge.tsx  # AI/Plagiarism badge
    ├── floating-chat-button.tsx  # Fixed chat FAB
    └── chat-window.tsx           # Overlay chat panel

lib/data/
└── project-details.json          # Extended mock data

types/
└── project.ts                    # Extended with new interfaces
```

---

## Extended Types

```typescript
interface AttachedFile {
  id: string;
  name: string;
  size: string;
  type: "pdf" | "doc" | "docx" | "image";
  uploadedAt: string;
}

interface Deliverable {
  id: string;
  name: string;
  size: string;
  version: number;
  uploadedAt: string;
  isFinal: boolean;
}

interface QualityReport {
  type: "ai" | "plagiarism";
  status: "locked" | "passed" | "available";
  score?: number;
  reportUrl?: string;
}

interface ChatMessage {
  id: string;
  sender: "user" | "supervisor";
  message: string;
  timestamp: string;
}

interface ProjectDetail extends Project {
  instructions: string;
  budget?: string;
  attachedFiles: AttachedFile[];
  deliverables: Deliverable[];
  qualityReports: QualityReport[];
  chatMessages: ChatMessage[];
  liveDocUrl?: string;
  supervisorName?: string;
}
```

---

## Component Specifications

### ProjectDetailHeader (sticky)
- Back arrow → navigates to `/projects`
- Project title (truncated if long)
- Kebab menu (DropdownMenu): "Cancel Project", "Contact Support"

### StatusBanner
- Thin 40px strip below header
- Full-width, colored by status (reuse STATUS_CONFIG)
- Shows status label + icon

### DeadlineCountdown
- Card with clock icon
- Real-time: "Due in: 3 Days, 14 Hours, 22 Min"
- Color shifts: green (>3 days), yellow (1-3 days), red (<24h)
- Uses useEffect with 1-minute interval

### LiveDraftTracker
- Card with document preview placeholder
- "Track Progress Live" title
- Button: "View Live Draft" (disabled if no URL)

### ProjectBriefAccordion
- shadcn Accordion, collapsed by default
- Sections: Subject, Word Count, Reference Style, Instructions, Budget
- AttachedFiles nested inside

### DeliverablesSection
- Card with "Deliverables" header
- Shows only when status is delivered/qc_approved/completed

### DeliverableItem
- Row with file icon, name, size, version badge
- "Download" button on right
- Final version highlighted with checkmark

### QualityReportBadge
- Two badges: AI Detection, Plagiarism Check
- States: locked (grayed), passed (green), available (blue)

### FloatingChatButton
- Fixed bottom-right (20px from edges)
- Circular 56px button with message icon
- Notification badge if unread

### ChatWindow
- Overlay panel: 380px × 500px (desktop)
- Sheet on mobile (80% height)
- Mock messages display only

---

## Page Layout

```
┌─────────────────────────────┐
│ ProjectDetailHeader (sticky)│
├─────────────────────────────┤
│ StatusBanner                │
├─────────────────────────────┤
│ DeadlineCountdown           │
├─────────────────────────────┤
│ LiveDraftTracker            │
├─────────────────────────────┤
│ ProjectBriefAccordion       │
│  └─ AttachedFiles           │
├─────────────────────────────┤
│ DeliverablesSection         │
│  └─ DeliverableItem(s)      │
├─────────────────────────────┤
│ QualityReportBadge (2x)     │
├─────────────────────────────┤
│ ProjectTimeline (reuse)     │
└─────────────────────────────┘
        FloatingChatButton [fixed]
```

## Conditional Rendering

| Component | Visible When |
|-----------|--------------|
| LiveDraftTracker | `in_progress` and later |
| DeliverablesSection | `delivered` and later |
| QualityReports | Always (locked for early statuses) |
| ProjectTimeline | Always (reuse from Batch 4) |

---

## Navigation

- From ProjectCard "View Details" → `/project/[id]`
- Back arrow → `/projects`
