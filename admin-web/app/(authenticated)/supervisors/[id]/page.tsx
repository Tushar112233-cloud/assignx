import { getSupervisorById } from "@/lib/admin/actions/supervisors";
import { SupervisorDetailView } from "@/components/admin/supervisors/supervisor-detail-view";
import { notFound } from "next/navigation";

export const metadata = { title: "Supervisor Details - AssignX Admin" };

export default async function SupervisorDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  try {
    const data = await getSupervisorById(id);
    return (
      <div className="flex flex-col gap-4 py-4">
        <SupervisorDetailView
          profile={data.profile}
          projects={data.projects}
          metrics={data.metrics}
        />
      </div>
    );
  } catch {
    notFound();
  }
}
