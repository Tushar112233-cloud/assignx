# Unified Subject Areas Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify subject areas across all apps so users, doers, and supervisors all use the same API-served subject list, enabling proper matching.

**Architecture:** Add `slug` field to Subject MongoDB model, seed 20 canonical subjects, then update all 6 frontends to fetch from `GET /api/subjects` instead of using hardcoded lists. Client-side icon/color maps keyed by slug handle presentation.

**Tech Stack:** Express/MongoDB (API), Next.js (web apps), Flutter/Riverpod (mobile apps)

**Spec:** `docs/superpowers/specs/2026-03-15-unified-subject-areas-design.md`

---

## Chunk 1: API Server Foundation

### Task 1: Update Subject Model with slug field

**Files:**
- Modify: `api-server/src/models/Subject.ts`

- [ ] **Step 1:** Add `slug` field to ISubject interface and schema

```typescript
// api-server/src/models/Subject.ts
import mongoose, { Schema, Document } from 'mongoose';

export interface ISubject extends Document {
  name: string;
  slug: string;
  category: string;
  isActive: boolean;
  createdAt: Date;
}

const subjectSchema = new Schema<ISubject>({
  name: { type: String, required: true },
  slug: { type: String, required: true, unique: true, index: true },
  category: { type: String },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

export const Subject = mongoose.model<ISubject>('Subject', subjectSchema, 'subjects');
```

- [ ] **Step 2:** Commit

```bash
git add api-server/src/models/Subject.ts
git commit -m "feat: add slug field to Subject model"
```

### Task 2: Update seed script with 20 canonical subjects

**Files:**
- Modify: `api-server/src/scripts/seed-test-data.ts` (lines 50-61, the `subjectNames` array)

- [ ] **Step 1:** Replace the `subjectNames` array with 20 subjects including slugs

Replace the existing array (lines 50-61):
```typescript
const subjectNames = [
  { name: 'Engineering', slug: 'engineering', category: 'STEM' },
  { name: 'Computer Science', slug: 'computer-science', category: 'STEM' },
  { name: 'Mathematics & Statistics', slug: 'mathematics', category: 'STEM' },
  { name: 'Physics', slug: 'physics', category: 'STEM' },
  { name: 'Chemistry', slug: 'chemistry', category: 'STEM' },
  { name: 'Biology', slug: 'biology', category: 'STEM' },
  { name: 'Data Science', slug: 'data-science', category: 'STEM' },
  { name: 'Business & Management', slug: 'business', category: 'Business' },
  { name: 'Economics', slug: 'economics', category: 'Business' },
  { name: 'Marketing', slug: 'marketing', category: 'Business' },
  { name: 'Finance', slug: 'finance', category: 'Business' },
  { name: 'Medicine & Healthcare', slug: 'medicine', category: 'Health' },
  { name: 'Nursing', slug: 'nursing', category: 'Health' },
  { name: 'Psychology', slug: 'psychology', category: 'Social Sciences' },
  { name: 'Sociology', slug: 'sociology', category: 'Social Sciences' },
  { name: 'Law', slug: 'law', category: 'Humanities' },
  { name: 'Humanities & Literature', slug: 'literature', category: 'Humanities' },
  { name: 'History', slug: 'history', category: 'Humanities' },
  { name: 'Arts & Design', slug: 'arts', category: 'Creative' },
  { name: 'Other', slug: 'other', category: 'Other' },
];
```

- [ ] **Step 2:** Update the seed loop to upsert by slug (preserves existing ObjectIds)

Replace the existing seed loop (lines 63-71):
```typescript
const subjects = [];
for (const s of subjectNames) {
  const existing = await Subject.findOneAndUpdate(
    { slug: s.slug },
    { $set: { name: s.name, slug: s.slug, category: s.category, isActive: true } },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );
  subjects.push(existing!);
}
```

- [ ] **Step 3:** Commit

```bash
git add api-server/src/scripts/seed-test-data.ts
git commit -m "feat: update seed script with 20 canonical subjects and slugs"
```

### Task 3: Add migration script for existing data

**Files:**
- Create: `api-server/src/scripts/migrate-subjects.ts`

- [ ] **Step 1:** Create migration script

