# Marketplace Loading Issue - Root Cause & Fix

**Date:** 2026-01-02
**Issue:** Marketplace page showing empty results
**Status:** ✅ FIXED

## Problem Summary

The marketplace page (`/connect`) was showing empty results even when listings exist in the database.

## Root Cause

The marketplace page defaulted to filtering listings by the user's university:

```typescript
// Before (WRONG)
const [universityOnly, setUniversityOnly] = useState(true); // Default to showing university content
```

**Why this caused empty results:**

1. **Default filter too restrictive**: When `universityOnly` is `true`, the app queries:
   ```typescript
   .eq("university_id", studentProfile.university_id)
   ```

2. **Missing university_id scenarios:**
   - User is a professional (not a student)
   - User's student profile doesn't have `university_id` set
   - User hasn't completed onboarding

3. **Result**: Query filters by `null` or missing university_id → **0 results**

## The Fix

Changed the default filter to show ALL listings:

```typescript
// After (CORRECT)
const [universityOnly, setUniversityOnly] = useState(false); // Default to showing all content
```

**Files Modified:**
- [page.tsx:140](../app/(dashboard)/connect/page.tsx#L140) - Changed default state
- [page.tsx:269](../app/(dashboard)/connect/page.tsx#L269) - Updated clearFilters() reset value

## How The Filter Works

### Query Logic in [marketplace.ts:269-280](../lib/actions/marketplace.ts#L269-L280)

```typescript
if (opts.universityOnly && user) {
  // Get user's university from their student profile
  const { data: studentProfile } = await supabase
    .from("students")
    .select("university_id")
    .eq("profile_id", user.id)
    .single();

  if (studentProfile?.university_id) {
    query = query.eq("university_id", studentProfile.university_id);
  }
}
```

**When universityOnly = true:**
- ✅ Student with university_id → Shows only their university's listings
- ❌ Student without university_id → Shows ALL listings (no filter applied)
- ❌ Professional user → Shows ALL listings (no student profile)

**When universityOnly = false (NEW DEFAULT):**
- ✅ Shows ALL active listings across all universities
- Users can manually toggle to "My Campus" if desired

## User Experience

### Before Fix
1. User visits `/connect`
2. Page loads with empty results
3. User thinks: "No one is selling anything?"
4. User leaves disappointed

### After Fix
1. User visits `/connect`
2. Page loads with **all available listings**
3. User sees active marketplace
4. User can optionally filter to "My Campus" if needed

## Toggle Behavior

The page includes two ways to enable university filtering:

1. **Quick Toggle Button** (line 424-435):
   ```tsx
   <Button onClick={() => setUniversityOnly(!universityOnly)}>
     <GraduationCap className="h-4 w-4" />
     <span>{universityOnly ? "My Campus" : "All Campuses"}</span>
   </Button>
   ```

2. **Filter Sheet** (line 355-367):
   ```tsx
   <Switch
     id="university-filter"
     checked={universityOnly}
     onCheckedChange={setUniversityOnly}
   />
   ```

## Testing

### To verify the fix:

1. **Log in to the app**:
   ```bash
   cd user-web && npm run dev
   ```

2. **Navigate to**: http://localhost:3000/connect

3. **Expected behavior**:
   - ✅ Page loads with all active marketplace listings
   - ✅ Toggle shows "All Campuses" by default
   - ✅ Clicking toggle switches to "My Campus" (university-specific)

### Diagnostic Endpoint

Created diagnostic API for troubleshooting:
- **Endpoint**: `GET /api/diagnose-marketplace`
- **File**: [route.ts](../app/api/diagnose-marketplace/route.ts)
- **Usage**: Visit while logged in to see system checks

## Database Structure

Relevant tables:
- `marketplace_listings` - Contains all listings with `university_id` field
- `students` - Links profiles to universities via `university_id`
- `professionals` - Professionals don't have university association

## Recommendations

1. **Default to inclusive**: Always default to showing more content rather than less
2. **Progressive filtering**: Let users opt-in to filters, not opt-out
3. **Graceful degradation**: If filter criteria can't be met, fall back to showing all content
4. **Clear UX**: The toggle button clearly shows current filter state

## Related Files

- [/connect/page.tsx](../app/(dashboard)/connect/page.tsx) - Main marketplace page
- [marketplace.ts](../lib/actions/marketplace.ts) - Server actions for data fetching
- [marketplace.ts](../types/marketplace.ts) - Type definitions
- [diagnose-marketplace/route.ts](../app/api/diagnose-marketplace/route.ts) - Diagnostic endpoint

## Future Improvements

1. **Smart defaults**:
   - If user has university_id → default to "My Campus"
   - If user doesn't have university_id → default to "All Campuses"

2. **Empty state messaging**:
   - When university filter shows 0 results → Suggest "Try All Campuses"

3. **Geolocation**:
   - Add distance-based filtering as alternative to university filtering

4. **Analytics**:
   - Track how often users toggle between campus views
   - Measure engagement with filtered vs. unfiltered results
