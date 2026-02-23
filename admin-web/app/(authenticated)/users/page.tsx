import { createClient } from "@/lib/supabase/server";
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
  const supabase = await createClient();

  const { data } = await supabase.rpc("admin_get_users", {
    p_search: params.search || null,
    p_user_type: params.type || null,
    p_status: params.status || null,
    p_page: parseInt(params.page || "1"),
    p_per_page: 20,
    p_sort_by: "created_at",
    p_sort_order: "desc",
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Users</h1>
        <p className="text-muted-foreground">Manage all platform users</p>
      </div>
      <UsersDataTable
        data={data?.data || []}
        total={data?.total || 0}
        page={data?.page || 1}
        totalPages={data?.total_pages || 1}
      />
    </div>
  );
}
