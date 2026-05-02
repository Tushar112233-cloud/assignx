"use client";

import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { useCallback, useRef, useState } from "react";
import {
  useReactTable,
  getCoreRowModel,
  flexRender,
  type ColumnDef,
} from "@tanstack/react-table";
import Link from "next/link";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import {
  IconDotsVertical,
  IconEye,
  IconCheck,
  IconX,
  IconStar,
  IconStarOff,
} from "@tabler/icons-react";
import { verifyExpert, rejectExpert, featureExpert, createExpert } from "@/lib/admin/actions/experts";
import { ExpertVerificationDialog } from "./expert-verification-dialog";
import { toast } from "sonner";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import { IconPlus } from "@tabler/icons-react";

type Expert = {
  id: string;
  full_name: string;
  email: string;
  avatar_url: string | null;
  is_active: boolean;
  category: string | null;
  hourly_rate: number | null;
  verification_status: string;
  is_featured: boolean;
  bio: string | null;
  qualifications: Record<string, unknown> | null;
  created_at: string;
};

const statusColors: Record<string, string> = {
  verified: "text-green-600 border-green-200 bg-green-50 dark:bg-green-900/20",
  pending: "text-yellow-600 border-yellow-200 bg-yellow-50 dark:bg-yellow-900/20",
  rejected: "text-red-600 border-red-200 bg-red-50 dark:bg-red-900/20",
};

function getInitials(name: string | null): string {
  if (!name) return "?";
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

function formatCurrency(amount: number | null): string {
  if (amount == null) return "\u20B90";
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    minimumFractionDigits: 0,
  }).format(amount);
}

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

