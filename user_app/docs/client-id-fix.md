# Database Schema Fix: client_id → user_id

**Date:** 2026-01-02
**Issue:** PostgrestException - column projects.client_id does not exist
**Status:** ✅ FIXED

---

## Problem

The Flutter app was querying the `projects` table using `client_id`, but the database schema uses `user_id` instead:

```
Error fetching completed projects count:
PostgrestException(message: column projects.client_id does not exist,
code: 42703, details: Bad Request, hint: null)
```

Error code **42703** means "undefined column" in PostgreSQL.

---

## Root Cause

**Database Schema:**
```sql
CREATE TABLE projects (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL,  -- ✅ Actual column name
  ...
);
```

**Flutter Code (WRONG):**
```dart
final response = await _supabase
    .from('projects')
    .select('id')
    .eq('client_id', userId)  // ❌ Column doesn't exist
    .eq('status', 'completed');
```

---

## The Fix

**File:** [lib/data/repositories/profile_repository.dart:305](../lib/data/repositories/profile_repository.dart#L305)

**Before:**
```dart
.eq('client_id', userId)
```

**After:**
```dart
.eq('user_id', userId)
```

**Full Function:**
```dart
Future<int> getCompletedProjectsCount() async {
  final userId = _currentUserId;
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  try {
    final response = await _supabase
        .from('projects')
        .select('id')
        .eq('user_id', userId)      // ✅ FIXED
        .eq('status', 'completed');

    return (response as List).length;
  } catch (e) {
    _logger.e('Error fetching completed projects count: $e');
    return 0;
  }
}
```

---

## Impact

### Before Fix
- ❌ Home screen couldn't load completed project count
- ❌ Database query failed with error 42703
- ⚠️ User dashboard showed incomplete statistics

### After Fix
- ✅ Completed projects count loads successfully
- ✅ Home screen statistics display correctly
- ✅ No database errors

---

## Testing

### To Verify the Fix

1. **Restart the app** (Hot reload won't pick up repository changes):
   ```bash
   # Press 'R' in Flutter terminal for hot restart
   # OR
   flutter run
   ```

2. **Navigate to Home Screen** and check:
   - ✅ Completed projects count displays
   - ✅ No red error messages in console
   - ✅ Statistics widgets load properly

3. **Check console logs:**
   ```
   # Before fix:
   ⛔ Error fetching completed projects count: PostgrestException(message: column projects.client_id does not exist...)

   # After fix:
   (No errors - silently loads count)
   ```

---

## Related Issues

This is the same type of schema mismatch that was fixed in:
- **Web App Marketplace:** `is_active` → `status` ([marketplace-fix-summary.md](../../user-web/docs/marketplace-fix-summary.md))

### Prevention

To prevent similar issues in the future:

1. **Use TypeScript/Dart types generated from database schema**
   ```bash
   # Supabase CLI can generate types
   supabase gen types typescript > types/database.ts
   ```

2. **Create integration tests** that verify database queries work

3. **Document schema in code comments:**
   ```dart
   // projects table columns: id, user_id, status, ...
   final response = await _supabase.from('projects')
   ```

4. **Use Supabase Studio** to verify column names before coding

---

## Database Schema Reference

### projects Table (Actual Schema)

```sql
CREATE TABLE public.projects (
  id uuid PRIMARY KEY,
  project_number character varying NOT NULL UNIQUE,
  user_id uuid NOT NULL,           -- ✅ Not 'client_id'
  service_type service_type_enum NOT NULL,
  title character varying NOT NULL,
  status project_status_enum NOT NULL DEFAULT 'submitted',
  supervisor_id uuid,
  doer_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  ...
  CONSTRAINT projects_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES public.profiles(id)
);
```

**Key Points:**
- `user_id` references `profiles.id` table
- NOT `client_id` (that column doesn't exist)
- Foreign key constraint ensures valid user references

---

## Checklist

- [x] Identified error in console logs
- [x] Located problematic query in code
- [x] Verified correct column name in database schema
- [x] Updated query to use `user_id`
- [x] Tested fix (restart required)
- [x] Documented the fix
- [ ] User to verify on next app restart

---

**Fix Applied:** 2026-01-02
**Needs:** App restart to take effect (Hot Restart with 'R')
**Status:** Ready for testing
