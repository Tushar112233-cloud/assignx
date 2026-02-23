## Projects Page Redesign Plan

### Goals
- Redesign the projects dashboard UI/UX with a new layout and component structure.
- Keep the existing font hierarchy (Geist Sans) and overall visual tone consistent with the Doer site.
- Use shadcn UI components and existing theme tokens/utilities.

### Files to Update
- `doer-web/app/(main)/projects/page.tsx`
- `doer-web/components/projects/ActiveProjectsTab.tsx`
- `doer-web/components/projects/UnderReviewTab.tsx`
- `doer-web/components/projects/CompletedTab.tsx`

### Layout Strategy
- Replace the tab-first layout with a dashboard-style overview:
  - Hero header with search + refresh controls and a focus summary card.
  - KPI row with four compact stat tiles.
  - Two-column content: Active + Review on the left, Completed on the right.

### Component Redesign
- Active projects: stacked pipeline cards with progress, status chips, and strong action CTAs.
- Review queue: compact review rows with status, submission timing, and payout.
- Completed: summary header + list style entries with status, completion date, and invoice action.

### Data + UX Enhancements
- Add search filtering across all project lists (title, subject, supervisor, status).
- Highlight revision-required work as the priority project in the summary card.

### QA Checklist
- Verify empty states for each section.
- Verify search filtering and refresh behavior.
- Check responsive layout on mobile/tablet/desktop.
- Ensure typography hierarchy matches the dashboard (sizes/weights/spacing).
