# Training Modules Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable admins to upload training modules (video/document/text) that doers and supervisors must complete during onboarding before accessing the main app.

**Architecture:** Update existing TrainingModule model with new content type fields. Repurpose admin-web `/learning` page to manage training modules. Update doer-web and superviser-web training pages to render different content types with auto-completion tracking. Make API training routes role-aware for both doers and supervisors.

**Tech Stack:** Express + MongoDB (API), Next.js 16 + shadcn/ui + Tailwind (frontends), Cloudinary (file uploads), Zustand (state management)

**Spec:** `docs/superpowers/specs/2026-03-15-training-modules-design.md`

---

## Chunk 1: API Server — Model & Route Updates

### Task 1: Update TrainingModule Model

**Files:**
- Modify: `api-server/src/models/TrainingModule.ts`

- [ ] **Step 1: Update the interface and schema**

Replace the entire file content. Add `contentType`, `contentUrl`, `contentHtml`, `isMandatory`, rename `duration` to `durationMinutes`, keep `videoUrl` as deprecated alias.

```typescript
import mongoose, { Schema, Document } from 'mongoose';

export interface ITrainingModule extends Document {
  title: string;
  description: string;
  contentType: 'video' | 'document' | 'text';
  contentUrl: string;
  contentHtml: string;
  thumbnailUrl: string;
  durationMinutes: number;
  targetRole: 'doer' | 'supervisor' | 'all';
  isMandatory: boolean;
  order: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const trainingModuleSchema = new Schema<ITrainingModule>(
  {
    title: { type: String, required: true },
    description: { type: String, default: '' },
    contentType: { type: String, enum: ['video', 'document', 'text'], default: 'video' },
    contentUrl: { type: String, default: '' },
    contentHtml: { type: String, default: '' },
    thumbnailUrl: { type: String, default: '' },
    durationMinutes: { type: Number, default: 0 },
    targetRole: { type: String, enum: ['doer', 'supervisor', 'all'], default: 'all' },
    isMandatory: { type: Boolean, default: true },
    order: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export const TrainingModule = mongoose.model<ITrainingModule>('TrainingModule', trainingModuleSchema, 'training_modules');
```

- [ ] **Step 2: Verify API server still compiles**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit 2>&1 | head -20`

Fix any type errors in files that reference old fields (`videoUrl`, `duration`, `category`).

- [ ] **Step 3: Commit**

```bash
git add api-server/src/models/TrainingModule.ts
git commit -m "feat: update TrainingModule model with contentType, isMandatory, durationMinutes"
```

---

### Task 2: Update TrainingProgress Model

**Files:**
- Modify: `api-server/src/models/TrainingProgress.ts`

- [ ] **Step 1: Replace `completed` boolean with `status` enum, add `startedAt`**

```typescript
import mongoose, { Schema, Document, Types } from 'mongoose';

export interface ITrainingProgress extends Document {
  userId: Types.ObjectId;
  userRole: 'doer' | 'supervisor';
  moduleId: Types.ObjectId;
  status: 'not_started' | 'in_progress' | 'completed';
  progress: number;
  startedAt: Date;
  completedAt: Date;
  lastAccessedAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const trainingProgressSchema = new Schema<ITrainingProgress>(
  {
    userId: { type: Schema.Types.ObjectId, required: true },
    userRole: { type: String, enum: ['doer', 'supervisor'], required: true },
    moduleId: { type: Schema.Types.ObjectId, ref: 'TrainingModule', required: true },
    status: { type: String, enum: ['not_started', 'in_progress', 'completed'], default: 'not_started' },
    progress: { type: Number, default: 0 },
    startedAt: { type: Date },
    completedAt: { type: Date },
    lastAccessedAt: { type: Date },
  },
  { timestamps: true }
);

trainingProgressSchema.index({ userId: 1, userRole: 1, moduleId: 1 }, { unique: true });

export const TrainingProgress = mongoose.model<ITrainingProgress>('TrainingProgress', trainingProgressSchema, 'training_progress');
```

- [ ] **Step 2: Commit**

```bash
git add api-server/src/models/TrainingProgress.ts
git commit -m "feat: replace completed boolean with status enum in TrainingProgress"
```

---

### Task 3: Update Training Routes (Role-Aware)

**Files:**
- Modify: `api-server/src/routes/training.routes.ts`

- [ ] **Step 1: Rewrite training.routes.ts**

The key changes:
1. Import `Supervisor` and `SupervisorActivation` models
2. Make `/complete` and `/status` role-aware (branch on `req.user.role`)
3. Add monotonic progress guard to `PUT /progress/:moduleId`
4. Filter by `isMandatory: true` in completion validation
5. Return new content fields in `/status` response
6. Check `status === 'completed'` instead of `completed: true`

```typescript
import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { TrainingModule, TrainingProgress, Doer, SupervisorActivation } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// GET /training/modules
router.get('/modules', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { role } = req.query;
    const filter: Record<string, unknown> = { isActive: true };
    if (role) {
      filter.$or = [{ targetRole: role }, { targetRole: 'all' }];
    }

    const modules = await TrainingModule.find(filter).sort({ order: 1 });
    res.json({ modules });
  } catch (err) {
    next(err);
  }
});

// GET /training/progress
router.get('/progress', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userRole = req.user!.role === 'supervisor' ? 'supervisor' : 'doer';
    const progress = await TrainingProgress.find({ userId: req.user!.id, userRole })
      .populate('moduleId');
    res.json({ progress });
  } catch (err) {
    next(err);
  }
});

// PUT /training/progress/:moduleId — monotonic progress, auto-complete at 100
router.put('/progress/:moduleId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userRole = req.user!.role === 'supervisor' ? 'supervisor' : 'doer';
    const newProgress = Number(req.body.progress) || 0;

    // Find existing record
    const existing = await TrainingProgress.findOne({
      userId: req.user!.id,
      userRole,
      moduleId: req.params.moduleId,
    });

    // Monotonic guard: only increase, never un-complete
    if (existing) {
      if (existing.status === 'completed') {
        return res.json({ progress: existing });
      }
      if (newProgress <= existing.progress) {
        return res.json({ progress: existing });
      }
    }

    const updates: Record<string, unknown> = {
      progress: newProgress,
      lastAccessedAt: new Date(),
      userRole,
    };

    if (!existing || existing.status === 'not_started') {
      updates.startedAt = existing?.startedAt || new Date();
      updates.status = newProgress >= 100 ? 'completed' : 'in_progress';
    } else {
      updates.status = newProgress >= 100 ? 'completed' : 'in_progress';
    }

    if (newProgress >= 100) {
      updates.completedAt = new Date();
      updates.status = 'completed';
      updates.progress = 100;
    }

    const progress = await TrainingProgress.findOneAndUpdate(
      { userId: req.user!.id, userRole, moduleId: req.params.moduleId },
      updates,
      { new: true, upsert: true }
    );
    res.json({ progress });
  } catch (err) {
    next(err);
  }
});

// POST /training/complete — role-aware: doer or supervisor
router.post('/complete', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const role = req.user!.role;
    const userRole = role === 'supervisor' ? 'supervisor' : 'doer';
    const targetRoleFilter = role === 'supervisor' ? 'supervisor' : 'doer';

    // Get all mandatory modules for this role
    const mandatoryModules = await TrainingModule.find({
      isActive: true,
      isMandatory: true,
      $or: [{ targetRole: targetRoleFilter }, { targetRole: 'all' }],
    });

    // Verify all mandatory modules are completed
    if (mandatoryModules.length > 0) {
      const completedProgress = await TrainingProgress.find({
        userId,
        userRole,
        status: 'completed',
        moduleId: { $in: mandatoryModules.map(m => m._id) },
      });

      if (completedProgress.length < mandatoryModules.length) {
        throw new AppError(
          `You must complete all ${mandatoryModules.length} required modules. ${completedProgress.length} completed so far.`,
          400
        );
      }
    }

    // Update the appropriate record based on role
    if (role === 'supervisor') {
      const activation = await SupervisorActivation.findOne({ supervisorId: userId });
      if (!activation) {
        throw new AppError('Supervisor activation record not found.', 404);
      }
      activation.trainingCompleted = true;
      activation.set('trainingCompletedAt', new Date());
      await activation.save();
    } else {
      const doer = await Doer.findById(userId);
      if (!doer) {
        throw new AppError('Doer profile not found.', 404);
      }
      doer.trainingCompleted = true;
      doer.trainingCompletedAt = new Date();
      await doer.save();
    }

    res.json({ success: true, message: 'Training completed successfully!' });
  } catch (err) {
    next(err);
  }
});

