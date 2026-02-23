"use client";

import * as React from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { assignTicket } from "@/lib/admin/actions/support";
import { toast } from "sonner";

interface AdminProfile {
  full_name: string | null;
  email: string | null;
  avatar_url?: string | null;
}

interface AssignDialogAdmin {
  id: string;
  role: string | null;
  profiles: AdminProfile | AdminProfile[] | null;
}

export function TicketAssignDialog({
  ticketId,
  admins,
  currentAssignee,
  children,
}: {
  ticketId: string;
  admins: AssignDialogAdmin[];
  currentAssignee?: string;
  children: React.ReactNode;
}) {
  const router = useRouter();
  const [open, setOpen] = React.useState(false);
  const [selectedAdmin, setSelectedAdmin] = React.useState(
    currentAssignee || ""
  );
  const [assigning, setAssigning] = React.useState(false);

  async function handleAssign() {
    if (!selectedAdmin) {
      toast.error("Please select an admin");
      return;
    }

    setAssigning(true);
    try {
      await assignTicket(ticketId, selectedAdmin);
      toast.success("Ticket assigned successfully");
      setOpen(false);
      router.refresh();
    } catch (err) {
      toast.error(
        err instanceof Error ? err.message : "Failed to assign ticket"
      );
    } finally {
      setAssigning(false);
    }
  }

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>{children}</SheetTrigger>
      <SheetContent>
        <SheetHeader>
          <SheetTitle>Assign Ticket</SheetTitle>
          <SheetDescription>
            Select an admin to handle this ticket
          </SheetDescription>
        </SheetHeader>
        <div className="flex flex-col gap-4 px-4 pt-4">
          <div className="flex flex-col gap-2">
            <Label>Admin</Label>
            <Select value={selectedAdmin} onValueChange={setSelectedAdmin}>
              <SelectTrigger>
                <SelectValue placeholder="Select an admin" />
              </SelectTrigger>
              <SelectContent>
                {admins.map((admin) => {
                  const profile = Array.isArray(admin.profiles)
                    ? admin.profiles[0]
                    : admin.profiles;
                  return (
                    <SelectItem key={admin.id} value={admin.id}>
                      {profile?.full_name || profile?.email || admin.id}
                      {admin.role && ` (${admin.role})`}
                    </SelectItem>
                  );
                })}
              </SelectContent>
            </Select>
          </div>
          <Button onClick={handleAssign} disabled={assigning || !selectedAdmin}>
            {assigning ? "Assigning..." : "Assign"}
          </Button>
        </div>
      </SheetContent>
    </Sheet>
  );
}
