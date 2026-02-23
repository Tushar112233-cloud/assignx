"use client";

import Link from "next/link";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";
import { UserActions } from "./user-actions";

type Profile = {
  id: string;
  full_name: string | null;
  email: string | null;
  avatar_url: string | null;
  user_type: string | null;
  is_active: boolean;
  city: string | null;
  phone: string | null;
  bio: string | null;
  onboarding_completed: boolean | null;
  created_at: string;
  updated_at: string | null;
};

type Wallet = {
  id: string;
  profile_id: string;
  balance: number;
  currency: string;
  created_at: string;
  updated_at: string | null;
} | null;

type Project = {
  id: string;
  title: string;
  status: string;
  service_type: string;
  user_quote: number | null;
  created_at: string;
};

type Activity = {
  id: string;
  action: string;
  description: string | null;
  created_at: string;
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

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

function formatDateTime(dateStr: string): string {
  return new Date(dateStr).toLocaleString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function formatCurrency(amount: number | null | undefined, currency = "INR"): string {
  if (amount == null) return "\u20B90.00";
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency,
    minimumFractionDigits: 2,
  }).format(amount);
}

const statusColors: Record<string, string> = {
  draft: "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-400",
  pending: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400",
  in_progress: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400",
  completed: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400",
  cancelled: "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400",
};

export function UserDetailPanel({
  profile,
  wallet,
  projects,
  activity,
}: {
  profile: Profile;
  wallet: Wallet;
  projects: Project[];
  activity: Activity[];
}) {
  return (
    <>
      <div className="flex items-center justify-between px-4 lg:px-6">
        <div className="flex items-center gap-4">
          <Avatar size="lg">
            {profile.avatar_url && (
              <AvatarImage src={profile.avatar_url} alt={profile.full_name || ""} />
            )}
            <AvatarFallback>{getInitials(profile.full_name)}</AvatarFallback>
          </Avatar>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">
              {profile.full_name || "Unnamed User"}
            </h1>
            <p className="text-muted-foreground">{profile.email}</p>
          </div>
        </div>
        <UserActions userId={profile.id} isActive={profile.is_active} />
      </div>

      <div className="px-4 lg:px-6">
        <Tabs defaultValue="profile">
          <TabsList>
            <TabsTrigger value="profile">Profile</TabsTrigger>
            <TabsTrigger value="projects">Projects ({projects.length})</TabsTrigger>
            <TabsTrigger value="wallet">Wallet</TabsTrigger>
            <TabsTrigger value="activity">Activity</TabsTrigger>
          </TabsList>

          <TabsContent value="profile">
            <Card className="mt-4">
              <CardHeader>
                <CardTitle>User Information</CardTitle>
              </CardHeader>
              <CardContent>
                <dl className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  <div>
                    <dt className="text-sm font-medium text-muted-foreground">Full Name</dt>
                    <dd className="mt-1">{profile.full_name || "-"}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-muted-foreground">Email</dt>
                    <dd className="mt-1">{profile.email || "-"}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-muted-foreground">Phone</dt>
                    <dd className="mt-1">{profile.phone || "-"}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-muted-foreground">User Type</dt>
                    <dd className="mt-1">
                      <Badge variant="secondary">{profile.user_type || "unknown"}</Badge>
                    </dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-muted-foreground">City</dt>
                    <dd className="mt-1">{profile.city || "-"}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-muted-foreground">Status</dt>
                    <dd className="mt-1">
                      <Badge variant={profile.is_active ? "outline" : "destructive"}>
                        {profile.is_active ? "Active" : "Suspended"}
                      </Badge>
                    </dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-muted-foreground">
                      Onboarding Completed
                    </dt>
                    <dd className="mt-1">{profile.onboarding_completed ? "Yes" : "No"}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-muted-foreground">Joined</dt>
                    <dd className="mt-1">{formatDate(profile.created_at)}</dd>
                  </div>
                  {profile.bio && (
                    <div className="sm:col-span-2">
                      <dt className="text-sm font-medium text-muted-foreground">Bio</dt>
                      <dd className="mt-1">{profile.bio}</dd>
                    </div>
                  )}
                </dl>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="projects">
            <Card className="mt-4">
              <CardHeader>
                <CardTitle>Recent Projects</CardTitle>
              </CardHeader>
              <CardContent>
                {projects.length === 0 ? (
                  <p className="text-sm text-muted-foreground">No projects found.</p>
                ) : (
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Title</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Service Type</TableHead>
                        <TableHead>Price</TableHead>
                        <TableHead>Created</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {projects.map((project) => (
                        <TableRow key={project.id}>
                          <TableCell>
                            <Link
                              href={`/projects/${project.id}`}
                              className="font-medium hover:underline"
                            >
                              {project.title}
                            </Link>
                          </TableCell>
                          <TableCell>
                            <Badge
                              variant="secondary"
                              className={statusColors[project.status] || ""}
                            >
                              {project.status.replace(/_/g, " ")}
                            </Badge>
                          </TableCell>
                          <TableCell>{project.service_type.replace(/_/g, " ")}</TableCell>
                          <TableCell>{formatCurrency(project.user_quote)}</TableCell>
                          <TableCell>{formatDate(project.created_at)}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="wallet">
            <Card className="mt-4">
              <CardHeader>
                <CardTitle>Wallet</CardTitle>
              </CardHeader>
              <CardContent>
                {wallet ? (
                  <div className="space-y-4">
                    <div className="rounded-lg border p-6">
                      <p className="text-sm font-medium text-muted-foreground">Current Balance</p>
                      <p className="mt-1 text-3xl font-bold">
                        {formatCurrency(wallet.balance, wallet.currency)}
                      </p>
                      <p className="mt-1 text-xs text-muted-foreground">
                        Last updated:{" "}
                        {wallet.updated_at ? formatDateTime(wallet.updated_at) : "-"}
                      </p>
                    </div>
                  </div>
                ) : (
                  <p className="text-sm text-muted-foreground">No wallet found for this user.</p>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="activity">
            <Card className="mt-4">
              <CardHeader>
                <CardTitle>Recent Activity</CardTitle>
              </CardHeader>
              <CardContent>
                {activity.length === 0 ? (
                  <p className="text-sm text-muted-foreground">No activity recorded.</p>
                ) : (
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Action</TableHead>
                        <TableHead>Description</TableHead>
                        <TableHead>Date</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {activity.map((entry) => (
                        <TableRow key={entry.id}>
                          <TableCell className="font-medium">
                            {entry.action.replace(/_/g, " ")}
                          </TableCell>
                          <TableCell className="text-muted-foreground">
                            {entry.description || "-"}
                          </TableCell>
                          <TableCell>{formatDateTime(entry.created_at)}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                )}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </>
  );
}
