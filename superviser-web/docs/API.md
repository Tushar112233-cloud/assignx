# API Documentation

> **AdminX Supervisor Panel** - API Reference

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [API Routes](#api-routes)
4. [Supabase Integration](#supabase-integration)
5. [Database Schema](#database-schema)
6. [Real-time Subscriptions](#real-time-subscriptions)

---

## Overview

AdminX uses Supabase as its backend, providing:
- PostgreSQL database with Row Level Security (RLS)
- Authentication via Supabase Auth
- Real-time subscriptions for live updates
- Storage for file uploads

### Base Configuration

```typescript
// Environment Variables
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

---

## Authentication

### Auth Flow

#### Login

```typescript
import { createClient } from "@/lib/supabase/client"

const supabase = createClient()

// Email/Password Login
const { data, error } = await supabase.auth.signInWithPassword({
  email: "supervisor@example.com",
  password: "password123"
})

// OAuth Login
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: "google",
  options: {
    redirectTo: `${window.location.origin}/api/auth/callback`
  }
})
```

#### Register

```typescript
const { data, error } = await supabase.auth.signUp({
  email: "new.supervisor@example.com",
  password: "securepassword",
  options: {
    data: {
      full_name: "John Doe",
      role: "supervisor"
    }
  }
})
```

#### Logout

```typescript
const { error } = await supabase.auth.signOut()
```

#### Session Management

```typescript
// Get current session
const { data: { session } } = await supabase.auth.getSession()

// Listen for auth changes
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_IN') {
    // Handle sign in
  } else if (event === 'SIGNED_OUT') {
    // Handle sign out
  }
})
```

---

## API Routes

### Auth Callback

**File:** `app/api/auth/callback/route.ts`

Handles OAuth callback and session exchange.

```typescript
// GET /api/auth/callback?code=xxx
// Exchanges auth code for session and redirects to dashboard
```

---

## Supabase Integration

### Client Setup

#### Browser Client

```typescript
// lib/supabase/client.ts
import { createBrowserClient } from "@supabase/ssr"

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

#### Server Client

```typescript
// lib/supabase/server.ts
import { createServerClient } from "@supabase/ssr"
import { cookies } from "next/headers"

export async function createClient() {
  const cookieStore = await cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => cookieStore.getAll(),
        setAll: (cookiesToSet) => {
          cookiesToSet.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options)
          })
        }
      }
    }
  )
}
```

---

## Database Schema

### Core Tables

#### supervisors

Stores supervisor profile information.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key (references auth.users) |
| full_name | text | Full name |
| email | text | Email address |
| phone | text | Phone number |
| avatar_url | text | Profile picture URL |
| qualification | text | Educational qualification |
| years_of_experience | int | Years of experience |
| subjects | text[] | Areas of expertise |
| bio | text | Short biography |
| bank_account_number | text | Bank account (encrypted) |
| ifsc_code | text | Bank IFSC code |
| is_verified | boolean | Verification status |
| is_activated | boolean | Activation status |
| activation_completed_at | timestamp | When activation completed |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |

#### projects

Stores project information.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| project_number | text | Unique project code (AX-XXXXX) |
| user_id | uuid | Client user ID |
| supervisor_id | uuid | Assigned supervisor |
| doer_id | uuid | Assigned doer |
| title | text | Project title |
| description | text | Project description |
| subject | text | Subject area |
| deadline | timestamp | Project deadline |
| status | text | Current status |
| user_amount | decimal | Amount charged to user |
| doer_payout | decimal | Amount paid to doer |
| supervisor_commission | decimal | Supervisor commission |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |

**Status Values:**
- `pending_quote` - Awaiting price quote
- `quoted` - Quote sent to user
- `pending_payment` - Awaiting payment
- `paid` - Payment received
- `assigned` - Assigned to doer
- `in_progress` - Work in progress
- `submitted_for_qc` - Submitted for review
- `revision_requested` - Needs revision
- `approved` - QC approved
- `delivered` - Delivered to user
- `completed` - Project completed

#### doers

Stores doer/expert information.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| full_name | text | Full name |
| email | text | Email address |
| phone | text | Phone number |
| avatar_url | text | Profile picture URL |
| qualification | text | Educational qualification |
| years_of_experience | int | Years of experience |
| skills | text[] | Technical skills |
| subjects | text[] | Subject expertise |
| rating | decimal | Average rating |
| total_reviews | int | Total review count |
| total_projects | int | Total projects |
| completed_projects | int | Completed projects |
| active_projects | int | Active projects |
| success_rate | decimal | Success percentage |
| is_available | boolean | Availability status |
| is_verified | boolean | Verification status |
| is_blacklisted | boolean | Blacklist status |
| blacklist_reason | text | Reason if blacklisted |
| created_at | timestamp | Creation timestamp |

