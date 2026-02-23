import { DashboardClient } from './dashboard-client'

/**
 * Dashboard page
 * Authentication and routing protection is handled by middleware.
 * Data fetching is done client-side via useAuth() and Supabase queries.
 */
export default function DashboardPage() {
  return <DashboardClient />
}
