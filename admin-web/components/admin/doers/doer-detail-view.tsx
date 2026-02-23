"use client";

import { useRouter } from "next/navigation";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";
import { IconArrowLeft } from "@tabler/icons-react";

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
  completed: "text-green-600 border-green-200 bg-green-50 dark:bg-green-900/20",
  in_progress: "text-blue-600 border-blue-200 bg-blue-50 dark:bg-blue-900/20",
  pending: "text-yellow-600 border-yellow-200 bg-yellow-50 dark:bg-yellow-900/20",
  cancelled: "text-red-600 border-red-200 bg-red-50 dark:bg-red-900/20",
};

interface DoerProfile {
  full_name: string | null;
  email: string | null;
  avatar_url: string | null;
  is_active: boolean;
  phone: string | null;
  city: string | null;
  bio: string | null;
  created_at: string | null;
}

interface DoerTask {
  id: string;
  title: string;
  status: string;
  price: number | null;
  created_at: string;
}

export function DoerDetailView({
  profile,
  tasks,
  metrics,
}: {
  profile: DoerProfile;
  tasks: DoerTask[];
  metrics: {
    total_tasks: number;
    completed: number;
    in_progress: number;
    completion_rate: number;
  };
}) {
  const router = useRouter();

  return (
    <div className="flex flex-col gap-6 px-4 lg:px-6">
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" onClick={() => router.back()}>
          <IconArrowLeft className="size-4" />
        </Button>
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Doer Details</h1>
          <p className="text-muted-foreground">View doer profile and performance</p>
        </div>
      </div>

      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center gap-4">
            <Avatar size="lg">
              {profile.avatar_url && <AvatarImage src={profile.avatar_url} alt={profile.full_name || ""} />}
              <AvatarFallback>{getInitials(profile.full_name)}</AvatarFallback>
            </Avatar>
            <div>
              <h2 className="text-xl font-semibold">{profile.full_name || "Unnamed"}</h2>
              <p className="text-muted-foreground">{profile.email || "-"}</p>
              <div className="mt-1 flex items-center gap-2">
                <Badge variant={profile.is_active ? "outline" : "destructive"}>
                  {profile.is_active ? "Active" : "Suspended"}
                </Badge>
                <Badge variant="outline" className="bg-yellow-50 text-yellow-600 border-yellow-200 dark:bg-yellow-900/20">
                  Doer
                </Badge>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-4 sm:grid-cols-4">
        <Card>
          <CardContent className="pt-6 text-center">
            <p className="text-sm text-muted-foreground">Total Tasks</p>
            <p className="text-2xl font-bold">{metrics.total_tasks}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6 text-center">
            <p className="text-sm text-muted-foreground">Completed</p>
            <p className="text-2xl font-bold text-green-600">{metrics.completed}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6 text-center">
            <p className="text-sm text-muted-foreground">In Progress</p>
            <p className="text-2xl font-bold text-blue-600">{metrics.in_progress}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6 text-center">
            <p className="text-sm text-muted-foreground">Completion Rate</p>
            <p className="text-2xl font-bold">{metrics.completion_rate}%</p>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="profile">
        <TabsList>
          <TabsTrigger value="profile">Profile</TabsTrigger>
          <TabsTrigger value="tasks">Tasks ({tasks.length})</TabsTrigger>
        </TabsList>
        <TabsContent value="profile">
          <Card>
            <CardHeader>
              <CardTitle>Profile Information</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Phone</p>
                  <p>{profile.phone || "-"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">College</p>
                  <p>{profile.city || "-"}</p>
                </div>
                <div className="sm:col-span-2">
                  <p className="text-sm font-medium text-muted-foreground">Bio</p>
                  <p>{profile.bio || "-"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Joined</p>
                  <p>{formatDate(profile.created_at)}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="tasks">
          <Card>
            <CardHeader>
              <CardTitle>Assigned Tasks</CardTitle>
            </CardHeader>
            <CardContent>
              {tasks.length === 0 ? (
                <p className="text-muted-foreground">No tasks assigned.</p>
              ) : (
                <div className="rounded-md border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Title</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Price</TableHead>
                        <TableHead>Created</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {tasks.map((t) => (
                        <TableRow key={t.id}>
                          <TableCell className="font-medium">{t.title}</TableCell>
                          <TableCell>
                            <Badge variant="outline" className={statusColors[t.status] || ""}>
                              {t.status}
                            </Badge>
                          </TableCell>
                          <TableCell>{formatCurrency(t.price)}</TableCell>
                          <TableCell>{formatDate(t.created_at)}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