```typescript
// api-server/src/scripts/migrate-subjects.ts
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

import { Subject } from '../models/Subject';
import { Project } from '../models/Project';

const MONGODB_URI = process.env.MONGODB_URI || '';

// Mapping: old string IDs / names → new slugs
const SLUG_MAP: Record<string, string> = {
  // user-web string IDs
  'engineering': 'engineering',
  'business': 'business',
  'medicine': 'medicine',
  'law': 'law',
  'science': 'biology', // "Natural Sciences" → closest match
  'mathematics': 'mathematics',
  'humanities': 'literature',
  'social-sciences': 'psychology', // closest match
  'arts': 'arts',
  'other': 'other',
  // user_app enum names
  'computerscience': 'computer-science',
  'computerScience': 'computer-science',
  'computer science': 'computer-science',
  'datascience': 'data-science',
  'dataScience': 'data-science',
  'data science': 'data-science',
  'nursing': 'nursing',
  'history': 'history',
  'sociology': 'sociology',
  'chemistry': 'chemistry',
  'physics': 'physics',
  'psychology': 'psychology',
  'literature': 'literature',
  'economics': 'economics',
  'finance': 'finance',
  'marketing': 'marketing',
  'biology': 'biology',
  // Old seed names
  'mechanical engineering': 'engineering',
  'mechanicalengineering': 'engineering',
  'business management': 'business',
  'businessmanagement': 'business',
  'english literature': 'literature',
  'englishliterature': 'literature',
};

async function migrate() {
  console.log('Connecting to MongoDB...');
  await mongoose.connect(MONGODB_URI);

  // Step 1: Add slugs to existing subjects that don't have them
  const existingSubjects = await Subject.find({});
  for (const sub of existingSubjects) {
    if (!sub.slug) {
      const slug = sub.name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
      const mapped = SLUG_MAP[sub.name.toLowerCase().replace(/\s+/g, '')] || slug;
      await Subject.updateOne({ _id: sub._id }, { $set: { slug: mapped } });
      console.log(`Added slug "${mapped}" to subject "${sub.name}"`);
    }
  }

  // Step 2: Build slug → ObjectId map
  const allSubjects = await Subject.find({});
  const slugToId: Record<string, mongoose.Types.ObjectId> = {};
  for (const s of allSubjects) {
    slugToId[s.slug] = s._id as mongoose.Types.ObjectId;
  }

  // Step 3: Migrate projects with string subjectId
  const projects = await Project.find({});
  let migratedCount = 0;
  for (const p of projects) {
    const sid = p.subjectId;
    if (sid && typeof sid === 'string' && !/^[0-9a-fA-F]{24}$/.test(sid)) {
      const normalized = sid.toLowerCase().replace(/\s+/g, '');
      const slug = SLUG_MAP[normalized] || SLUG_MAP[sid] || sid;
      const objectId = slugToId[slug];
      if (objectId) {
        await Project.updateOne({ _id: p._id }, { $set: { subjectId: objectId } });
        migratedCount++;
        console.log(`Migrated project ${p._id}: "${sid}" → ObjectId(${objectId})`);
      } else {
        console.warn(`No match for project ${p._id} subjectId: "${sid}"`);
      }
    }
  }

  console.log(`\nMigrated ${migratedCount} projects.`);
  await mongoose.disconnect();
}

migrate().catch(console.error);
```

- [ ] **Step 2:** Commit

```bash
git add api-server/src/scripts/migrate-subjects.ts
git commit -m "feat: add subject data migration script"
```

---

## Chunk 2: user-web Changes

### Task 4: Create subject icon map and fetch hook

**Files:**
- Modify: `user-web/lib/data/subjects.ts` — replace hardcoded list with icon/color map
- Create: `user-web/lib/hooks/use-subjects.ts` — fetch hook

- [ ] **Step 1:** Rewrite `user-web/lib/data/subjects.ts` to be a slug-to-presentation map only

