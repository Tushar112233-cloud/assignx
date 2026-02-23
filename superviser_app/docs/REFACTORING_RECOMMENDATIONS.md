# Refactoring Recommendations

## Large Files Requiring Refactoring

### High Priority (900+ lines)

#### 1. profile_screen.dart (972 lines)
**Recommended Actions:**
- Extract `_ProfileHeader` to `widgets/profile_header.dart`
- Extract `_ProfileStats` to `widgets/profile_stats.dart`
- Extract `_ProfileSection` components to separate files
- Move form logic to dedicated form widgets
- Consider using a `ProfileFormController` for complex form state

#### 2. users_screen.dart (914 lines)
**Recommended Actions:**
- Extract `_UserCard` to `widgets/user_card.dart`
- Extract `_UserFilters` to `widgets/user_filters.dart`
- Extract `_UserDetailsSheet` to `widgets/user_details_sheet.dart`
- Separate search logic into provider

### Medium Priority (700-900 lines)

#### 3. project_detail_screen.dart (798 lines)
**Recommended Actions:**
- Extract timeline widget to `widgets/project_timeline.dart`
- Extract file attachment list to `widgets/project_files.dart`
- Extract action buttons to `widgets/project_actions.dart`
- Move status change logic to provider

#### 4. reviews_screen.dart (760 lines)
**Recommended Actions:**
- Extract review card to `widgets/review_card.dart`
- Extract rating display to `widgets/rating_display.dart`
- Extract review response form to separate widget

### Lower Priority (600-700 lines)

#### 5. doers_screen.dart (670 lines)
- Extract doer card and filters to widgets

#### 6. earnings_screen.dart (631 lines)
- Extract charts and statistics displays

## General Refactoring Guidelines

1. **Widget Extraction Rule**: Any widget class exceeding 100 lines should be extracted to its own file
2. **Component Files**: Group related widgets in feature/presentation/widgets/
3. **Naming Convention**: Use snake_case for files, PascalCase for classes
4. **Imports**: Use relative imports within features, package imports for cross-feature

## Migration Strategy

1. Start with leaf widgets (no dependencies on other local widgets)
2. Move to container widgets after dependencies are extracted
3. Update imports in parent files
4. Run tests after each extraction
5. Commit frequently with clear messages
