import { getUserById } from "@/lib/admin/actions/users";
import { UserDetailPanel } from "@/components/admin/users/user-detail-panel";
import { notFound } from "next/navigation";

export const metadata = { title: "User Details - AssignX Admin" };

export default async function UserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  try {
    const userData = await getUserById(id);
    return (
      <div className="flex flex-col gap-4 py-4">
        <UserDetailPanel
          profile={userData.profile}
          wallet={userData.wallet}
          projects={userData.projects}
          activity={userData.activity}
        />
      </div>
    );
  } catch {
    notFound();
  }
}