#### chat_rooms

Stores chat room information.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| project_id | uuid | Related project |
| user_id | uuid | Client user ID |
| supervisor_id | uuid | Supervisor ID |
| doer_id | uuid | Doer ID (optional) |
| last_message_at | timestamp | Last message time |
| created_at | timestamp | Creation timestamp |

#### messages

Stores chat messages.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| room_id | uuid | Chat room ID |
| sender_id | uuid | Sender user ID |
| sender_type | text | user/supervisor/doer |
| content | text | Message content |
| attachments | jsonb | File attachments |
| is_read | boolean | Read status |
| created_at | timestamp | Creation timestamp |

#### notifications

Stores user notifications.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| user_id | uuid | Recipient user ID |
| type | text | Notification type |
| title | text | Notification title |
| message | text | Notification body |
| data | jsonb | Additional data |
| is_read | boolean | Read status |
| created_at | timestamp | Creation timestamp |

#### earnings

Stores earnings/payment records.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| supervisor_id | uuid | Supervisor ID |
| project_id | uuid | Related project |
| amount | decimal | Earning amount |
| type | text | commission/bonus |
| status | text | pending/paid |
| paid_at | timestamp | Payment timestamp |
| created_at | timestamp | Creation timestamp |

---

## Real-time Subscriptions

### Chat Messages

```typescript
// Subscribe to new messages in a chat room
const channel = supabase
  .channel(`room:${roomId}`)
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'messages',
      filter: `room_id=eq.${roomId}`
    },
    (payload) => {
      // Handle new message
      console.log('New message:', payload.new)
    }
  )
  .subscribe()

// Cleanup
channel.unsubscribe()
```

### Project Updates

```typescript
// Subscribe to project status changes
const channel = supabase
  .channel('project-updates')
  .on(
    'postgres_changes',
    {
      event: 'UPDATE',
      schema: 'public',
      table: 'projects',
      filter: `supervisor_id=eq.${supervisorId}`
    },
    (payload) => {
      // Handle project update
      console.log('Project updated:', payload.new)
    }
  )
  .subscribe()
```

### Notifications

```typescript
// Subscribe to new notifications
const channel = supabase
  .channel('notifications')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'notifications',
      filter: `user_id=eq.${userId}`
    },
    (payload) => {
      // Show notification toast
      toast(payload.new.title)
    }
  )
  .subscribe()
```

---

## Query Examples

### Fetch Projects

```typescript
// Get all projects for supervisor
const { data, error } = await supabase
  .from('projects')
  .select(`
    *,
    user:users(full_name, email),
    doer:doers(full_name, rating)
  `)
  .eq('supervisor_id', supervisorId)
  .order('created_at', { ascending: false })
```

### Update Project Status

```typescript
const { data, error } = await supabase
  .from('projects')
  .update({
    status: 'approved',
    updated_at: new Date().toISOString()
  })
  .eq('id', projectId)
  .select()
```

### Create Quote

```typescript
const { data, error } = await supabase
  .from('projects')
  .update({
    status: 'quoted',
    user_amount: 2500,
    doer_payout: 1625,
    supervisor_commission: 375,
    updated_at: new Date().toISOString()
  })
  .eq('id', projectId)
```

### Assign Doer

```typescript
const { data, error } = await supabase
  .from('projects')
  .update({
    doer_id: doerId,
    status: 'assigned',
    updated_at: new Date().toISOString()
  })
  .eq('id', projectId)
```

---

## Error Handling

### Standard Error Response

```typescript
interface SupabaseError {
  message: string
  details: string
  hint: string
  code: string
}

// Handle errors
try {
  const { data, error } = await supabase.from('projects').select()

  if (error) {
    console.error('Database error:', error.message)
    throw error
  }

  return data
} catch (error) {
  // Handle network or other errors
  console.error('Request failed:', error)
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| PGRST116 | No rows returned |
| PGRST301 | Row level security violation |
| 23505 | Unique constraint violation |
| 23503 | Foreign key violation |
| 42501 | Insufficient privileges |

---

## Rate Limiting

Supabase applies rate limits based on your plan:

| Plan | Requests/second |
|------|-----------------|
| Free | 500 |
| Pro | 5,000 |
| Enterprise | Custom |

Implement client-side throttling for high-frequency operations like real-time updates.
