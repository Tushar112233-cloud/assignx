# Unified Subject Areas Design

**Date:** 2026-03-15
**Status:** Approved

## Problem

Subject areas are defined independently across 7+ apps with 4 different lists (10-20 items each), different granularity, and incompatible ID formats. user-web sends string slugs as `subjectId`, doer_app sends plain strings, user_app uses a 16-value enum, and superviser-web uses free-text input. No matching between users' project subjects and doers' profile subjects is possible.

## Solution

Single source of truth: the `subjects` MongoDB collection, served via `GET /api/subjects`. All frontends fetch from this endpoint. No hardcoded subject lists.

## Canonical Subject List (20 subjects)

| Slug | Name | Category |
|------|------|----------|
| `engineering` | Engineering | STEM |
| `computer-science` | Computer Science | STEM |
| `mathematics` | Mathematics & Statistics | STEM |
| `physics` | Physics | STEM |
| `chemistry` | Chemistry | STEM |
| `biology` | Biology | STEM |
| `data-science` | Data Science | STEM |
| `business` | Business & Management | Business |
| `economics` | Economics | Business |
| `marketing` | Marketing | Business |
| `finance` | Finance | Business |
| `medicine` | Medicine & Healthcare | Health |
| `nursing` | Nursing | Health |
| `psychology` | Psychology | Social Sciences |
| `sociology` | Sociology | Social Sciences |
| `law` | Law | Humanities |
| `literature` | Humanities & Literature | Humanities |
| `history` | History | Humanities |
| `arts` | Arts & Design | Creative |
| `other` | Other | Other |

## Architecture

### API Server

**Subject Model** (`api-server/src/models/Subject.ts`) — add `slug` field to schema:

```typescript
interface ISubject {
  name: string;       // "Computer Science"
  slug: string;       // "computer-science" (unique, stable identifier)
  category: string;   // "STEM"
  isActive: boolean;
  createdAt: Date;
}

// Schema must add:
slug: { type: String, required: true, unique: true, index: true }
```

- `slug` is unique and indexed — used by frontends to map icons/colors
- `_id` (ObjectId) is what gets stored in `Project.subjectId`, `Doer.subjects[].subjectId`, `Supervisor.subjects[].subjectId`

**Project Model** (`api-server/src/models/Project.ts`) — change `subjectId` from `Schema.Types.Mixed` to `Schema.Types.ObjectId` with `ref: 'Subject'` after migration is complete, to enforce type safety.

**Seed Script** (`api-server/src/scripts/seed-test-data.ts`) — update `subjectNames` array to 20 subjects with slugs. Use **upsert by name** to preserve existing ObjectIds for the 10 subjects that already exist (Computer Science, Mathematics, etc.), and insert the 10 new ones. Update category values from old scheme (e.g., "Engineering" → "STEM") on existing records.

**`GET /api/subjects`** — endpoint already exists at `api-server/src/routes/reference.routes.ts`, returns `{ subjects: [...] }`. The slug field will be returned automatically once added to the model. No route changes needed. Note: query parameters like `is_active`, `parent_id`, `sort` are currently ignored by the handler — all filtering is hardcoded to `{ isActive: true }` sorted by name.

### user-web (Next.js)

**Current:** Hardcoded `lib/data/subjects.ts` with 10 categories, string IDs like `"engineering"`.

**Change:**
- Create `lib/hooks/use-subjects.ts` — SWR/fetch hook for `GET /api/subjects`
- Create `lib/data/subject-icons.ts` — client-side map of `slug -> { icon, color }` for UI presentation
- Update `SubjectSelector` component (`components/add-project/subject-selector.tsx`) to use fetched subjects + icon map
- When creating a project, send MongoDB `_id` as `subjectId` (not the slug)
- Keep `"other"` handling: if subject slug is `"other"`, show custom subject text input
- Legacy rendering: when displaying existing projects with string `subjectId` values, fall back to slug-based lookup

### user_app (Flutter)

**Current:** `ProjectSubject` enum with 16 hardcoded values in `lib/data/models/project_subject.dart`.

**Change:**
- Create `lib/data/models/subject.dart` — model class parsing API response
- Create `lib/data/repositories/subject_repository.dart` — fetches from `GET /api/subjects`
- Create `lib/data/providers/subjects_provider.dart` — Riverpod provider with caching
- Create `lib/core/constants/subject_icons.dart` — slug-to-icon/color map
- Update project creation form to use fetched subjects
- Remove `ProjectSubject` enum — update all references to use the API model

### doer_app (Flutter)

**Current:** 10 hardcoded `ChipOption` values in `ProfileSetupScreen` (`lib/features/onboarding/screens/profile_setup_screen.dart`, lines 115-126).

