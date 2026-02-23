# AssignX - Complete Database Schema

> **Database:** Supabase (PostgreSQL)  
> **Authentication:** Supabase Auth + Google OAuth  
> **Version:** 1.0 | **Date:** December 2025

---

## 📋 Table of Contents

1. [Schema Overview](#1-schema-overview)
2. [Entity Relationship Diagram](#2-entity-relationship-diagram)
3. [Core Tables](#3-core-tables)
4. [Project & Workflow Tables](#4-project--workflow-tables)
5. [Financial Tables](#5-financial-tables)
6. [Chat & Communication Tables](#6-chat--communication-tables)
7. [Marketplace Tables](#7-marketplace-tables)
8. [Training & Activation Tables](#8-training--activation-tables)
9. [Reviews & Ratings Tables](#9-reviews--ratings-tables)
10. [Configuration Tables](#10-configuration-tables)
11. [Support & Audit Tables](#11-support--audit-tables)
12. [Indexes Summary](#12-indexes-summary)
13. [Row Level Security (RLS) Policies](#13-row-level-security-rls-policies)
14. [Database Functions & Triggers](#14-database-functions--triggers)
15. [SQL Migration Scripts](#15-sql-migration-scripts)

---

## 1. Schema Overview

### Table Count by Category

| Category | Tables | Description |
|----------|--------|-------------|
| Core/Auth | 8 | Users, profiles, role-specific extensions |
| Projects | 9 | Projects, files, deliverables, workflow |
| Financial | 7 | Wallets, transactions, payouts, quotes |
| Chat | 4 | Rooms, messages, participants |
| Marketplace | 4 | Listings, categories, images |
| Training | 6 | Modules, quizzes, activation |
| Reviews | 3 | Ratings for all user types |
| Configuration | 12 | Lookups, settings, referrals |
| Support/Audit | 4 | Tickets, logs |
| **Total** | **57** | Complete platform coverage |

### Naming Conventions

- Tables: `snake_case` (plural for collections)
- Columns: `snake_case`
- Primary Keys: `id` (UUID)
- Foreign Keys: `{table_name}_id`
- Timestamps: `created_at`, `updated_at`
- Soft Delete: `deleted_at`
- Status Fields: `status` with ENUM types

---

## 2. Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            ASSIGNX DATABASE SCHEMA                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐                     │
│  │   PROFILES   │────<│   STUDENTS   │     │ PROFESSIONALS│                     │
│  │   (base)     │     └──────────────┘     └──────────────┘                     │
│  └──────┬───────┘                                                                │
│         │                                                                        │
│         ├─────────────────────────────────────────────────────────┐              │
│         │                                                         │              │
│  ┌──────▼───────┐     ┌──────────────┐     ┌──────────────┐      │              │
│  │    DOERS     │────<│DOER_SKILLS   │     │DOER_ACTIVATION│      │              │
│  └──────┬───────┘     └──────────────┘     └──────────────┘      │              │
│         │                                                         │              │
│  ┌──────▼───────┐     ┌──────────────┐     ┌──────────────┐      │              │
│  │  SUPERVISORS │────<│SUP_EXPERTISE │     │SUP_ACTIVATION │      │              │
│  └──────┬───────┘     └──────────────┘     └──────────────┘      │              │
│         │                                                         │              │
│         └─────────────────────┬───────────────────────────────────┘              │
│                               │                                                  │
│                        ┌──────▼───────┐                                          │
│                        │   PROJECTS   │                                          │
│                        └──────┬───────┘                                          │
│                               │                                                  │
│      ┌────────────────────────┼────────────────────────┐                        │
│      │                        │                        │                        │
│ ┌────▼─────┐  ┌───────────────▼──────┐  ┌─────────────▼────────┐               │
│ │  FILES   │  │  PROJECT_ASSIGNMENTS │  │  PROJECT_DELIVERABLES│               │
│ └──────────┘  └───────────────┬──────┘  └──────────────────────┘               │
│                               │                                                  │
│              ┌────────────────┼────────────────┐                                │
│              │                │                │                                │
│       ┌──────▼──────┐  ┌──────▼──────┐  ┌─────▼───────┐                        │
│       │   QUOTES    │  │  PAYMENTS   │  │    CHATS    │                        │
│       └─────────────┘  └─────────────┘  └─────────────┘                        │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Core Tables

### 3.1 `profiles` - Base User Table

All authenticated users have a profile. Links to Supabase Auth.

```sql
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Basic Info
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    phone_verified BOOLEAN DEFAULT FALSE,
    avatar_url TEXT,
    
    -- Role Management
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('student', 'professional', 'doer', 'supervisor', 'admin')),
    is_active BOOLEAN DEFAULT TRUE,
    is_blocked BOOLEAN DEFAULT FALSE,
    block_reason TEXT,
    
    -- Location
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    
    -- Metadata
    last_login_at TIMESTAMPTZ,
    login_count INTEGER DEFAULT 0,
    device_tokens TEXT[], -- For push notifications
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_user_type ON profiles(user_type);
CREATE INDEX idx_profiles_phone ON profiles(phone);
CREATE INDEX idx_profiles_city ON profiles(city);
CREATE INDEX idx_profiles_is_active ON profiles(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_profiles_created_at ON profiles(created_at DESC);
```

### 3.2 `students` - Student User Extension

```sql
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Academic Info
    university_id UUID REFERENCES universities(id),
    course_id UUID REFERENCES courses(id),
    semester INTEGER CHECK (semester BETWEEN 1 AND 12),
    year_of_study INTEGER CHECK (year_of_study BETWEEN 1 AND 6),
    student_id_number VARCHAR(50),
    expected_graduation_year INTEGER,
    
    -- Verification
    college_email VARCHAR(255),
    college_email_verified BOOLEAN DEFAULT FALSE,
    student_id_verified BOOLEAN DEFAULT FALSE,
    
    -- Preferences
    preferred_subjects UUID[], -- Array of subject IDs
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_students_profile_id ON students(profile_id);
CREATE INDEX idx_students_university_id ON students(university_id);
CREATE INDEX idx_students_course_id ON students(course_id);
CREATE INDEX idx_students_college_email ON students(college_email);
```

### 3.3 `professionals` - Job Seeker / Business User Extension

```sql
CREATE TABLE professionals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Professional Info
    professional_type VARCHAR(20) NOT NULL CHECK (professional_type IN ('job_seeker', 'business', 'creator')),
    industry_id UUID REFERENCES industries(id),
    company_name VARCHAR(255),
    job_title VARCHAR(255),
    linkedin_url TEXT,
    
    -- Business specific
    business_type VARCHAR(100),
    gst_number VARCHAR(20),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_professionals_profile_id ON professionals(profile_id);
CREATE INDEX idx_professionals_type ON professionals(professional_type);
CREATE INDEX idx_professionals_industry_id ON professionals(industry_id);
```

### 3.4 `doers` - Expert/Freelancer Table

```sql
CREATE TABLE doers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Professional Info
    qualification VARCHAR(50) NOT NULL CHECK (qualification IN ('high_school', 'undergraduate', 'postgraduate', 'phd')),
    university_name VARCHAR(255),
    experience_level VARCHAR(20) NOT NULL CHECK (experience_level IN ('beginner', 'intermediate', 'pro')),
    years_of_experience INTEGER DEFAULT 0,
    bio TEXT,
    
    -- Availability
    is_available BOOLEAN DEFAULT TRUE,
    availability_updated_at TIMESTAMPTZ,
    max_concurrent_projects INTEGER DEFAULT 3,
    
    -- Activation Status
    is_activated BOOLEAN DEFAULT FALSE,
    activated_at TIMESTAMPTZ,
    
    -- Performance Metrics
    total_projects_completed INTEGER DEFAULT 0,
    total_earnings DECIMAL(12, 2) DEFAULT 0,
    average_rating DECIMAL(3, 2) DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    success_rate DECIMAL(5, 2) DEFAULT 100,
    on_time_delivery_rate DECIMAL(5, 2) DEFAULT 100,
    
    -- Banking
    bank_account_name VARCHAR(255),
    bank_account_number VARCHAR(50),
    bank_ifsc_code VARCHAR(20),
    bank_name VARCHAR(100),
    upi_id VARCHAR(100),
    bank_verified BOOLEAN DEFAULT FALSE,
    
    -- Flags
    is_flagged BOOLEAN DEFAULT FALSE,
    flag_reason TEXT,
    flagged_by UUID REFERENCES profiles(id),
    flagged_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_doers_profile_id ON doers(profile_id);
CREATE INDEX idx_doers_is_available ON doers(is_available) WHERE is_available = TRUE;
CREATE INDEX idx_doers_is_activated ON doers(is_activated) WHERE is_activated = TRUE;
CREATE INDEX idx_doers_qualification ON doers(qualification);
CREATE INDEX idx_doers_experience_level ON doers(experience_level);
CREATE INDEX idx_doers_average_rating ON doers(average_rating DESC);
CREATE INDEX idx_doers_success_rate ON doers(success_rate DESC);
CREATE INDEX idx_doers_is_flagged ON doers(is_flagged) WHERE is_flagged = TRUE;
```

### 3.5 `doer_skills` - Doer Skills Junction Table

```sql
CREATE TABLE doer_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doer_id UUID NOT NULL REFERENCES doers(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    proficiency_level VARCHAR(20) DEFAULT 'intermediate' CHECK (proficiency_level IN ('beginner', 'intermediate', 'expert')),
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES profiles(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(doer_id, skill_id)
);

-- Indexes
CREATE INDEX idx_doer_skills_doer_id ON doer_skills(doer_id);
CREATE INDEX idx_doer_skills_skill_id ON doer_skills(skill_id);
CREATE INDEX idx_doer_skills_is_verified ON doer_skills(is_verified) WHERE is_verified = TRUE;
```

### 3.6 `doer_subjects` - Doer Subject Areas

```sql
CREATE TABLE doer_subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doer_id UUID NOT NULL REFERENCES doers(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(doer_id, subject_id)
);

-- Indexes
CREATE INDEX idx_doer_subjects_doer_id ON doer_subjects(doer_id);
CREATE INDEX idx_doer_subjects_subject_id ON doer_subjects(subject_id);
CREATE INDEX idx_doer_subjects_is_primary ON doer_subjects(is_primary) WHERE is_primary = TRUE;
```

### 3.7 `supervisors` - Supervisor/Admin Table

```sql
CREATE TABLE supervisors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Professional Info
    qualification VARCHAR(50) NOT NULL CHECK (qualification IN ('undergraduate', 'postgraduate', 'phd', 'professional')),
    years_of_experience INTEGER NOT NULL,
    cv_url TEXT,
    cv_verified BOOLEAN DEFAULT FALSE,
    cv_verified_at TIMESTAMPTZ,
    cv_verified_by UUID REFERENCES profiles(id),
    
    -- Availability
    is_available BOOLEAN DEFAULT TRUE,
    availability_updated_at TIMESTAMPTZ,
    max_concurrent_projects INTEGER DEFAULT 10,
    
    -- Activation Status
    is_activated BOOLEAN DEFAULT FALSE,
    activated_at TIMESTAMPTZ,
    
    -- Performance Metrics
    total_projects_managed INTEGER DEFAULT 0,
    total_earnings DECIMAL(12, 2) DEFAULT 0,
    average_rating DECIMAL(3, 2) DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    success_rate DECIMAL(5, 2) DEFAULT 100,
    average_response_time_hours DECIMAL(5, 2),
    
    -- Banking
    bank_account_name VARCHAR(255),
    bank_account_number VARCHAR(50),
    bank_ifsc_code VARCHAR(20),
    bank_name VARCHAR(100),
    upi_id VARCHAR(100),
    bank_verified BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_supervisors_profile_id ON supervisors(profile_id);
CREATE INDEX idx_supervisors_is_available ON supervisors(is_available) WHERE is_available = TRUE;
CREATE INDEX idx_supervisors_is_activated ON supervisors(is_activated) WHERE is_activated = TRUE;
CREATE INDEX idx_supervisors_average_rating ON supervisors(average_rating DESC);
CREATE INDEX idx_supervisors_success_rate ON supervisors(success_rate DESC);
```

### 3.8 `supervisor_expertise` - Supervisor Subject Areas

```sql
CREATE TABLE supervisor_expertise (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supervisor_id UUID NOT NULL REFERENCES supervisors(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(supervisor_id, subject_id)
);

-- Indexes
CREATE INDEX idx_supervisor_expertise_supervisor_id ON supervisor_expertise(supervisor_id);
CREATE INDEX idx_supervisor_expertise_subject_id ON supervisor_expertise(subject_id);
```

### 3.9 `admins` - Admin Panel Users

```sql
CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Role & Permissions
    admin_role VARCHAR(50) NOT NULL CHECK (admin_role IN ('super_admin', 'admin', 'moderator', 'support')),
    permissions JSONB DEFAULT '{}',
    
    -- Activity
    last_active_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_admins_profile_id ON admins(profile_id);
CREATE INDEX idx_admins_role ON admins(admin_role);
```

---

## 4. Project & Workflow Tables

### 4.1 `projects` - Main Projects Table

```sql
CREATE TYPE project_status AS ENUM (
    'draft',
    'submitted',
    'analyzing',
    'quoted',
    'payment_pending',
    'paid',
    'assigning',
    'assigned',
    'in_progress',
    'submitted_for_qc',
    'qc_in_progress',
    'qc_approved',
    'qc_rejected',
    'delivered',
    'revision_requested',
    'in_revision',
    'completed',
    'auto_approved',
    'cancelled',
    'refunded'
);

CREATE TYPE service_type AS ENUM (
    'new_project',
    'proofreading',
    'plagiarism_check',
    'ai_detection',
    'expert_opinion'
);

CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Project Identity
    project_number VARCHAR(20) NOT NULL UNIQUE, -- e.g., #AX-2940
    
    -- Ownership
    user_id UUID NOT NULL REFERENCES profiles(id),
    
    -- Service Type
    service_type service_type NOT NULL,
    
    -- Project Details
    title VARCHAR(255) NOT NULL,
    subject_id UUID REFERENCES subjects(id),
    topic VARCHAR(500),
    description TEXT,
    word_count INTEGER,
    page_count INTEGER,
    reference_style_id UUID REFERENCES reference_styles(id),
    specific_instructions TEXT,
    
    -- Proofreading specific
    focus_areas TEXT[], -- ['grammar', 'flow', 'formatting', 'citations']
    
    -- Deadline
    deadline TIMESTAMPTZ NOT NULL,
    original_deadline TIMESTAMPTZ,
    deadline_extended BOOLEAN DEFAULT FALSE,
    deadline_extension_reason TEXT,
    
    -- Status
    status project_status NOT NULL DEFAULT 'submitted',
    status_updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Assignment
    supervisor_id UUID REFERENCES supervisors(id),
    supervisor_assigned_at TIMESTAMPTZ,
    doer_id UUID REFERENCES doers(id),
    doer_assigned_at TIMESTAMPTZ,
    
    -- Pricing
    user_quote DECIMAL(10, 2), -- Amount user pays
    doer_payout DECIMAL(10, 2), -- Amount doer receives
    supervisor_commission DECIMAL(10, 2), -- Supervisor earnings
    platform_fee DECIMAL(10, 2), -- Platform earnings
    
    -- Payment
    is_paid BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMPTZ,
    payment_id UUID REFERENCES payments(id),
    
    -- Delivery
    delivered_at TIMESTAMPTZ,
    expected_delivery_at TIMESTAMPTZ,
    
    -- Auto-approval
    auto_approve_at TIMESTAMPTZ, -- 48h after delivery
    
    -- Quality Reports
    ai_report_url TEXT,
    ai_score DECIMAL(5, 2),
    plagiarism_report_url TEXT,
    plagiarism_score DECIMAL(5, 2),
    
    -- Live Tracking
    live_document_url TEXT, -- Google Docs link
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
    
    -- Completion
    completed_at TIMESTAMPTZ,
    completion_notes TEXT,
    
    -- User feedback
    user_approved BOOLEAN,
    user_approved_at TIMESTAMPTZ,
    user_feedback TEXT,
    user_grade VARCHAR(10), -- Grade received (if shared)
    
    -- Cancellation
    cancelled_at TIMESTAMPTZ,
    cancelled_by UUID REFERENCES profiles(id),
    cancellation_reason TEXT,
    
    -- Metadata
    source VARCHAR(20) DEFAULT 'app' CHECK (source IN ('app', 'website')),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_projects_project_number ON projects(project_number);
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_supervisor_id ON projects(supervisor_id);
CREATE INDEX idx_projects_doer_id ON projects(doer_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_service_type ON projects(service_type);
CREATE INDEX idx_projects_subject_id ON projects(subject_id);
CREATE INDEX idx_projects_deadline ON projects(deadline);
CREATE INDEX idx_projects_is_paid ON projects(is_paid);
CREATE INDEX idx_projects_created_at ON projects(created_at DESC);
CREATE INDEX idx_projects_status_supervisor ON projects(status, supervisor_id) WHERE supervisor_id IS NOT NULL;
CREATE INDEX idx_projects_status_doer ON projects(status, doer_id) WHERE doer_id IS NOT NULL;
CREATE INDEX idx_projects_pending_payment ON projects(status) WHERE status = 'payment_pending';
CREATE INDEX idx_projects_auto_approve ON projects(auto_approve_at) WHERE auto_approve_at IS NOT NULL AND status = 'delivered';
```

### 4.2 `project_files` - User Uploaded Files

```sql
CREATE TABLE project_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- File Info
    file_name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_type VARCHAR(50), -- pdf, doc, docx, jpg, png
    file_size_bytes BIGINT,
    
    -- Categorization
    file_category VARCHAR(50) DEFAULT 'reference' CHECK (file_category IN ('reference', 'brief', 'attachment', 'other')),
    
    -- Metadata
    uploaded_by UUID NOT NULL REFERENCES profiles(id),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_project_files_project_id ON project_files(project_id);
CREATE INDEX idx_project_files_uploaded_by ON project_files(uploaded_by);
```

### 4.3 `project_deliverables` - Completed Work Files

```sql
CREATE TABLE project_deliverables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- File Info
    file_name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_type VARCHAR(50),
    file_size_bytes BIGINT,
    
    -- Version Control
    version INTEGER DEFAULT 1,
    is_final BOOLEAN DEFAULT FALSE,
    
    -- QC Status
    qc_status VARCHAR(20) DEFAULT 'pending' CHECK (qc_status IN ('pending', 'approved', 'rejected')),
    qc_notes TEXT,
    qc_by UUID REFERENCES supervisors(id),
    qc_at TIMESTAMPTZ,
    
    -- Metadata
    uploaded_by UUID NOT NULL REFERENCES profiles(id),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_project_deliverables_project_id ON project_deliverables(project_id);
CREATE INDEX idx_project_deliverables_qc_status ON project_deliverables(qc_status);
CREATE INDEX idx_project_deliverables_is_final ON project_deliverables(is_final) WHERE is_final = TRUE;
```

### 4.4 `project_status_history` - Status Audit Trail

```sql
CREATE TABLE project_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- Status Change
    from_status project_status,
    to_status project_status NOT NULL,
    
    -- Actor
    changed_by UUID REFERENCES profiles(id),
    changed_by_type VARCHAR(20) CHECK (changed_by_type IN ('user', 'doer', 'supervisor', 'admin', 'system')),
    
    -- Details
    notes TEXT,
    metadata JSONB,
    
    -- Timestamp
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_project_status_history_project_id ON project_status_history(project_id);
CREATE INDEX idx_project_status_history_created_at ON project_status_history(created_at DESC);
CREATE INDEX idx_project_status_history_to_status ON project_status_history(to_status);
```

### 4.5 `project_revisions` - Revision Requests

```sql
CREATE TABLE project_revisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- Revision Info
    revision_number INTEGER NOT NULL,
    requested_by UUID NOT NULL REFERENCES profiles(id),
    requested_by_type VARCHAR(20) NOT NULL CHECK (requested_by_type IN ('user', 'supervisor')),
    
    -- Details
    feedback TEXT NOT NULL,
    specific_changes TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'rejected')),
    
    -- Response
    response_notes TEXT,
    completed_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_project_revisions_project_id ON project_revisions(project_id);
CREATE INDEX idx_project_revisions_status ON project_revisions(status);
CREATE INDEX idx_project_revisions_requested_by ON project_revisions(requested_by);
```

### 4.6 `project_quotes` - Pricing Quotes

```sql
CREATE TABLE project_quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- Quote Details
    user_amount DECIMAL(10, 2) NOT NULL, -- What user pays
    doer_amount DECIMAL(10, 2) NOT NULL, -- What doer gets
    supervisor_amount DECIMAL(10, 2) NOT NULL, -- Supervisor commission
    platform_amount DECIMAL(10, 2) NOT NULL, -- Platform fee
    
    -- Breakdown
    base_price DECIMAL(10, 2),
    urgency_fee DECIMAL(10, 2) DEFAULT 0,
    complexity_fee DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    discount_code VARCHAR(50),
    
    -- Quote Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'accepted', 'rejected', 'expired')),
    valid_until TIMESTAMPTZ,
    
    -- Quoted by
    quoted_by UUID NOT NULL REFERENCES supervisors(id),
    
    -- Response
    responded_at TIMESTAMPTZ,
    rejection_reason TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_project_quotes_project_id ON project_quotes(project_id);
CREATE INDEX idx_project_quotes_status ON project_quotes(status);
CREATE INDEX idx_project_quotes_quoted_by ON project_quotes(quoted_by);
```

### 4.7 `project_assignments` - Assignment History

```sql
CREATE TABLE project_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- Assignment Type
    assignment_type VARCHAR(20) NOT NULL CHECK (assignment_type IN ('supervisor', 'doer')),
    
    -- Assignee
    assignee_id UUID NOT NULL, -- References supervisors.id or doers.id based on type
    
    -- Assigner
    assigned_by UUID NOT NULL REFERENCES profiles(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'reassigned', 'completed', 'cancelled')),
    
    -- Reason (for reassignment)
    reassignment_reason TEXT,
    
    -- Timestamps
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_project_assignments_project_id ON project_assignments(project_id);
CREATE INDEX idx_project_assignments_assignee_id ON project_assignments(assignee_id);
CREATE INDEX idx_project_assignments_type ON project_assignments(assignment_type);
CREATE INDEX idx_project_assignments_status ON project_assignments(status);
```

### 4.8 `quality_reports` - AI/Plagiarism Reports

```sql
CREATE TABLE quality_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    deliverable_id UUID REFERENCES project_deliverables(id),
    
    -- Report Type
    report_type VARCHAR(20) NOT NULL CHECK (report_type IN ('ai_detection', 'plagiarism')),
    
    -- Results
    score DECIMAL(5, 2), -- Percentage
    result VARCHAR(20) CHECK (result IN ('pass', 'fail', 'warning')),
    report_url TEXT,
    
    -- Details
    details JSONB, -- Detailed breakdown
    
    -- Generated by
    generated_by UUID REFERENCES profiles(id),
    tool_used VARCHAR(100), -- e.g., 'turnitin', 'gptzero'
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_quality_reports_project_id ON quality_reports(project_id);
CREATE INDEX idx_quality_reports_deliverable_id ON quality_reports(deliverable_id);
CREATE INDEX idx_quality_reports_type ON quality_reports(report_type);
CREATE INDEX idx_quality_reports_result ON quality_reports(result);
```

### 4.9 `project_timeline` - Milestone Tracking

```sql
CREATE TABLE project_timeline (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- Milestone
    milestone_type VARCHAR(50) NOT NULL,
    milestone_title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Status
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    
    -- Order
    sequence_order INTEGER NOT NULL,
    
    -- Timestamps
    expected_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_project_timeline_project_id ON project_timeline(project_id);
CREATE INDEX idx_project_timeline_is_completed ON project_timeline(is_completed);
```

---

## 5. Financial Tables

### 5.1 `wallets` - User Wallets

```sql
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Balance
    balance DECIMAL(12, 2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    currency VARCHAR(3) DEFAULT 'INR',
    
    -- Lifetime Stats
    total_credited DECIMAL(12, 2) DEFAULT 0,
    total_debited DECIMAL(12, 2) DEFAULT 0,
    total_withdrawn DECIMAL(12, 2) DEFAULT 0,
    
    -- Lock (for pending transactions)
    locked_amount DECIMAL(12, 2) DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_wallets_profile_id ON wallets(profile_id);
CREATE INDEX idx_wallets_balance ON wallets(balance) WHERE balance > 0;
```

### 5.2 `wallet_transactions` - Wallet Transaction History

```sql
CREATE TYPE transaction_type AS ENUM (
    'credit',
    'debit',
    'refund',
    'withdrawal',
    'top_up',
    'project_payment',
    'project_earning',
    'commission',
    'bonus',
    'penalty',
    'reversal'
);

CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    
    -- Transaction Details
    transaction_type transaction_type NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    balance_before DECIMAL(12, 2) NOT NULL,
    balance_after DECIMAL(12, 2) NOT NULL,
    
    -- Reference
    reference_type VARCHAR(50), -- 'project', 'payout', 'top_up', etc.
    reference_id UUID, -- ID of related entity
    
    -- Description
    description TEXT,
    notes TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_wallet_transactions_wallet_id ON wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_type ON wallet_transactions(transaction_type);
CREATE INDEX idx_wallet_transactions_reference ON wallet_transactions(reference_type, reference_id);
CREATE INDEX idx_wallet_transactions_created_at ON wallet_transactions(created_at DESC);
CREATE INDEX idx_wallet_transactions_status ON wallet_transactions(status);
```

### 5.3 `payments` - Payment Records

```sql
CREATE TYPE payment_status AS ENUM (
    'initiated',
    'pending',
    'processing',
    'completed',
    'failed',
    'cancelled',
    'refunded',
    'partially_refunded'
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Payer
    user_id UUID NOT NULL REFERENCES profiles(id),
    
    -- Amount
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    
    -- Payment Gateway
    gateway VARCHAR(50) DEFAULT 'razorpay',
    gateway_order_id VARCHAR(255),
    gateway_payment_id VARCHAR(255),
    gateway_signature VARCHAR(255),
    
    -- Payment Method
    payment_method VARCHAR(50), -- upi, card, netbanking, wallet
    payment_method_details JSONB,
    
    -- Reference
    reference_type VARCHAR(50) NOT NULL, -- 'project', 'top_up', 'subscription'
    reference_id UUID,
    
    -- Status
    status payment_status NOT NULL DEFAULT 'initiated',
    
    -- Failure Info
    failure_reason TEXT,
    failure_code VARCHAR(50),
    
    -- Refund Info
    refund_amount DECIMAL(12, 2),
    refund_id VARCHAR(255),
    refunded_at TIMESTAMPTZ,
    refund_reason TEXT,
    
    -- Timestamps
    initiated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_gateway_order_id ON payments(gateway_order_id);
CREATE INDEX idx_payments_gateway_payment_id ON payments(gateway_payment_id);
CREATE INDEX idx_payments_reference ON payments(reference_type, reference_id);
CREATE INDEX idx_payments_created_at ON payments(created_at DESC);
```

### 5.4 `payment_methods` - Saved Payment Methods

```sql
CREATE TABLE payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Method Type
    method_type VARCHAR(20) NOT NULL CHECK (method_type IN ('upi', 'card', 'netbanking')),
    
    -- Details (encrypted/tokenized)
    upi_id VARCHAR(100),
    card_last_four VARCHAR(4),
    card_network VARCHAR(20), -- visa, mastercard, rupay
    card_type VARCHAR(20), -- debit, credit
    card_token TEXT, -- Gateway token
    bank_name VARCHAR(100),
    
    -- Display
    display_name VARCHAR(100),
    
    -- Flags
    is_default BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_payment_methods_profile_id ON payment_methods(profile_id);
CREATE INDEX idx_payment_methods_is_default ON payment_methods(is_default) WHERE is_default = TRUE;
```

### 5.5 `payouts` - Doer/Supervisor Payouts

```sql
CREATE TYPE payout_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'cancelled'
);

CREATE TABLE payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Recipient
    recipient_id UUID NOT NULL REFERENCES profiles(id),
    recipient_type VARCHAR(20) NOT NULL CHECK (recipient_type IN ('doer', 'supervisor')),
    
    -- Amount
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    
    -- Bank Details (snapshot at time of payout)
    bank_account_name VARCHAR(255),
    bank_account_number VARCHAR(50),
    bank_ifsc_code VARCHAR(20),
    bank_name VARCHAR(100),
    upi_id VARCHAR(100),
    
    -- Payment Method
    payout_method VARCHAR(20) NOT NULL CHECK (payout_method IN ('bank_transfer', 'upi')),
    
    -- Gateway
    gateway VARCHAR(50) DEFAULT 'razorpay',
    gateway_payout_id VARCHAR(255),
    gateway_reference VARCHAR(255),
    
    -- Status
    status payout_status NOT NULL DEFAULT 'pending',
    
    -- Failure Info
    failure_reason TEXT,
    retry_count INTEGER DEFAULT 0,
    
    -- Reference
    reference_type VARCHAR(50), -- 'project_earnings', 'withdrawal_request'
    reference_ids UUID[], -- Array of project IDs or transaction IDs
    
    -- Processing
    requested_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_payouts_recipient_id ON payouts(recipient_id);
CREATE INDEX idx_payouts_recipient_type ON payouts(recipient_type);
CREATE INDEX idx_payouts_status ON payouts(status);
CREATE INDEX idx_payouts_created_at ON payouts(created_at DESC);
CREATE INDEX idx_payouts_gateway_payout_id ON payouts(gateway_payout_id);
```

### 5.6 `payout_requests` - Withdrawal Requests

```sql
CREATE TABLE payout_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Requester
    profile_id UUID NOT NULL REFERENCES profiles(id),
    requester_type VARCHAR(20) NOT NULL CHECK (requester_type IN ('doer', 'supervisor')),
    
    -- Amount
    requested_amount DECIMAL(12, 2) NOT NULL,
    approved_amount DECIMAL(12, 2),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'processing', 'completed', 'cancelled')),
    
    -- Processing
    reviewed_by UUID REFERENCES admins(id),
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    
    -- Payout Link
    payout_id UUID REFERENCES payouts(id),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_payout_requests_profile_id ON payout_requests(profile_id);
CREATE INDEX idx_payout_requests_status ON payout_requests(status);
CREATE INDEX idx_payout_requests_created_at ON payout_requests(created_at DESC);
```

### 5.7 `invoices` - Invoice Generation

```sql
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Invoice Number
    invoice_number VARCHAR(50) NOT NULL UNIQUE, -- e.g., INV-2025-00001
    
    -- Parties
    user_id UUID NOT NULL REFERENCES profiles(id),
    
    -- Reference
    project_id UUID REFERENCES projects(id),
    payment_id UUID REFERENCES payments(id),
    
    -- Amounts
    subtotal DECIMAL(12, 2) NOT NULL,
    tax_amount DECIMAL(12, 2) DEFAULT 0,
    discount_amount DECIMAL(12, 2) DEFAULT 0,
    total_amount DECIMAL(12, 2) NOT NULL,
    
    -- Tax Details
    tax_rate DECIMAL(5, 2),
    tax_type VARCHAR(20), -- GST, etc.
    
    -- Invoice Details
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE,
    
    -- Status
    status VARCHAR(20) DEFAULT 'generated' CHECK (status IN ('draft', 'generated', 'sent', 'paid', 'cancelled')),
    
    -- PDF
    pdf_url TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_invoices_invoice_number ON invoices(invoice_number);
CREATE INDEX idx_invoices_user_id ON invoices(user_id);
CREATE INDEX idx_invoices_project_id ON invoices(project_id);
CREATE INDEX idx_invoices_status ON invoices(status);
```

---

## 6. Chat & Communication Tables

### 6.1 `chat_rooms` - Chat Rooms

```sql
CREATE TYPE chat_room_type AS ENUM (
    'project_user_supervisor',
    'project_supervisor_doer',
    'project_all',
    'support',
    'direct'
);

CREATE TABLE chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Room Info
    room_type chat_room_type NOT NULL,
    name VARCHAR(255),
    
    -- Project Link
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_suspended BOOLEAN DEFAULT FALSE,
    suspended_by UUID REFERENCES profiles(id),
    suspended_at TIMESTAMPTZ,
    suspension_reason TEXT,
    
    -- Metadata
    last_message_at TIMESTAMPTZ,
    message_count INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_chat_rooms_project_id ON chat_rooms(project_id);
CREATE INDEX idx_chat_rooms_room_type ON chat_rooms(room_type);
CREATE INDEX idx_chat_rooms_is_active ON chat_rooms(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_chat_rooms_last_message_at ON chat_rooms(last_message_at DESC);
```

### 6.2 `chat_participants` - Room Participants

```sql
CREATE TABLE chat_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Room & User
    chat_room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Role in Chat
    participant_role VARCHAR(20) NOT NULL CHECK (participant_role IN ('user', 'doer', 'supervisor', 'admin', 'support')),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    left_at TIMESTAMPTZ,
    
    -- Read Status
    last_read_at TIMESTAMPTZ,
    unread_count INTEGER DEFAULT 0,
    
    -- Notifications
    notifications_enabled BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(chat_room_id, profile_id)
);

-- Indexes
CREATE INDEX idx_chat_participants_room_id ON chat_participants(chat_room_id);
CREATE INDEX idx_chat_participants_profile_id ON chat_participants(profile_id);
CREATE INDEX idx_chat_participants_is_active ON chat_participants(is_active) WHERE is_active = TRUE;
```

### 6.3 `chat_messages` - Messages

```sql
CREATE TYPE message_type AS ENUM (
    'text',
    'file',
    'image',
    'system',
    'action'
);

CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Room
    chat_room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    
    -- Sender
    sender_id UUID NOT NULL REFERENCES profiles(id),
    
    -- Message Content
    message_type message_type NOT NULL DEFAULT 'text',
    content TEXT,
    
    -- File Attachment
    file_url TEXT,
    file_name VARCHAR(255),
    file_type VARCHAR(50),
    file_size_bytes BIGINT,
    
    -- System/Action Messages
    action_type VARCHAR(50), -- 'status_change', 'file_uploaded', etc.
    action_metadata JSONB,
    
    -- Reply
    reply_to_id UUID REFERENCES chat_messages(id),
    
    -- Status
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMPTZ,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    
    -- Moderation
    is_flagged BOOLEAN DEFAULT FALSE,
    flagged_reason TEXT,
    contains_contact_info BOOLEAN DEFAULT FALSE, -- Auto-detected
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_chat_messages_room_id ON chat_messages(chat_room_id);
CREATE INDEX idx_chat_messages_sender_id ON chat_messages(sender_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at DESC);
CREATE INDEX idx_chat_messages_room_created ON chat_messages(chat_room_id, created_at DESC);
CREATE INDEX idx_chat_messages_is_deleted ON chat_messages(is_deleted) WHERE is_deleted = FALSE;
CREATE INDEX idx_chat_messages_is_flagged ON chat_messages(is_flagged) WHERE is_flagged = TRUE;
```

### 6.4 `notifications` - Push/In-App Notifications

```sql
CREATE TYPE notification_type AS ENUM (
    'project_submitted',
    'quote_ready',
    'payment_received',
    'project_assigned',
    'task_available',
    'task_assigned',
    'work_submitted',
    'qc_approved',
    'qc_rejected',
    'revision_requested',
    'project_delivered',
    'project_completed',
    'new_message',
    'payout_processed',
    'system_alert',
    'promotional'
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Recipient
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Notification Details
    notification_type notification_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    
    -- Reference
    reference_type VARCHAR(50), -- 'project', 'chat', 'payout', etc.
    reference_id UUID,
    
    -- Deep Link
    action_url TEXT,
    
    -- Channels
    push_sent BOOLEAN DEFAULT FALSE,
    push_sent_at TIMESTAMPTZ,
    whatsapp_sent BOOLEAN DEFAULT FALSE,
    whatsapp_sent_at TIMESTAMPTZ,
    email_sent BOOLEAN DEFAULT FALSE,
    email_sent_at TIMESTAMPTZ,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_notifications_profile_id ON notifications(profile_id);
CREATE INDEX idx_notifications_type ON notifications(notification_type);
CREATE INDEX idx_notifications_is_read ON notifications(profile_id, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_reference ON notifications(reference_type, reference_id);
```

---

## 7. Marketplace Tables

### 7.1 `marketplace_categories` - Listing Categories

```sql
CREATE TABLE marketplace_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Category Info
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(100),
    
    -- Hierarchy
    parent_id UUID REFERENCES marketplace_categories(id),
    
    -- Display
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_marketplace_categories_slug ON marketplace_categories(slug);
CREATE INDEX idx_marketplace_categories_parent_id ON marketplace_categories(parent_id);
CREATE INDEX idx_marketplace_categories_is_active ON marketplace_categories(is_active) WHERE is_active = TRUE;
```

### 7.2 `marketplace_listings` - Items for Sale/Rent

```sql
CREATE TYPE listing_type AS ENUM (
    'sell',
    'rent',
    'free',
    'opportunity',
    'housing',
    'community_post',
    'poll',
    'event'
);

CREATE TYPE listing_status AS ENUM (
    'draft',
    'pending_review',
    'active',
    'sold',
    'rented',
    'expired',
    'rejected',
    'removed'
);

CREATE TABLE marketplace_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Owner
    seller_id UUID NOT NULL REFERENCES profiles(id),
    
    -- Listing Type
    listing_type listing_type NOT NULL,
    category_id UUID REFERENCES marketplace_categories(id),
    
    -- Basic Info
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Pricing
    price DECIMAL(10, 2),
    price_negotiable BOOLEAN DEFAULT TRUE,
    rent_period VARCHAR(20), -- 'daily', 'weekly', 'monthly'
    
    -- Condition (for items)
    item_condition VARCHAR(20) CHECK (item_condition IN ('new', 'like_new', 'good', 'fair', 'poor')),
    
    -- Location
    city VARCHAR(100),
    university_id UUID REFERENCES universities(id),
    location_text VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    distance_km DECIMAL(5, 2), -- Calculated from user
    
    -- Housing Specific
    housing_type VARCHAR(50), -- 'room', 'flat', 'pg', 'flatmate'
    bedrooms INTEGER,
    available_from DATE,
    
    -- Opportunity Specific
    opportunity_type VARCHAR(50), -- 'internship', 'job', 'gig', 'event'
    company_name VARCHAR(255),
    application_deadline DATE,
    opportunity_url TEXT,
    
    -- Community Post Specific
    post_content TEXT,
    
    -- Poll Specific
    poll_options JSONB, -- Array of options
    poll_ends_at TIMESTAMPTZ,
    
    -- Status
    status listing_status NOT NULL DEFAULT 'pending_review',
    
    -- Moderation
    reviewed_by UUID REFERENCES admins(id),
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    
    -- Stats
    view_count INTEGER DEFAULT 0,
    inquiry_count INTEGER DEFAULT 0,
    
    -- Timestamps
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_marketplace_listings_seller_id ON marketplace_listings(seller_id);
CREATE INDEX idx_marketplace_listings_type ON marketplace_listings(listing_type);
CREATE INDEX idx_marketplace_listings_category_id ON marketplace_listings(category_id);
CREATE INDEX idx_marketplace_listings_status ON marketplace_listings(status);
CREATE INDEX idx_marketplace_listings_city ON marketplace_listings(city);
CREATE INDEX idx_marketplace_listings_university_id ON marketplace_listings(university_id);
CREATE INDEX idx_marketplace_listings_price ON marketplace_listings(price);
CREATE INDEX idx_marketplace_listings_created_at ON marketplace_listings(created_at DESC);
CREATE INDEX idx_marketplace_listings_location ON marketplace_listings USING GIST (
    ll_to_earth(latitude, longitude)
) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
CREATE INDEX idx_marketplace_listings_active ON marketplace_listings(status, created_at DESC) WHERE status = 'active';
```

### 7.3 `listing_images` - Listing Media

```sql
CREATE TABLE listing_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES marketplace_listings(id) ON DELETE CASCADE,
    
    -- Image Info
    image_url TEXT NOT NULL,
    thumbnail_url TEXT,
    
    -- Order
    display_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_listing_images_listing_id ON listing_images(listing_id);
CREATE INDEX idx_listing_images_is_primary ON listing_images(is_primary) WHERE is_primary = TRUE;
```

### 7.4 `listing_inquiries` - Buyer Inquiries

```sql
CREATE TABLE listing_inquiries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES marketplace_listings(id) ON DELETE CASCADE,
    
    -- Inquirer
    inquirer_id UUID NOT NULL REFERENCES profiles(id),
    
    -- Message
    message TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'responded', 'closed')),
    
    -- Response
    response TEXT,
    responded_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_listing_inquiries_listing_id ON listing_inquiries(listing_id);
CREATE INDEX idx_listing_inquiries_inquirer_id ON listing_inquiries(inquirer_id);
CREATE INDEX idx_listing_inquiries_status ON listing_inquiries(status);
```

---

## 8. Training & Activation Tables

### 8.1 `training_modules` - Training Content

```sql
CREATE TABLE training_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Module Info
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Target
    target_role VARCHAR(20) NOT NULL CHECK (target_role IN ('doer', 'supervisor')),
    
    -- Content
    content_type VARCHAR(20) NOT NULL CHECK (content_type IN ('video', 'pdf', 'article', 'quiz')),
    content_url TEXT,
    content_html TEXT,
    duration_minutes INTEGER,
    
    -- Order
    sequence_order INTEGER NOT NULL,
    
    -- Requirements
    is_mandatory BOOLEAN DEFAULT TRUE,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_training_modules_target_role ON training_modules(target_role);
CREATE INDEX idx_training_modules_is_active ON training_modules(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_training_modules_sequence ON training_modules(target_role, sequence_order);
```

### 8.2 `training_progress` - User Training Progress

```sql
CREATE TABLE training_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    module_id UUID NOT NULL REFERENCES training_modules(id) ON DELETE CASCADE,
    
    -- Progress
    status VARCHAR(20) DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed')),
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
    
    -- Completion
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    time_spent_minutes INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(profile_id, module_id)
);

-- Indexes
CREATE INDEX idx_training_progress_profile_id ON training_progress(profile_id);
CREATE INDEX idx_training_progress_module_id ON training_progress(module_id);
CREATE INDEX idx_training_progress_status ON training_progress(status);
```

### 8.3 `quiz_questions` - Quiz Questions

```sql
CREATE TABLE quiz_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Quiz Target
    target_role VARCHAR(20) NOT NULL CHECK (target_role IN ('doer', 'supervisor')),
    
    -- Question
    question_text TEXT NOT NULL,
    question_type VARCHAR(20) DEFAULT 'multiple_choice' CHECK (question_type IN ('multiple_choice', 'true_false', 'scenario')),
    
    -- Options
    options JSONB NOT NULL, -- Array of {id, text, is_correct}
    correct_option_ids TEXT[], -- Array of correct option IDs
    
    -- Explanation
    explanation TEXT,
    
    -- Scoring
    points INTEGER DEFAULT 1,
    
    -- Order
    sequence_order INTEGER,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_quiz_questions_target_role ON quiz_questions(target_role);
CREATE INDEX idx_quiz_questions_is_active ON quiz_questions(is_active) WHERE is_active = TRUE;
```

### 8.4 `quiz_attempts` - Quiz Attempt Records

```sql
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Quiz Info
    target_role VARCHAR(20) NOT NULL CHECK (target_role IN ('doer', 'supervisor')),
    
    -- Attempt Details
    attempt_number INTEGER NOT NULL,
    
    -- Answers
    answers JSONB NOT NULL, -- Array of {question_id, selected_options, is_correct}
    
    -- Scoring
    total_questions INTEGER NOT NULL,
    correct_answers INTEGER NOT NULL,
    score_percentage DECIMAL(5, 2) NOT NULL,
    
    -- Pass/Fail
    passing_score DECIMAL(5, 2) NOT NULL,
    is_passed BOOLEAN NOT NULL,
    
    -- Timing
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL,
    time_taken_seconds INTEGER,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_quiz_attempts_profile_id ON quiz_attempts(profile_id);
CREATE INDEX idx_quiz_attempts_target_role ON quiz_attempts(target_role);
CREATE INDEX idx_quiz_attempts_is_passed ON quiz_attempts(is_passed);
CREATE INDEX idx_quiz_attempts_created_at ON quiz_attempts(created_at DESC);
```

### 8.5 `doer_activation` - Doer Activation Status

```sql
CREATE TABLE doer_activation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doer_id UUID NOT NULL UNIQUE REFERENCES doers(id) ON DELETE CASCADE,
    
    -- Step 1: Training
    training_completed BOOLEAN DEFAULT FALSE,
    training_completed_at TIMESTAMPTZ,
    
    -- Step 2: Quiz
    quiz_passed BOOLEAN DEFAULT FALSE,
    quiz_passed_at TIMESTAMPTZ,
    quiz_attempt_id UUID REFERENCES quiz_attempts(id),
    total_quiz_attempts INTEGER DEFAULT 0,
    
    -- Step 3: Bank Details
    bank_details_added BOOLEAN DEFAULT FALSE,
    bank_details_added_at TIMESTAMPTZ,
    
    -- Overall Status
    is_fully_activated BOOLEAN DEFAULT FALSE,
    activated_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_doer_activation_doer_id ON doer_activation(doer_id);
CREATE INDEX idx_doer_activation_is_activated ON doer_activation(is_fully_activated);
```

### 8.6 `supervisor_activation` - Supervisor Activation Status

```sql
CREATE TABLE supervisor_activation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supervisor_id UUID NOT NULL UNIQUE REFERENCES supervisors(id) ON DELETE CASCADE,
    
    -- Step 1: CV Verification
    cv_submitted BOOLEAN DEFAULT FALSE,
    cv_submitted_at TIMESTAMPTZ,
    cv_verified BOOLEAN DEFAULT FALSE,
    cv_verified_at TIMESTAMPTZ,
    cv_verified_by UUID REFERENCES admins(id),
    cv_rejection_reason TEXT,
    
    -- Step 2: Training
    training_completed BOOLEAN DEFAULT FALSE,
    training_completed_at TIMESTAMPTZ,
    
    -- Step 3: Quiz
    quiz_passed BOOLEAN DEFAULT FALSE,
    quiz_passed_at TIMESTAMPTZ,
    quiz_attempt_id UUID REFERENCES quiz_attempts(id),
    total_quiz_attempts INTEGER DEFAULT 0,
    
    -- Step 4: Bank Details
    bank_details_added BOOLEAN DEFAULT FALSE,
    bank_details_added_at TIMESTAMPTZ,
    
    -- Overall Status
    is_fully_activated BOOLEAN DEFAULT FALSE,
    activated_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_supervisor_activation_supervisor_id ON supervisor_activation(supervisor_id);
CREATE INDEX idx_supervisor_activation_is_activated ON supervisor_activation(is_fully_activated);
CREATE INDEX idx_supervisor_activation_cv_verified ON supervisor_activation(cv_verified);
```

---

## 9. Reviews & Ratings Tables

### 9.1 `doer_reviews` - Reviews for Doers

```sql
CREATE TABLE doer_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Doer being reviewed
    doer_id UUID NOT NULL REFERENCES doers(id) ON DELETE CASCADE,
    
    -- Reviewer
    reviewer_id UUID NOT NULL REFERENCES profiles(id),
    reviewer_type VARCHAR(20) NOT NULL CHECK (reviewer_type IN ('user', 'supervisor')),
    
    -- Project
    project_id UUID REFERENCES projects(id),
    
    -- Rating
    overall_rating INTEGER NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
    quality_rating INTEGER CHECK (quality_rating BETWEEN 1 AND 5),
    timeliness_rating INTEGER CHECK (timeliness_rating BETWEEN 1 AND 5),
    communication_rating INTEGER CHECK (communication_rating BETWEEN 1 AND 5),
    
    -- Review
    review_text TEXT,
    
    -- Visibility
    is_public BOOLEAN DEFAULT TRUE,
    
    -- Moderation
    is_flagged BOOLEAN DEFAULT FALSE,
    flag_reason TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_doer_reviews_doer_id ON doer_reviews(doer_id);
CREATE INDEX idx_doer_reviews_reviewer_id ON doer_reviews(reviewer_id);
CREATE INDEX idx_doer_reviews_project_id ON doer_reviews(project_id);
CREATE INDEX idx_doer_reviews_overall_rating ON doer_reviews(overall_rating);
CREATE INDEX idx_doer_reviews_created_at ON doer_reviews(created_at DESC);
```

### 9.2 `supervisor_reviews` - Reviews for Supervisors

```sql
CREATE TABLE supervisor_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Supervisor being reviewed
    supervisor_id UUID NOT NULL REFERENCES supervisors(id) ON DELETE CASCADE,
    
    -- Reviewer
    reviewer_id UUID NOT NULL REFERENCES profiles(id),
    reviewer_type VARCHAR(20) NOT NULL CHECK (reviewer_type IN ('user', 'doer')),
    
    -- Project
    project_id UUID REFERENCES projects(id),
    
    -- Rating
    overall_rating INTEGER NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
    communication_rating INTEGER CHECK (communication_rating BETWEEN 1 AND 5),
    helpfulness_rating INTEGER CHECK (helpfulness_rating BETWEEN 1 AND 5),
    
    -- Review
    review_text TEXT,
    
    -- Visibility
    is_public BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_supervisor_reviews_supervisor_id ON supervisor_reviews(supervisor_id);
CREATE INDEX idx_supervisor_reviews_reviewer_id ON supervisor_reviews(reviewer_id);
CREATE INDEX idx_supervisor_reviews_project_id ON supervisor_reviews(project_id);
CREATE INDEX idx_supervisor_reviews_created_at ON supervisor_reviews(created_at DESC);
```

### 9.3 `user_feedback` - User Satisfaction Feedback

```sql
CREATE TABLE user_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- User
    user_id UUID NOT NULL REFERENCES profiles(id),
    
    -- Project
    project_id UUID REFERENCES projects(id),
    
    -- Rating
    overall_satisfaction INTEGER NOT NULL CHECK (overall_satisfaction BETWEEN 1 AND 5),
    would_recommend BOOLEAN,
    
    -- Feedback
    feedback_text TEXT,
    improvement_suggestions TEXT,
    
    -- NPS Score
    nps_score INTEGER CHECK (nps_score BETWEEN 0 AND 10),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_feedback_user_id ON user_feedback(user_id);
CREATE INDEX idx_user_feedback_project_id ON user_feedback(project_id);
CREATE INDEX idx_user_feedback_nps_score ON user_feedback(nps_score);
```

---

## 10. Configuration Tables

### 10.1 `universities` - University Master

```sql
CREATE TABLE universities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- University Info
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    
    -- Verification
    email_domains TEXT[], -- ['@lpu.in', '@lpu.edu']
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_universities_name ON universities(name);
CREATE INDEX idx_universities_city ON universities(city);
CREATE INDEX idx_universities_is_active ON universities(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_universities_email_domains ON universities USING GIN(email_domains);
```

### 10.2 `courses` - Course Master

```sql
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Course Info
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(50), -- B.Tech, MBA, etc.
    degree_type VARCHAR(50), -- undergraduate, postgraduate, diploma
    duration_years INTEGER,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_courses_name ON courses(name);
CREATE INDEX idx_courses_degree_type ON courses(degree_type);
CREATE INDEX idx_courses_is_active ON courses(is_active) WHERE is_active = TRUE;
```

### 10.3 `subjects` - Subject Master

```sql
CREATE TABLE subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Subject Info
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(100),
    
    -- Categorization
    parent_id UUID REFERENCES subjects(id),
    category VARCHAR(100), -- 'academic', 'professional', 'creative'
    
    -- Display
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_subjects_slug ON subjects(slug);
CREATE INDEX idx_subjects_parent_id ON subjects(parent_id);
CREATE INDEX idx_subjects_category ON subjects(category);
CREATE INDEX idx_subjects_is_active ON subjects(is_active) WHERE is_active = TRUE;
```

### 10.4 `skills` - Skills Master

```sql
CREATE TABLE skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Skill Info
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    
    -- Categorization
    category VARCHAR(100), -- 'programming', 'writing', 'design', etc.
    subject_id UUID REFERENCES subjects(id),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_skills_slug ON skills(slug);
CREATE INDEX idx_skills_category ON skills(category);
CREATE INDEX idx_skills_subject_id ON skills(subject_id);
CREATE INDEX idx_skills_is_active ON skills(is_active) WHERE is_active = TRUE;
```

### 10.5 `industries` - Industry Master

```sql
CREATE TABLE industries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Industry Info
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_industries_slug ON industries(slug);
CREATE INDEX idx_industries_is_active ON industries(is_active) WHERE is_active = TRUE;
```

### 10.6 `reference_styles` - Citation Styles

```sql
CREATE TABLE reference_styles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Style Info
    name VARCHAR(100) NOT NULL, -- APA, Harvard, MLA, Chicago
    version VARCHAR(50),
    description TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_reference_styles_name ON reference_styles(name);
```

### 10.7 `referral_codes` - Promo/Referral Codes

```sql
CREATE TABLE referral_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Code Info
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    
    -- Type
    code_type VARCHAR(20) NOT NULL CHECK (code_type IN ('referral', 'promo', 'campaign')),
    
    -- Owner (for referral codes)
    owner_id UUID REFERENCES profiles(id),
    
    -- Discount
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(10, 2) NOT NULL,
    max_discount DECIMAL(10, 2), -- For percentage discounts
    min_order_value DECIMAL(10, 2),
    
    -- Usage Limits
    max_uses INTEGER,
    max_uses_per_user INTEGER DEFAULT 1,
    current_uses INTEGER DEFAULT 0,
    
    -- Validity
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_referral_codes_code ON referral_codes(code);
CREATE INDEX idx_referral_codes_owner_id ON referral_codes(owner_id);
CREATE INDEX idx_referral_codes_type ON referral_codes(code_type);
CREATE INDEX idx_referral_codes_is_active ON referral_codes(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_referral_codes_valid ON referral_codes(valid_from, valid_until) WHERE is_active = TRUE;
```

### 10.8 `referral_usage` - Referral Code Usage Tracking

```sql
CREATE TABLE referral_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Code
    referral_code_id UUID NOT NULL REFERENCES referral_codes(id),
    
    -- User
    used_by UUID NOT NULL REFERENCES profiles(id),
    
    -- Usage
    project_id UUID REFERENCES projects(id),
    payment_id UUID REFERENCES payments(id),
    discount_applied DECIMAL(10, 2) NOT NULL,
    
    -- Timestamps
    used_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_referral_usage_code_id ON referral_usage(referral_code_id);
CREATE INDEX idx_referral_usage_used_by ON referral_usage(used_by);
CREATE INDEX idx_referral_usage_used_at ON referral_usage(used_at DESC);
```

### 10.9 `banners` - Promotional Banners

```sql
CREATE TABLE banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Banner Info
    title VARCHAR(255) NOT NULL,
    subtitle TEXT,
    
    -- Media
    image_url TEXT NOT NULL,
    image_url_mobile TEXT,
    
    -- Action
    cta_text VARCHAR(100),
    cta_url TEXT,
    cta_action VARCHAR(50), -- 'navigate', 'open_url', 'open_modal'
    
    -- Targeting
    target_user_types TEXT[], -- ['student', 'professional']
    target_roles TEXT[], -- ['user', 'doer', 'supervisor']
    
    -- Display
    display_location VARCHAR(50) NOT NULL, -- 'home', 'marketplace', 'project'
    display_order INTEGER DEFAULT 0,
    
    -- Schedule
    start_date TIMESTAMPTZ DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Stats
    impression_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_banners_display_location ON banners(display_location);
CREATE INDEX idx_banners_is_active ON banners(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_banners_schedule ON banners(start_date, end_date) WHERE is_active = TRUE;
CREATE INDEX idx_banners_target_user_types ON banners USING GIN(target_user_types);
```

### 10.10 `faqs` - FAQ Management

```sql
CREATE TABLE faqs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- FAQ Info
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    
    -- Categorization
    category VARCHAR(100),
    target_role VARCHAR(20), -- 'user', 'doer', 'supervisor', 'all'
    
    -- Display
    display_order INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Stats
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_faqs_category ON faqs(category);
CREATE INDEX idx_faqs_target_role ON faqs(target_role);
CREATE INDEX idx_faqs_is_active ON faqs(is_active) WHERE is_active = TRUE;
```

### 10.11 `pricing_guides` - Pricing Reference

```sql
CREATE TABLE pricing_guides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Service
    service_type service_type NOT NULL,
    subject_id UUID REFERENCES subjects(id),
    
    -- Pricing
    base_price_per_page DECIMAL(10, 2),
    base_price_per_word DECIMAL(10, 4),
    base_price_fixed DECIMAL(10, 2),
    
    -- Urgency Multipliers
    urgency_24h_multiplier DECIMAL(3, 2) DEFAULT 1.5,
    urgency_48h_multiplier DECIMAL(3, 2) DEFAULT 1.3,
    urgency_72h_multiplier DECIMAL(3, 2) DEFAULT 1.15,
    
    -- Complexity Multipliers
    complexity_easy_multiplier DECIMAL(3, 2) DEFAULT 1.0,
    complexity_medium_multiplier DECIMAL(3, 2) DEFAULT 1.2,
    complexity_hard_multiplier DECIMAL(3, 2) DEFAULT 1.5,
    
    -- Margins
    supervisor_percentage DECIMAL(5, 2) DEFAULT 15,
    platform_percentage DECIMAL(5, 2) DEFAULT 20,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_pricing_guides_service_type ON pricing_guides(service_type);
CREATE INDEX idx_pricing_guides_subject_id ON pricing_guides(subject_id);
CREATE INDEX idx_pricing_guides_is_active ON pricing_guides(is_active) WHERE is_active = TRUE;
```

### 10.12 `app_settings` - Global App Settings

```sql
CREATE TABLE app_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Setting
    key VARCHAR(100) NOT NULL UNIQUE,
    value JSONB NOT NULL,
    
    -- Description
    description TEXT,
    
    -- Categorization
    category VARCHAR(100),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_app_settings_key ON app_settings(key);
CREATE INDEX idx_app_settings_category ON app_settings(category);
```

---

## 11. Support & Audit Tables

### 11.1 `support_tickets` - Support Tickets

```sql
CREATE TYPE ticket_status AS ENUM (
    'open',
    'in_progress',
    'waiting_response',
    'resolved',
    'closed',
    'reopened'
);

CREATE TYPE ticket_priority AS ENUM (
    'low',
    'medium',
    'high',
    'urgent'
);

CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Ticket Number
    ticket_number VARCHAR(20) NOT NULL UNIQUE, -- e.g., TKT-2025-00001
    
    -- Requester
    requester_id UUID NOT NULL REFERENCES profiles(id),
    
    -- Ticket Info
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100),
    
    -- Reference
    project_id UUID REFERENCES projects(id),
    
    -- Priority & Status
    priority ticket_priority DEFAULT 'medium',
    status ticket_status DEFAULT 'open',
    
    -- Assignment
    assigned_to UUID REFERENCES admins(id),
    assigned_at TIMESTAMPTZ,
    
    -- Resolution
    resolution_notes TEXT,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES profiles(id),
    
    -- Satisfaction
    satisfaction_rating INTEGER CHECK (satisfaction_rating BETWEEN 1 AND 5),
    satisfaction_feedback TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    first_response_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_support_tickets_ticket_number ON support_tickets(ticket_number);
CREATE INDEX idx_support_tickets_requester_id ON support_tickets(requester_id);
CREATE INDEX idx_support_tickets_status ON support_tickets(status);
CREATE INDEX idx_support_tickets_priority ON support_tickets(priority);
CREATE INDEX idx_support_tickets_assigned_to ON support_tickets(assigned_to);
CREATE INDEX idx_support_tickets_created_at ON support_tickets(created_at DESC);
CREATE INDEX idx_support_tickets_open ON support_tickets(status, priority) WHERE status IN ('open', 'in_progress', 'waiting_response');
```

### 11.2 `ticket_messages` - Ticket Conversation

```sql
CREATE TABLE ticket_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
    
    -- Sender
    sender_id UUID NOT NULL REFERENCES profiles(id),
    sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('requester', 'support', 'admin')),
    
    -- Message
    message TEXT NOT NULL,
    
    -- Attachments
    attachments JSONB, -- Array of {file_name, file_url}
    
    -- Internal Note
    is_internal BOOLEAN DEFAULT FALSE, -- Not visible to requester
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_ticket_messages_ticket_id ON ticket_messages(ticket_id);
CREATE INDEX idx_ticket_messages_sender_id ON ticket_messages(sender_id);
CREATE INDEX idx_ticket_messages_created_at ON ticket_messages(created_at);
```

### 11.3 `activity_logs` - User Activity Audit

```sql
CREATE TABLE activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Actor
    profile_id UUID REFERENCES profiles(id),
    
    -- Action
    action VARCHAR(100) NOT NULL,
    action_category VARCHAR(50), -- 'auth', 'project', 'payment', 'profile', 'admin'
    
    -- Target
    target_type VARCHAR(50),
    target_id UUID,
    
    -- Details
    description TEXT,
    metadata JSONB,
    
    -- Request Info
    ip_address INET,
    user_agent TEXT,
    device_type VARCHAR(20),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_activity_logs_profile_id ON activity_logs(profile_id);
CREATE INDEX idx_activity_logs_action ON activity_logs(action);
CREATE INDEX idx_activity_logs_action_category ON activity_logs(action_category);
CREATE INDEX idx_activity_logs_target ON activity_logs(target_type, target_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at DESC);

-- Partition by month for performance (optional)
-- CREATE TABLE activity_logs_y2025m01 PARTITION OF activity_logs
--     FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

### 11.4 `error_logs` - Application Errors (Sentry Supplement)

```sql
CREATE TABLE error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Error Info
    error_type VARCHAR(100) NOT NULL,
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    
    -- Context
    profile_id UUID REFERENCES profiles(id),
    request_url TEXT,
    request_method VARCHAR(10),
    request_body JSONB,
    
    -- Environment
    app_version VARCHAR(20),
    platform VARCHAR(20), -- 'ios', 'android', 'web'
    device_info JSONB,
    
    -- Sentry Reference
    sentry_event_id VARCHAR(100),
    
    -- Resolution
    is_resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMPTZ,
    resolution_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_error_logs_error_type ON error_logs(error_type);
CREATE INDEX idx_error_logs_profile_id ON error_logs(profile_id);
CREATE INDEX idx_error_logs_is_resolved ON error_logs(is_resolved) WHERE is_resolved = FALSE;
CREATE INDEX idx_error_logs_created_at ON error_logs(created_at DESC);
CREATE INDEX idx_error_logs_sentry_id ON error_logs(sentry_event_id);
```

---

## 12. Indexes Summary

### Performance-Critical Indexes

| Table | Index | Purpose |
|-------|-------|---------|
| `projects` | `idx_projects_status_supervisor` | Supervisor dashboard queries |
| `projects` | `idx_projects_pending_payment` | Payment reminder triggers |
| `projects` | `idx_projects_auto_approve` | Auto-approval scheduler |
| `doers` | `idx_doers_is_available` | Task assignment queries |
| `chat_messages` | `idx_chat_messages_room_created` | Chat history loading |
| `notifications` | `idx_notifications_is_read` | Unread count queries |
| `marketplace_listings` | `idx_marketplace_listings_active` | Feed queries |

### Composite Indexes for Common Queries

```sql
-- User's projects with status
CREATE INDEX idx_projects_user_status ON projects(user_id, status);

-- Doer's active assignments
CREATE INDEX idx_projects_doer_active ON projects(doer_id, status) 
WHERE status IN ('assigned', 'in_progress', 'submitted_for_qc');

-- Supervisor's workload
CREATE INDEX idx_projects_supervisor_active ON projects(supervisor_id, status)
WHERE status IN ('analyzing', 'quoted', 'assigned', 'in_progress', 'qc_in_progress');

-- Recent transactions for wallet
CREATE INDEX idx_wallet_transactions_recent ON wallet_transactions(wallet_id, created_at DESC);

-- User's unread notifications
CREATE INDEX idx_notifications_user_unread ON notifications(profile_id, created_at DESC)
WHERE is_read = FALSE;
```

---

## 13. Row Level Security (RLS) Policies

> ⚠️ **RLS NOT IMPLEMENTED FOR NOW**
> 
> Row Level Security policies are **not included in the initial release**. All data access control will be handled at the application/API layer for now.
> 
> RLS policies will be implemented in a future phase for enhanced security directly at the database level.

---

## 14. Database Functions & Triggers

### Auto-Update Timestamps

```sql
-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ... apply to all tables with updated_at column
```

### Generate Project Number

```sql
CREATE OR REPLACE FUNCTION generate_project_number()
RETURNS TRIGGER AS $$
DECLARE
    next_num INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(project_number FROM 4) AS INTEGER)), 0) + 1
    INTO next_num
    FROM projects;
    
    NEW.project_number := 'AX-' || LPAD(next_num::TEXT, 5, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_project_number
    BEFORE INSERT ON projects
    FOR EACH ROW
    WHEN (NEW.project_number IS NULL)
    EXECUTE FUNCTION generate_project_number();
```

### Generate Ticket Number

```sql
CREATE OR REPLACE FUNCTION generate_ticket_number()
RETURNS TRIGGER AS $$
DECLARE
    year_str TEXT;
    next_num INTEGER;
BEGIN
    year_str := EXTRACT(YEAR FROM NOW())::TEXT;
    
    SELECT COALESCE(MAX(CAST(SUBSTRING(ticket_number FROM 10) AS INTEGER)), 0) + 1
    INTO next_num
    FROM support_tickets
    WHERE ticket_number LIKE 'TKT-' || year_str || '-%';
    
    NEW.ticket_number := 'TKT-' || year_str || '-' || LPAD(next_num::TEXT, 5, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_ticket_number
    BEFORE INSERT ON support_tickets
    FOR EACH ROW
    WHEN (NEW.ticket_number IS NULL)
    EXECUTE FUNCTION generate_ticket_number();
```

### Project Status Change Logger

```sql
CREATE OR REPLACE FUNCTION log_project_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO project_status_history (
            project_id,
            from_status,
            to_status,
            changed_by_type,
            created_at
        ) VALUES (
            NEW.id,
            OLD.status,
            NEW.status,
            'system',
            NOW()
        );
        
        NEW.status_updated_at := NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER project_status_change_trigger
    BEFORE UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION log_project_status_change();
```

### Wallet Balance Update

```sql
CREATE OR REPLACE FUNCTION update_wallet_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.transaction_type IN ('credit', 'refund', 'top_up', 'project_earning', 'commission', 'bonus') THEN
        UPDATE wallets
        SET balance = balance + NEW.amount,
            total_credited = total_credited + NEW.amount,
            updated_at = NOW()
        WHERE id = NEW.wallet_id;
    ELSIF NEW.transaction_type IN ('debit', 'withdrawal', 'project_payment', 'penalty') THEN
        UPDATE wallets
        SET balance = balance - NEW.amount,
            total_debited = total_debited + NEW.amount,
            updated_at = NOW()
        WHERE id = NEW.wallet_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER wallet_balance_trigger
    AFTER INSERT ON wallet_transactions
    FOR EACH ROW
    WHEN (NEW.status = 'completed')
    EXECUTE FUNCTION update_wallet_balance();
```

### Update Doer Statistics

```sql
CREATE OR REPLACE FUNCTION update_doer_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        UPDATE doers
        SET 
            total_projects_completed = total_projects_completed + 1,
            total_earnings = total_earnings + COALESCE(NEW.doer_payout, 0),
            updated_at = NOW()
        WHERE id = NEW.doer_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER doer_stats_trigger
    AFTER UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION update_doer_stats();
```

### Auto-Create Wallet on Profile Creation

```sql
CREATE OR REPLACE FUNCTION create_wallet_for_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO wallets (profile_id, balance, currency)
    VALUES (NEW.id, 0, 'INR');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_wallet_trigger
    AFTER INSERT ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION create_wallet_for_profile();
```

### Contact Info Detection in Chat

```sql
CREATE OR REPLACE FUNCTION detect_contact_info()
RETURNS TRIGGER AS $$
BEGIN
    -- Check for phone numbers, emails, social media handles
    IF NEW.content ~* '(\+91|91)?[6-9][0-9]{9}' OR  -- Indian mobile
       NEW.content ~* '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' OR  -- Email
       NEW.content ~* '@[a-zA-Z0-9_]{3,}' OR  -- Social handles
       NEW.content ~* 'whatsapp|telegram|instagram|facebook' THEN
        NEW.contains_contact_info := TRUE;
        NEW.is_flagged := TRUE;
        NEW.flagged_reason := 'Potential contact information detected';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER detect_contact_trigger
    BEFORE INSERT ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION detect_contact_info();
```

---

## 15. SQL Migration Scripts

### Initial Setup Script

```sql
-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "cube";
CREATE EXTENSION IF NOT EXISTS "earthdistance";

-- Create custom types
CREATE TYPE project_status AS ENUM (...);
CREATE TYPE service_type AS ENUM (...);
CREATE TYPE payment_status AS ENUM (...);
-- ... all other enums

-- Create tables in order (respecting foreign keys)
-- 1. Configuration tables (no dependencies)
-- 2. Core tables (profiles, then role extensions)
-- 3. Project tables
-- 4. Financial tables
-- 5. Chat tables
-- 6. Marketplace tables
-- 7. Training tables
-- 8. Review tables
-- 9. Support tables

-- Create indexes
-- Create functions and triggers
-- NOTE: RLS not implemented for now - access control handled at API layer
-- Insert seed data (universities, courses, subjects, skills, etc.)
```

### Seed Data Examples

```sql
-- Insert reference styles
INSERT INTO reference_styles (name, version) VALUES
('APA', '7th Edition'),
('Harvard', 'Standard'),
('MLA', '9th Edition'),
('Chicago', '17th Edition'),
('IEEE', 'Standard'),
('Vancouver', 'Standard');

-- Insert subjects
INSERT INTO subjects (name, slug, category) VALUES
('Computer Science', 'computer-science', 'academic'),
('Business & Management', 'business-management', 'academic'),
('Engineering', 'engineering', 'academic'),
('Mathematics', 'mathematics', 'academic'),
('Physics', 'physics', 'academic'),
('Marketing', 'marketing', 'academic'),
('Finance', 'finance', 'academic'),
('Law', 'law', 'academic'),
('Medicine', 'medicine', 'academic'),
('Psychology', 'psychology', 'academic');

-- Insert skills
INSERT INTO skills (name, slug, category) VALUES
('Python', 'python', 'programming'),
('JavaScript', 'javascript', 'programming'),
('Java', 'java', 'programming'),
('SQL', 'sql', 'programming'),
('Excel', 'excel', 'data'),
('Data Analysis', 'data-analysis', 'data'),
('Content Writing', 'content-writing', 'writing'),
('Academic Writing', 'academic-writing', 'writing'),
('Research', 'research', 'academic'),
('Proofreading', 'proofreading', 'writing');

-- Insert marketplace categories
INSERT INTO marketplace_categories (name, slug) VALUES
('Books & Study Material', 'books'),
('Electronics', 'electronics'),
('Hostel Essentials', 'hostel'),
('Housing', 'housing'),
('Jobs & Internships', 'opportunities'),
('Events', 'events'),
('Community', 'community');
```

---

## 📊 Table Count Summary

| Category | Count |
|----------|-------|
| Core/Auth | 9 |
| Projects & Workflow | 9 |
| Financial | 7 |
| Chat & Communication | 4 |
| Marketplace | 4 |
| Training & Activation | 6 |
| Reviews & Ratings | 3 |
| Configuration | 12 |
| Support & Audit | 4 |
| **Total Tables** | **58** |

---

*Schema Generated: December 2025*  
*Project: AssignX v1.0*  
*Database: Supabase (PostgreSQL 15+)*
