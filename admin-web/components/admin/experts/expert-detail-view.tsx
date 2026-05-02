"use client";

import { useState, useRef, useCallback } from "react";
import { useRouter } from "next/navigation";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Separator } from "@/components/ui/separator";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Select, SelectTrigger, SelectValue, SelectContent, SelectItem,
} from "@/components/ui/select";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter,
} from "@/components/ui/dialog";
import { IconArrowLeft, IconCheck, IconX, IconBan, IconStar, IconEdit, IconLink, IconVideo } from "@tabler/icons-react";
import { verifyExpert, rejectExpert, suspendExpert, featureExpert, updateExpert, getExpertBookings, updateBookingMeetLink } from "@/lib/admin/actions/experts";
import { toast } from "sonner";

function getInitials(name: string | null): string {
  if (!name) return "?";
  return name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);
}

function formatCurrency(amount: number | null): string {
  if (amount == null) return "\u20B90";
  return new Intl.NumberFormat("en-IN", { style: "currency", currency: "INR", minimumFractionDigits: 0 }).format(amount);
}

function formatDate(dateStr: string | null): string {
  if (!dateStr) return "-";
  return new Date(dateStr).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" });
}

const statusColors: Record<string, string> = {
  verified: "text-green-600 border-green-200 bg-green-50 dark:bg-green-900/20",
  pending: "text-yellow-600 border-yellow-200 bg-yellow-50 dark:bg-yellow-900/20",
  rejected: "text-red-600 border-red-200 bg-red-50 dark:bg-red-900/20",
};

interface ExpertProfile {
  id: string;
  full_name: string;
  email: string;
  avatar_url: string | null;
  verification_status: string;
  is_featured: boolean;
  is_active: boolean;
  category: string | null;
  hourly_rate: number | null;
  phone: string | null;
  city: string | null;
  bio: string | null;
  created_at: string | null;
  review_count: number;
  session_count: number;
  headline?: string | null;
  designation?: string | null;
  availability_slots?: Array<{day: string; startTime: string; endTime: string}>;
}

const CATEGORIES = ["academic","career","research","technology","entrepreneurship","finance","mental_health","fitness","language","arts","law","other"];
const DAYS = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"];

interface BookingRow {
  id: string;
  expertId: any;
  userId: any;
  date: string;
  startTime: string;
  endTime: string;
  duration: number;
  topic: string;
  notes: string;
  status: string;
  meetLink: string;
  amount: number;
  paymentStatus: string;
  paymentId: string;
  createdAt: string;
}