// GET /training/status — role-aware
router.get('/status', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const role = req.user!.role;
    const userRole = role === 'supervisor' ? 'supervisor' : 'doer';
    const targetRoleFilter = role === 'supervisor' ? 'supervisor' : 'doer';

    // Check if training already completed
    let trainingCompleted = false;
    if (role === 'supervisor') {
      const activation = await SupervisorActivation.findOne({ supervisorId: userId });
      trainingCompleted = activation?.trainingCompleted ?? false;
    } else {
      const doer = await Doer.findById(userId);
      if (!doer) {
        throw new AppError('Doer profile not found.', 404);
      }
      trainingCompleted = doer.trainingCompleted ?? false;
    }

    // Get all mandatory modules for this role
    const mandatoryModules = await TrainingModule.find({
      isActive: true,
      isMandatory: true,
      $or: [{ targetRole: targetRoleFilter }, { targetRole: 'all' }],
    }).sort({ order: 1 });

    // Get progress for mandatory modules
    const progress = await TrainingProgress.find({
      userId,
      userRole,
      moduleId: { $in: mandatoryModules.map(m => m._id) },
    });

    const progressMap = new Map(progress.map(p => [p.moduleId.toString(), p]));

    const modules = mandatoryModules.map(m => ({
      id: m._id,
      title: m.title,
      description: m.description,
      contentType: m.contentType,
      contentUrl: m.contentUrl,
      contentHtml: m.contentHtml,
      thumbnailUrl: m.thumbnailUrl,
      durationMinutes: m.durationMinutes,
      isMandatory: m.isMandatory,
      order: m.order,
      status: progressMap.get(m._id.toString())?.status || 'not_started',
      progress: progressMap.get(m._id.toString())?.progress || 0,
    }));

    res.json({
      trainingCompleted,
      totalRequired: mandatoryModules.length,
      completedRequired: progress.filter(p => p.status === 'completed').length,
      modules,
    });
  } catch (err) {
    next(err);
  }
});

export default router;
```

- [ ] **Step 2: Verify compilation**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit 2>&1 | head -20`

- [ ] **Step 3: Commit**

```bash
git add api-server/src/routes/training.routes.ts
git commit -m "feat: make training routes role-aware for doer and supervisor"
```

---

### Task 4: Update Admin Routes (Soft Delete)

**Files:**
- Modify: `api-server/src/routes/admin.routes.ts:483-488`

- [ ] **Step 1: Change hard-delete to soft-delete**

Find the delete endpoint at line 483 and replace `findByIdAndDelete` with a soft-delete:

```typescript
// Old (line 483-488):
router.delete('/training-modules/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await TrainingModule.findByIdAndDelete(req.params.id);
    res.json({ success: true });
  } catch (err) { next(err); }
});

// New:
router.delete('/training-modules/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const module = await TrainingModule.findByIdAndUpdate(req.params.id, { isActive: false }, { new: true });
    if (!module) throw new AppError('Module not found', 404);
    res.json({ success: true });
  } catch (err) { next(err); }
});
```

- [ ] **Step 2: Commit**

```bash
git add api-server/src/routes/admin.routes.ts
git commit -m "fix: change training module delete to soft-delete"
```

---

## Chunk 2: Admin-Web — Training Modules Management

### Task 5: Update Admin Actions to Use Training Modules API

**Files:**
- Modify: `admin-web/lib/admin/actions/learning.ts`

- [ ] **Step 1: Rewrite actions to point to training-modules endpoints**

```typescript
"use server";

import { verifyAdmin, serverFetch } from "@/lib/admin/auth";

export async function getTrainingModules(params: {
  search?: string;
  contentType?: string;
  targetRole?: string;
  page?: number;
  perPage?: number;
}) {
  await verifyAdmin();

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.contentType) query.set("contentType", params.contentType);
  if (params.targetRole) query.set("targetRole", params.targetRole);
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));

  try {
    const result = await serverFetch(`/api/admin/training-modules?${query.toString()}`);
    const arr = result.modules || result.data || [];
    return {
      data: arr,
      total: result.total || arr.length,
      page: result.page || params.page || 1,
      totalPages: result.totalPages || Math.ceil((result.total || arr.length) / (params.perPage || 20)),
    };
  } catch {
    return { data: [], total: 0, page: params.page || 1, totalPages: 1 };
  }
}

export async function getTrainingModuleById(id: string) {
  await verifyAdmin();
  return serverFetch(`/api/admin/training-modules/${id}`);
}

export async function createTrainingModule(formData: {
  title: string;
  description?: string;
  contentType: string;
  contentUrl?: string;
  contentHtml?: string;
  thumbnailUrl?: string;
  durationMinutes?: number;
  targetRole: string;
  isMandatory?: boolean;
  order?: number;
  isActive?: boolean;
}) {
  await verifyAdmin();

  return serverFetch(`/api/admin/training-modules`, {
    method: "POST",
    body: JSON.stringify(formData),
  });
}

export async function updateTrainingModule(
  id: string,
  formData: {
    title?: string;
    description?: string;
    contentType?: string;
    contentUrl?: string;
    contentHtml?: string;
    thumbnailUrl?: string;
    durationMinutes?: number;
    targetRole?: string;
    isMandatory?: boolean;
    order?: number;
    isActive?: boolean;
  }
) {
  await verifyAdmin();

  return serverFetch(`/api/admin/training-modules/${id}`, {
    method: "PUT",
    body: JSON.stringify(formData),
  });
}

export async function deleteTrainingModule(id: string) {
  await verifyAdmin();

  await serverFetch(`/api/admin/training-modules/${id}`, {
    method: "DELETE",
  });

  return { success: true };
}

export async function toggleModuleActive(id: string, isActive: boolean) {
  await verifyAdmin();

  await serverFetch(`/api/admin/training-modules/${id}`, {
    method: "PUT",
    body: JSON.stringify({ isActive }),
  });

  return { success: true };
}
```

- [ ] **Step 2: Commit**

```bash
git add admin-web/lib/admin/actions/learning.ts
git commit -m "feat: rewrite admin learning actions to use training-modules API"
```

---

### Task 6: Update Admin Types

**Files:**
- Modify: `admin-web/lib/admin/types.ts`

- [ ] **Step 1: Add/update TrainingModule type**

Find the existing `LearningResource` type and add a `TrainingModule` type alongside it (or replace if `LearningResource` is no longer used elsewhere):

```typescript
/** Training module managed by admin */
export type TrainingModule = {
  id: string;
  _id?: string;
  title: string;
  description: string;
  contentType: 'video' | 'document' | 'text';
  contentUrl: string;
  contentHtml: string;
  thumbnailUrl: string;
  durationMinutes: number;
  targetRole: 'doer' | 'supervisor' | 'all';
  isMandatory: boolean;
  order: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
};
```

- [ ] **Step 2: Commit**

```bash
git add admin-web/lib/admin/types.ts
git commit -m "feat: add TrainingModule type to admin types"
```

---

### Task 7: Rebuild Learning Data Table for Training Modules

**Files:**
- Modify: `admin-web/components/admin/learning/learning-data-table.tsx`

- [ ] **Step 1: Rewrite data table for training modules**

Replace the entire file. Key changes:
- Use `TrainingModule` type instead of `LearningResource`
- Columns: Title, Content Type, Target Role, Required, Order, Active, Actions
- Import actions from updated learning.ts
- Content type badges: video (purple), document (red), text (blue)
- Target role badges: doer (green), supervisor (orange), all (gray)