```typescript
// user-web/lib/data/subjects.ts
import {
  BookOpen, Calculator, Microscope, Scale, Heart,
  Briefcase, Cpu, Palette, Globe, Users, Beaker,
  GraduationCap, TrendingUp, DollarSign, Stethoscope,
  History, Brain, type LucideIcon,
} from "lucide-react";

export interface SubjectPresentation {
  icon: LucideIcon;
  color: string;
}

/** Client-side icon/color map keyed by subject slug */
export const subjectPresentationMap: Record<string, SubjectPresentation> = {
  "engineering":      { icon: Cpu, color: "bg-blue-500/10 text-blue-500" },
  "computer-science": { icon: Cpu, color: "bg-sky-500/10 text-sky-500" },
  "mathematics":      { icon: Calculator, color: "bg-indigo-500/10 text-indigo-500" },
  "physics":          { icon: Microscope, color: "bg-violet-500/10 text-violet-500" },
  "chemistry":        { icon: Beaker, color: "bg-emerald-500/10 text-emerald-500" },
  "biology":          { icon: Microscope, color: "bg-green-500/10 text-green-500" },
  "data-science":     { icon: TrendingUp, color: "bg-teal-500/10 text-teal-500" },
  "business":         { icon: Briefcase, color: "bg-purple-500/10 text-purple-500" },
  "economics":        { icon: TrendingUp, color: "bg-amber-500/10 text-amber-500" },
  "marketing":        { icon: Briefcase, color: "bg-fuchsia-500/10 text-fuchsia-500" },
  "finance":          { icon: DollarSign, color: "bg-lime-500/10 text-lime-500" },
  "medicine":         { icon: Heart, color: "bg-red-500/10 text-red-500" },
  "nursing":          { icon: Stethoscope, color: "bg-rose-500/10 text-rose-500" },
  "psychology":       { icon: Brain, color: "bg-pink-500/10 text-pink-500" },
  "sociology":        { icon: Users, color: "bg-cyan-500/10 text-cyan-500" },
  "law":              { icon: Scale, color: "bg-amber-500/10 text-amber-500" },
  "literature":       { icon: BookOpen, color: "bg-pink-500/10 text-pink-500" },
  "history":          { icon: History, color: "bg-stone-500/10 text-stone-500" },
  "arts":             { icon: Palette, color: "bg-orange-500/10 text-orange-500" },
  "other":            { icon: Globe, color: "bg-gray-500/10 text-gray-500" },
};

/** Get presentation for a subject by slug, with fallback */
export function getSubjectPresentation(slug: string): SubjectPresentation {
  return subjectPresentationMap[slug] || subjectPresentationMap["other"];
}

// Keep document types and turnaround times (unchanged)
export const documentTypes = [
  { id: "essay", name: "Essay" },
  { id: "thesis", name: "Thesis / Dissertation" },
  { id: "research-paper", name: "Research Paper" },
  { id: "report", name: "Report" },
  { id: "case-study", name: "Case Study" },
  { id: "assignment", name: "Assignment" },
  { id: "article", name: "Article" },
  { id: "other", name: "Other" },
];

export const turnaroundTimes = [
  { value: "72h", label: "72 Hours", price: 0.02 },
  { value: "48h", label: "48 Hours", price: 0.03 },
  { value: "24h", label: "24 Hours", price: 0.05 },
] as const;
```

- [ ] **Step 2:** Create `user-web/lib/hooks/use-subjects.ts`

```typescript
// user-web/lib/hooks/use-subjects.ts
"use client";

import { useState, useEffect } from "react";
import { apiClient } from "@/lib/api/client";

export interface ApiSubject {
  _id: string;
  name: string;
  slug: string;
  category: string;
  isActive: boolean;
}

interface UseSubjectsReturn {
  subjects: ApiSubject[];
  isLoading: boolean;
  error: string | null;
  retry: () => void;
}

export function useSubjects(): UseSubjectsReturn {
  const [subjects, setSubjects] = useState<ApiSubject[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchSubjects = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await apiClient<{ subjects: ApiSubject[] }>("/api/subjects");
      setSubjects(data.subjects);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load subjects");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSubjects();
  }, []);

  return { subjects, isLoading, error, retry: fetchSubjects };
}
```

- [ ] **Step 3:** Commit

```bash
git add user-web/lib/data/subjects.ts user-web/lib/hooks/use-subjects.ts
git commit -m "feat(user-web): add subject fetch hook and icon map"
```

### Task 5: Update SubjectSelector to use API data

**Files:**
- Modify: `user-web/components/add-project/subject-selector.tsx`

- [ ] **Step 1:** Update SubjectSelector to use `useSubjects` hook + presentation map

