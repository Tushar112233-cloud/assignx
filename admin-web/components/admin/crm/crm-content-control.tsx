"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import {
  IconPhoto,
  IconQuestionMark,
  IconShoppingCart,
  IconMessage2,
  IconBook2,
  IconToggleLeft,
  IconToggleRight,
  IconEye,
  IconEyeOff,
  IconCheck,
  IconX,
  IconEdit,
  IconPlus,
} from "@tabler/icons-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { toast } from "sonner";
import {
  toggleContentStatus,
  moderateCampusPost,
  moderateMarketplaceListing,
  updateFaq,
  createFaq,
} from "@/lib/admin/actions/crm";

type ContentOverview = {
  banners: { data: any[]; total: number };
  faqs: { data: any[]; total: number };
  listings: { data: any[]; total: number };
  campusPosts: { data: any[]; total: number };
  learningResources: { data: any[]; total: number };
};

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
}

// ---- Banners Tab ----
function BannersTab({ banners }: { banners: any[] }) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  const handleToggle = (id: string, current: boolean) => {
    startTransition(async () => {
      try {
        await toggleContentStatus("banners", id, !current);
        toast.success(`Banner ${!current ? "activated" : "deactivated"}`);
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Failed to update");
      }
    });
  };

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Title</TableHead>
            <TableHead>Location</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Created</TableHead>
            <TableHead className="w-24">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {banners.length === 0 ? (
            <TableRow>
              <TableCell colSpan={5} className="h-20 text-center text-muted-foreground">
                No banners found.
              </TableCell>
            </TableRow>
          ) : (
            banners.map((banner) => (
              <TableRow key={banner.id}>
                <TableCell>
                  <div className="flex items-center gap-3">
                    {banner.image_url ? (
                      <img
                        src={banner.image_url}
                        alt=""
                        className="h-8 w-14 rounded object-cover border"
                      />
                    ) : (
                      <div className="h-8 w-14 rounded bg-muted flex items-center justify-center">
                        <IconPhoto className="h-4 w-4 text-muted-foreground" />
                      </div>
                    )}
                    <span className="font-medium text-sm">{banner.title}</span>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary">
                    {banner.display_location || "default"}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant={banner.is_active ? "outline" : "secondary"}>
                    {banner.is_active ? "Active" : "Inactive"}
                  </Badge>
                </TableCell>
                <TableCell className="text-sm text-muted-foreground">
                  {formatDate(banner.created_at)}
                </TableCell>
                <TableCell>
                  <Button
                    variant="ghost"
                    size="sm"
                    disabled={isPending}
                    onClick={() => handleToggle(banner.id, banner.is_active)}
                  >
                    {banner.is_active ? (
                      <IconToggleRight className="h-4 w-4 text-green-600" />
                    ) : (
                      <IconToggleLeft className="h-4 w-4 text-muted-foreground" />
                    )}
                  </Button>
                </TableCell>
              </TableRow>
            ))
          )}
        </TableBody>
      </Table>
    </div>
  );
}