```typescript
"use client";

import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { useCallback, useState } from "react";
import {
  useReactTable,
  getCoreRowModel,
  flexRender,
  type ColumnDef,
} from "@tanstack/react-table";
import Link from "next/link";
import {
  Table, TableHeader, TableRow, TableHead, TableBody, TableCell,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu, DropdownMenuTrigger, DropdownMenuContent,
  DropdownMenuItem, DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import {
  Select, SelectTrigger, SelectValue, SelectContent, SelectItem,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import {
  IconDotsVertical, IconEdit, IconTrash, IconPlus,
} from "@tabler/icons-react";
import { deleteTrainingModule, toggleModuleActive } from "@/lib/admin/actions/learning";
import { toast } from "sonner";
import type { TrainingModule } from "@/lib/admin/types";

const contentTypeColors: Record<string, string> = {
  video: "bg-purple-100 text-purple-800",
  document: "bg-red-100 text-red-800",
  text: "bg-blue-100 text-blue-800",
};

const roleColors: Record<string, string> = {
  doer: "bg-green-100 text-green-800",
  supervisor: "bg-orange-100 text-orange-800",
  all: "bg-gray-100 text-gray-800",
};

export function LearningDataTable({
  data,
  total,
  page,
  totalPages,
}: {
  data: TrainingModule[];
  total: number;
  page: number;
  totalPages: number;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const [searchValue, setSearchValue] = useState(searchParams.get("search") || "");

  const updateParams = useCallback(
    (key: string, value: string | null) => {
      const params = new URLSearchParams(searchParams.toString());
      if (value && value !== "all") {
        params.set(key, value);
      } else {
        params.delete(key);
      }
      if (key !== "page") params.delete("page");
      router.push(`${pathname}?${params.toString()}`);
    },
    [router, pathname, searchParams]
  );

  const handleSearch = useCallback(() => {
    updateParams("search", searchValue || null);
  }, [updateParams, searchValue]);

  const handleDelete = useCallback(
    async (id: string) => {
      try {
        await deleteTrainingModule(id);
        toast.success("Module deactivated");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Delete failed");
      }
    },
    [router]
  );

  const handleToggleActive = useCallback(
    async (id: string, current: boolean) => {
      try {
        await toggleModuleActive(id, !current);
        toast.success(!current ? "Module activated" : "Module deactivated");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Action failed");
      }
    },
    [router]
  );

  const columns: ColumnDef<TrainingModule>[] = [
    {
      accessorKey: "title",
      header: "Title",
      cell: ({ getValue }) => (
        <span className="font-medium">{getValue() as string}</span>
      ),
    },
    {
      accessorKey: "contentType",
      header: "Type",
      cell: ({ getValue }) => {
        const type = (getValue() as string) || "text";
        return (
          <Badge variant="secondary" className={contentTypeColors[type] || ""}>
            {type}
          </Badge>
        );
      },
    },
    {
      accessorKey: "targetRole",
      header: "Role",
      cell: ({ getValue }) => {
        const role = (getValue() as string) || "all";
        return (
          <Badge variant="secondary" className={roleColors[role] || ""}>
            {role}
          </Badge>
        );
      },
    },
    {
      accessorKey: "isMandatory",
      header: "Required",
      cell: ({ getValue }) =>
        (getValue() as boolean) ? (
          <Badge variant="default" className="bg-red-500">Required</Badge>
        ) : (
          <span className="text-muted-foreground text-sm">Optional</span>
        ),
    },
    {
      accessorKey: "order",
      header: "Order",
      cell: ({ getValue }) => getValue() as number,
    },
    {
      accessorKey: "isActive",
      header: "Status",
      cell: ({ getValue }) => {
        const active = getValue() as boolean;
        return (
          <Badge variant={active ? "outline" : "destructive"}>
            {active ? "Active" : "Inactive"}
          </Badge>
        );
      },
    },
    {
      id: "actions",
      header: "",
      cell: ({ row }) => {
        const mod = row.original;
        return (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="size-8">
                <IconDotsVertical className="size-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem asChild>
                <Link href={`/learning/create?edit=${mod.id || mod._id}`}>
                  <IconEdit className="size-4" />
                  Edit
                </Link>
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={() => handleToggleActive(mod.id || mod._id!, mod.isActive)}
              >
                {mod.isActive ? "Deactivate" : "Activate"}
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem
                variant="destructive"
                onClick={() => handleDelete(mod.id || mod._id!)}
              >
                <IconTrash className="size-4" />
                Delete
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        );
      },
    },
  ];

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <div className="flex flex-col gap-4 px-4 lg:px-6">
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex items-center gap-2">
          <Input
            placeholder="Search modules..."
            value={searchValue}
            onChange={(e) => setSearchValue(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleSearch()}
            className="w-64"
          />
          <Button variant="outline" size="sm" onClick={handleSearch}>
            Search
          </Button>
        </div>
        <Select
          value={searchParams.get("contentType") || "all"}
          onValueChange={(v) => updateParams("contentType", v)}
        >
          <SelectTrigger className="w-40">
            <SelectValue placeholder="Content Type" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Types</SelectItem>
            <SelectItem value="video">Video</SelectItem>
            <SelectItem value="document">Document</SelectItem>
            <SelectItem value="text">Text</SelectItem>
          </SelectContent>
        </Select>
        <Select
          value={searchParams.get("targetRole") || "all"}
          onValueChange={(v) => updateParams("targetRole", v)}
        >
          <SelectTrigger className="w-40">
            <SelectValue placeholder="Target Role" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Roles</SelectItem>
            <SelectItem value="doer">Doer</SelectItem>
            <SelectItem value="supervisor">Supervisor</SelectItem>
          </SelectContent>
        </Select>
        <Button asChild size="sm" className="ml-auto">
          <Link href="/learning/create">
            <IconPlus className="size-4" />
            Add Module
          </Link>
        </Button>
      </div>

      <div className="rounded-md border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <TableHead key={header.id}>
                    {header.isPlaceholder
                      ? null
                      : flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length ? (
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={columns.length} className="h-24 text-center">
                  No training modules found.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          {total} module{total !== 1 ? "s" : ""} total &middot; Page {page} of {totalPages}
        </p>
        <div className="flex gap-2">
          <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => updateParams("page", String(page - 1))}>
            Previous
          </Button>
          <Button variant="outline" size="sm" disabled={page >= totalPages} onClick={() => updateParams("page", String(page + 1))}>
            Next
          </Button>
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add admin-web/components/admin/learning/learning-data-table.tsx
git commit -m "feat: rebuild learning data table for training modules"
```

---

### Task 8: Rebuild Learning Form for Training Modules

**Files:**
- Modify: `admin-web/components/admin/learning/learning-form.tsx`

- [ ] **Step 1: Rewrite form with content type switching**

Key changes:
- Content Type selector: Video Link, Document Upload, Text Content
- Conditional fields per content type
- Video: URL input
- Document: File input that uploads to Cloudinary via `/api/upload`, then stores URL
- Text: Textarea for content
- Target Role: Doer / Supervisor / All
- Required toggle
- Duration (minutes), Order, Active toggle

