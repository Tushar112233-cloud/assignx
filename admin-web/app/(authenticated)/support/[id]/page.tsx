import { notFound } from "next/navigation";
import { getTicketById } from "@/lib/admin/actions/support";
import { getAdmins } from "@/lib/admin/actions/support";
import { TicketDetailView } from "@/components/admin/support/ticket-detail-view";

export const metadata = { title: "Ticket Detail - AssignX Admin" };

export default async function TicketDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  try {
    const [ticketData, admins] = await Promise.all([
      getTicketById(id),
      getAdmins(),
    ]);

    return (
      <div className="flex flex-col gap-4 py-4">
        <TicketDetailView
          ticket={ticketData.ticket}
          messages={ticketData.messages || ticketData.ticket?.messages || []}
          admins={admins}
        />
      </div>
    );
  } catch {
    notFound();
  }
}