The component currently imports `subjects` from `@/lib/data/subjects` and uses `subject.id`, `subject.name`, `subject.icon`, `subject.color`. Update it to:
- Fetch from API via `useSubjects()`
- Map icons/colors from `getSubjectPresentation(subject.slug)`
- Use `subject._id` as the value (MongoDB ObjectId string)
- Use `subject.slug` to check for "other"

Key changes:
- Replace `import { subjects, type Subject } from "@/lib/data/subjects"` with imports from hooks + presentation map
- The `value` and `onChange` now pass `_id` (ObjectId string) instead of slug
- When checking for "other", look up the slug: `subjects.find(s => s._id === value)?.slug === "other"`
- Show loading state while fetching

- [ ] **Step 2:** Update `new-project-form.tsx` — the `subjectId` in payload is now already an ObjectId string (no change needed since SubjectSelector now passes `_id`)

- [ ] **Step 3:** Update `consultation-form.tsx` — same pattern, SubjectSelector already passes ObjectId

- [ ] **Step 4:** Update `step-subject.tsx` — update "other" check to use slug lookup instead of `=== "other"`

Check: `const selectedSubjectSlug = subjects.find(s => s._id === selectedSubject)?.slug;` then `selectedSubjectSlug === "other"` for custom subject input visibility.

- [ ] **Step 5:** Commit

```bash
git add user-web/components/add-project/
git commit -m "feat(user-web): update SubjectSelector to use API subjects"
```

---

## Chunk 3: Flutter Apps

### Task 6: Create shared Subject model for Flutter apps

**Files:**
- Create: `user_app/lib/data/models/subject.dart` (rewrite existing file)
- Create: `doer_app/lib/data/models/subject.dart`
- Create: `superviser_app/lib/data/models/subject.dart`

- [ ] **Step 1:** Create Subject model in user_app (replace existing ProjectSubject enum file)

```dart
// user_app/lib/data/models/subject.dart
import 'package:flutter/material.dart';

/// Subject model from API.
class Subject {
  final String id;
  final String name;
  final String slug;
  final String category;
  final bool isActive;

  const Subject({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    this.isActive = true,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  /// Client-side icon map by slug.
  IconData get icon => _slugIconMap[slug] ?? Icons.category;

  /// Client-side color map by slug.
  Color get color => _slugColorMap[slug] ?? const Color(0xFF9CA3AF);

  static const Map<String, IconData> _slugIconMap = {
    'engineering': Icons.engineering,
    'computer-science': Icons.computer,
    'mathematics': Icons.calculate,
    'physics': Icons.science,
    'chemistry': Icons.biotech,
    'biology': Icons.eco,
    'data-science': Icons.trending_up,
    'business': Icons.business_center,
    'economics': Icons.trending_up,
    'marketing': Icons.campaign,
    'finance': Icons.attach_money,
    'medicine': Icons.medical_services,
    'nursing': Icons.healing,
    'psychology': Icons.psychology,
    'sociology': Icons.groups,
    'law': Icons.gavel,
    'literature': Icons.menu_book,
    'history': Icons.history_edu,
    'arts': Icons.palette,
    'other': Icons.category,
  };

  static const Map<String, Color> _slugColorMap = {
    'engineering': Color(0xFF3B82F6),
    'computer-science': Color(0xFF0EA5E9),
    'mathematics': Color(0xFF6366F1),
    'physics': Color(0xFF8B5CF6),
    'chemistry': Color(0xFF10B981),
    'biology': Color(0xFF22C55E),
    'data-science': Color(0xFF14B8A6),
    'business': Color(0xFFA855F7),
    'economics': Color(0xFFF59E0B),
    'marketing': Color(0xFFD946EF),
    'finance': Color(0xFF84CC16),
    'medicine': Color(0xFFEF4444),
    'nursing': Color(0xFFF472B6),
    'psychology': Color(0xFFEC4899),
    'sociology': Color(0xFF06B6D4),
    'law': Color(0xFF78716C),
    'literature': Color(0xFF14B8A6),
    'history': Color(0xFFA78BFA),
    'arts': Color(0xFFF97316),
    'other': Color(0xFF9CA3AF),
  };
}
```

- [ ] **Step 2:** Copy same file to `doer_app/lib/data/models/subject.dart` and `superviser_app/lib/data/models/subject.dart`

- [ ] **Step 3:** Commit

