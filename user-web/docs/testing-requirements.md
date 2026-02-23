# Testing Requirements Analysis - User Web

## Executive Summary

This document provides a comprehensive analysis of the testing state and requirements for the AssignX User Web application.

---

## 1. Current Testing State

### 1.1 Testing Infrastructure Status

| Component | Status | Notes |
|-----------|--------|-------|
| Jest | **NOT CONFIGURED** | No jest.config.js found |
| Vitest | **NOT CONFIGURED** | No vitest.config.ts found |
| Playwright | **INSTALLED** | @playwright/test v1.57.0 in devDependencies, but no config |
| Cypress | **NOT CONFIGURED** | Not installed |
| Test Scripts | **MISSING** | No test script in package.json |
| Test Coverage | **NONE** | No coverage configuration |

### 1.2 Existing Tests

**FINDING: NO APPLICATION TESTS EXIST**

- No `*.test.ts` or `*.test.tsx` files in `app/`, `components/`, or `lib/`
- No `__tests__/` directories in source folders
- No test setup files (setupTests.ts)
- Playwright is installed but no configuration or test files found

### 1.3 Project Statistics

| Category | Count |
|----------|-------|
| Total Components | 184 |
| API Routes | 9 |
| Server Actions | 6 files |
| Validation Schemas | 5 files |
| Pages | 20+ |

---

## 2. Critical Testing Requirements

### 2.1 Priority 1: Authentication Flow (CRITICAL)

**Files to test:**
- `D:/assign-x/user-web/lib/actions/auth.ts`
- `D:/assign-x/user-web/app/auth/callback/route.ts`
- `D:/assign-x/user-web/middleware.ts`

**Test Cases Required:**

```typescript
// Unit Tests
describe('Auth Actions', () => {
  describe('signInWithGoogle', () => {
    it('should initiate OAuth flow with correct parameters')
    it('should redirect to Google OAuth URL')
    it('should handle OAuth initialization errors')
  })

  describe('signOut', () => {
    it('should clear user session')
    it('should redirect to login page')
    it('should revalidate layout path')
  })

  describe('getUser', () => {
    it('should return user when authenticated')
    it('should return null when not authenticated')
  })

  describe('getAuthUserData', () => {
    it('should return OAuth metadata')
    it('should merge profile data with OAuth data')
    it('should return null for unauthenticated users')
  })
})
```

### 2.2 Priority 1: Payment Processing (CRITICAL)

**Files to test:**
- `D:/assign-x/user-web/app/api/payments/create-order/route.ts`
- `D:/assign-x/user-web/app/api/payments/verify/route.ts`
- `D:/assign-x/user-web/lib/actions/payment-methods.ts`
- `D:/assign-x/user-web/components/payments/razorpay-checkout.tsx`

**Test Cases Required:**

```typescript
// API Route Tests
describe('POST /api/payments/create-order', () => {
  it('should reject unauthenticated requests with 401')
  it('should reject requests without CSRF token')
  it('should enforce rate limiting (5 req/min)')
  it('should validate minimum amount (100 paise)')
  it('should create Razorpay order successfully')
  it('should log order creation to activity_logs')
  it('should handle Razorpay API errors gracefully')
})

// Server Actions Tests
describe('Payment Methods Actions', () => {
  describe('getPaymentMethods', () => {
    it('should return empty array for unauthenticated users')
    it('should return payment methods sorted by default first')
    it('should handle database errors gracefully')
  })

  describe('addCardPaymentMethod', () => {
    it('should validate card token format')
    it('should create payment method in database')
    it('should set as default if first payment method')
  })

  describe('deletePaymentMethod', () => {
    it('should validate UUID format')
    it('should prevent deletion of others\' payment methods')
    it('should reassign default if deleting default method')
  })
})
```

### 2.3 Priority 1: Form Validations (CRITICAL)

**Files to test:**
- `D:/assign-x/user-web/lib/validations/project.ts`
- `D:/assign-x/user-web/lib/validations/student.ts`
- `D:/assign-x/user-web/lib/validations/professional.ts`
- `D:/assign-x/user-web/lib/validations/file-upload.ts`

**Test Cases Required:**

```typescript
// Validation Schema Tests
describe('Project Validation Schemas', () => {
  describe('projectStep1Schema', () => {
    it('should require subject selection')
    it('should require topic minimum 5 characters')
    it('should reject empty topic')
  })

  describe('projectStep2Schema', () => {
    it('should validate word count between 250-50000')
    it('should validate reference style enum values')
    it('should make referenceCount optional')
  })

  describe('projectStep3Schema', () => {
    it('should require deadline date')
    it('should validate urgency enum values')
    it('should reject past dates')
  })
})

describe('Student Validation Schemas', () => {
  describe('studentStep1Schema', () => {
    it('should require minimum 2 character name')
    it('should require user be at least 16 years old')
    it('should reject invalid date formats')
  })

  describe('studentStep3Schema', () => {
    it('should validate phone number format')
    it('should require terms acceptance')
    it('should allow optional college email')
  })
})
```

### 2.4 Priority 2: Data Actions (HIGH)

