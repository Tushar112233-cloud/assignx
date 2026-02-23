# Testing Checklist - Dashboard & Campus Connect Pages

## Pre-Test Setup
- [ ] Ensure Flutter SDK is updated
- [ ] Run `flutter pub get` to install dependencies
- [ ] Verify Android emulator is available (`flutter devices`)
- [ ] Check that `run.sh` script exists and is executable
- [ ] Review reference images from planner agent

## Phase 1: Automated Widget Tests

### Dashboard Page Tests
- [ ] Run: `flutter test test/pages/home_page_test.dart`
- [ ] Check test coverage: `flutter test --coverage`
- [ ] Review coverage report for gaps
- [ ] Fix any failing tests
- [ ] Document test results

### Campus Connect Page Tests
- [ ] Run: `flutter test test/pages/campus_connect_page_test.dart`
- [ ] Check test coverage: `flutter test --coverage`
- [ ] Review coverage report for gaps
- [ ] Fix any failing tests
- [ ] Document test results

### Integration Tests
- [ ] Run: `flutter test test/integration/`
- [ ] Verify navigation flows work correctly
- [ ] Check state preservation tests pass
- [ ] Document any integration issues

## Phase 2: Manual Testing on Emulator

### Setup Emulator
```bash
# Start Android emulator
bash run.sh

# OR if run.sh doesn't work:
flutter run
```

### Dashboard Page Manual Tests

#### Visual Inspection
- [ ] Hero section gradient renders correctly
- [ ] User greeting displays with name
- [ ] Motivational quote is visible and readable
- [ ] Avatar image loads (or placeholder shows)
- [ ] All 4 action cards are present and properly laid out
- [ ] Action card icons are correct and visible
- [ ] Action card colors match design
- [ ] Quick action buttons are visible
- [ ] Bottom navbar shows all 5 tabs
- [ ] Overall layout matches reference image

#### Interaction Tests
- [ ] Tap each action card - verify navigation works
  - [ ] View Tasks card
  - [ ] Quick Notes card
  - [ ] Schedule card
  - [ ] Resources card
- [ ] Tap "Create Task" button - verify action
- [ ] Tap "Join Event" button - verify action
- [ ] Tap each bottom navbar tab - verify navigation
  - [ ] Home (current page, should stay)
  - [ ] Campus Connect
  - [ ] Tasks
  - [ ] Profile
  - [ ] Settings

#### Scrolling Tests
- [ ] Scroll down on Dashboard
- [ ] Verify smooth scrolling (no jank)
- [ ] Check all content is accessible
- [ ] Verify no overflow or layout issues
- [ ] Test scroll back to top

#### Screenshot Capture
- [ ] Capture full Dashboard page screenshot
- [ ] Capture hero section close-up
- [ ] Capture action cards grid
- [ ] Capture bottom navbar
- [ ] Save to: `test_results/screenshots/dashboard/`

### Campus Connect Page Manual Tests

#### Visual Inspection
- [ ] Navigate to Campus Connect via bottom navbar
- [ ] Hero section gradient renders (deep purple to indigo)
- [ ] Title "Campus Connect" is visible and styled correctly
- [ ] Subtitle is visible and readable
- [ ] Search bar renders with correct styling
- [ ] Search icon is visible on left
- [ ] All 4 filter tabs are present
  - [ ] All
  - [ ] Events
  - [ ] Study Groups
  - [ ] Announcements
- [ ] Post cards render in feed
- [ ] Post avatars, usernames, timestamps visible
- [ ] Post content text is readable
- [ ] Like, Comment, Share buttons visible on each post
- [ ] Bottom navbar is visible
- [ ] Overall layout matches reference image

#### Interaction Tests
- [ ] Tap in search bar - verify keyboard appears
- [ ] Type in search bar - verify text appears
- [ ] Search for specific content - verify filtering works
- [ ] Clear search - verify all posts return
- [ ] Tap each filter tab:
  - [ ] "All" - shows all posts
  - [ ] "Events" - filters to events only
  - [ ] "Study Groups" - filters to study groups only
  - [ ] "Announcements" - filters to announcements only
- [ ] Verify active tab highlighting changes
- [ ] Tap Like button on post - verify count changes and visual feedback
- [ ] Tap Like again - verify unlike works
- [ ] Tap Comment button - verify navigation to comments
- [ ] Tap Share button - verify share action
- [ ] Tap post card - verify navigation to post detail

#### Scrolling Tests
- [ ] Scroll down through post feed
- [ ] Verify smooth scrolling (60 FPS)
- [ ] Check lazy loading works (if implemented)
- [ ] Scroll to bottom - verify no issues
- [ ] Scroll back up smoothly

#### Screenshot Capture
- [ ] Capture full Campus Connect page screenshot
- [ ] Capture hero section close-up
- [ ] Capture search and filter section
- [ ] Capture post feed with multiple posts
- [ ] Capture individual post card close-up
- [ ] Capture active filter tab states
- [ ] Save to: `test_results/screenshots/campus_connect/`

## Phase 3: Performance Testing

### Dashboard Page Performance
- [ ] Measure page load time (target: < 500ms)
  ```bash
  flutter run --profile
  # Use DevTools Timeline
  ```
- [ ] Check frame rate during scroll (target: 60 FPS)
- [ ] Monitor memory usage
- [ ] Check for memory leaks after multiple navigations
- [ ] Test with slow network simulation
- [ ] Document performance metrics