```bash
git add user_app/lib/data/models/subject.dart doer_app/lib/data/models/subject.dart superviser_app/lib/data/models/subject.dart
git commit -m "feat: add Subject API model to all Flutter apps"
```

### Task 7: Create subject repository and provider for Flutter apps

**Files:**
- Create: `user_app/lib/data/repositories/subject_repository.dart`
- Create: `user_app/lib/providers/subjects_provider.dart`
- Create: `doer_app/lib/data/repositories/subject_repository.dart`
- Create: `doer_app/lib/providers/subjects_provider.dart`
- Create: `superviser_app/lib/features/common/data/repositories/subject_repository.dart`
- Create: `superviser_app/lib/features/common/providers/subjects_provider.dart`

- [ ] **Step 1:** Create subject repository for user_app

```dart
// user_app/lib/data/repositories/subject_repository.dart
import '../models/subject.dart';
import '../../core/api/api_client.dart';

class SubjectRepository {
  Future<List<Subject>> getSubjects() async {
    final response = await ApiClient.get('/api/subjects');
    final List<dynamic> subjectList = response['subjects'] ?? [];
    return subjectList.map((json) => Subject.fromJson(json)).toList();
  }
}
```

- [ ] **Step 2:** Create subjects provider for user_app

```dart
// user_app/lib/providers/subjects_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/subject.dart';
import '../data/repositories/subject_repository.dart';

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository();
});

final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  final repository = ref.watch(subjectRepositoryProvider);
  return repository.getSubjects();
});
```

- [ ] **Step 3:** Create same files for doer_app (identical code, different import paths)

- [ ] **Step 4:** Create same files for superviser_app at `lib/features/common/data/repositories/` and `lib/features/common/providers/` (following the feature-based structure)

- [ ] **Step 5:** Commit

```bash
git add user_app/lib/data/repositories/subject_repository.dart user_app/lib/providers/subjects_provider.dart
git add doer_app/lib/data/repositories/subject_repository.dart doer_app/lib/providers/subjects_provider.dart
git add superviser_app/lib/features/common/
git commit -m "feat: add subject repository and provider to all Flutter apps"
```

### Task 8: Update doer_app ProfileSetupScreen

**Files:**
- Modify: `doer_app/lib/features/onboarding/screens/profile_setup_screen.dart`

- [ ] **Step 1:** Replace hardcoded `_subjectOptions` (lines 115-126) with API-fetched subjects

Changes needed:
- Import `subjects_provider.dart` and `Subject` model
- Remove hardcoded `_subjectOptions` list
- In `_buildSkillsStep()`, use `ref.watch(subjectsProvider)` to get subjects
- Map API subjects to `ChipOption<String>` using `subject.id` as value and `subject.name` as label
- Show loading indicator while fetching
- Show error/retry if fetch fails
- The `_selectedSubjects` list now stores MongoDB ObjectId strings (not slug strings)

- [ ] **Step 2:** Update `_submitProfile()` — the `subjectIds` parameter already sends `_selectedSubjects`, which now contains ObjectId strings instead of slugs. No change needed to the submission logic itself.

- [ ] **Step 3:** Commit

```bash
git add doer_app/lib/features/onboarding/screens/profile_setup_screen.dart
git commit -m "feat(doer_app): fetch subjects from API in profile setup"
```

### Task 9: Update user_app project creation form

**Files:**
- Modify: `user_app/lib/features/add_project/screens/new_project_form.dart`
- Remove: `user_app/lib/data/models/project_subject.dart` (replaced by `subject.dart`)

- [ ] **Step 1:** Read the current `new_project_form.dart` to understand the subject selection UI

- [ ] **Step 2:** Replace `ProjectSubject` enum usage with API-fetched subjects via `ref.watch(subjectsProvider)`. Use `subject.id` (ObjectId) as the value sent to API, `subject.name` for display, `subject.icon`/`subject.color` for presentation.

- [ ] **Step 3:** Update any other files that import `project_subject.dart` to use the new `subject.dart` model

- [ ] **Step 4:** Delete `user_app/lib/data/models/project_subject.dart`

- [ ] **Step 5:** Commit

```bash
git add user_app/lib/features/add_project/ user_app/lib/data/models/
git commit -m "feat(user_app): use API subjects in project creation"
```

