import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { format } from "date-fns";

export const metadata = { title: "Messages - AssignX Admin" };

export default async function MessagesPage() {
  const supabase = await createClient();

  const [{ data: rooms, count }, { count: totalMessages }] = await Promise.all([
    supabase
      .from("chat_rooms")
      .select("*, projects!project_id(title)", { count: "exact" })
      .order("last_message_at", { ascending: false, nullsFirst: false })
      .limit(50),
    supabase.from("chat_messages").select("id", { count: "exact", head: true }),
  ]);

  const activeRooms = (rooms || []).filter((r: any) => r.is_active && !r.is_suspended).length;
  const suspendedRooms = (rooms || []).filter((r: any) => r.is_suspended).length;

  return (
    <div className="flex flex-col gap-6 py-4 px-4 lg:px-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Messages</h1>
        <p className="text-muted-foreground">Monitor all platform chat rooms and conversations</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {[
          { label: "Total Chat Rooms", value: count ?? 0 },
          { label: "Active Rooms", value: activeRooms },
          { label: "Suspended Rooms", value: suspendedRooms },
          { label: "Total Messages", value: totalMessages ?? 0 },
        ].map((s) => (
          <Card key={s.label}>
            <CardHeader className="pb-1 pt-4 px-4">
              <CardTitle className="text-xs font-medium text-muted-foreground">{s.label}</CardTitle>
            </CardHeader>
            <CardContent className="px-4 pb-4">
              <span className="text-2xl font-bold tabular-nums">{s.value}</span>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Chat Rooms Table */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">All Chat Rooms</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <div className="overflow-hidden rounded-b-lg">
            <Table>
              <TableHeader className="bg-muted">
                <TableRow>
                  <TableHead>Project</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Messages</TableHead>
                  <TableHead>Last Active</TableHead>
                  <TableHead>Created</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {(rooms || []).length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="h-24 text-center text-muted-foreground">
                      No chat rooms yet.
                    </TableCell>
                  </TableRow>
                ) : (
                  (rooms as any[]).map((room) => (
                    <TableRow key={room.id}>
                      <TableCell className="font-medium max-w-[200px] truncate">
                        {room.projects?.title || room.name || "—"}
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline" className="text-xs capitalize">
                          {room.room_type?.replace(/_/g, " ") || "—"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        {room.is_suspended ? (
                          <Badge variant="outline" className="text-xs text-red-600 border-red-200 bg-red-50">
                            Suspended
                          </Badge>
                        ) : room.is_active ? (
                          <Badge variant="outline" className="text-xs text-green-600 border-green-200 bg-green-50">
                            Active
                          </Badge>
                        ) : (
                          <Badge variant="outline" className="text-xs text-gray-600 border-gray-200 bg-gray-50">
                            Inactive
                          </Badge>
                        )}
                      </TableCell>
                      <TableCell className="text-right tabular-nums">
                        {room.message_count ?? 0}
                      </TableCell>
                      <TableCell className="text-muted-foreground text-sm">
                        {room.last_message_at
                          ? format(new Date(room.last_message_at), "dd MMM yyyy, HH:mm")
                          : "—"}
                      </TableCell>
                      <TableCell className="text-muted-foreground text-sm">
                        {format(new Date(room.created_at), "dd MMM yyyy")}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
