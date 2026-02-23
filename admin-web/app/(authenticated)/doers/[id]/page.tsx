import { getDoerById } from "@/lib/admin/actions/doers";
import { DoerDetailView } from "@/components/admin/doers/doer-detail-view";
import { notFound } from "next/navigation";

export const metadata = { title: "Doer Details - AssignX Admin" };

export default async function DoerDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  try {
    const data = await getDoerById(id);
    return (
      <div className="flex flex-col gap-4 py-4">
        <DoerDetailView
          profile={data.profile}
          tasks={data.tasks}
          metrics={data.metrics}
        />
      </div>
    );
  } catch {
    notFound();
  }
}