### Task 10: Update superviser_app profile

**Files:**
- Modify: `superviser_app/lib/features/profile/data/models/profile_model.dart`
- Modify: Profile edit screen (find the correct file in `superviser_app/lib/features/profile/`)

- [ ] **Step 1:** Read current profile edit screens to find where subjects are selected

- [ ] **Step 2:** Update to fetch from `subjectsProvider` instead of using hardcoded values

- [ ] **Step 3:** Commit

```bash
git add superviser_app/lib/features/
git commit -m "feat(superviser_app): use API subjects in profile"
```

---

## Chunk 4: superviser-web Changes

### Task 11: Add subject fetch hook to superviser-web

**Files:**
- Create: `superviser-web/lib/hooks/use-subjects.ts`

- [ ] **Step 1:** Create the hook (same pattern as user-web but using superviser-web's apiClient)

```typescript
// superviser-web/lib/hooks/use-subjects.ts
"use client";

import { useState, useEffect } from "react";

export interface ApiSubject {
  _id: string;
  name: string;
  slug: string;
  category: string;
  isActive: boolean;
}

interface UseSubjectsReturn {
  subjects: ApiSubject[];
  isLoading: boolean;
  error: string | null;
  retry: () => void;
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

export function useSubjects(): UseSubjectsReturn {
  const [subjects, setSubjects] = useState<ApiSubject[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchSubjects = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const res = await fetch(`${API_URL}/api/subjects`);
      if (!res.ok) throw new Error("Failed to fetch subjects");
      const data = await res.json();
      setSubjects(data.subjects || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load subjects");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSubjects();
  }, []);

  return { subjects, isLoading, error, retry: fetchSubjects };
}
```

- [ ] **Step 2:** Commit

```bash
git add superviser-web/lib/hooks/use-subjects.ts
git commit -m "feat(superviser-web): add useSubjects hook"
```

### Task 12: Update superviser-web ProfileEditor with structured subject selection

**Files:**
- Modify: `superviser-web/components/profile/profile-editor.tsx`
- Modify: `superviser-web/components/profile/types.ts`

- [ ] **Step 1:** Add `subjects` field to `SupervisorProfile` type

In `types.ts`, add:
```typescript
subjects: Array<{ subjectId: string; isPrimary: boolean }>;
```

- [ ] **Step 2:** Update `ProfileEditor` to replace free-text expertise input with subject multi-select

Replace the "Areas of Expertise" card (lines 234-275) with a subject multi-select that:
- Uses `useSubjects()` hook to fetch available subjects
- Shows checkboxes/badges for each subject
- Allows selecting multiple subjects
- Stores selected subject `_id` values in `editedProfile.subjects`
- Keeps the existing `expertise_areas` field as-is (for free-text skills that aren't subjects)

- [ ] **Step 3:** Commit

```bash
git add superviser-web/components/profile/
git commit -m "feat(superviser-web): replace free-text expertise with structured subject selection"
```

---

## Chunk 5: Verification & Cleanup

### Task 13: Verify doer-web compatibility

**Files:**
- Read: `doer-web/components/onboarding/ProfileSetupForm.tsx`

- [ ] **Step 1:** Verify that doer-web's ProfileSetupForm correctly handles the new `slug` field in subject responses

- [ ] **Step 2:** Verify it sends ObjectId `_id` values when saving profile (not string slugs)

- [ ] **Step 3:** Fix any issues found, commit if changes made

### Task 14: Run seed script and verify

- [ ] **Step 1:** Run the seed script to populate/update subjects in the database

```bash
cd api-server && npx ts-node-dev src/scripts/seed-test-data.ts
```

- [ ] **Step 2:** Verify subjects in MongoDB have slug field

- [ ] **Step 3:** Run the migration script if there are existing projects with string subjectId values

```bash
cd api-server && npx ts-node-dev src/scripts/migrate-subjects.ts
```

### Task 15: Final verification

- [ ] **Step 1:** Start the API server and verify `GET /api/subjects` returns 20 subjects with slugs
- [ ] **Step 2:** Test user-web project creation — verify SubjectSelector shows API subjects and sends ObjectId
- [ ] **Step 3:** Test doer_app profile setup — verify subjects load from API
- [ ] **Step 4:** Test superviser-web profile editor — verify structured subject selection works