```typescript
"use client";

import { useState, useRef } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Select, SelectTrigger, SelectValue, SelectContent, SelectItem,
} from "@/components/ui/select";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { createTrainingModule, updateTrainingModule } from "@/lib/admin/actions/learning";
import { toast } from "sonner";
import { Loader2, Upload } from "lucide-react";
import type { TrainingModule } from "@/lib/admin/types";

export function LearningForm({ resource }: { resource?: TrainingModule }) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const editId = resource?.id || resource?._id || searchParams.get("edit");
  const isEdit = !!editId;
  const fileRef = useRef<HTMLInputElement>(null);

  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [title, setTitle] = useState(resource?.title || "");
  const [description, setDescription] = useState(resource?.description || "");
  const [contentType, setContentType] = useState<string>(resource?.contentType || "video");
  const [contentUrl, setContentUrl] = useState(resource?.contentUrl || "");
  const [contentHtml, setContentHtml] = useState(resource?.contentHtml || "");
  const [thumbnailUrl, setThumbnailUrl] = useState(resource?.thumbnailUrl || "");
  const [durationMinutes, setDurationMinutes] = useState(resource?.durationMinutes || 0);
  const [targetRole, setTargetRole] = useState(resource?.targetRole || "all");
  const [isMandatory, setIsMandatory] = useState(resource?.isMandatory ?? true);
  const [order, setOrder] = useState(resource?.order || 0);
  const [isActive, setIsActive] = useState(resource?.isActive ?? true);

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    try {
      const formData = new FormData();
      formData.append("file", file);

      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"}/api/upload`,
        {
          method: "POST",
          body: formData,
          headers: {
            Authorization: `Bearer ${document.cookie.split("admin-token=")[1]?.split(";")[0] || ""}`,
          },
        }
      );

      if (!res.ok) throw new Error("Upload failed");
      const data = await res.json();
      setContentUrl(data.url || data.secure_url || data.fileUrl);
      toast.success("File uploaded successfully");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Upload failed");
    } finally {
      setUploading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) {
      toast.error("Title is required");
      return;
    }

    if (contentType === "video" && !contentUrl.trim()) {
      toast.error("Video URL is required");
      return;
    }

    if (contentType === "document" && !contentUrl.trim()) {
      toast.error("Please upload a document");
      return;
    }

    if (contentType === "text" && !contentHtml.trim()) {
      toast.error("Text content is required");
      return;
    }

    setLoading(true);
    try {
      const formData = {
        title: title.trim(),
        description: description.trim(),
        contentType,
        contentUrl: contentType !== "text" ? contentUrl.trim() : "",
        contentHtml: contentType === "text" ? contentHtml : "",
        thumbnailUrl: thumbnailUrl.trim() || undefined,
        durationMinutes,
        targetRole,
        isMandatory,
        order,
        isActive,
      };

      if (isEdit && editId) {
        await updateTrainingModule(editId, formData);
        toast.success("Module updated");
      } else {
        await createTrainingModule(formData);
        toast.success("Module created");
      }
      router.push("/learning");
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>{isEdit ? "Edit Training Module" : "New Training Module"}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
          {/* Title & Content Type */}
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-2">
              <Label htmlFor="title">Title *</Label>
              <Input
                id="title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Module title"
                required
              />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="contentType">Content Type *</Label>
              <Select value={contentType} onValueChange={setContentType}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="video">Video Link</SelectItem>
                  <SelectItem value="document">Document Upload</SelectItem>
                  <SelectItem value="text">Text Content</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Description */}
          <div className="flex flex-col gap-2">
            <Label htmlFor="description">Description</Label>
            <Textarea
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Brief description of the module"
              rows={2}
            />
          </div>

          {/* Conditional Content Fields */}
          {contentType === "video" && (
            <div className="flex flex-col gap-2">
              <Label htmlFor="contentUrl">Video URL *</Label>
              <Input
                id="contentUrl"
                value={contentUrl}
                onChange={(e) => setContentUrl(e.target.value)}
                placeholder="https://youtube.com/watch?v=... or https://vimeo.com/..."
              />
            </div>
          )}

          {contentType === "document" && (
            <div className="flex flex-col gap-2">
              <Label>Document *</Label>
              <div className="flex items-center gap-3">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => fileRef.current?.click()}
                  disabled={uploading}
                >
                  {uploading ? (
                    <>
                      <Loader2 className="size-4 animate-spin mr-2" />
                      Uploading...
                    </>
                  ) : (
                    <>
                      <Upload className="size-4 mr-2" />
                      Choose File
                    </>
                  )}
                </Button>
                <input
                  ref={fileRef}
                  type="file"
                  accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx"
                  className="hidden"
                  onChange={handleFileUpload}
                />
                {contentUrl && (
                  <span className="text-sm text-muted-foreground truncate max-w-[300px]">
                    {contentUrl}
                  </span>
                )}
              </div>
            </div>
          )}

          {contentType === "text" && (
            <div className="flex flex-col gap-2">
              <Label htmlFor="contentHtml">Text Content *</Label>
              <Textarea
                id="contentHtml"
                value={contentHtml}
                onChange={(e) => setContentHtml(e.target.value)}
                placeholder="Write the training content here..."
                rows={10}
              />
            </div>
          )}

          {/* Target Role & Required */}
          <div className="grid gap-4 sm:grid-cols-3">
            <div className="flex flex-col gap-2">
              <Label htmlFor="targetRole">Target Role *</Label>
              <Select value={targetRole} onValueChange={setTargetRole}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All</SelectItem>
                  <SelectItem value="doer">Doer</SelectItem>
                  <SelectItem value="supervisor">Supervisor</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="duration">Duration (minutes)</Label>
              <Input
                id="duration"
                type="number"
                min={0}
                value={durationMinutes}
                onChange={(e) => setDurationMinutes(parseInt(e.target.value) || 0)}
              />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="order">Display Order</Label>
              <Input
                id="order"
                type="number"
                min={0}
                value={order}
                onChange={(e) => setOrder(parseInt(e.target.value) || 0)}
              />
            </div>
          </div>

          {/* Thumbnail */}
          <div className="flex flex-col gap-2">
            <Label htmlFor="thumbnail">Thumbnail URL (optional)</Label>
            <Input
              id="thumbnail"
              value={thumbnailUrl}
              onChange={(e) => setThumbnailUrl(e.target.value)}
              placeholder="https://..."
            />
          </div>

          {/* Toggles */}
          <div className="flex flex-wrap gap-6">
            <label className="flex items-center gap-2 text-sm">
              <Checkbox
                checked={isMandatory}
                onCheckedChange={(checked) => setIsMandatory(!!checked)}
              />
              Required (must complete during onboarding)
            </label>
            <label className="flex items-center gap-2 text-sm">
              <Checkbox
                checked={isActive}
                onCheckedChange={(checked) => setIsActive(!!checked)}
              />
              Active
            </label>
          </div>

          {/* Actions */}
          <div className="flex gap-3">
            <Button type="submit" disabled={loading || uploading}>
              {loading ? "Saving..." : isEdit ? "Update Module" : "Create Module"}
            </Button>
            <Button type="button" variant="outline" onClick={() => router.push("/learning")}>
              Cancel
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add admin-web/components/admin/learning/learning-form.tsx
git commit -m "feat: rebuild learning form for training modules with content type switching"
```

---

### Task 9: Update Admin Learning Page

**Files:**
- Modify: `admin-web/app/(authenticated)/learning/page.tsx`
- Modify: `admin-web/app/(authenticated)/learning/create/page.tsx`

- [ ] **Step 1: Update learning page to use training modules action**

```typescript
import { getTrainingModules } from "@/lib/admin/actions/learning";
import { LearningDataTable } from "@/components/admin/learning/learning-data-table";

export const metadata = { title: "Training Modules - AssignX Admin" };

export default async function LearningPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    contentType?: string;
    targetRole?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const result = await getTrainingModules({
    search: params.search || undefined,
    contentType: params.contentType || undefined,
    targetRole: params.targetRole || undefined,
    page: parseInt(params.page || "1"),
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">
          Training Modules
        </h1>
        <p className="text-muted-foreground">
          Manage onboarding training modules for doers and supervisors
        </p>
      </div>
      <LearningDataTable
        data={result.data}
        total={result.total}
        page={result.page}
        totalPages={result.totalPages}
      />
    </div>
  );
}
```

- [ ] **Step 2: Update create page title**

```typescript
import { LearningForm } from "@/components/admin/learning/learning-form";

export const metadata = { title: "Create Training Module - AssignX Admin" };

