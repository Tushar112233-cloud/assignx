import { notFound } from "next/navigation";
import { getProjectById } from "@/lib/admin/actions/projects";
import { ProjectDetailView } from "@/components/admin/projects/project-detail-view";

export const metadata = { title: "Project Detail - AssignX Admin" };

export default async function ProjectDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  try {
    const data = await getProjectById(id);
    return (
      <div className="flex flex-col gap-4 py-4">
        <ProjectDetailView
          project={data.project}
          statusHistory={data.statusHistory}
          files={data.files}
          payments={data.payments}
        />
      </div>
    );
  } catch {
    notFound();
  }
}
