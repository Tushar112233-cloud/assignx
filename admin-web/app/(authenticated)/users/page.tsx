import { serverFetch } from "@/lib/admin/auth";
import { UsersDataTable } from "@/components/admin/users/users-data-table";

export const metadata = { title: "Users - AssignX Admin" };

export default async function UsersPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    type?: string;
    status?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const query = new URLSearchParams();
  if (params.search) query.set("search", params.search);
  if (params.type) query.set("userType", params.type);
  if (params.status) query.set("status", params.status);
  query.set("page", params.page || "1");
  query.set("perPage", "20");
  query.set("sortBy", "created_at");
  query.set("sortOrder", "desc");

  const result = await serverFetch(`/api/admin/users?${query.toString()}`).catch(() => ({
    users: [],
    total: 0,
    page: 1,
    totalPages: 1,
  }));

  const rawUsers = result?.users || result?.data || [];

  // Normalize camelCase API response to snake_case for component
  const users = rawUsers.map((u: any) => ({
    id: u._id || u.id,
    full_name: u.fullName || u.full_name || null,
    email: u.email || null,
    avatar_url: u.avatarUrl || u.avatar_url || null,
    user_type: u.userType || u.user_type || null,
    is_active: u.isActive ?? u.is_active ?? true,
    project_count: u.projectCount ?? u.project_count ?? 0,
    wallet_balance: u.walletBalance ?? u.wallet_balance ?? 0,
    created_at: u.createdAt || u.created_at || new Date().toISOString(),
  }));

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Users</h1>
        <p className="text-muted-foreground">Manage all platform users</p>
      </div>
      <UsersDataTable
        data={users}
        total={result?.total || users.length}
        page={result?.page || 1}
        totalPages={result?.totalPages || result?.total_pages || 1}
      />
    </div>
  );
}