export function ExpertDetailView({ expert }: { expert: ExpertProfile }) {
  const router = useRouter();
  const [editOpen, setEditOpen] = useState(false);
  const [editLoading, setEditLoading] = useState(false);
  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const avatarRef = useRef<HTMLInputElement>(null);

  // Bookings state
  const [bookings, setBookings] = useState<BookingRow[]>([]);
  const [bookingsLoading, setBookingsLoading] = useState(false);
  const [meetLinkDialogOpen, setMeetLinkDialogOpen] = useState(false);
  const [editingBookingId, setEditingBookingId] = useState<string | null>(null);
  const [meetLinkValue, setMeetLinkValue] = useState("");
  const [meetLinkSaving, setMeetLinkSaving] = useState(false);

  const loadBookings = useCallback(async () => {
    setBookingsLoading(true);
    try {
      const result = await getExpertBookings();
      // Filter to show only this expert's bookings
      setBookings(result.bookings.filter((b: BookingRow) => {
        const bExpertId = typeof b.expertId === "object" ? (b.expertId?._id || b.expertId?.id) : b.expertId;
        return bExpertId === expert.id;
      }));
    } catch { /* ignore */ }
    finally { setBookingsLoading(false); }
  }, [expert.id]);

  const handleSaveMeetLink = async () => {
    if (!editingBookingId || !meetLinkValue.trim()) return;
    setMeetLinkSaving(true);
    try {
      await updateBookingMeetLink(editingBookingId, meetLinkValue.trim());
      toast.success("Meet link updated");
      setMeetLinkDialogOpen(false);
      setEditingBookingId(null);
      setMeetLinkValue("");
      loadBookings();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to update meet link");
    } finally {
      setMeetLinkSaving(false);
    }
  };
  const [editForm, setEditForm] = useState({
    full_name: expert.full_name || "",
    email: expert.email || "",
    headline: expert.headline || "",
    designation: expert.designation || "",
    organization: expert.city || "",
    category: expert.category || "academic",
    hourly_rate: String(expert.hourly_rate || 0),
    bio: expert.bio || "",
    whatsapp_number: expert.phone || "",
    avatar_url: expert.avatar_url || "",
    availability_slots: (expert.availability_slots || []) as Array<{day: string; startTime: string; endTime: string}>,
  });

  const handleAvatarUpload = useCallback(async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploadingAvatar(true);
    try {
      const formData = new FormData();
      formData.append("file", file);
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"}/api/upload`,
        {
          method: "POST",
          body: formData,
          headers: { Authorization: `Bearer ${document.cookie.split("admin-token=")[1]?.split(";")[0] || ""}` },
        }
      );
      if (!res.ok) throw new Error("Upload failed");
      const data = await res.json();
      setEditForm(f => ({ ...f, avatar_url: data.url || data.secure_url || data.fileUrl || "" }));
      toast.success("Photo uploaded");
    } catch { toast.error("Upload failed"); }
    finally { setUploadingAvatar(false); }
  }, []);

  const handleSaveEdit = async () => {
    setEditLoading(true);
    try {
      await updateExpert(expert.id, {
        full_name: editForm.full_name,
        email: editForm.email,
        headline: editForm.headline,
        designation: editForm.designation,
        organization: editForm.organization,
        category: editForm.category,
        hourly_rate: Number(editForm.hourly_rate) || 0,
        bio: editForm.bio,
        whatsapp_number: editForm.whatsapp_number,
        avatar_url: editForm.avatar_url,
        availability_slots: editForm.availability_slots,
      });
      toast.success("Expert updated");
      setEditOpen(false);
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Update failed");
    } finally {
      setEditLoading(false);
    }
  };

  async function handleAction(action: string) {
    try {
      if (action === "verify") {
        await verifyExpert(expert.id);
        toast.success("Expert verified");
      } else if (action === "reject") {
        await rejectExpert(expert.id, "Rejected by admin");
        toast.success("Expert rejected");
      } else if (action === "suspend") {
        await suspendExpert(expert.id);
        toast.success("Expert suspended");
      } else if (action === "feature") {
        await featureExpert(expert.id, !expert.is_featured);
        toast.success(expert.is_featured ? "Expert unfeatured" : "Expert featured");
      }
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Action failed");
    }
  }

  return (
    <div className="flex flex-col gap-6 px-4 lg:px-6">
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" onClick={() => router.back()}>
          <IconArrowLeft className="size-4" />
        </Button>
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Expert Details</h1>
          <p className="text-muted-foreground">View and manage expert profile</p>
        </div>
      </div>

      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div className="flex items-center gap-4">
              <Avatar size="lg">
                {expert.avatar_url && <AvatarImage src={expert.avatar_url} alt={expert.full_name} />}
                <AvatarFallback>{getInitials(expert.full_name)}</AvatarFallback>
              </Avatar>
              <div>
                <h2 className="text-xl font-semibold">{expert.full_name}</h2>
                <p className="text-muted-foreground">{expert.email}</p>
                <div className="mt-1 flex items-center gap-2">
                  <Badge variant="outline" className={statusColors[expert.verification_status] || ""}>
                    {expert.verification_status}
                  </Badge>
                  {expert.is_featured && (
                    <Badge variant="outline" className="text-yellow-600 border-yellow-200 bg-yellow-50 dark:bg-yellow-900/20">
                      Featured
                    </Badge>
                  )}
                  <Badge variant={expert.is_active ? "outline" : "destructive"}>
                    {expert.is_active ? "Active" : "Suspended"}
                  </Badge>
                </div>
              </div>
            </div>
            <div className="flex gap-2 flex-wrap">
              <Button size="sm" variant="outline" onClick={() => setEditOpen(true)}>
                <IconEdit className="size-4" />
                Edit
              </Button>
              {expert.verification_status !== "verified" && (
                <Button size="sm" onClick={() => handleAction("verify")}>
                  <IconCheck className="size-4" />
                  Verify
                </Button>
              )}
              {expert.verification_status !== "rejected" && (
                <Button variant="outline" size="sm" className="text-red-600" onClick={() => handleAction("reject")}>
                  <IconX className="size-4" />
                  Reject
                </Button>
              )}
              <Button variant="outline" size="sm" onClick={() => handleAction("feature")}>
                <IconStar className="size-4" />
                {expert.is_featured ? "Unfeature" : "Feature"}
              </Button>
              {expert.is_active && (
                <Button variant="outline" size="sm" className="text-red-600" onClick={() => handleAction("suspend")}>
                  <IconBan className="size-4" />
                  Suspend
                </Button>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      <Tabs defaultValue="profile">
        <TabsList>
          <TabsTrigger value="profile">Profile</TabsTrigger>
          <TabsTrigger value="bookings" onClick={() => { if (bookings.length === 0) loadBookings(); }}>Bookings</TabsTrigger>
          <TabsTrigger value="reviews">Reviews ({expert.review_count})</TabsTrigger>
          <TabsTrigger value="sessions">Sessions ({expert.session_count})</TabsTrigger>
          <TabsTrigger value="earnings">Earnings</TabsTrigger>
        </TabsList>
        <TabsContent value="profile">
          <Card>
            <CardHeader>
              <CardTitle>Profile Information</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Headline</p>
                  <p>{expert.headline || "-"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Designation</p>
                  <p>{expert.designation || "-"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Category</p>
                  <p className="capitalize">{expert.category?.replace(/_/g, " ") || "-"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Hourly Rate</p>
                  <p>{formatCurrency(expert.hourly_rate)}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Organization</p>
                  <p>{expert.city || "-"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">WhatsApp</p>
                  <p>{expert.phone || "-"}</p>
                </div>
                <div className="sm:col-span-2">
                  <p className="text-sm font-medium text-muted-foreground">Bio</p>
                  <p>{expert.bio || "-"}</p>
                </div>
                {expert.availability_slots && expert.availability_slots.length > 0 && (
                  <div className="sm:col-span-2">
                    <p className="text-sm font-medium text-muted-foreground mb-2">Availability</p>
                    <div className="flex flex-wrap gap-2">
                      {expert.availability_slots.map(slot => (
                        <span key={slot.day} className="text-xs px-2 py-1 rounded-full bg-green-50 text-green-700 border border-green-200 capitalize">
                          {slot.day} {slot.startTime}–{slot.endTime}
                        </span>
                      ))}
                    </div>
                  </div>
                )}
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Joined</p>
                  <p>{formatDate(expert.created_at)}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="bookings">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle>Bookings</CardTitle>
              <Button variant="outline" size="sm" onClick={loadBookings} disabled={bookingsLoading}>
                {bookingsLoading ? "Loading..." : "Refresh"}
              </Button>
            </CardHeader>
            <CardContent>
              {bookingsLoading ? (
                <p className="text-muted-foreground">Loading bookings...</p>
              ) : bookings.length === 0 ? (
                <p className="text-muted-foreground">No bookings found for this expert.</p>
              ) : (
                <div className="space-y-3">
                  {bookings.map((booking) => {
                    const userName = typeof booking.userId === "object"
                      ? (booking.userId?.name || booking.userId?.email || "User")
                      : "User";
                    const bookingDate = booking.date ? new Date(booking.date).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" }) : "-";

                    return (
                      <div key={booking.id} className="flex items-center gap-4 p-4 rounded-lg border">
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1">
                            <p className="font-medium text-sm truncate">{userName}</p>
                            <Badge variant="outline" className={
                              booking.status === "confirmed" ? "text-green-600 border-green-200 bg-green-50" :
                              booking.status === "completed" ? "text-blue-600 border-blue-200 bg-blue-50" :
                              booking.status === "cancelled" ? "text-red-600 border-red-200 bg-red-50" :
                              "text-yellow-600 border-yellow-200 bg-yellow-50"
                            }>
                              {booking.status}
                            </Badge>
                            <Badge variant="outline" className={
                              booking.paymentStatus === "completed" ? "text-green-600 border-green-200 bg-green-50" :
                              "text-yellow-600 border-yellow-200 bg-yellow-50"
                            }>
                              Payment: {booking.paymentStatus}
                            </Badge>
                          </div>
                          <div className="flex items-center gap-4 text-xs text-muted-foreground">
                            <span>{bookingDate}</span>
                            <span>{booking.startTime || "-"}</span>
                            <span>{booking.duration}min</span>
                            {booking.topic && <span className="truncate max-w-[200px]">Topic: {booking.topic}</span>}
                            <span className="font-medium text-foreground">{formatCurrency(booking.amount)}</span>
                          </div>
                          {booking.meetLink && (
                            <div className="flex items-center gap-1.5 mt-1.5 text-xs">
                              <IconVideo className="size-3 text-blue-500" />
                              <a href={booking.meetLink} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline truncate max-w-xs">
                                {booking.meetLink}
                              </a>
                            </div>
                          )}
                        </div>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => {
                            setEditingBookingId(booking.id);
                            setMeetLinkValue(booking.meetLink || "");
                            setMeetLinkDialogOpen(true);
                          }}
                        >
                          <IconLink className="size-4 mr-1" />
                          {booking.meetLink ? "Edit" : "Add"} Meet Link
                        </Button>
                      </div>
                    );
                  })}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Meet Link Dialog */}
          <Dialog open={meetLinkDialogOpen} onOpenChange={setMeetLinkDialogOpen}>
            <DialogContent className="max-w-md">
              <DialogHeader>
                <DialogTitle>{meetLinkValue ? "Edit" : "Add"} Google Meet Link</DialogTitle>
              </DialogHeader>
              <div className="py-3 space-y-3">
                <div className="grid gap-1">
                  <Label className="text-xs font-medium">Google Meet URL</Label>
                  <Input
                    type="url"
                    placeholder="https://meet.google.com/xxx-xxxx-xxx"
                    value={meetLinkValue}
                    onChange={(e) => setMeetLinkValue(e.target.value)}
                  />
                  <p className="text-xs text-muted-foreground">
                    This link will be visible to the user in their booking details.
                  </p>
                </div>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setMeetLinkDialogOpen(false)}>Cancel</Button>
                <Button onClick={handleSaveMeetLink} disabled={meetLinkSaving || !meetLinkValue.trim()}>
                  {meetLinkSaving ? "Saving..." : "Save Meet Link"}
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </TabsContent>
        <TabsContent value="reviews">
          <Card>
            <CardHeader>
              <CardTitle>Reviews</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground">
                {expert.review_count > 0
                  ? `${expert.review_count} review${expert.review_count !== 1 ? "s" : ""} received.`
                  : "No reviews yet."}
              </p>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="sessions">
          <Card>
            <CardHeader>
              <CardTitle>Session History</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground">
                {expert.session_count > 0
                  ? `${expert.session_count} session${expert.session_count !== 1 ? "s" : ""} completed.`
                  : "No sessions yet."}
              </p>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="earnings">
          <Card>
            <CardHeader>
              <CardTitle>Earnings</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid gap-4 sm:grid-cols-3">
                <div className="rounded-md border p-4 text-center">
                  <p className="text-sm text-muted-foreground">Rate per Hour</p>
                  <p className="text-2xl font-bold">{formatCurrency(expert.hourly_rate)}</p>
                </div>
                <div className="rounded-md border p-4 text-center">
                  <p className="text-sm text-muted-foreground">Sessions</p>
                  <p className="text-2xl font-bold">{expert.session_count}</p>
                </div>
                <div className="rounded-md border p-4 text-center">
                  <p className="text-sm text-muted-foreground">Reviews</p>
                  <p className="text-2xl font-bold">{expert.review_count}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Edit Expert Dialog */}
      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Edit Expert</DialogTitle>
          </DialogHeader>
          <div className="grid gap-3 py-2">
            {/* Avatar Upload */}
            <div className="flex items-center gap-4">
              <Avatar className="h-16 w-16">
                {editForm.avatar_url && <AvatarImage src={editForm.avatar_url} />}
                <AvatarFallback className="text-lg">{getInitials(editForm.full_name)}</AvatarFallback>
              </Avatar>
              <div>
                <Button type="button" variant="outline" size="sm" disabled={uploadingAvatar} onClick={() => avatarRef.current?.click()}>
                  {uploadingAvatar ? "Uploading..." : "Change Photo"}
                </Button>
                <input ref={avatarRef} type="file" accept="image/*" className="hidden" onChange={handleAvatarUpload} />
              </div>
            </div>

            {/* Text fields */}
            {([
              { label: "Full Name", key: "full_name", type: "text" },
              { label: "Email", key: "email", type: "email" },
              { label: "Headline", key: "headline", type: "text" },
              { label: "Designation", key: "designation", type: "text" },
              { label: "Organization", key: "organization", type: "text" },
              { label: "Hourly Rate (₹)", key: "hourly_rate", type: "number" },
              { label: "WhatsApp Number", key: "whatsapp_number", type: "text" },
            ] as const).map(({ label, key, type }) => (
              <div key={key} className="grid gap-1">
                <Label className="text-xs font-medium">{label}</Label>
                <Input
                  type={type}
                  value={editForm[key]}
                  onChange={(e) => setEditForm(f => ({ ...f, [key]: e.target.value }))}
                />
              </div>
            ))}

            {/* Category */}
            <div className="grid gap-1">
              <Label className="text-xs font-medium">Category</Label>
              <Select value={editForm.category} onValueChange={(v) => setEditForm(f => ({ ...f, category: v }))}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  {CATEGORIES.map(c => (
                    <SelectItem key={c} value={c}>{c.replace(/_/g, " ")}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Bio */}
            <div className="grid gap-1">
              <Label className="text-xs font-medium">Bio</Label>
              <Textarea
                value={editForm.bio}
                onChange={(e) => setEditForm(f => ({ ...f, bio: e.target.value }))}
                rows={3}
              />
            </div>

            {/* Availability Slots */}
            <div className="grid gap-2">
              <Label className="text-xs font-medium">Availability</Label>
              {DAYS.map(day => {
                const slot = editForm.availability_slots.find(s => s.day === day);
                const isActive = !!slot;
                return (
                  <div key={day} className="flex items-center gap-2">
                    <Checkbox
                      checked={isActive}
                      onCheckedChange={(checked) => {
                        if (checked) {
                          setEditForm(f => ({ ...f, availability_slots: [...f.availability_slots, { day, startTime: "09:00", endTime: "17:00" }] }));
                        } else {
                          setEditForm(f => ({ ...f, availability_slots: f.availability_slots.filter(s => s.day !== day) }));
                        }
                      }}
                    />
                    <span className="text-sm capitalize w-20">{day}</span>
                    {isActive && slot && (
                      <>
                        <Input
                          type="time"
                          value={slot.startTime}
                          className="w-28 h-7 text-xs"
                          onChange={(e) => setEditForm(f => ({
                            ...f,
                            availability_slots: f.availability_slots.map(s => s.day === day ? { ...s, startTime: e.target.value } : s),
                          }))}
                        />
                        <span className="text-xs text-muted-foreground">to</span>
                        <Input
                          type="time"
                          value={slot.endTime}
                          className="w-28 h-7 text-xs"
                          onChange={(e) => setEditForm(f => ({
                            ...f,
                            availability_slots: f.availability_slots.map(s => s.day === day ? { ...s, endTime: e.target.value } : s),
                          }))}
                        />
                      </>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditOpen(false)}>Cancel</Button>
            <Button onClick={handleSaveEdit} disabled={editLoading}>
              {editLoading ? "Saving..." : "Save Changes"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