**Files to test:**
- `D:/assign-x/user-web/lib/actions/data.ts`
- `D:/assign-x/user-web/lib/actions/marketplace.ts`

**Test Cases Required:**

```typescript
describe('Data Actions', () => {
  describe('getProfile', () => {
    it('should return null for unauthenticated users')
    it('should return profile with student relations')
    it('should return profile with professional relations')
    it('should include wallet data')
  })

  describe('getProjects', () => {
    it('should return empty array for unauthenticated users')
    it('should filter by status when provided')
    it('should order by created_at descending')
    it('should include subject and reference_style relations')
  })

  describe('getProjectById', () => {
    it('should return null for non-existent project')
    it('should not return other users\' projects')
    it('should include all project relations')
  })

  describe('Notifications', () => {
    it('should limit results to specified count')
    it('should mark notification as read')
    it('should only mark own notifications')
  })
})
```

### 2.5 Priority 2: Rate Limiting (HIGH)

**File to test:**
- `D:/assign-x/user-web/lib/rate-limit.ts`

**Test Cases Required:**

```typescript
describe('Rate Limiter', () => {
  describe('rateLimit', () => {
    it('should allow requests under limit')
    it('should block requests over limit')
    it('should reset after interval')
    it('should track unique tokens separately')
    it('should cleanup old entries')
    it('should limit total tracked entries')
  })

  describe('paymentRateLimiter', () => {
    it('should use 1 minute interval')
    it('should track up to 1000 unique tokens')
  })
})
```

### 2.6 Priority 2: CSRF Protection (HIGH)

**File to test:**
- `D:/assign-x/user-web/lib/csrf.ts`

**Test Cases Required:**

```typescript
describe('CSRF Protection', () => {
  describe('validateOriginOnly', () => {
    it('should accept requests from allowed origins')
    it('should reject requests from unknown origins')
    it('should handle missing origin header')
  })

  describe('csrfError', () => {
    it('should return 403 status')
    it('should include error message')
  })
})
```

---

## 3. Component Testing Requirements

### 3.1 Form Components (Priority 1)

| Component | Path | Test Priority |
|-----------|------|---------------|
| StudentSignupForm | components/auth/student-signup-form.tsx | HIGH |
| ProfessionalSignupForm | components/auth/professional-signup-form.tsx | HIGH |
| NewProjectForm | components/add-project/new-project-form.tsx | HIGH |
| RazorpayCheckout | components/payments/razorpay-checkout.tsx | CRITICAL |
| WalletTopUpSheet | components/profile/wallet-top-up-sheet.tsx | HIGH |

**Required Test Coverage:**
- Form submission handling
- Validation error display
- Loading states
- Error states
- Success states
- API integration

### 3.2 Interactive Components (Priority 2)

| Component | Path | Test Priority |
|-----------|------|---------------|
| FileUploadZone | components/add-project/file-upload-zone.tsx | HIGH |
| DeadlinePicker | components/add-project/deadline-picker.tsx | MEDIUM |
| SubjectSelector | components/add-project/subject-selector.tsx | MEDIUM |
| UniversitySelector | components/auth/university-selector.tsx | MEDIUM |
| CourseSelector | components/auth/course-selector.tsx | MEDIUM |

### 3.3 Dashboard Components (Priority 3)

| Component | Path | Test Priority |
|-----------|------|---------------|
| RecentProjects | components/dashboard/recent-projects.tsx | MEDIUM |
| CampusPulse | components/dashboard/campus-pulse.tsx | LOW |
| BannerCarousel | components/dashboard/banner-carousel.tsx | LOW |
| DashboardHeader | components/dashboard/dashboard-header.tsx | MEDIUM |

---

## 4. E2E Test Requirements

### 4.1 Critical User Flows

#### Flow 1: User Registration & Onboarding
```
1. Land on home page
2. Click "Get Started"
3. Redirect to Google OAuth
4. Complete OAuth flow
5. Select role (Student/Professional)
6. Complete multi-step signup form
7. Verify profile creation
8. Redirect to dashboard
```

#### Flow 2: Project Submission
```
1. Login as authenticated user
2. Navigate to "Add Project"
3. Select subject
4. Enter project details
5. Upload files
6. Set deadline
7. Review price estimate
8. Submit project
9. Verify project appears in list
```

#### Flow 3: Wallet Top-Up
```
1. Navigate to Wallet
2. Click "Add Money"
3. Enter amount
4. Proceed to Razorpay checkout
5. Complete payment (test mode)
6. Verify wallet balance updated
```

#### Flow 4: Payment Method Management
```
1. Navigate to Payment Methods
2. Add new card via Razorpay
3. Verify card appears in list
4. Set card as default
5. Delete card
6. Add UPI ID
```

### 4.2 Playwright Configuration Required

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## 5. Manual Testing Scenarios

### 5.1 Cross-Browser Testing
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

### 5.2 Responsive Design Testing
- [ ] Mobile (320px - 480px)
- [ ] Tablet (481px - 768px)
- [ ] Laptop (769px - 1024px)
- [ ] Desktop (1025px+)

