# Development Rules for User App Recreation

## Session Objective
Recreate the exact implementation of dashboard and Campus Connect pages from provided images, then apply the same design pattern to all other pages.

## Image References
- **Dashboard**: `C:\Users\omraj\Downloads\MobileDashboard_1.png`
- **Campus Connect**: `C:\Users\omraj\Downloads\CampusConnect_1.png`

## Critical Design Requirements

### 1. Dashboard Page (MobileDashboard_1.png)
- **Top Bar**: Fixed position with "AssignX" logo, wallet balance (₹10,100), notification bell
- **Greeting Section**:
  - Dynamic greeting ("Good Morning/Afternoon/Evening")
  - User first name display
  - Subtitle: "Ready to optimize your workflow and generate insights."
- **Action Cards Grid** (2x2 layout):
  1. New Project (+ icon)
  2. Plagiarism Check (shield icon)
  3. Generate Content (pen icon)
  4. Insights (chart icon)
- **Needs Attention Section**:
  - Horizontal scrollable list
  - Shows projects requiring action
  - Status indicators (payment due, delivered, etc.)
- **Bottom Navigation**: Fixed at 30-50px above bottom edge
- **Gradient**: Subtle creamy, orangish, purplish gradient overlay

### 2. Campus Connect Page (CampusConnect_1.png)
- **Top Bar**: Same as dashboard
- **Hero Section**:
  - Large gradient background (peachy/orangish to greenish/turquoise)
  - Centered chat bubble icon
  - "Campus Connect" title
- **Search Bar**: "Search campus posts..."
- **Filter Tabs**: Community, Opportunities, Products, Housing
- **Content Feed**:
  - Card-based layout
  - Staggered/masonry grid
  - Various post types (discussion, help, events, products, housing)
- **Bottom Navigation**: Same as dashboard (fixed position)

### 3. Bottom Navigation Specifications
- **Position**: Fixed at 30-50px above bottom edge (not at absolute bottom)
- **Icons** (5 items): Home, Projects/Folder, Community/People, Chat/Messages, Profile
- **Behavior**: Always visible, scrollable content above it
- **Style**: Clean, modern with active state indicators

## Development Workflow

### Page Completion Process
1. Implement the page matching the design 100%
2. Run Android emulator: `bash run.sh`
3. Capture screenshot of implemented page
4. Perform QA checks:
   - **Visual Accuracy**: Does it match the reference image?
   - **Layout**: Correct spacing, alignment, sizing
   - **Colors**: Exact color matching
   - **Typography**: Font sizes, weights, styles
   - **Interactions**: Tap targets, scrolling, animations
   - **Responsiveness**: Different screen sizes
5. Document any deviations and fix immediately
6. Move to next page only after current page passes QA

### QA Checklist (Per Page)
- [ ] Exact layout match with reference image
- [ ] Color scheme matches (gradients, backgrounds, text)
- [ ] Typography correct (sizes, weights, families)
- [ ] Spacing and padding accurate
- [ ] Icons match reference
- [ ] Bottom navbar fixed at correct position (30-50px from bottom)
- [ ] Scrollable content doesn't overlap navbar
- [ ] All tap targets work correctly
- [ ] Animations smooth and appropriate
- [ ] No console errors or warnings
- [ ] Performance optimized

## Flutter Best Practices

### Component Architecture
- **Create reusable components** for every UI element
- Break down into smallest possible components
- Use composition over inheritance
- Single responsibility principle

### Code Organization
```
lib/
├── features/
│   ├── dashboard/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── models/
│   ├── campus_connect/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── models/
│   └── ...
├── shared/
│   ├── widgets/
│   ├── decorations/
│   └── animations/
└── core/
    ├── theme/
    ├── constants/
    └── utils/
```

### Documentation
- **JSDoc comments** for all functions
- Document component props and purpose
- Explain complex logic
- Note any deviations from design

### Naming Conventions
- **Components**: PascalCase (e.g., `DashboardActionCard`)
- **Files**: snake_case (e.g., `dashboard_action_card.dart`)
- **Variables**: camelCase (e.g., `walletBalance`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `MAX_ITEMS`)

## Design Pattern Consistency

Once dashboard and Campus Connect are approved, apply these patterns to all pages:
1. **Same top bar** across all pages
2. **Same bottom navigation** (fixed 30-50px from bottom)
3. **Consistent gradients** and color schemes
4. **Same card styles** (rounded corners, shadows, etc.)
5. **Consistent typography** system
6. **Same icon style** throughout
7. **Consistent spacing** system
8. **Same animation** timings and curves

## Critical "Hate My Code" QA Perspective

Review every implementation with these critical questions:
1. **Readability**: Can someone understand this in 6 months?
2. **Reusability**: Is this component used more than once but not extracted?
3. **Magic Numbers**: Are there hardcoded values that should be constants?
4. **Nested Widgets**: Is the widget tree too deep (>4-5 levels)?
5. **Duplication**: Is there repeated code that should be extracted?
6. **Performance**: Are there unnecessary rebuilds?
7. **Null Safety**: Are all null cases handled?
8. **Error Handling**: What happens when things go wrong?
9. **Accessibility**: Is this usable for all users?
10. **State Management**: Is state properly managed?

## Testing After Each Page

### Manual Testing Checklist
- [ ] Launch emulator: `bash run.sh`
- [ ] Navigate to the page
- [ ] Test all interactions
- [ ] Try different screen orientations
- [ ] Test with different content (empty states, long text, etc.)
- [ ] Check all animations
- [ ] Verify scrolling behavior
- [ ] Test bottom navbar visibility during scroll
- [ ] Check performance (no jank or lag)
- [ ] Screenshot and compare with reference

### Screenshot Comparison
1. Take screenshot of implemented page
2. Place side-by-side with reference image
3. Identify any differences:
   - Layout differences
   - Color differences
   - Spacing differences
   - Font differences
   - Icon differences
4. Fix all differences before proceeding

## Priority Order

1. **Dashboard Page** (MobileDashboard_1.png)
   - Implement exact design
   - Test on emulator
   - QA review
   - Screenshot verification

2. **Campus Connect Page** (CampusConnect_1.png)
   - Implement exact design
   - Apply consistent patterns from dashboard
   - Test on emulator
   - QA review
   - Screenshot verification

3. **All Other Pages**
   - Apply the same design patterns
   - Follow the established component library
   - Maintain consistency across all pages

## Commit Strategy

After each page is completed and verified:
```bash
git add .
git commit -m "feat(page-name): implement exact design from reference image

- Layout matches reference 100%
- All interactions working
- QA checks passed
- Screenshot verified"
```

## Success Criteria

A page is considered complete when:
1. ✅ Visual match is 100% accurate
2. ✅ All interactions work correctly
3. ✅ No console errors or warnings
4. ✅ Performance is optimized
5. ✅ Code is clean and well-documented
6. ✅ Components are reusable
7. ✅ Screenshot verification passed
8. ✅ QA checklist completed
9. ✅ Committed to git
10. ✅ Ready for next page

## Notes

- **Never compromise on design accuracy** - match the reference exactly
- **Think component-first** - every UI element should be a component
- **Document everything** - future you will thank you
- **Test thoroughly** - catch issues early
- **Keep it consistent** - once patterns are established, follow them everywhere
