# API Documentation

## Overview

AssignX uses **Next.js Server Actions** for server-side operations and **Supabase** as the backend service. This document covers all API interactions.

---

## Server Actions (`lib/actions/`)

### Authentication Actions (`auth.ts`)

#### `signInWithGoogle()`
Initiates Google OAuth sign-in flow.

```typescript
"use server"

export async function signInWithGoogle(): Promise<{ error?: string } | void>
```

**Returns:**
- Redirects to Google OAuth consent screen on success
- `{ error: string }` on failure

**Usage:**
```tsx
import { signInWithGoogle } from "@/lib/actions/auth";

<Button onClick={() => signInWithGoogle()}>
  Sign in with Google
</Button>
```

---

#### `signOut()`
Signs out the current user.

```typescript
"use server"

export async function signOut(): Promise<void>
```

**Effects:**
- Clears Supabase session
- Revalidates layout cache
- Redirects to `/login`

---

#### `getUser()`
Gets the current authenticated user.

```typescript
"use server"

export async function getUser(): Promise<User | null>
```

**Returns:**
- `User` object if authenticated
- `null` if not authenticated

---

#### `createProfile(data)`
Creates or updates a user profile.

```typescript
"use server"

export async function createProfile(data: {
  fullName: string;
  phone?: string;
  userType: "student" | "professional" | "business";
}): Promise<{ error?: string; success?: boolean }>
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `fullName` | string | Yes | User's full name |
| `phone` | string | No | Phone number |
| `userType` | enum | Yes | Account type |

---

#### `createStudentProfile(data)`
Creates a student profile with academic details.

```typescript
"use server"

export async function createStudentProfile(data: {
  fullName: string;
  dateOfBirth: string;
  universityId: string;
  courseId: string;
  semester: number;
  collegeEmail?: string;
  phone: string;
}): Promise<{ error?: string; success?: boolean }>
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `fullName` | string | Yes | Student's full name |
| `dateOfBirth` | string | Yes | ISO date string |
| `universityId` | string | Yes | University ID from dropdown |
| `courseId` | string | Yes | Course ID from dropdown |
| `semester` | number | Yes | Current semester (1-12) |
| `collegeEmail` | string | No | .edu email address |
| `phone` | string | Yes | Phone number |

---

#### `createProfessionalProfile(data)`
Creates a professional profile.

```typescript
"use server"

export async function createProfessionalProfile(data: {
  fullName: string;
  industryId: string;
  phone: string;
}): Promise<{ error?: string; success?: boolean }>
```

---

## Supabase Client Setup

### Browser Client (`lib/supabase/client.ts`)
```typescript
import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

### Server Client (`lib/supabase/server.ts`)
```typescript
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function createClient() {
  const cookieStore = await cookies();
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll(); },
        setAll(cookies) { /* ... */ },
      },
    }
  );
}
```

---

## OAuth Callback Route

### `app/auth/callback/route.ts`

Handles OAuth redirect from Google.

```typescript
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/home";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      // Check if profile exists
      const { data: { user } } = await supabase.auth.getUser();
      const { data: profile } = await supabase
        .from("profiles")
        .select("*")
        .eq("id", user?.id)
        .single();

      if (!profile) {
        return NextResponse.redirect(`${origin}/onboarding`);
      }

      return NextResponse.redirect(`${origin}${next}`);
    }
  }

  return NextResponse.redirect(`${origin}/login?error=auth_failed`);
}
```

---

## Database Schema (Supabase)

### `profiles` Table
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  full_name TEXT,
  phone TEXT,
  user_type TEXT CHECK (user_type IN ('student', 'professional', 'business')),
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### `students` Table
```sql
CREATE TABLE students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  university_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  semester INTEGER,
  college_email TEXT,
  date_of_birth DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### `professionals` Table
```sql
CREATE TABLE professionals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  industry_id TEXT NOT NULL,
  professional_type TEXT,
  company_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Middleware

### `middleware.ts`

Handles authentication redirects.

```typescript
import { type NextRequest, NextResponse } from "next/server";
import { updateSession } from "@/lib/supabase/middleware";

