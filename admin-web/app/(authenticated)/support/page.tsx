import { getTickets, getTicketStats } from "@/lib/admin/actions/support";
import { TicketStatsCards } from "@/components/admin/support/ticket-stats-cards";
import { TicketsDataTable } from "@/components/admin/support/tickets-data-table";

export const metadata = { title: "Support - AssignX Admin" };

export default async function SupportPage({
  searchParams,
}: {
  searchParams: Promise<{
    search?: string;
    status?: string;
    priority?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const [stats, ticketsData] = await Promise.all([
    getTicketStats().catch(() => ({
      open_count: 0,
      in_progress_count: 0,
      avg_resolution_time: 0,
      by_priority: { low: 0, medium: 0, high: 0, urgent: 0 },
    })),
    getTickets({
      search: params.search,
      status: params.status,
      priority: params.priority,
      page: parseInt(params.page || "1"),
      perPage: 20,
    }).catch(() => ({ data: [], total: 0, page: 1, total_pages: 1 })),
  ]);

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Support</h1>
        <p className="text-muted-foreground">
          Manage support tickets and customer inquiries
        </p>
      </div>
      <TicketStatsCards stats={stats} />
      <TicketsDataTable
        data={ticketsData.data || []}
        total={ticketsData.total || 0}
        page={ticketsData.page || 1}
        totalPages={ticketsData.total_pages || 1}
      />
    </div>
  );
}
