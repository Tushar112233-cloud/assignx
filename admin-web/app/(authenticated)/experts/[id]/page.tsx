import { getExpertById } from "@/lib/admin/actions/experts";
import { ExpertDetailView } from "@/components/admin/experts/expert-detail-view";
import { notFound } from "next/navigation";

export const metadata = { title: "Expert Details - AssignX Admin" };

export default async function ExpertDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  const expert = await getExpertById(id);
  if (!expert) notFound();

  return (
    <div className="flex flex-col gap-4 py-4">
      <ExpertDetailView expert={expert} />
    </div>
  );
}