export default function CreateTrainingModulePage() {
  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">
          Create Training Module
        </h1>
        <p className="text-muted-foreground">
          Add a new training module for onboarding
        </p>
      </div>
      <div className="px-4 lg:px-6">
        <LearningForm />
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add admin-web/app/(authenticated)/learning/page.tsx admin-web/app/(authenticated)/learning/create/page.tsx
git commit -m "feat: update admin learning pages for training modules"
```

---

## Chunk 3: Doer-Web — Training Page with Auto-Completion

### Task 10: Update Doer Training Service

**Files:**
- Modify: `doer-web/lib/services/training.ts`

- [ ] **Step 1: Update service to use correct API shape**

The existing service already calls the right endpoints but sends wrong payload for `markModuleComplete`. Fix it to send `{ progress: 100 }` which is what the API expects:

```typescript
import { apiClient } from '@/lib/api/client'

export async function getTrainingModules(role: string) {
  const data = await apiClient<{ modules: any[] }>(`/api/training/modules?role=${role}`)
  return data.modules || []
}

export async function getTrainingProgress() {
  const data = await apiClient<{ progress: any[] }>('/api/training/progress')
  return data.progress || []
}

export async function updateModuleProgress(moduleId: string, progress: number) {
  const data = await apiClient(`/api/training/progress/${moduleId}`, {
    method: 'PUT',
    body: JSON.stringify({ progress }),
  })
  return data
}

export async function markModuleComplete(moduleId: string) {
  return updateModuleProgress(moduleId, 100)
}

export async function getTrainingStatus() {
  const data = await apiClient<{
    trainingCompleted: boolean
    totalRequired: number
    completedRequired: number
    modules: any[]
  }>('/api/training/status')
  return data
}

export async function completeTraining() {
  await apiClient('/api/training/complete', { method: 'POST' })
}
```

- [ ] **Step 2: Commit**

```bash
git add doer-web/lib/services/training.ts
git commit -m "fix: update doer training service to use correct API payload"
```

---

### Task 11: Update Doer Training Page with Content Views

**Files:**
- Modify: `doer-web/app/(activation)/training/page.tsx`

- [ ] **Step 1: Rewrite training page**

Major changes:
1. Fetch modules via `getTrainingStatus()` which returns modules with content fields
2. Add module content views: video player, document viewer, text reader
3. Auto-completion logic per content type
4. Replace "Continue to Quiz" with "Continue to Bank Details"
5. Track progress via `updateModuleProgress()`

The page should show a list of modules. When a user clicks a module, an expanded content view appears inline (not a new page). Auto-completion happens based on content type:
- Video: track time, complete at 90% of duration
- Document: complete on "View Document" click
- Text: complete when scrolled to bottom

```typescript
'use client'

import { useState, useEffect, useCallback, useRef } from 'react'
import { useRouter } from 'next/navigation'
import {
  CheckCircle2, PlayCircle, Loader2, ArrowRight, BookOpen,
  FileText, Video, ChevronDown, ChevronUp, ExternalLink, Download,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { apiClient, getAccessToken } from '@/lib/api/client'
import { getTrainingStatus, updateModuleProgress, completeTraining } from '@/lib/services/training'
import { useAuthStore } from '@/stores/authStore'
import { useActivationStore } from '@/hooks/useActivation'
import { ROUTES } from '@/lib/constants'
import type { Doer } from '@/types/database'

interface Module {
  id: string
  _id?: string
  title: string
  description: string
  contentType: 'video' | 'document' | 'text'
  contentUrl: string
  contentHtml: string
  thumbnailUrl: string
  durationMinutes: number
  isMandatory: boolean
  order: number
  status: 'not_started' | 'in_progress' | 'completed'
  progress: number
}

export default function TrainingPage() {
  const router = useRouter()
  const [modules, setModules] = useState<Module[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [expandedId, setExpandedId] = useState<string | null>(null)
  const [completingId, setCompletingId] = useState<string | null>(null)
  const [markingComplete, setMarkingComplete] = useState(false)
  const [trainingDone, setTrainingDone] = useState(false)
  const [totalRequired, setTotalRequired] = useState(0)
  const [completedRequired, setCompletedRequired] = useState(0)

  const loadData = useCallback(async () => {
    try {
      const token = getAccessToken()
      if (!token) { router.push('/login'); return }

      const data = await getTrainingStatus()
      const mods = (data.modules || []).map((m: any) => ({
        ...m,
        id: m.id || m._id,
      }))
      setModules(mods)
      setTotalRequired(data.totalRequired || 0)
      setCompletedRequired(data.completedRequired || 0)
      setTrainingDone(data.trainingCompleted || false)
    } catch (err) {
      console.error('Error loading training data:', err)
      setError('Failed to load training modules.')
    } finally {
      setIsLoading(false)
    }
  }, [router])

  useEffect(() => { loadData() }, [loadData])

  const handleAutoComplete = async (moduleId: string) => {
    setCompletingId(moduleId)
    try {
      await updateModuleProgress(moduleId, 100)
      await loadData()
    } catch (err) {
      console.error('Error completing module:', err)
      setError('Failed to complete module.')
    } finally {
      setCompletingId(null)
    }
  }

  const handleCompleteTraining = async () => {
    if (markingComplete) return
    setMarkingComplete(true)
    setError(null)
    try {
      await completeTraining()
      const updatedDoer = await apiClient<Doer>('/api/doers/me')
      if (updatedDoer) useAuthStore.getState().setDoer(updatedDoer)

      const currentActivation = useActivationStore.getState().activation
      if (currentActivation) {
        useActivationStore.getState().setActivation({
          ...currentActivation,
          training_completed: true,
          training_completed_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
      }
      setTrainingDone(true)
    } catch (err) {
      console.error('Error completing training:', err)
      setError('Failed to mark training as complete.')
    } finally {
      setMarkingComplete(false)
    }
  }

  const allRequiredDone = completedRequired >= totalRequired && totalRequired > 0

  const progressPercent = trainingDone
    ? 100
    : totalRequired > 0
      ? Math.round((completedRequired / totalRequired) * 100)
      : 0

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-[#5A7CFF]" />
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-[#F5F8FF]">
      <div className="max-w-2xl mx-auto px-4 py-8 space-y-6">
        {/* Header */}
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-[#5A7CFF] to-[#49C5FF] flex items-center justify-center shadow-lg shadow-[#5A7CFF]/20">
            <BookOpen className="h-6 w-6 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">Training</h1>
            <p className="text-sm text-slate-500">Complete all required modules to get started</p>
          </div>
        </div>

        {/* Progress bar */}
        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm font-semibold text-slate-700">Overall progress</span>
            <span className="text-sm font-bold text-[#5A7CFF]">{progressPercent}%</span>
          </div>
          <div className="w-full h-2.5 bg-slate-100 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF] rounded-full transition-all duration-500"
              style={{ width: `${progressPercent}%` }}
            />
          </div>
          <p className="mt-2 text-xs text-slate-400">
            {trainingDone ? 'Training complete' : `${completedRequired} of ${totalRequired} required modules completed`}
          </p>
        </div>

        {error && (
          <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
            {error}
          </div>
        )}

        {/* Module cards */}
        <div className="space-y-3">
          {modules.map((mod) => {
            const isCompleted = mod.status === 'completed'
            const isExpanded = expandedId === mod.id
            const isCompleting = completingId === mod.id

            return (
              <div
                key={mod.id}
                className={`rounded-2xl border bg-white shadow-sm transition-all ${
                  isCompleted ? 'border-emerald-200' : 'border-slate-200'
                }`}
              >
                {/* Module header */}
                <div
                  className="p-5 flex items-start gap-4 cursor-pointer"
                  onClick={() => !isCompleted && setExpandedId(isExpanded ? null : mod.id)}
                >
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${
                    isCompleted ? 'bg-emerald-100' : 'bg-[#5A7CFF]/10'
                  }`}>
                    {isCompleted ? (
                      <CheckCircle2 className="h-5 w-5 text-emerald-600" />
                    ) : mod.contentType === 'video' ? (
                      <Video className="h-5 w-5 text-[#5A7CFF]" />
                    ) : mod.contentType === 'document' ? (
                      <FileText className="h-5 w-5 text-[#5A7CFF]" />
                    ) : (
                      <BookOpen className="h-5 w-5 text-[#5A7CFF]" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] font-semibold uppercase tracking-wider text-slate-400 bg-slate-100 px-1.5 py-0.5 rounded-full">
                        {mod.contentType}
                      </span>
                      {mod.durationMinutes > 0 && (
                        <span className="text-[10px] text-slate-400">~{mod.durationMinutes} min</span>
                      )}
                      {mod.isMandatory && (
                        <span className="text-[10px] font-semibold text-[#5A7CFF] bg-[#EEF2FF] px-1.5 py-0.5 rounded-full">Required</span>
                      )}
                      {isCompleted && (
                        <span className="text-[10px] font-semibold text-emerald-700 bg-emerald-50 px-1.5 py-0.5 rounded-full">Completed</span>
                      )}
                    </div>
                    <h3 className="text-sm font-semibold text-slate-900 mt-0.5">{mod.title}</h3>
                    <p className="text-xs text-slate-500 mt-1">{mod.description}</p>
                  </div>
                  {!isCompleted && (
                    <div className="shrink-0">
                      {isExpanded ? <ChevronUp className="h-5 w-5 text-slate-400" /> : <ChevronDown className="h-5 w-5 text-slate-400" />}
                    </div>
                  )}
                </div>

                {/* Expanded content view */}
                {isExpanded && !isCompleted && (
                  <div className="border-t border-slate-100 p-5">
                    {/* Video content */}
                    {mod.contentType === 'video' && mod.contentUrl && (
                      <VideoModuleView
                        url={mod.contentUrl}
                        durationMinutes={mod.durationMinutes}
                        onComplete={() => handleAutoComplete(mod.id)}
                        isCompleting={isCompleting}
                      />
                    )}

                    {/* Document content */}
                    {mod.contentType === 'document' && mod.contentUrl && (
                      <DocumentModuleView
                        url={mod.contentUrl}
                        onComplete={() => handleAutoComplete(mod.id)}
                        isCompleting={isCompleting}
                      />
                    )}

                    {/* Text content */}
                    {mod.contentType === 'text' && mod.contentHtml && (
                      <TextModuleView
                        content={mod.contentHtml}
                        onComplete={() => handleAutoComplete(mod.id)}
                        isCompleting={isCompleting}
                      />
                    )}
                  </div>
                )}
              </div>
            )
          })}
        </div>

        {/* No modules */}
        {modules.length === 0 && !trainingDone && (
          <div className="rounded-2xl border border-slate-200 bg-white p-8 text-center shadow-sm">
            <BookOpen className="h-10 w-10 text-slate-300 mx-auto" />
            <p className="mt-3 text-sm text-slate-500">No training modules available. Mark training as complete to proceed.</p>
            <Button onClick={handleCompleteTraining} disabled={markingComplete} className="mt-4 rounded-xl bg-[#5A7CFF] text-white">
              {markingComplete ? <><Loader2 className="h-4 w-4 animate-spin mr-2" />Completing...</> : 'Mark Training as Complete'}
            </Button>
          </div>
        )}

        {/* All done - complete training */}
        {!trainingDone && allRequiredDone && modules.length > 0 && (
          <div className="rounded-2xl border border-slate-200 bg-white p-8 text-center shadow-sm">
            <CheckCircle2 className="h-10 w-10 text-emerald-500 mx-auto" />
            <p className="mt-3 text-sm text-slate-500">All required modules completed!</p>
            <Button onClick={handleCompleteTraining} disabled={markingComplete} className="mt-4 rounded-xl bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF] text-white font-semibold">
              {markingComplete ? <><Loader2 className="h-4 w-4 animate-spin mr-2" />Completing...</> : <><CheckCircle2 className="h-4 w-4 mr-2" />Continue</>}
            </Button>
          </div>
        )}

        {/* Training complete */}
        {trainingDone && (
          <div className="rounded-2xl border border-emerald-200 bg-gradient-to-br from-emerald-50 to-white p-6 text-center shadow-sm">
            <CheckCircle2 className="h-14 w-14 text-emerald-600 mx-auto" />
            <h3 className="mt-3 text-lg font-bold text-slate-900">Training Complete!</h3>
            <p className="mt-1 text-sm text-slate-500">Next: add your bank details.</p>
            <Button
              onClick={() => router.push(ROUTES.bankDetails)}
              size="lg"
              className="mt-4 rounded-xl bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF] text-white font-semibold"
            >
              Continue to Bank Details
              <ArrowRight className="h-4 w-4 ml-2" />
            </Button>
          </div>
        )}
      </div>
    </div>
  )
}

/** Video module: embeds iframe, tracks watch time, auto-completes at 90% duration */
function VideoModuleView({ url, durationMinutes, onComplete, isCompleting }: {
  url: string; durationMinutes: number; onComplete: () => void; isCompleting: boolean
}) {
  const [timeWatched, setTimeWatched] = useState(0)
  const intervalRef = useRef<ReturnType<typeof setInterval>>(null)
  const completedRef = useRef(false)
  const targetSeconds = Math.max((durationMinutes * 60) * 0.9, 10)

  useEffect(() => {
    intervalRef.current = setInterval(() => {
      setTimeWatched(prev => {
        const next = prev + 1
        if (next >= targetSeconds && !completedRef.current) {
          completedRef.current = true
          onComplete()
        }
        return next
      })
    }, 1000)
    return () => { if (intervalRef.current) clearInterval(intervalRef.current) }
  }, [targetSeconds, onComplete])

  // Convert URL to embeddable format
  const embedUrl = getEmbedUrl(url)

  return (
    <div className="space-y-3">
      {embedUrl ? (
        <div className="aspect-video rounded-xl overflow-hidden bg-black">
          <iframe src={embedUrl} className="w-full h-full" allowFullScreen allow="autoplay; encrypted-media" />
        </div>
      ) : (
        <a href={url} target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-2 text-sm text-[#5A7CFF] hover:underline">
          <ExternalLink className="h-4 w-4" />
          Open video in new tab
        </a>
      )}
      <div className="flex items-center justify-between text-xs text-slate-400">
        <span>Time watched: {Math.floor(timeWatched / 60)}:{String(timeWatched % 60).padStart(2, '0')}</span>
        {isCompleting && <span className="text-[#5A7CFF]">Completing...</span>}
      </div>
    </div>
  )
}

/** Document module: shows download/view link, auto-completes on click */
function DocumentModuleView({ url, onComplete, isCompleting }: {
  url: string; onComplete: () => void; isCompleting: boolean
}) {
  const handleOpen = () => {
    window.open(url, '_blank')
    onComplete()
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-slate-500">Open the document below to complete this module.</p>
      <Button onClick={handleOpen} disabled={isCompleting} variant="outline" className="gap-2">
        {isCompleting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Download className="h-4 w-4" />}
        {isCompleting ? 'Completing...' : 'View Document'}
      </Button>
    </div>
  )
}

/** Text module: scrollable content, auto-completes when scrolled to bottom */
function TextModuleView({ content, onComplete, isCompleting }: {
  content: string; onComplete: () => void; isCompleting: boolean
}) {
  const containerRef = useRef<HTMLDivElement>(null)
  const completedRef = useRef(false)

  const handleScroll = () => {
    if (completedRef.current || !containerRef.current) return
    const { scrollTop, scrollHeight, clientHeight } = containerRef.current
    if (scrollTop + clientHeight >= scrollHeight - 20) {
      completedRef.current = true
      onComplete()
    }
  }

  return (
    <div className="space-y-2">
      <p className="text-xs text-slate-400">Scroll to the bottom to complete this module.</p>
      <div
        ref={containerRef}
        onScroll={handleScroll}
        className="max-h-96 overflow-y-auto rounded-xl border border-slate-100 bg-slate-50 p-4 text-sm text-slate-700 leading-relaxed whitespace-pre-wrap"
      >
        {content}
      </div>
      {isCompleting && <p className="text-xs text-[#5A7CFF]">Completing...</p>}
    </div>
  )
}

/** Convert YouTube/Vimeo URLs to embeddable format */
function getEmbedUrl(url: string): string | null {
  try {
    const u = new URL(url)
    // YouTube
    if (u.hostname.includes('youtube.com') || u.hostname.includes('youtu.be')) {
      const videoId = u.hostname.includes('youtu.be')
        ? u.pathname.slice(1)
        : u.searchParams.get('v')
      if (videoId) return `https://www.youtube.com/embed/${videoId}`
    }
    // Vimeo
    if (u.hostname.includes('vimeo.com')) {
      const match = u.pathname.match(/\/(\d+)/)
      if (match) return `https://player.vimeo.com/video/${match[1]}`
    }
  } catch {}
  return null
}
```

- [ ] **Step 2: Commit**

```bash
git add doer-web/app/(activation)/training/page.tsx
git commit -m "feat: rebuild doer training page with content views and auto-completion"
```

---

### Task 12: Update Doer Activation Steps (Remove Quiz)

**Files:**
- Modify: `doer-web/lib/constants.ts:109-131`
- Modify: `doer-web/app/(activation)/layout.tsx`
- Modify: `doer-web/hooks/useActivation.ts`

- [ ] **Step 1: Update ACTIVATION_STEPS to 2 steps**

In `doer-web/lib/constants.ts`, replace lines 109-131:

```typescript
/** Activation steps configuration */
export const ACTIVATION_STEPS = [
  {
    id: 1,
    title: 'Complete Training',
    description: 'Complete all required training modules',
    route: '/training',
    icon: 'play-circle',
  },
  {
    id: 2,
    title: 'Add Bank Details',
    description: 'Set up your payment information',
    route: '/bank-details',
    icon: 'credit-card',
  },
] as const
```

- [ ] **Step 2: Update activation layout stepper**

In `doer-web/app/(activation)/layout.tsx`, update `getCurrentStep`:

```typescript
const getCurrentStep = () => {
  if (pathname.includes('/training')) return 1
  if (pathname.includes('/bank-details')) return 2
  return 1
}
```

And update `getStepStatus`:

```typescript
const getStepStatus = (stepId: number) => {
  let completedSteps = 0
  if (activation?.training_completed) completedSteps = 1
  if (activation?.bank_details_added) completedSteps = 2

  if (stepId < currentStep || stepId <= completedSteps) return 'completed'
  if (stepId === currentStep) return 'current'
  return 'locked'
}
```

Remove `ClipboardCheck` from icon imports (no longer needed).

- [ ] **Step 3: Update useActivation step logic**

In `doer-web/hooks/useActivation.ts`, update `getCurrentStep`, `isStepCompleted`, `isStepUnlocked`, and `getProgressPercentage` to use 2 steps instead of 3:

`getCurrentStep`:
```typescript
const getCurrentStep = useCallback(() => {
  if (!store.activation) return 1
  if (!store.activation.training_completed) return 1
  if (!store.activation.bank_details_added) return 2
  return 2
}, [store.activation])
```

`isStepCompleted`:
```typescript
const isStepCompleted = useCallback(
  (step: number) => {
    if (!store.activation) return false
    switch (step) {
      case 1: return store.activation.training_completed
      case 2: return store.activation.bank_details_added
      default: return false
    }
  },
  [store.activation]
)
```

`isStepUnlocked`:
```typescript
const isStepUnlocked = useCallback(
  (step: number) => {
    if (step === 1) return true
    if (!store.activation) return false
    switch (step) {
      case 2: return store.activation.training_completed
      default: return false
    }
  },
  [store.activation]
)
```

`getProgressPercentage`:
```typescript
const getProgressPercentage = useCallback(() => {
  let completed = 0
  if (store.activation?.training_completed) completed++
  if (store.activation?.bank_details_added) completed++
  return (completed / 2) * 100
}, [store.activation])
```

- [ ] **Step 4: Commit**

```bash
git add doer-web/lib/constants.ts doer-web/app/(activation)/layout.tsx doer-web/hooks/useActivation.ts
git commit -m "feat: simplify doer activation to 2 steps (remove quiz requirement)"
```

---

## Chunk 4: Superviser-Web — Training Page & Fixes

### Task 13: Fix Supervisor Training Service

**Files:**
- Modify: `superviser-web/lib/services/training.ts`

- [ ] **Step 1: Fix markModuleComplete to use correct endpoint**

```typescript
import { apiFetch } from "@/lib/api/client"

export async function getTrainingModules(role: string) {
  const data = await apiFetch<{ modules: unknown[] }>(
    `/api/training/modules?role=${role}`
  )
  return data.modules || []
}

export async function getTrainingProgress() {
  const data = await apiFetch<{ progress: unknown[] }>("/api/training/progress")
  return data.progress || []
}

export async function updateModuleProgress(moduleId: string, progress: number) {
  const data = await apiFetch(`/api/training/progress/${moduleId}`, {
    method: "PUT",
    body: JSON.stringify({ progress }),
  })
  return data
}

export async function markModuleComplete(moduleId: string) {
  return updateModuleProgress(moduleId, 100)
}

export async function getTrainingStatus() {
  const data = await apiFetch<{
    trainingCompleted: boolean
    totalRequired: number
    completedRequired: number
    modules: unknown[]
  }>("/api/training/status")
  return data
}

export async function completeTraining() {
  await apiFetch("/api/training/complete", { method: "POST" })
}
```

- [ ] **Step 2: Commit**

```bash
git add superviser-web/lib/services/training.ts
git commit -m "fix: supervisor training service uses correct PUT endpoint"
```

---

### Task 14: Update Supervisor Training Page

**Files:**
- Modify: `superviser-web/app/training/page.tsx`

- [ ] **Step 1: Rewrite training page with content views and /complete call**

Same pattern as doer-web but with supervisor theme colors (orange #F97316) and calling `POST /training/complete` before navigating to dashboard.

```typescript
"use client"

import { useState, useEffect, useCallback, useRef } from "react"
import { useRouter } from "next/navigation"
import {
  Loader2, CheckCircle2, BookOpen, Video, FileText,
  ArrowRight, ChevronDown, ChevronUp, ExternalLink, Download,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { getAccessToken } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"
import { apiFetch } from "@/lib/api/client"
import { getTrainingStatus, updateModuleProgress, completeTraining } from "@/lib/services/training"

interface Module {
  id: string
  _id?: string
  title: string
  description: string
  contentType: 'video' | 'document' | 'text'
  contentUrl: string
  contentHtml: string
  thumbnailUrl: string
  durationMinutes: number
  isMandatory: boolean
  order: number
  status: 'not_started' | 'in_progress' | 'completed'
  progress: number
}

export default function TrainingPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [modules, setModules] = useState<Module[]>([])
  const [expandedId, setExpandedId] = useState<string | null>(null)
  const [completingId, setCompletingId] = useState<string | null>(null)
  const [markingComplete, setMarkingComplete] = useState(false)
  const [trainingDone, setTrainingDone] = useState(false)
  const [totalRequired, setTotalRequired] = useState(0)
  const [completedRequired, setCompletedRequired] = useState(0)

  const loadData = useCallback(async () => {
    try {
      const data = await getTrainingStatus()
      const mods = (data.modules || []).map((m: any) => ({
        ...m,
        id: m.id || m._id,
      }))
      setModules(mods)
      setTotalRequired(data.totalRequired || 0)
      setCompletedRequired(data.completedRequired || 0)
      setTrainingDone(data.trainingCompleted || false)
    } catch (err) {
      console.error("Training load error:", err)
    }
  }, [])

  useEffect(() => {
    const init = async () => {
      try {
        const token = getAccessToken()
        const user = getStoredUser()
        if (!token || !user) { router.replace("/login"); return }

        try { await apiFetch("/api/supervisors/me") } catch {
          router.replace("/pending-approval"); return
        }

        await loadData()
      } catch (err) {
        console.error("Training init error:", err)
      } finally {
        setLoading(false)
      }
    }
    init()
  }, [router, loadData])

  const handleAutoComplete = async (moduleId: string) => {
    setCompletingId(moduleId)
    try {
      await updateModuleProgress(moduleId, 100)
      await loadData()
    } catch (err) {
      console.error("Failed to complete module:", err)
    } finally {
      setCompletingId(null)
    }
  }

  const handleCompleteTraining = async () => {
    if (markingComplete) return
    setMarkingComplete(true)
    try {
      await completeTraining()
      setTrainingDone(true)
    } catch (err) {
      console.error("Error completing training:", err)
    } finally {
      setMarkingComplete(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-24">
        <Loader2 className="h-8 w-8 animate-spin text-[#F97316]" />
      </div>
    )
  }

  const allComplete = completedRequired >= totalRequired && totalRequired > 0
  const progressPercent = trainingDone ? 100 : totalRequired > 0 ? Math.round((completedRequired / totalRequired) * 100) : 100

  return (
    <div className="max-w-2xl mx-auto px-4 py-8 space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[#1C1C1C]">Supervisor Training</h1>
        <p className="text-sm text-gray-400 mt-1">Complete all required modules to access your dashboard.</p>
      </div>

      {/* Progress bar */}
      <div className="rounded-xl border border-gray-200/60 bg-white p-5 space-y-3">
        <div className="flex items-center justify-between text-sm">
          <span className="font-medium text-[#1C1C1C]">{completedRequired} of {totalRequired} modules completed</span>
          <span className="text-[#F97316] font-semibold">{progressPercent}%</span>
        </div>
        <div className="h-2 rounded-full bg-gray-100 overflow-hidden">
          <div className="h-full rounded-full bg-[#F97316] transition-all duration-500" style={{ width: `${progressPercent}%` }} />
        </div>
      </div>

      {/* Module list */}
      <div className="space-y-3">
        {modules.map((mod) => {
          const isCompleted = mod.status === 'completed'
          const isExpanded = expandedId === mod.id
          const isCompleting = completingId === mod.id

          return (
            <div key={mod.id} className={`rounded-xl border bg-white transition-all ${isCompleted ? "border-emerald-200/60" : "border-gray-200/60"}`}>
              <div
                className="p-5 flex items-start gap-4 cursor-pointer"
                onClick={() => !isCompleted && setExpandedId(isExpanded ? null : mod.id)}
              >
                <div className={`h-10 w-10 rounded-lg flex items-center justify-center shrink-0 ${isCompleted ? "bg-emerald-50" : "bg-[#F97316]/10"}`}>
                  {isCompleted ? (
                    <CheckCircle2 className="h-5 w-5 text-emerald-500" />
                  ) : mod.contentType === 'video' ? (
                    <Video className="h-5 w-5 text-[#F97316]" />
                  ) : mod.contentType === 'document' ? (
                    <FileText className="h-5 w-5 text-[#F97316]" />
                  ) : (
                    <BookOpen className="h-5 w-5 text-[#F97316]" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-[10px] font-semibold uppercase tracking-wider text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full">{mod.contentType}</span>
                    {mod.durationMinutes > 0 && <span className="text-[10px] text-gray-400">~{mod.durationMinutes} min</span>}
                    {mod.isMandatory && <span className="text-[10px] font-semibold text-[#F97316] bg-[#F97316]/10 px-2 py-0.5 rounded-full">Required</span>}
                  </div>
                  <h3 className="text-sm font-semibold text-[#1C1C1C]">{mod.title}</h3>
                  {mod.description && <p className="text-xs text-gray-400 mt-0.5 line-clamp-2">{mod.description}</p>}
                </div>
                {!isCompleted && (
                  <div className="shrink-0">{isExpanded ? <ChevronUp className="h-5 w-5 text-gray-400" /> : <ChevronDown className="h-5 w-5 text-gray-400" />}</div>
                )}
                {isCompleted && <span className="text-xs font-medium text-emerald-600 shrink-0">Completed</span>}
              </div>

              {isExpanded && !isCompleted && (
                <div className="border-t border-gray-100 p-5">
                  {mod.contentType === 'video' && mod.contentUrl && (
                    <VideoView url={mod.contentUrl} durationMinutes={mod.durationMinutes} onComplete={() => handleAutoComplete(mod.id)} isCompleting={isCompleting} />
                  )}
                  {mod.contentType === 'document' && mod.contentUrl && (
                    <DocumentView url={mod.contentUrl} onComplete={() => handleAutoComplete(mod.id)} isCompleting={isCompleting} />
                  )}
                  {mod.contentType === 'text' && mod.contentHtml && (
                    <TextView content={mod.contentHtml} onComplete={() => handleAutoComplete(mod.id)} isCompleting={isCompleting} />
                  )}
                </div>
              )}
            </div>
          )
        })}
      </div>

      {/* No modules */}
      {modules.length === 0 && !trainingDone && (
        <div className="text-center py-12">
          <CheckCircle2 className="h-12 w-12 text-emerald-500 mx-auto" />
          <h2 className="text-xl font-semibold text-[#1C1C1C] mt-3">No training required</h2>
          <Button onClick={() => { handleCompleteTraining().then(() => router.push("/dashboard")) }} className="mt-4 bg-[#F97316] hover:bg-[#EA580C] text-white rounded-xl">
            Go to Dashboard <ArrowRight className="h-4 w-4 ml-2" />
          </Button>
        </div>
      )}

      {/* All done */}
      {!trainingDone && allComplete && modules.length > 0 && (
        <div className="text-center pt-4">
          <Button onClick={handleCompleteTraining} disabled={markingComplete} size="lg" className="rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white font-semibold px-8">
            {markingComplete ? <><Loader2 className="h-4 w-4 animate-spin mr-2" />Completing...</> : <>Continue to Dashboard <ArrowRight className="h-4 w-4 ml-2" /></>}
          </Button>
        </div>
      )}

      {trainingDone && (
        <div className="text-center pt-4">
          <Button onClick={() => router.push("/dashboard")} size="lg" className="rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white font-semibold px-8">
            Go to Dashboard <ArrowRight className="h-4 w-4 ml-2" />
          </Button>
        </div>
      )}
    </div>
  )
}

function VideoView({ url, durationMinutes, onComplete, isCompleting }: { url: string; durationMinutes: number; onComplete: () => void; isCompleting: boolean }) {
  const [timeWatched, setTimeWatched] = useState(0)
  const intervalRef = useRef<ReturnType<typeof setInterval>>(null)
  const completedRef = useRef(false)
  const targetSeconds = Math.max((durationMinutes * 60) * 0.9, 10)

  useEffect(() => {
    intervalRef.current = setInterval(() => {
      setTimeWatched(prev => {
        const next = prev + 1
        if (next >= targetSeconds && !completedRef.current) {
          completedRef.current = true
          onComplete()
        }
        return next
      })
    }, 1000)
    return () => { if (intervalRef.current) clearInterval(intervalRef.current) }
  }, [targetSeconds, onComplete])

  const embedUrl = getEmbedUrl(url)
  return (
    <div className="space-y-3">
      {embedUrl ? (
        <div className="aspect-video rounded-xl overflow-hidden bg-black">
          <iframe src={embedUrl} className="w-full h-full" allowFullScreen allow="autoplay; encrypted-media" />
        </div>
      ) : (
        <a href={url} target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-2 text-sm text-[#F97316] hover:underline">
          <ExternalLink className="h-4 w-4" /> Open video
        </a>
      )}
      <div className="flex items-center justify-between text-xs text-gray-400">
        <span>Time: {Math.floor(timeWatched / 60)}:{String(timeWatched % 60).padStart(2, '0')}</span>
        {isCompleting && <span className="text-[#F97316]">Completing...</span>}
      </div>
    </div>
  )
}

function DocumentView({ url, onComplete, isCompleting }: { url: string; onComplete: () => void; isCompleting: boolean }) {
  return (
    <div className="space-y-3">
      <p className="text-sm text-gray-500">Open the document to complete this module.</p>
      <Button onClick={() => { window.open(url, '_blank'); onComplete() }} disabled={isCompleting} variant="outline" className="gap-2">
        {isCompleting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Download className="h-4 w-4" />}
        {isCompleting ? 'Completing...' : 'View Document'}
      </Button>
    </div>
  )
}

function TextView({ content, onComplete, isCompleting }: { content: string; onComplete: () => void; isCompleting: boolean }) {
  const containerRef = useRef<HTMLDivElement>(null)
  const completedRef = useRef(false)

  const handleScroll = () => {
    if (completedRef.current || !containerRef.current) return
    const { scrollTop, scrollHeight, clientHeight } = containerRef.current
    if (scrollTop + clientHeight >= scrollHeight - 20) {
      completedRef.current = true
      onComplete()
    }
  }

  return (
    <div className="space-y-2">
      <p className="text-xs text-gray-400">Scroll to the bottom to complete.</p>
      <div ref={containerRef} onScroll={handleScroll} className="max-h-96 overflow-y-auto rounded-xl border border-gray-100 bg-gray-50 p-4 text-sm text-gray-700 leading-relaxed whitespace-pre-wrap">
        {content}
      </div>
      {isCompleting && <p className="text-xs text-[#F97316]">Completing...</p>}
    </div>
  )
}

function getEmbedUrl(url: string): string | null {
  try {
    const u = new URL(url)
    if (u.hostname.includes('youtube.com') || u.hostname.includes('youtu.be')) {
      const videoId = u.hostname.includes('youtu.be') ? u.pathname.slice(1) : u.searchParams.get('v')
      if (videoId) return `https://www.youtube.com/embed/${videoId}`
    }
    if (u.hostname.includes('vimeo.com')) {
      const match = u.pathname.match(/\/(\d+)/)
      if (match) return `https://player.vimeo.com/video/${match[1]}`
    }
  } catch {}
  return null
}
```

- [ ] **Step 2: Commit**

```bash
git add superviser-web/app/training/page.tsx
git commit -m "feat: rebuild supervisor training page with content views and /complete call"
```

---

### Task 15: Fix ActivationGuard Redirect

**Files:**
- Modify: `superviser-web/components/auth/activation-guard.tsx`

- [ ] **Step 1: Change redirect from `/modules` to `/training`, check training status**

```typescript
"use client"

import { useEffect, useState } from "react"
import { useRouter, usePathname } from "next/navigation"
import { apiFetch, getAccessToken } from "@/lib/api/client"

const BYPASS_PATHS = ["/login", "/register", "/pending", "/modules", "/training", "/pending-approval"]

export function ActivationGuard({ children }: { children: React.ReactNode }) {
  const router = useRouter()
  const pathname = usePathname()
  const [checked, setChecked] = useState(false)

  useEffect(() => {
    const check = async () => {
      const token = getAccessToken()
      if (!token) { setChecked(true); return }

      if (BYPASS_PATHS.some(p => pathname.startsWith(p))) {
        setChecked(true)
        return
      }

      try {
        // Check training completion via training status endpoint
        const data = await apiFetch<{ trainingCompleted: boolean }>("/api/training/status")
        if (!data.trainingCompleted) {
          router.replace("/training")
          return
        }
      } catch {
        // If training status fails, fall back to auth/me check
        try {
          const data = await apiFetch<{
            profile: { userType: string }
            roleData: { isActivated: boolean } | null
          }>("/api/auth/me")

          if (
            data.profile?.userType === "supervisor" &&
            data.roleData &&
            !data.roleData.isActivated
          ) {
            router.replace("/training")
            return
          }
        } catch {}
      }

      setChecked(true)
    }

    check()
  }, [pathname, router])

  if (!checked) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="h-6 w-6 animate-spin rounded-full border-2 border-[#F97316] border-t-transparent" />
      </div>
    )
  }

  return <>{children}</>
}
```

- [ ] **Step 2: Commit**

```bash
git add superviser-web/components/auth/activation-guard.tsx
git commit -m "fix: activation guard redirects to /training and checks training status"
```

---

## Chunk 5: Verification & Final Commit

### Task 16: Verify Everything Compiles

- [ ] **Step 1: Check API server compiles**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit 2>&1 | head -30`

Fix any type errors.

- [ ] **Step 2: Check admin-web builds**

Run: `cd "/Volumes/Crucial X9/AssignX/admin-web" && npx next build 2>&1 | tail -20`

Fix any build errors.

- [ ] **Step 3: Check doer-web builds**

Run: `cd "/Volumes/Crucial X9/AssignX/doer-web" && npx next build 2>&1 | tail -20`

Fix any build errors.

- [ ] **Step 4: Check superviser-web builds**

Run: `cd "/Volumes/Crucial X9/AssignX/superviser-web" && npx next build 2>&1 | tail -20`

Fix any build errors.

### Task 17: Manual Testing Checklist

- [ ] **Step 1: Start API server and test training module CRUD**

1. Start API: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx ts-node-dev src/index.ts`
2. Create a module via curl:
```bash
curl -X POST http://localhost:4000/api/admin/training-modules \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin-token>" \
  -d '{"title":"Welcome Video","contentType":"video","contentUrl":"https://youtube.com/watch?v=test","targetRole":"doer","isMandatory":true,"durationMinutes":5,"order":1}'
```
3. Verify it appears in `GET /api/admin/training-modules`

- [ ] **Step 2: Test admin-web learning page**

1. Start admin-web: `cd "/Volumes/Crucial X9/AssignX/admin-web" && npx next dev --port 3002 --turbopack`
2. Navigate to `http://localhost:3002/learning`
3. Verify data table shows modules with correct columns
4. Create a new module of each type (video, document, text)
5. Verify edit and delete work

- [ ] **Step 3: Test doer-web training flow**

1. Start doer-web: `cd "/Volumes/Crucial X9/AssignX/doer-web" && npx next dev --port 3003 --turbopack`
2. Login as a doer
3. Verify redirect to `/training`
4. Expand each module type and verify content view
5. Complete all modules, verify "Continue to Bank Details" appears
6. Verify POST /training/complete is called

- [ ] **Step 4: Test supervisor-web training flow**

1. Start superviser-web: `cd "/Volumes/Crucial X9/AssignX/superviser-web" && npx next dev --port 3001 --turbopack`
2. Login as a supervisor
3. Verify redirect to `/training` (not `/modules`)
4. Complete modules, verify "Continue to Dashboard" calls POST /training/complete
5. After completion, verify dashboard is accessible