### 5.3 Accessibility Testing
- [ ] Screen reader compatibility
- [ ] Keyboard navigation
- [ ] Color contrast (WCAG 2.1 AA)
- [ ] Focus indicators
- [ ] ARIA labels on interactive elements

### 5.4 Error Scenarios
- [ ] Network offline behavior
- [ ] API timeout handling
- [ ] Invalid form submissions
- [ ] Session expiration handling
- [ ] Payment failure recovery

---

## 6. Recommended Test Setup

### 6.1 Testing Stack Recommendation

| Tool | Purpose | Reason |
|------|---------|--------|
| Vitest | Unit & Integration | Fast, native TypeScript, compatible with React Testing Library |
| React Testing Library | Component Testing | Encourages accessible, user-centric testing |
| MSW (Mock Service Worker) | API Mocking | Realistic network request mocking |
| Playwright | E2E Testing | Already installed, cross-browser, excellent DX |

### 6.2 Required Package Installation

```bash
npm install -D vitest @vitest/ui @vitest/coverage-v8 \
  @testing-library/react @testing-library/jest-dom @testing-library/user-event \
  msw happy-dom
```

### 6.3 Configuration Files Needed

1. `vitest.config.ts` - Test runner configuration
2. `tests/setup.ts` - Test environment setup
3. `tests/mocks/handlers.ts` - MSW request handlers
4. `tests/mocks/server.ts` - MSW server configuration
5. `playwright.config.ts` - E2E test configuration

### 6.4 Recommended Folder Structure

```
user-web/
  tests/
    unit/
      lib/
        validations/
          project.test.ts
          student.test.ts
        rate-limit.test.ts
        csrf.test.ts
      actions/
        auth.test.ts
        data.test.ts
        payment-methods.test.ts
    integration/
      api/
        payments.test.ts
        notifications.test.ts
    components/
      auth/
        student-signup-form.test.tsx
      payments/
        razorpay-checkout.test.tsx
    e2e/
      auth.spec.ts
      project-submission.spec.ts
      wallet.spec.ts
      payment-methods.spec.ts
    mocks/
      handlers.ts
      server.ts
    fixtures/
      user.ts
      project.ts
    setup.ts
```

---

## 7. Coverage Goals

### 7.1 Initial Targets (Phase 1)

| Category | Target | Focus |
|----------|--------|-------|
| Validation Schemas | 100% | All Zod schemas |
| Rate Limiting | 90% | Core logic |
| CSRF Protection | 90% | Security critical |
| Auth Actions | 80% | Core auth flows |

### 7.2 Medium-Term Targets (Phase 2)

| Category | Target | Focus |
|----------|--------|-------|
| Server Actions | 80% | All data operations |
| API Routes | 85% | Payment endpoints |
| Form Components | 70% | Critical forms |

### 7.3 Long-Term Targets (Phase 3)

| Category | Target | Focus |
|----------|--------|-------|
| All Components | 60% | UI coverage |
| E2E Flows | 100% | Critical paths |
| Overall | 70% | Line coverage |

---

## 8. Action Items

### Immediate (Week 1)
1. [ ] Install testing dependencies (Vitest, RTL, MSW)
2. [ ] Create test configuration files
3. [ ] Set up MSW handlers for Supabase mocking
4. [ ] Write validation schema tests (100% coverage)
5. [ ] Write rate-limit.ts tests

### Short-Term (Week 2-3)
1. [ ] Write auth action tests
2. [ ] Write payment API route tests
3. [ ] Write data action tests
4. [ ] Configure Playwright for E2E
5. [ ] Write first E2E test (auth flow)

### Medium-Term (Week 4-6)
1. [ ] Write component tests for forms
2. [ ] Write remaining E2E tests
3. [ ] Set up CI/CD test pipeline
4. [ ] Configure coverage reporting
5. [ ] Add visual regression testing

---

## Appendix A: File Inventory

### Server Actions (6 files)
- `lib/actions/auth.ts` - Authentication operations
- `lib/actions/data.ts` - Data fetching operations
- `lib/actions/invoice.ts` - Invoice generation
- `lib/actions/marketplace.ts` - Marketplace operations
- `lib/actions/payment-methods.ts` - Payment method CRUD
- `lib/actions/index.ts` - Exports

### API Routes (9 endpoints)
- `api/payments/create-order` - Create Razorpay order
- `api/payments/verify` - Verify payment
- `api/payments/customers` - Customer management
- `api/payments/methods` - Payment methods
- `api/payments/wallet-pay` - Wallet payments
- `api/notifications/push` - Push notifications
- `api/notifications/subscribe` - Notification subscription
- `api/notifications/whatsapp` - WhatsApp notifications
- `auth/callback` - OAuth callback

### Validation Schemas (5 files)
- `lib/validations/project.ts` - Project form schemas
- `lib/validations/student.ts` - Student signup schemas
- `lib/validations/professional.ts` - Professional signup schemas
- `lib/validations/file-upload.ts` - File validation schemas
- `lib/validations/server.ts` - Server-side schemas

---

*Report generated by TESTER agent - Hive Mind Collective*
*Date: 2026-01-03*
