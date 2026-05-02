# tests-it:should

## Overview

Directory-based community: doer-web/tests

- **Size**: 36 nodes
- **Cohesion**: 0.0562
- **Dominant Language**: tsx

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| createMockProject | Function | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 150-165 |
| describe:ProjectsPage@L181 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 181-661 |
| beforeEach@L184 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 184-199 |
| describe:1. Data Loading@L201 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 201-248 |
| it:should load projects from all three categories on mount@L202 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 202-210 |
| it:should display loading skeleton when loading@L212 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 212-223 |
| it:should handle API errors gracefully@L225 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 225-234 |
| it:should not load projects when doer is not available@L236 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 236-247 |
| describe:2. Search Functionality@L250 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 250-338 |
| it:should filter projects by title when searching@L251 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 251-266 |
| it:should filter projects by subject name@L268 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 268-296 |
| it:should be case-insensitive when searching@L298 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 298-312 |
| it:should update results in real-time as user types@L314 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 314-337 |
| describe:3. Filter System@L340 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 340-429 |
| it:should filter projects by status@L341 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 341-357 |
| it:should filter urgent projects (deadline <= 3 days)@L359 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 359-393 |
| it:should sort projects by deadline@L395 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 395-410 |
| it:should update count badges when filters change@L412 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 412-428 |
| describe:4. Navigation@L431 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 431-483 |
| it:should navigate to project detail when card is clicked@L432 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 432-443 |
| it:should navigate to workspace when Open Workspace is clicked@L445 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 445-456 |
| it:should navigate from timeline in sidebar@L458 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 458-469 |
| it:should navigate to dashboard when New Project is clicked@L471 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 471-482 |
| describe:5. Refresh Mechanism@L485 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 485-558 |
| it:should reload data when refresh button is clicked@L486 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 486-505 |
| it:should disable refresh button during refresh@L507 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 507-533 |
| it:should show spinning icon during refresh@L535 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 535-557 |
| describe:6. Tab Switching@L560 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 560-592 |
| it:should switch to review tab when clicked@L561 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 561-575 |
| it:should switch to completed tab when clicked@L577 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 577-591 |
| describe:7. Edge Cases@L594 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 594-642 |
| it:should handle empty project lists@L595 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 595-603 |
| it:should handle search with no results@L605 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 605-619 |
| it:should handle projects with null payout values@L621 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 621-641 |
| describe:8. Performance@L644 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 644-660 |
| it:should use memoization to prevent unnecessary re-renders@L645 | Test | /Volumes/Crucial X9/AssignX/doer-web/tests/projects-page.spec.tsx | 645-659 |

## Execution Flows

No execution flows pass through this community.

## Dependencies

### Outgoing

- `expect` (61 edge(s))
- `toBeInTheDocument` (43 edge(s))
- `waitFor` (38 edge(s))
- `getByTestId` (36 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/app/(main)/projects/page.tsx::ProjectsPage` (26 edge(s))
- `render` (25 edge(s))
- `getByText` (24 edge(s))
- `resolve` (14 edge(s))
- `within` (13 edge(s))
- `click` (11 edge(s))
- `toHaveBeenCalledWith` (11 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/services/project.service.ts::getProjectsByCategory` (9 edge(s))
- `type` (7 edge(s))
- `mockReturnValue` (6 edge(s))
- `queryByText` (6 edge(s))

### Incoming

- `expect` (61 edge(s))
- `toBeInTheDocument` (43 edge(s))
- `waitFor` (38 edge(s))
- `getByTestId` (36 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/app/(main)/projects/page.tsx::ProjectsPage` (26 edge(s))
- `render` (25 edge(s))
- `getByText` (24 edge(s))
- `resolve` (14 edge(s))
- `within` (13 edge(s))
- `click` (11 edge(s))
- `toHaveBeenCalledWith` (11 edge(s))
- `type` (7 edge(s))
- `mockReturnValue` (6 edge(s))
- `queryByText` (6 edge(s))
- `mockImplementation` (4 edge(s))
