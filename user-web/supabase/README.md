# Supabase Migrations

This folder contains database migrations for the AssignX platform.

## Applying Migrations

### Option 1: Supabase Dashboard (Recommended for Production)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the contents of each migration file
4. Execute the SQL

### Option 2: Supabase CLI

```bash
# Install Supabase CLI if not installed
npm install -g supabase

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Push migrations
supabase db push
```

## Migration Files

### 20241231_atomic_wallet_transactions.sql

**Purpose:** Implements atomic (all-or-nothing) wallet transactions to prevent race conditions and data inconsistencies.

**Functions Created:**
- `process_wallet_topup` - Atomically processes wallet top-ups via Razorpay
- `process_razorpay_project_payment` - Atomically processes project payments via Razorpay
- `process_wallet_project_payment` - Atomically processes project payments using wallet balance

**Security Features:**
- Uses `FOR UPDATE` row locking to prevent concurrent modifications
- All operations within a single transaction
- Automatic rollback on any failure
- SECURITY DEFINER for controlled access

**Usage in API:**
```typescript
// Wallet top-up
await supabase.rpc("process_wallet_topup", {
  p_profile_id: profileId,
  p_amount: amount,
  p_razorpay_order_id: orderId,
  p_razorpay_payment_id: paymentId,
})

// Wallet payment for project
await supabase.rpc("process_wallet_project_payment", {
  p_profile_id: profileId,
  p_project_id: projectId,
  p_amount: amount,
})
```

## Important Notes

1. **Run migrations in order** - Files are prefixed with dates for ordering
2. **Test in development first** - Always test migrations in a dev environment
3. **Backup before production** - Create a database backup before applying to production
