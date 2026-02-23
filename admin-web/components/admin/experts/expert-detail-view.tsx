"use client";

import { useRouter } from "next/navigation";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Separator } from "@/components/ui/separator";
import { IconArrowLeft, IconCheck, IconX, IconBan, IconStar } from "@tabler/icons-react";
import { verifyExpert, rejectExpert, suspendExpert, featureExpert } from "@/lib/admin/actions/experts";
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
  profile_bio: string | null;
  profile_created_at: string | null;
  created_at: string | null;
  review_count: number;
  session_count: number;
}

export function ExpertDetailView({ expert }: { expert: ExpertProfile }) {
  const router = useRouter();

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
            <div className="flex gap-2">
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
                  <p className="text-sm font-medium text-muted-foreground">Category</p>
                  <p className="capitalize">{expert.category || "-"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Hourly Rate</p>
                  <p>{formatCurrency(expert.hourly_rate)}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Phone</p>
                  <p>{expert.phone || "-"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">College</p>
                  <p>{expert.city || "-"}</p>
                </div>
                <div className="sm:col-span-2">
                  <p className="text-sm font-medium text-muted-foreground">Bio</p>
                  <p>{expert.bio || expert.profile_bio || "-"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Joined</p>
                  <p>{formatDate(expert.profile_created_at || expert.created_at)}</p>
                </div>
              </div>
            </CardContent>
          </Card>
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
    </div>
  );
}