export async function middleware(request: NextRequest) {
  return await updateSession(request);
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
```

### Session Update (`lib/supabase/middleware.ts`)
```typescript
export async function updateSession(request: NextRequest) {
  const response = NextResponse.next({ request });
  const supabase = createServerClient(/* ... */);

  const { data: { user } } = await supabase.auth.getUser();

  // Redirect unauthenticated users from protected routes
  if (!user && !request.nextUrl.pathname.startsWith("/login")) {
    const loginUrl = new URL("/login", request.url);
    return NextResponse.redirect(loginUrl);
  }

  return response;
}
```

---

## Mock Data Files

### Location: `lib/data/`

| File | Description | Used By |
|------|-------------|---------|
| `projects.json` | Sample projects with all statuses | `useProjectStore` |
| `banners.json` | Promotional banner data | `BannerCarousel` |
| `services.ts` | Dashboard services config | `ServicesGrid` |
| `subjects.ts` | Subject categories | `SubjectSelector` |
| `connect.ts` | Tutors, resources, groups, Q&A | Connect page |
| `profile.ts` | User profile mock data | Profile page |
| `settings.ts` | FAQ, tickets mock data | Settings, Support |
| `universities.json` | University list | `UniversitySelector` |
| `courses.json` | Course/degree list | `CourseSelector` |
| `industries.json` | Industry list | `IndustrySelector` |

---

## Form Validation Schemas

### Location: `lib/validations/`

#### Student Schema (`student.ts`)
```typescript
export const studentStep1Schema = z.object({
  fullName: z.string().min(2, "Name must be at least 2 characters"),
  dateOfBirth: z.date({ required_error: "Date of birth is required" }),
});

export const studentStep2Schema = z.object({
  universityId: z.string().min(1, "University is required"),
  courseId: z.string().min(1, "Course is required"),
  semester: z.number().min(1).max(12),
});

export const studentStep3Schema = z.object({
  phone: z.string().regex(/^[6-9]\d{9}$/, "Invalid Indian phone number"),
  collegeEmail: z.string().email().optional(),
  termsAccepted: z.literal(true, { errorMap: () => ({ message: "Required" }) }),
});
```

#### Professional Schema (`professional.ts`)
```typescript
export const professionalSchema = z.object({
  fullName: z.string().min(2),
  industryId: z.string().min(1),
  phone: z.string().regex(/^[6-9]\d{9}$/),
  termsAccepted: z.literal(true),
});
```

#### Project Schema (`project.ts`)
```typescript
export const projectStep1Schema = z.object({
  subject: z.string().min(1, "Subject is required"),
  topic: z.string().min(5, "Topic must be at least 5 characters"),
});

export const projectStep2Schema = z.object({
  wordCount: z.number().min(250).max(50000),
  referenceStyle: z.enum(["apa7", "mla9", "harvard", "chicago", "ieee", "none"]),
  referenceCount: z.number().min(0).max(100).optional(),
});
```

---

## Error Handling

### Server Action Pattern
```typescript
export async function serverAction(data: Input): Promise<ActionResult> {
  try {
    // Validate input
    const validated = schema.parse(data);

    // Perform operation
    const result = await operation(validated);

    // Return success
    return { success: true, data: result };
  } catch (error) {
    // Handle Zod validation errors
    if (error instanceof z.ZodError) {
      return { error: error.errors[0].message };
    }

    // Handle Supabase errors
    if (error instanceof Error) {
      return { error: error.message };
    }

    // Generic error
    return { error: "An unexpected error occurred" };
  }
}
```

### Client-Side Error Handling
```tsx
const handleSubmit = async (data: FormData) => {
  try {
    const result = await serverAction(data);

    if (result.error) {
      toast.error(result.error);
      return;
    }

    toast.success("Success!");
    router.push("/next-page");
  } catch (error) {
    toast.error("Something went wrong");
  }
};
```
