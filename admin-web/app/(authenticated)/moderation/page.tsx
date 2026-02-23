import { getFlaggedContent } from "@/lib/admin/actions/moderation";
import { ModerationQueue } from "@/components/admin/moderation/moderation-queue";

export const metadata = { title: "Moderation - AssignX Admin" };

export default async function ModerationPage({
  searchParams,
}: {
  searchParams: Promise<{
    type?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const flaggedContent = await getFlaggedContent({
    contentType: params.type || undefined,
    page: parseInt(params.page || "1"),
    perPage: 20,
  });

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Moderation</h1>
        <p className="text-muted-foreground">
          Review and moderate flagged content
        </p>
      </div>
      <ModerationQueue
        data={flaggedContent.data}
        total={flaggedContent.total}
        page={flaggedContent.page}
        totalPages={flaggedContent.total_pages}
      />
    </div>
  );
}