export function ExpertsDataTable({
  data,
  total,
  page,
  totalPages,
}: {
  data: Expert[];
  total: number;
  page: number;
  totalPages: number;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const [searchValue, setSearchValue] = useState(searchParams.get("search") || "");
  const [verifyDialog, setVerifyDialog] = useState<{
    open: boolean;
    expertId: string;
    action: "verify" | "reject";
  }>({ open: false, expertId: "", action: "verify" });

  const [addDialog, setAddDialog] = useState(false);
  const [addForm, setAddForm] = useState({
    email: "", full_name: "", headline: "", designation: "",
    organization: "", category: "academic", hourly_rate: "500", bio: "", whatsapp_number: "",
    avatar_url: "",
    uploading_avatar: false,
    availability_slots: [] as Array<{day: string; startTime: string; endTime: string}>,
  });
  const [addLoading, setAddLoading] = useState(false);
  const avatarInputRef = useRef<HTMLInputElement>(null);

  const handleAvatarUpload = useCallback(async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (file.size > 2 * 1024 * 1024) {
      toast.error("File too large. Max 2MB.");
      return;
    }

    setAddForm((f) => ({ ...f, uploading_avatar: true }));
    try {
      const formData = new FormData();
      formData.append("file", file);

      const token = document.cookie.split("admin-token=")[1]?.split(";")[0] || "";
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"}/api/upload`,
        {
          method: "POST",
          body: formData,
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (!res.ok) throw new Error("Upload failed");

      const data = await res.json();
      const url = data.url || data.secure_url || data.fileUrl || "";
      setAddForm((f) => ({ ...f, avatar_url: url, uploading_avatar: false }));
      toast.success("Photo uploaded");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Upload failed");
      setAddForm((f) => ({ ...f, uploading_avatar: false }));
    }
    // Reset input so the same file can be re-selected
    if (avatarInputRef.current) avatarInputRef.current.value = "";
  }, []);

  const updateParams = useCallback(
    (key: string, value: string | null) => {
      const params = new URLSearchParams(searchParams.toString());
      if (value && value !== "all") {
        params.set(key, value);
      } else {
        params.delete(key);
      }
      if (key !== "page") params.delete("page");
      router.push(`${pathname}?${params.toString()}`);
    },
    [router, pathname, searchParams]
  );

  const handleSearch = useCallback(() => {
    updateParams("search", searchValue || null);
  }, [updateParams, searchValue]);

  const handleFeatureToggle = useCallback(
    async (expertId: string, featured: boolean) => {
      try {
        await featureExpert(expertId, !featured);
        toast.success(featured ? "Expert unfeatured" : "Expert featured");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Action failed");
      }
    },
    [router]
  );

  const handleVerification = useCallback(
    async (action: "verify" | "reject", reason?: string) => {
      try {
        if (action === "verify") {
          await verifyExpert(verifyDialog.expertId);
          toast.success("Expert verified successfully");
        } else {
          await rejectExpert(verifyDialog.expertId, reason || "");
          toast.success("Expert rejected");
        }
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Action failed");
      }
    },
    [router, verifyDialog.expertId]
  );

  const columns: ColumnDef<Expert>[] = [
    {
      accessorKey: "full_name",
      header: "Expert",
      cell: ({ row }) => {
        const expert = row.original;
        return (
          <div className="flex items-center gap-3">
            <Avatar size="default">
              {expert.avatar_url && (
                <AvatarImage src={expert.avatar_url} alt={expert.full_name} />
              )}
              <AvatarFallback>{getInitials(expert.full_name)}</AvatarFallback>
            </Avatar>
            <div className="flex flex-col">
              <span className="font-medium">{expert.full_name}</span>
              <span className="text-xs text-muted-foreground">{expert.email}</span>
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "category",
      header: "Category",
      cell: ({ getValue }) => (
        <span className="capitalize">{(getValue() as string) || "-"}</span>
      ),
    },
    {
      accessorKey: "hourly_rate",
      header: "Rate/hr",
      cell: ({ getValue }) => formatCurrency(getValue() as number | null),
    },
    {
      accessorKey: "verification_status",
      header: "Verification",
      cell: ({ getValue }) => {
        const status = (getValue() as string) || "pending";
        return (
          <Badge variant="outline" className={statusColors[status] || ""}>
            {status}
          </Badge>
        );
      },
    },
    {
      accessorKey: "is_featured",
      header: "Featured",
      cell: ({ row }) => {
        const expert = row.original;
        return (
          <Button
            variant="ghost"
            size="icon"
            className="size-8"
            onClick={() => handleFeatureToggle(expert.id, expert.is_featured)}
          >
            {expert.is_featured ? (
              <IconStar className="size-4 fill-yellow-400 text-yellow-400" />
            ) : (
              <IconStarOff className="size-4 text-muted-foreground" />
            )}
          </Button>
        );
      },
    },
    {
      accessorKey: "created_at",
      header: "Joined",
      cell: ({ getValue }) => formatDate(getValue() as string),
    },
    {
      id: "actions",
      header: "",
      cell: ({ row }) => {
        const expert = row.original;
        return (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="size-8">
                <IconDotsVertical className="size-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem asChild>
                <Link href={`/experts/${expert.id}`}>
                  <IconEye className="size-4" />
                  View Details
                </Link>
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              {expert.verification_status !== "verified" && (
                <DropdownMenuItem
                  onClick={() =>
                    setVerifyDialog({
                      open: true,
                      expertId: expert.id,
                      action: "verify",
                    })
                  }
                >
                  <IconCheck className="size-4" />
                  Verify Expert
                </DropdownMenuItem>
              )}
              {expert.verification_status !== "rejected" && (
                <DropdownMenuItem
                  variant="destructive"
                  onClick={() =>
                    setVerifyDialog({
                      open: true,
                      expertId: expert.id,
                      action: "reject",
                    })
                  }
                >
                  <IconX className="size-4" />
                  Reject Expert
                </DropdownMenuItem>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        );
      },
    },
  ];

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <div className="flex flex-col gap-4 px-4 lg:px-6">
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex items-center gap-2">
          <Input
            placeholder="Search experts..."
            value={searchValue}
            onChange={(e) => setSearchValue(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleSearch()}
            className="w-64"
          />
          <Button variant="outline" size="sm" onClick={handleSearch}>
            Search
          </Button>
        </div>
        <Select
          value={searchParams.get("status") || "all"}
          onValueChange={(v) => updateParams("status", v)}
        >
          <SelectTrigger className="w-40">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Status</SelectItem>
            <SelectItem value="verified">Verified</SelectItem>
            <SelectItem value="pending">Pending</SelectItem>
            <SelectItem value="rejected">Rejected</SelectItem>
          </SelectContent>
        </Select>
        <span className="ml-auto text-sm text-muted-foreground">
          {total} expert{total !== 1 ? "s" : ""} total
        </span>
        <Button size="sm" onClick={() => setAddDialog(true)}>
          <IconPlus className="size-4 mr-1" />
          Add Expert
        </Button>
      </div>

      <div className="rounded-md border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <TableHead key={header.id}>
                    {header.isPlaceholder
                      ? null
                      : flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length ? (
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={columns.length} className="h-24 text-center">
                  No experts found.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          Page {page} of {totalPages}
        </p>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            disabled={page <= 1}
            onClick={() => updateParams("page", String(page - 1))}
          >
            Previous
          </Button>
          <Button
            variant="outline"
            size="sm"
            disabled={page >= totalPages}
            onClick={() => updateParams("page", String(page + 1))}
          >
            Next
          </Button>
        </div>
      </div>

      <ExpertVerificationDialog
        open={verifyDialog.open}
        onOpenChange={(open) => setVerifyDialog({ ...verifyDialog, open })}
        action={verifyDialog.action}
        onConfirm={handleVerification}
      />

      <Dialog open={addDialog} onOpenChange={setAddDialog}>
        <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Add New Expert</DialogTitle>
          </DialogHeader>
          <div className="grid gap-3 py-2">
            {/* Profile Picture Upload */}
            <div className="flex items-center gap-4">
              <Avatar className="h-16 w-16">
                {addForm.avatar_url ? (
                  <AvatarImage src={addForm.avatar_url} />
                ) : null}
                <AvatarFallback className="text-lg">{getInitials(addForm.full_name)}</AvatarFallback>
              </Avatar>
              <div>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  disabled={addForm.uploading_avatar}
                  onClick={() => avatarInputRef.current?.click()}
                >
                  {addForm.uploading_avatar ? "Uploading..." : "Upload Photo"}
                </Button>
                <input ref={avatarInputRef} type="file" accept="image/*" className="hidden" onChange={handleAvatarUpload} />
                <p className="text-xs text-muted-foreground mt-1">JPG, PNG. Max 2MB.</p>
              </div>
            </div>

            {[
              { label: "Email *", key: "email", type: "email", placeholder: "expert@example.com" },
              { label: "Full Name *", key: "full_name", type: "text", placeholder: "Dr. Priya Sharma" },
              { label: "Headline *", key: "headline", type: "text", placeholder: "Senior AI Researcher at IIT Delhi" },
              { label: "Designation *", key: "designation", type: "text", placeholder: "Professor / Consultant" },
              { label: "Organization", key: "organization", type: "text", placeholder: "IIT Delhi (optional)" },
              { label: "Hourly Rate (₹) *", key: "hourly_rate", type: "number", placeholder: "500" },
              { label: "WhatsApp Number", key: "whatsapp_number", type: "text", placeholder: "+91 9876543210 (optional)" },
            ].map(({ label, key, type, placeholder }) => (
              <div key={key} className="grid gap-1">
                <Label className="text-xs font-medium">{label}</Label>
                <Input
                  type={type}
                  placeholder={placeholder}
                  value={addForm[key as keyof typeof addForm] as string}
                  onChange={(e) => setAddForm((f) => ({ ...f, [key]: e.target.value }))}
                />
              </div>
            ))}
            <div className="grid gap-1">
              <Label className="text-xs font-medium">Category *</Label>
              <Select
                value={addForm.category}
                onValueChange={(v) => setAddForm((f) => ({ ...f, category: v }))}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {["academic","career","research","technology","entrepreneurship","finance","mental_health","fitness","language","arts","law","other"].map((c) => (
                    <SelectItem key={c} value={c}>{c.replace(/_/g, " ")}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="grid gap-1">
              <Label className="text-xs font-medium">Bio</Label>
              <Textarea
                placeholder="Short bio about the expert..."
                value={addForm.bio}
                onChange={(e) => setAddForm((f) => ({ ...f, bio: e.target.value }))}
                rows={3}
              />
            </div>

            {/* Availability Time Slots */}
            <div className="grid gap-2">
              <Label className="text-xs font-medium">Availability</Label>
              {["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"].map((day) => {
                const slot = addForm.availability_slots.find((s) => s.day === day);
                const isActive = !!slot;
                return (
                  <div key={day} className="flex items-center gap-2">
                    <Checkbox
                      checked={isActive}
                      onCheckedChange={(checked) => {
                        if (checked) {
                          setAddForm((f) => ({
                            ...f,
                            availability_slots: [...f.availability_slots, { day, startTime: "09:00", endTime: "17:00" }],
                          }));
                        } else {
                          setAddForm((f) => ({
                            ...f,
                            availability_slots: f.availability_slots.filter((s) => s.day !== day),
                          }));
                        }
                      }}
                    />
                    <span className="text-sm capitalize w-20">{day}</span>
                    {isActive && (
                      <>
                        <Input
                          type="time"
                          value={slot!.startTime}
                          className="w-28 h-7 text-xs"
                          onChange={(e) =>
                            setAddForm((f) => ({
                              ...f,
                              availability_slots: f.availability_slots.map((s) =>
                                s.day === day ? { ...s, startTime: e.target.value } : s
                              ),
                            }))
                          }
                        />
                        <span className="text-xs text-muted-foreground">to</span>
                        <Input
                          type="time"
                          value={slot!.endTime}
                          className="w-28 h-7 text-xs"
                          onChange={(e) =>
                            setAddForm((f) => ({
                              ...f,
                              availability_slots: f.availability_slots.map((s) =>
                                s.day === day ? { ...s, endTime: e.target.value } : s
                              ),
                            }))
                          }
                        />
                      </>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setAddDialog(false)}>Cancel</Button>
            <Button
              disabled={addLoading || !addForm.email || !addForm.full_name || !addForm.headline || !addForm.designation}
              onClick={async () => {
                setAddLoading(true);
                try {
                  await createExpert({
                    email: addForm.email,
                    full_name: addForm.full_name,
                    headline: addForm.headline,
                    designation: addForm.designation,
                    organization: addForm.organization || undefined,
                    category: addForm.category,
                    hourly_rate: Number(addForm.hourly_rate) || 500,
                    bio: addForm.bio || undefined,
                    whatsapp_number: addForm.whatsapp_number || undefined,
                    avatar_url: addForm.avatar_url || undefined,
                    availability_slots: addForm.availability_slots.length > 0 ? addForm.availability_slots : undefined,
                  });
                  toast.success("Expert added successfully");
                  setAddDialog(false);
                  setAddForm({ email: "", full_name: "", headline: "", designation: "", organization: "", category: "academic", hourly_rate: "500", bio: "", whatsapp_number: "", avatar_url: "", uploading_avatar: false, availability_slots: [] });
                  router.refresh();
                } catch (err) {
                  toast.error(err instanceof Error ? err.message : "Failed to add expert");
                } finally {
                  setAddLoading(false);
                }
              }}
            >
              {addLoading ? "Adding..." : "Add Expert"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
