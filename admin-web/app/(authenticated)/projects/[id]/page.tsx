import { notFound } from "next/navigation";
import { getProjectById } from "@/lib/admin/actions/projects";
import { ProjectDetailView } from "@/components/admin/projects/project-detail-view";

export const metadata = { title: "Project Detail - AssignX Admin" };

function mapPerson(data: any) {
  if (!data) return null;
  return {
    full_name: data.full_name || data.fullName || null,
    email: data.email || null,
    avatar_url: data.avatar_url || data.avatarUrl || null,
  };
}

export default async function ProjectDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  try {
    const data = await getProjectById(id);
    const p = data.project;

    const project = {
      id: p._id || p.id,
      title: p.title,
      description: p.description || p.specificInstructions || p.specific_instructions || null,
      status: p.status,
      service_type: p.service_type || p.serviceType || null,
      subject: p.subject || p.subjects?.name || p.subjectId || null,
      price: p.user_quote || p.pricing?.userQuote || null,
      deadline: p.deadline || null,
      created_at: p.created_at || p.createdAt,
      updated_at: p.updated_at || p.updatedAt || null,
      user: mapPerson(p.profiles || p.userId),
      supervisor: mapPerson(p.supervisors || p.supervisorId),
      doer: mapPerson(p.doers || p.doerId),
    };

    const statusHistory = (p.statusHistory || data.statusHistory || []).map((h: any) => ({
      id: h._id || h.id || Math.random().toString(),
      old_status: h.fromStatus || h.old_status || "",
      new_status: h.toStatus || h.new_status || "",
      reason: h.notes || h.reason || "",
      created_at: h.createdAt || h.created_at,
      changed_by_profile: h.changed_by_profile || (h.changedBy ? { full_name: h.changedBy } : null),
    }));

    const files = (p.files || data.files || []).map((f: any) => ({
      id: f._id || f.id || Math.random().toString(),
      file_name: f.fileName || f.file_name || null,
      name: f.name || null,
      file_url: f.fileUrl || f.file_url || null,
      created_at: f.createdAt || f.created_at,
    }));

    return (
      <div className="flex flex-col gap-4 py-4">
        <ProjectDetailView
          project={project}
          statusHistory={statusHistory}
          files={files}
          payments={data.payments ?? []}
        />
      </div>
    );
  } catch {
    notFound();
  }
}