**Change:**
- Create `lib/data/models/subject.dart` — model class (same structure as user_app)
- Create `lib/data/repositories/subject_repository.dart` — fetches from API
- Create `lib/data/providers/subjects_provider.dart` — Riverpod provider
- Update `ProfileSetupScreen` to load `_subjectOptions` from provider instead of hardcoded list
- Send MongoDB `_id` values as `subjectIds` in profile setup
- Add `"other"` subject support (currently missing from doer_app)

### doer-web (Next.js)

**Current:** Already fetches from API in `ProfileSetupForm` (`components/onboarding/ProfileSetupForm.tsx`). Uses `GET /api/subjects?is_active=true&parent_id=null&sort=name` — note query params are ignored by API handler.

**Change:** Verify slug field renders correctly. This app is closest to correct already. Ensure it sends ObjectId `_id` values (not string slugs) when saving doer profile subjects.

### superviser-web (Next.js)

**Current:** Free-text `expertise_areas: string[]` in `components/profile/types.ts` (line 14) with manual add/remove in `ProfileEditor`. No structured subject selection.

**Change:**
- Create `lib/hooks/use-subjects.ts` — fetch hook (same pattern as user-web)
- Add `subjects: Array<{ subjectId: string; isPrimary: boolean }>` to `SupervisorProfile` type in `components/profile/types.ts`
- Update `ProfileEditor` to replace free-text expertise input with a multi-select of subjects from API
- On save, write selected subject `_id` values to `Supervisor.subjects[]` array (which already exists in the Mongoose model with `subjectId` refs)
- Keep `expertise` field as-is for backward compatibility (free-text skills/expertise), but subject selection is now structured

### superviser_app (Flutter)

**Current:** `preferredSubjects: List<String>` in `lib/features/profile/data/models/profile_model.dart` — parsed from API responses, not hardcoded in the model. Subject selection UI may have hardcoded options in profile edit screens.

**Change:**
- Create `lib/data/models/subject.dart` — model class
- Create `lib/data/repositories/subject_repository.dart` — fetches from API
- Update profile edit UI to use structured subject selection from API
- Send MongoDB `_id` values

### admin-web (Next.js)

**Current:** References subjects in project detail views and CRM components.

**Change:** Verify subject display works with the new slug-based data. admin-web primarily reads/displays subjects, so changes should be minimal — ensure it can resolve both ObjectId and legacy string `subjectId` values for display.

## Data Flow

```
subjects collection (MongoDB, with slug field)
    ↓
GET /api/subjects (API server)
    ↓
All frontends fetch on load
    ↓
Display: slug → icon/color map (client-side)
Storage: _id → subjectId field (sent to API)
    ↓
Matching: Project.subjectId === Doer.subjects[].subjectId
```

## Migration

### Seed Data Update
- Upsert existing 10 subjects by name (preserving their ObjectIds) — add `slug` field, update `category` to new values
- Insert 10 new subjects with slugs and categories
- Category renames: "Engineering" → "STEM", "Science" → "STEM", "Humanities" → "Humanities", "Business" → "Business", "Social Sciences" → "Social Sciences"
- Name updates: "Mathematics" → "Mathematics & Statistics", "English Literature" → "Humanities & Literature"

### Data Migration Script
- Run a one-time migration script that:
  1. Finds all projects where `subjectId` is a string (not ObjectId)
  2. Matches the string to the new subject's slug
  3. Updates `subjectId` to the corresponding ObjectId
- Same migration for any doer/supervisor records with string subject references
- **Backup:** Export affected collections before running migration
- **Rollback:** Keep a mapping of `{ documentId, oldSubjectId (string), newSubjectId (ObjectId) }` so changes can be reversed

### Schema Tightening
- After migration is verified, change `Project.subjectId` from `Schema.Types.Mixed` to `Schema.Types.ObjectId` with `ref: 'Subject'`

## Error Handling

- If `/api/subjects` fails, show a retry button (not a fallback hardcoded list — keeps the single source of truth principle clean)
- Subjects are cached client-side after first fetch (SWR for web, Riverpod for Flutter)
- Flutter cache strategy: cache until app restart (subjects change rarely)

## Testing

- API: Verify `GET /api/subjects` returns all 20 subjects with slugs
- Each frontend: Verify subjects render from API data
- Project creation: Verify `subjectId` is an ObjectId, not a string
- Doer profile: Verify subject IDs stored are ObjectIds
- Matching: Verify a project's `subjectId` matches a doer's `subjects[].subjectId`
- Legacy display: Verify existing projects with string `subjectId` still render correctly