// ---- FAQs Tab ----
function FaqsTab({ faqs }: { faqs: any[] }) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [editingFaq, setEditingFaq] = useState<any | null>(null);
  const [createOpen, setCreateOpen] = useState(false);
  const [newQuestion, setNewQuestion] = useState("");
  const [newAnswer, setNewAnswer] = useState("");
  const [newCategory, setNewCategory] = useState("");

  const handleToggle = (id: string, current: boolean) => {
    startTransition(async () => {
      try {
        await toggleContentStatus("faqs", id, !current);
        toast.success(`FAQ ${!current ? "activated" : "deactivated"}`);
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Failed to update");
      }
    });
  };

  const handleUpdate = (faq: any) => {
    startTransition(async () => {
      try {
        await updateFaq(faq.id, {
          question: faq.question,
          answer: faq.answer,
        });
        toast.success("FAQ updated");
        setEditingFaq(null);
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Failed to update");
      }
    });
  };

  const handleCreate = () => {
    if (!newQuestion.trim() || !newAnswer.trim()) {
      toast.error("Question and answer are required");
      return;
    }
    startTransition(async () => {
      try {
        await createFaq({
          question: newQuestion,
          answer: newAnswer,
          category: newCategory || "general",
        });
        toast.success("FAQ created");
        setCreateOpen(false);
        setNewQuestion("");
        setNewAnswer("");
        setNewCategory("");
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Failed to create");
      }
    });
  };

  return (
    <div className="space-y-3">
      <div className="flex justify-end">
        <Dialog open={createOpen} onOpenChange={setCreateOpen}>
          <DialogTrigger asChild>
            <Button size="sm">
              <IconPlus className="h-4 w-4 mr-1" />
              Add FAQ
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Create FAQ</DialogTitle>
              <DialogDescription>Add a new frequently asked question.</DialogDescription>
            </DialogHeader>
            <div className="space-y-3">
              <div className="space-y-2">
                <Label>Category</Label>
                <Input
                  value={newCategory}
                  onChange={(e) => setNewCategory(e.target.value)}
                  placeholder="e.g. general, billing, projects"
                />
              </div>
              <div className="space-y-2">
                <Label>Question</Label>
                <Input
                  value={newQuestion}
                  onChange={(e) => setNewQuestion(e.target.value)}
                  placeholder="Enter the question"
                />
              </div>
              <div className="space-y-2">
                <Label>Answer</Label>
                <Textarea
                  value={newAnswer}
                  onChange={(e) => setNewAnswer(e.target.value)}
                  placeholder="Enter the answer"
                  rows={4}
                />
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setCreateOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleCreate} disabled={isPending}>
                {isPending ? "Creating..." : "Create"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Question</TableHead>
              <TableHead>Category</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="w-28">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {faqs.length === 0 ? (
              <TableRow>
                <TableCell colSpan={4} className="h-20 text-center text-muted-foreground">
                  No FAQs found.
                </TableCell>
              </TableRow>
            ) : (
              faqs.map((faq) => (
                <TableRow key={faq.id}>
                  <TableCell>
                    <div className="max-w-md">
                      <div className="font-medium text-sm">{faq.question}</div>
                      <div className="text-xs text-muted-foreground line-clamp-2 mt-0.5">
                        {faq.answer}
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant="secondary">{faq.category || "general"}</Badge>
                  </TableCell>
                  <TableCell>
                    <Badge variant={faq.is_active ? "outline" : "secondary"}>
                      {faq.is_active ? "Active" : "Inactive"}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-1">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() =>
                          setEditingFaq(
                            editingFaq?.id === faq.id ? null : { ...faq }
                          )
                        }
                      >
                        <IconEdit className="h-4 w-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        disabled={isPending}
                        onClick={() => handleToggle(faq.id, faq.is_active)}
                      >
                        {faq.is_active ? (
                          <IconToggleRight className="h-4 w-4 text-green-600" />
                        ) : (
                          <IconToggleLeft className="h-4 w-4 text-muted-foreground" />
                        )}
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      {/* Edit FAQ Dialog */}
      <Dialog
        open={!!editingFaq}
        onOpenChange={(open) => !open && setEditingFaq(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit FAQ</DialogTitle>
          </DialogHeader>
          {editingFaq && (
            <div className="space-y-3">
              <div className="space-y-2">
                <Label>Question</Label>
                <Input
                  value={editingFaq.question}
                  onChange={(e) =>
                    setEditingFaq({ ...editingFaq, question: e.target.value })
                  }
                />
              </div>
              <div className="space-y-2">
                <Label>Answer</Label>
                <Textarea
                  value={editingFaq.answer}
                  onChange={(e) =>
                    setEditingFaq({ ...editingFaq, answer: e.target.value })
                  }
                  rows={4}
                />
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditingFaq(null)}>
              Cancel
            </Button>
            <Button
              onClick={() => handleUpdate(editingFaq)}
              disabled={isPending}
            >
              {isPending ? "Saving..." : "Save Changes"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// ---- Marketplace Listings Tab ----
function ListingsTab({ listings }: { listings: any[] }) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  const handleModerate = (id: string, action: "approve" | "reject") => {
    startTransition(async () => {
      try {
        await moderateMarketplaceListing(id, action);
        toast.success(`Listing ${action === "approve" ? "approved" : "rejected"}`);
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Failed to moderate");
      }
    });
  };

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Title</TableHead>
            <TableHead>Type</TableHead>
            <TableHead>Price</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Views</TableHead>
            <TableHead className="w-28">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {listings.length === 0 ? (
            <TableRow>
              <TableCell colSpan={6} className="h-20 text-center text-muted-foreground">
                No listings found.
              </TableCell>
            </TableRow>
          ) : (
            listings.map((listing) => (
              <TableRow key={listing.id}>
                <TableCell>
                  <div>
                    <div className="font-medium text-sm">{listing.title}</div>
                    <div className="text-xs text-muted-foreground">
                      by {listing.seller?.full_name || "Unknown"}
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary">{listing.listing_type}</Badge>
                </TableCell>
                <TableCell className="text-sm">
                  {listing.price ? formatCurrency(Number(listing.price)) : "Free"}
                </TableCell>
                <TableCell>
                  <Badge
                    variant={
                      listing.status === "active"
                        ? "outline"
                        : listing.status === "pending"
                          ? "secondary"
                          : "destructive"
                    }
                  >
                    {listing.status}
                  </Badge>
                </TableCell>
                <TableCell className="text-sm text-muted-foreground">
                  {listing.view_count || 0}
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-1">
                    {listing.status !== "active" && (
                      <Button
                        variant="ghost"
                        size="sm"
                        disabled={isPending}
                        onClick={() => handleModerate(listing.id, "approve")}
                        title="Approve"
                      >
                        <IconCheck className="h-4 w-4 text-green-600" />
                      </Button>
                    )}
                    {listing.status !== "rejected" && (
                      <Button
                        variant="ghost"
                        size="sm"
                        disabled={isPending}
                        onClick={() => handleModerate(listing.id, "reject")}
                        title="Reject"
                      >
                        <IconX className="h-4 w-4 text-red-600" />
                      </Button>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            ))
          )}
        </TableBody>
      </Table>
    </div>
  );
}

// ---- Campus Posts Tab ----
function CampusPostsTab({ posts }: { posts: any[] }) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  const handleModerate = (id: string, action: "hide" | "unhide" | "unflag") => {
    startTransition(async () => {
      try {
        await moderateCampusPost(id, action);
        toast.success(`Post ${action === "hide" ? "hidden" : action === "unhide" ? "restored" : "unflagged"}`);
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Failed to moderate");
      }
    });
  };

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Content</TableHead>
            <TableHead>Category</TableHead>
            <TableHead>Engagement</TableHead>
            <TableHead>Flags</TableHead>
            <TableHead className="w-28">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {posts.length === 0 ? (
            <TableRow>
              <TableCell colSpan={5} className="h-20 text-center text-muted-foreground">
                No campus posts found.
              </TableCell>
            </TableRow>
          ) : (
            posts.map((post) => (
              <TableRow
                key={post.id}
                className={post.is_hidden ? "opacity-50" : ""}
              >
                <TableCell>
                  <div className="max-w-md">
                    <div className="font-medium text-sm">
                      {post.title || "Untitled"}
                    </div>
                    <div className="text-xs text-muted-foreground line-clamp-1 mt-0.5">
                      {post.content}
                    </div>
                    <div className="text-xs text-muted-foreground mt-0.5">
                      by {post.author?.full_name || "Unknown"} - {formatDate(post.created_at)}
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary">{post.category || "general"}</Badge>
                </TableCell>
                <TableCell className="text-sm text-muted-foreground">
                  {post.likes_count || 0}L / {post.comments_count || 0}C
                </TableCell>
                <TableCell>
                  {post.is_flagged ? (
                    <Badge variant="destructive">Flagged</Badge>
                  ) : post.is_hidden ? (
                    <Badge variant="secondary">Hidden</Badge>
                  ) : (
                    <Badge variant="outline">Clean</Badge>
                  )}
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-1">
                    {post.is_hidden ? (
                      <Button
                        variant="ghost"
                        size="sm"
                        disabled={isPending}
                        onClick={() => handleModerate(post.id, "unhide")}
                        title="Restore"
                      >
                        <IconEye className="h-4 w-4 text-green-600" />
                      </Button>
                    ) : (
                      <Button
                        variant="ghost"
                        size="sm"
                        disabled={isPending}
                        onClick={() => handleModerate(post.id, "hide")}
                        title="Hide"
                      >
                        <IconEyeOff className="h-4 w-4 text-red-600" />
                      </Button>
                    )}
                    {post.is_flagged && (
                      <Button
                        variant="ghost"
                        size="sm"
                        disabled={isPending}
                        onClick={() => handleModerate(post.id, "unflag")}
                        title="Unflag"
                      >
                        <IconCheck className="h-4 w-4 text-blue-600" />
                      </Button>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            ))
          )}
        </TableBody>
      </Table>
    </div>
  );
}

// ---- Learning Resources Tab ----
function LearningTab({ resources }: { resources: any[] }) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  const handleToggle = (id: string, current: boolean) => {
    startTransition(async () => {
      try {
        await toggleContentStatus("learning_resources", id, !current);
        toast.success(`Resource ${!current ? "activated" : "deactivated"}`);
        router.refresh();
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Failed to update");
      }
    });
  };

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Title</TableHead>
            <TableHead>Type</TableHead>
            <TableHead>Category</TableHead>
            <TableHead>Views</TableHead>
            <TableHead>Status</TableHead>
            <TableHead className="w-24">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {resources.length === 0 ? (
            <TableRow>
              <TableCell colSpan={6} className="h-20 text-center text-muted-foreground">
                No learning resources found.
              </TableCell>
            </TableRow>
          ) : (
            resources.map((res) => (
              <TableRow key={res.id}>
                <TableCell>
                  <div>
                    <div className="font-medium text-sm">{res.title}</div>
                    {res.is_featured && (
                      <Badge variant="secondary" className="mt-1 bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400">
                        Featured
                      </Badge>
                    )}
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary">{res.content_type || "article"}</Badge>
                </TableCell>
                <TableCell className="text-sm text-muted-foreground">
                  {res.category || "-"}
                </TableCell>
                <TableCell className="text-sm text-muted-foreground">
                  {res.view_count || 0}
                </TableCell>
                <TableCell>
                  <Badge variant={res.is_active ? "outline" : "secondary"}>
                    {res.is_active ? "Active" : "Inactive"}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Button
                    variant="ghost"
                    size="sm"
                    disabled={isPending}
                    onClick={() => handleToggle(res.id, res.is_active)}
                  >
                    {res.is_active ? (
                      <IconToggleRight className="h-4 w-4 text-green-600" />
                    ) : (
                      <IconToggleLeft className="h-4 w-4 text-muted-foreground" />
                    )}
                  </Button>
                </TableCell>
              </TableRow>
            ))
          )}
        </TableBody>
      </Table>
    </div>
  );
}

// ---- Main Component ----
export function CrmContentControl({
  content,
}: {
  content: ContentOverview;
}) {
  const contentSummary = [
    { label: "Banners", count: content.banners.total, icon: IconPhoto, color: "text-blue-600" },
    { label: "FAQs", count: content.faqs.total, icon: IconQuestionMark, color: "text-purple-600" },
    { label: "Listings", count: content.listings.total, icon: IconShoppingCart, color: "text-green-600" },
    { label: "Campus Posts", count: content.campusPosts.total, icon: IconMessage2, color: "text-orange-600" },
    { label: "Learning", count: content.learningResources.total, icon: IconBook2, color: "text-cyan-600" },
  ];

  return (
    <div className="space-y-6">
      {/* Summary cards */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
        {contentSummary.map((item) => {
          const Icon = item.icon;
          return (
            <Card key={item.label}>
              <CardContent className="pt-4 pb-3 px-4">
                <div className="flex items-center gap-2 mb-1">
                  <Icon className={`h-4 w-4 ${item.color}`} />
                  <span className="text-sm text-muted-foreground">{item.label}</span>
                </div>
                <div className="text-xl font-bold">{item.count}</div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Tabbed content */}
      <Tabs defaultValue="banners">
        <TabsList>
          <TabsTrigger value="banners">Banners</TabsTrigger>
          <TabsTrigger value="faqs">FAQs</TabsTrigger>
          <TabsTrigger value="listings">Listings</TabsTrigger>
          <TabsTrigger value="posts">Campus Posts</TabsTrigger>
          <TabsTrigger value="learning">Learning</TabsTrigger>
        </TabsList>

        <TabsContent value="banners" className="mt-4">
          <BannersTab banners={content.banners.data} />
        </TabsContent>

        <TabsContent value="faqs" className="mt-4">
          <FaqsTab faqs={content.faqs.data} />
        </TabsContent>

        <TabsContent value="listings" className="mt-4">
          <ListingsTab listings={content.listings.data} />
        </TabsContent>

        <TabsContent value="posts" className="mt-4">
          <CampusPostsTab posts={content.campusPosts.data} />
        </TabsContent>

        <TabsContent value="learning" className="mt-4">
          <LearningTab resources={content.learningResources.data} />
        </TabsContent>
      </Tabs>
    </div>
  );
}