### Campus Connect Page Performance
- [ ] Measure page load time (target: < 700ms)
- [ ] Check frame rate during feed scroll (target: 60 FPS)
- [ ] Test with large number of posts (50+)
- [ ] Measure search performance (debounce works?)
- [ ] Check filter tab switching speed
- [ ] Monitor memory usage during scrolling
- [ ] Document performance metrics

## Phase 4: Visual Regression Testing

### Compare with Reference Images
For each screenshot captured:
- [ ] Compare Dashboard screenshots with reference
  - [ ] Overall layout match (%)
  - [ ] Color accuracy (%)
  - [ ] Component positioning (%)
  - [ ] Font sizes and styles match
- [ ] Compare Campus Connect screenshots with reference
  - [ ] Overall layout match (%)
  - [ ] Gradient accuracy (%)
  - [ ] Component positioning (%)
  - [ ] Font sizes and styles match
- [ ] Calculate visual accuracy score for each page
- [ ] Document differences found

### Visual Accuracy Scoring
```
Score = (Layout_Match * 0.4) + (Color_Accuracy * 0.3) + (Component_Positioning * 0.3)
Target: > 95%
```

## Phase 5: Edge Cases & Error Handling

### Dashboard Edge Cases
- [ ] Test with no user data
- [ ] Test with very long username
- [ ] Test with no avatar image
- [ ] Test offline behavior
- [ ] Test with slow API response
- [ ] Test rapid navigation (tap spamming)
- [ ] Test back button behavior

### Campus Connect Edge Cases
- [ ] Test with empty post feed
- [ ] Test with only 1-2 posts
- [ ] Test with 100+ posts
- [ ] Test search with no results
- [ ] Test filter with no matching posts
- [ ] Test offline behavior
- [ ] Test with very long post content
- [ ] Test rapid like/unlike spam
- [ ] Test rapid filter switching

## Phase 6: Cross-Device Testing (If Available)

### Different Screen Sizes
- [ ] Test on small phone (e.g., iPhone SE)
- [ ] Test on medium phone (e.g., Pixel 5)
- [ ] Test on large phone (e.g., Pixel 7 Pro)
- [ ] Test on tablet (if available)
- [ ] Verify responsive layout works
- [ ] Check no overflow on small screens

### Different OS Versions
- [ ] Test on Android 12 (if available)
- [ ] Test on Android 13 (if available)
- [ ] Test on Android 14 (if available)
- [ ] Document any OS-specific issues

## Phase 7: Accessibility Testing

### Screen Reader Compatibility
- [ ] Enable TalkBack (Android) or VoiceOver (iOS)
- [ ] Navigate Dashboard with screen reader
- [ ] Navigate Campus Connect with screen reader
- [ ] Verify all interactive elements are labeled
- [ ] Check navigation order is logical

### Contrast & Readability
- [ ] Verify text has sufficient contrast
- [ ] Check text is readable at default size
- [ ] Test with large text settings
- [ ] Verify touch targets are large enough (48x48dp minimum)

## Phase 8: Documentation

### Test Results Summary
Create: `test_results/TEST_RESULTS_SUMMARY.md`

Include:
- [ ] Total tests run vs passed
- [ ] Widget test coverage percentage
- [ ] Integration test results
- [ ] Visual accuracy scores
- [ ] Performance metrics
- [ ] Issues found with severity
- [ ] Screenshots comparison
- [ ] Recommendations for improvements

### Issues Found
For each issue:
- [ ] Severity (Critical/High/Medium/Low)
- [ ] Description
- [ ] Steps to reproduce
- [ ] Expected vs actual behavior
- [ ] Screenshot evidence
- [ ] Suggested fix

### Performance Report
- [ ] Dashboard load time
- [ ] Campus Connect load time
- [ ] Scroll FPS (both pages)
- [ ] Memory usage metrics
- [ ] Network request analysis
- [ ] Bottlenecks identified

## Phase 9: Reporting to Reviewer

### Memory Hook Update
```bash
npx claude-flow@alpha hooks post-edit \
  --file "test_results/TEST_RESULTS_SUMMARY.md" \
  --memory-key "hive/testing/results"
```

### Notification
```bash
npx claude-flow@alpha hooks notify \
  --message "Testing completed. Results available in memory: hive/testing/results"
```

### Final Hook
```bash
npx claude-flow@alpha hooks post-task \
  --task-id "testing-dashboard-campus"
```

## Success Criteria

### Automated Tests
- ✅ Widget test coverage > 90%
- ✅ All widget tests pass
- ✅ All integration tests pass
- ✅ No test failures

### Manual Tests
- ✅ All visual elements render correctly
- ✅ All interactions work as expected
- ✅ No crashes or errors
- ✅ Smooth navigation between pages

### Visual Accuracy
- ✅ Dashboard visual score > 95%
- ✅ Campus Connect visual score > 95%
- ✅ Layout matches reference images
- ✅ Colors and gradients accurate

### Performance
- ✅ Dashboard load < 500ms
- ✅ Campus Connect load < 700ms
- ✅ Scroll FPS consistently 60
- ✅ Memory usage < 100MB
- ✅ No memory leaks detected

### Edge Cases
- ✅ Handles empty states gracefully
- ✅ Error messages are helpful
- ✅ Offline behavior is acceptable
- ✅ No crashes in edge cases

---

**Completion**: Check off each item as you complete it. Document any issues or deviations from expected behavior immediately.
