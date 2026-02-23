# Utilities Documentation

> **AdminX Supervisor Panel** - Library & Utilities Reference

## Table of Contents

1. [Overview](#overview)
2. [Core Utilities](#core-utilities)
3. [Supabase Clients](#supabase-clients)
4. [Mock Data](#mock-data)
5. [Analytics](#analytics)
6. [Metadata](#metadata)
7. [Store](#store)
8. [Types](#types)

---

## Overview

The `lib/` directory contains utility functions, configurations, and service integrations.

**Structure:**
```
lib/
├── mock-data/          # Development mock data
│   ├── doers.ts        # Doer mock data
│   ├── resources.ts    # Resource mock data
│   ├── users.ts        # User mock data
│   └── index.ts        # Barrel exports
├── supabase/           # Supabase client setup
│   ├── client.ts       # Browser client
│   ├── server.ts       # Server client
│   └── middleware.ts   # Middleware client
├── analytics.ts        # Analytics utilities
├── metadata.ts         # SEO metadata
└── utils.ts            # General utilities
```

---

## Core Utilities

### utils.ts

General utility functions.

#### cn()

Merge class names with Tailwind CSS support.

```typescript
import { cn } from "@/lib/utils"

// Basic usage
<div className={cn("px-4 py-2", "bg-blue-500")} />

// Conditional classes
<div className={cn(
  "base-class",
  isActive && "active-class",
  variant === "primary" ? "primary-class" : "secondary-class"
)} />

// With arrays
<div className={cn([
  "flex items-center",
  "gap-2",
  customClass
])} />
```

**Implementation:**
```typescript
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

#### formatCurrency()

Format numbers as Indian Rupee currency.

```typescript
import { formatCurrency } from "@/lib/utils"

formatCurrency(25000)
// "₹25,000"

formatCurrency(1500.50)
// "₹1,500.50"

formatCurrency(100000, { notation: "compact" })
// "₹1L"
```

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| amount | number | required | Amount to format |
| options | object | {} | Intl.NumberFormat options |

#### formatDate()

Format dates in various styles.

```typescript
import { formatDate } from "@/lib/utils"

const date = new Date("2025-01-15")

formatDate(date)
// "15 Jan 2025"

formatDate(date, "long")
// "January 15, 2025"

formatDate(date, "relative")
// "2 days ago"
```

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| date | Date \| string | required | Date to format |
| style | "short" \| "long" \| "relative" | "short" | Format style |

#### truncateText()

Truncate text with ellipsis.

```typescript
import { truncateText } from "@/lib/utils"

truncateText("This is a very long text", 10)
// "This is a..."

truncateText("Short", 10)
// "Short"
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| text | string | Text to truncate |
| maxLength | number | Maximum length |

#### generateProjectNumber()

Generate unique project number.

```typescript
import { generateProjectNumber } from "@/lib/utils"

generateProjectNumber()
// "AX-00001"

generateProjectNumber(12345)
// "AX-12345"
```

#### debounce()

Debounce function execution.

```typescript
import { debounce } from "@/lib/utils"

const debouncedSearch = debounce((query: string) => {
  searchAPI(query)
}, 300)

// Call multiple times, only executes after 300ms pause
debouncedSearch("test")
debouncedSearch("testing")
debouncedSearch("testing 123")
```

#### sleep()

Promise-based delay.

```typescript
import { sleep } from "@/lib/utils"

async function process() {
  await doSomething()
  await sleep(1000) // Wait 1 second
  await doSomethingElse()
}
```

---

## Supabase Clients

### client.ts (Browser)

Browser-side Supabase client.

```typescript
import { createClient } from "@/lib/supabase/client"

// In a client component
function Component() {
  const supabase = createClient()

  const fetchData = async () => {
    const { data, error } = await supabase
      .from("projects")
      .select("*")
  }
}
```

**Features:**
- Browser-only
- Handles cookies automatically
- Singleton pattern

### server.ts (Server)

Server-side Supabase client.

```typescript
import { createClient } from "@/lib/supabase/server"

// In a Server Component or Route Handler
async function Page() {
  const supabase = await createClient()

  const { data } = await supabase
    .from("projects")
    .select("*")

  return <ProjectList projects={data} />
}
```

**Features:**
- Server-only
- Access to cookies()
- Async creation

### middleware.ts (Middleware)

Middleware Supabase client.

```typescript
import { createClient } from "@/lib/supabase/middleware"

// In middleware.ts
export async function middleware(request: NextRequest) {
  const { supabase, response } = createClient(request)

  const { data: { session } } = await supabase.auth.getSession()

  if (!session) {
    return NextResponse.redirect('/login')
  }

  return response
}
```

**Features:**
- For middleware use
- Handles session refresh
- Returns modified response

---

## Mock Data

### doers.ts

Mock doer data for development.

```typescript
import {
  MOCK_DOERS,
  MOCK_DOER_REVIEWS,
  MOCK_DOER_PROJECTS,
  SUBJECT_OPTIONS
} from "@/lib/mock-data"

// Use in components
const doers = MOCK_DOERS
const reviews = MOCK_DOER_REVIEWS
const subjects = SUBJECT_OPTIONS
```

**Exports:**
| Export | Type | Description |
|--------|------|-------------|
| MOCK_DOERS | Doer[] | Sample doer profiles |
| MOCK_DOER_REVIEWS | DoerReview[] | Sample reviews |
| MOCK_DOER_PROJECTS | DoerProject[] | Sample projects |
| SUBJECT_OPTIONS | string[] | Available subjects |

### resources.ts

Mock resource data.

```typescript
import {
  MOCK_AI_RESULT,
  MOCK_PLAGIARISM_RESULT,
  MOCK_TRAINING_VIDEOS
} from "@/lib/mock-data"
```

**Exports:**
| Export | Type | Description |
|--------|------|-------------|
| MOCK_AI_RESULT | AIDetectionResult | Sample AI detection |
| MOCK_PLAGIARISM_RESULT | PlagiarismCheckResult | Sample plagiarism check |
| MOCK_TRAINING_VIDEOS | TrainingVideo[] | Sample training videos |

### users.ts

Mock user data.

```typescript
import { MOCK_USERS } from "@/lib/mock-data"

const users = MOCK_USERS
```

**Exports:**
| Export | Type | Description |
|--------|------|-------------|
| MOCK_USERS | User[] | Sample user profiles |

---

## Analytics

### analytics.ts

Analytics and error tracking utilities.

```typescript
import {
  trackEvent,
  trackPageView,
  trackError,
  setUser
} from "@/lib/analytics"

// Track custom event
trackEvent("quote_submitted", {
  projectId: "proj-123",
  amount: 2500,
})

// Track page view
trackPageView("/dashboard")

// Track error
trackError(new Error("Something went wrong"), {
  component: "QuoteModal",
})

// Set user identity
setUser("user-123", {
  name: "John Doe",
  email: "john@example.com",
})
```

**Functions:**

#### trackEvent()
```typescript
function trackEvent(
  eventName: string,
  properties?: EventProperties
): void
```

#### trackPageView()
```typescript
function trackPageView(
  path: string,
  properties?: EventProperties
): void
```

#### trackError()
```typescript
function trackError(
  error: Error,
  context?: ErrorContext
): void
```

#### setUser()
```typescript
function setUser(
  userId: string,
  traits?: UserTraits
): void
```

---

## Metadata

### metadata.ts

SEO metadata utilities.

```typescript
import { siteConfig, createMetadata } from "@/lib/metadata"

// Site configuration
console.log(siteConfig.name) // "AdminX"
console.log(siteConfig.description) // "Supervisor Panel for AssignX"

// Create page metadata
export const metadata = createMetadata({
  title: "Dashboard",
  description: "Supervisor dashboard overview",
})
```

**siteConfig:**
```typescript
const siteConfig = {
  name: "AdminX",
  description: "Supervisor Panel for AssignX - Quality Control Hub",
  url: "https://adminx.assignx.com",
  ogImage: "/og-image.png",
  links: {
    support: "mailto:support@assignx.com",
  },
}
```

**createMetadata():**
```typescript
function createMetadata(options: {
  title?: string
  description?: string
  image?: string
  noIndex?: boolean
}): Metadata
```

---

## Store

### Zustand Store

**Path:** `store/index.ts`

Global state management with Zustand.

```typescript
import { create } from "zustand"
import { persist } from "zustand/middleware"

interface AppStore {
  // State
  supervisor: Supervisor | null
  isAvailable: boolean
  sidebarOpen: boolean

  // Actions
  setSupervisor: (supervisor: Supervisor | null) => void
  setAvailability: (status: boolean) => void
  toggleSidebar: () => void
}

export const useAppStore = create<AppStore>()(
  persist(
    (set) => ({
      // Initial state
      supervisor: null,
      isAvailable: true,
      sidebarOpen: true,

      // Actions
      setSupervisor: (supervisor) => set({ supervisor }),
      setAvailability: (isAvailable) => set({ isAvailable }),
      toggleSidebar: () =>
        set((state) => ({ sidebarOpen: !state.sidebarOpen })),
    }),
    {
      name: "adminx-storage",
      partialize: (state) => ({
        sidebarOpen: state.sidebarOpen,
      }),
    }
  )
)
```

**Usage:**
```typescript
import { useAppStore } from "@/store"

function Component() {
  const supervisor = useAppStore((state) => state.supervisor)
  const setSupervisor = useAppStore((state) => state.setSupervisor)

  // Or destructure multiple values
  const { isAvailable, setAvailability } = useAppStore()
}
```

---

## Types

### Global Types

**Path:** `types/`

Shared TypeScript definitions.

#### database.types.ts

Supabase database types (auto-generated).

```typescript
import type { Database } from "@/types/database.types"

type Project = Database["public"]["Tables"]["projects"]["Row"]
type ProjectInsert = Database["public"]["Tables"]["projects"]["Insert"]
type ProjectUpdate = Database["public"]["Tables"]["projects"]["Update"]
```

#### index.ts

Common type definitions.

```typescript
// User roles
export type UserRole = "user" | "supervisor" | "doer" | "admin"

// Project status
export type ProjectStatus =
  | "pending_quote"
  | "quoted"
  | "pending_payment"
  | "paid"
  | "assigned"
  | "in_progress"
  | "submitted_for_qc"
  | "revision_requested"
  | "approved"
  | "delivered"
  | "completed"

// Common interfaces
export interface Pagination {
  page: number
  pageSize: number
  total: number
}

export interface ApiResponse<T> {
  data: T | null
  error: string | null
  success: boolean
}
```

---

## Environment Variables

**Required Variables:**

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

**Access in Code:**

```typescript
// Public (client & server)
process.env.NEXT_PUBLIC_SUPABASE_URL

// Server only
process.env.SUPABASE_SERVICE_ROLE_KEY
```

---

## Best Practices

### Import Organization

```typescript
// 1. External packages
import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"

// 2. Internal absolute imports
import { Button } from "@/components/ui/button"
import { useAppStore } from "@/store"
import { cn } from "@/lib/utils"

// 3. Relative imports
import { LocalComponent } from "./local-component"
import type { LocalType } from "./types"
```

### Error Handling

```typescript
import { trackError } from "@/lib/analytics"

async function fetchData() {
  try {
    const { data, error } = await supabase
      .from("projects")
      .select("*")

    if (error) throw error

    return data
  } catch (error) {
    trackError(error as Error, { function: "fetchData" })
    throw error
  }
}
```

### Type Safety

```typescript
// Always type function parameters and returns
function calculateCommission(amount: number, rate: number): number {
  return amount * (rate / 100)
}

// Use generics for reusable utilities
function getFirst<T>(items: T[]): T | undefined {
  return items[0]
}
```
