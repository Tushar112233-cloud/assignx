import { getCollegeDetail } from "@/lib/admin/actions/colleges";
import { CollegeDetailView } from "@/components/admin/colleges/college-detail-view";

export const metadata = { title: "College Detail - AssignX Admin" };

export default async function CollegeDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const collegeName = decodeURIComponent(id);
  const detail = await getCollegeDetail(collegeName);

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">
          {detail.collegeName}
        </h1>
        <p className="text-muted-foreground">
          {detail.totalUsers} user{detail.totalUsers !== 1 ? "s" : ""} enrolled
        </p>
      </div>
      <CollegeDetailView detail={detail} />
    </div>
  );
}
