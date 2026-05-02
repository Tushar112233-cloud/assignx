"use client";

import { useEffect, useState, useCallback } from "react";
import Link from "next/link";
import { toast } from "sonner";
import {
  IconPlus,
  IconEdit,
  IconTrash,
  IconToggleLeft,
  IconToggleRight,
  IconExternalLink,
  IconFileText,
  IconCheck,
  IconX,
  IconStar,
  IconEye,
} from "@tabler/icons-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  getInvestors,
  createInvestor,
  updateInvestor,
  toggleInvestorActive,
  deactivateInvestor,
  getPitchDecks,
  updatePitchDeckStatus,
  type AdminInvestor,
  type AdminPitchDeck,
} from "@/lib/admin/actions/investors";

const FUNDING_STAGE_OPTIONS = [
  { value: "pre-seed", label: "Pre-seed" },
  { value: "seed", label: "Seed" },
  { value: "series-a", label: "Series A" },
  { value: "series-b", label: "Series B" },
  { value: "series-c", label: "Series C" },
  { value: "growth", label: "Growth" },
];

const SECTOR_OPTIONS = [
  "Tech", "Fintech", "Healthcare", "EdTech", "SaaS",
  "D2C", "AI/ML", "Web3", "Enterprise", "Sustainability",
];

const PITCH_STATUS_OPTIONS = [
  { value: "pending", label: "Pending" },
  { value: "reviewed", label: "Reviewed" },
  { value: "shortlisted", label: "Shortlisted" },
  { value: "rejected", label: "Rejected" },
];

const statusColors: Record<string, string> = {
  pending: "text-yellow-600 border-yellow-200 bg-yellow-50 dark:bg-yellow-900/20",
  reviewed: "text-blue-600 border-blue-200 bg-blue-50 dark:bg-blue-900/20",
  shortlisted: "text-green-600 border-green-200 bg-green-50 dark:bg-green-900/20",
  rejected: "text-red-600 border-red-200 bg-red-50 dark:bg-red-900/20",
};

function formatDate(dateStr: string): string {
  if (!dateStr) return "N/A";
  return new Date(dateStr).toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

/** Multi-select toggle for funding stages and sectors */
function MultiSelectToggle({
  options,
  selected,
  onToggle,
}: {
  options: { value: string; label: string }[] | string[];
  selected: string[];
  onToggle: (value: string) => void;
}) {
  return (
    <div className="flex flex-wrap gap-1.5">
      {options.map((opt) => {
        const value = typeof opt === "string" ? opt : opt.value;
        const label = typeof opt === "string" ? opt : opt.label;
        const isSelected = selected.includes(value);
        return (
          <button
            key={value}
            type="button"
            onClick={() => onToggle(value)}
            className={`px-2.5 py-1 rounded-md text-xs font-medium border transition-colors ${
              isSelected
                ? "bg-primary text-primary-foreground border-primary"
                : "bg-muted/50 text-muted-foreground border-border/40 hover:bg-muted"
            }`}
          >
            {label}
          </button>
        );
      })}
    </div>
  );
}

/** Investor form modal for create/edit */
function InvestorFormDialog({
  open,
  onClose,
  onSaved,
  investor,
}: {
  open: boolean;
  onClose: () => void;
  onSaved: () => void;
  investor?: AdminInvestor | null;
}) {
  const [name, setName] = useState("");
  const [firm, setFirm] = useState("");
  const [bio, setBio] = useState("");
  const [fundingStages, setFundingStages] = useState<string[]>([]);
  const [sectors, setSectors] = useState<string[]>([]);
  const [ticketMin, setTicketMin] = useState("");
  const [ticketMax, setTicketMax] = useState("");
  const [ticketCurrency, setTicketCurrency] = useState("USD");
  const [dealCount, setDealCount] = useState("");
  const [linkedinUrl, setLinkedinUrl] = useState("");
  const [websiteUrl, setWebsiteUrl] = useState("");
  const [contactEmail, setContactEmail] = useState("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (investor) {
      setName(investor.name);
      setFirm(investor.firm);
      setBio(investor.bio);
      setFundingStages(investor.funding_stages);
      setSectors(investor.sectors);
      setTicketMin(investor.ticket_size?.min?.toString() || "");
      setTicketMax(investor.ticket_size?.max?.toString() || "");
      setTicketCurrency(investor.ticket_size?.currency || "USD");
      setDealCount(investor.deal_count?.toString() || "");
      setLinkedinUrl(investor.linkedin_url || "");
      setWebsiteUrl(investor.website_url || "");
      setContactEmail(investor.contact_email || "");
    } else {
      setName("");
      setFirm("");
      setBio("");
      setFundingStages([]);
      setSectors([]);
      setTicketMin("");
      setTicketMax("");
      setTicketCurrency("USD");
      setDealCount("");
      setLinkedinUrl("");
      setWebsiteUrl("");
      setContactEmail("");
    }
  }, [investor, open]);

  const toggleStage = (stage: string) => {
    setFundingStages((prev) =>
      prev.includes(stage) ? prev.filter((s) => s !== stage) : [...prev, stage]
    );
  };

  const toggleSector = (sector: string) => {
    setSectors((prev) =>
      prev.includes(sector) ? prev.filter((s) => s !== sector) : [...prev, sector]
    );
  };

  const handleSave = async () => {
    if (!name.trim() || !firm.trim() || !bio.trim()) {
      toast.error("Name, firm, and bio are required");
      return;
    }
    if (fundingStages.length === 0) {
      toast.error("Select at least one funding stage");
      return;
    }
    if (sectors.length === 0) {
      toast.error("Select at least one sector");
      return;
    }

    setSaving(true);
    try {
      const ticketSize =
        ticketMin && ticketMax
          ? { min: Number(ticketMin), max: Number(ticketMax), currency: ticketCurrency }
          : undefined;

      if (investor) {
        await updateInvestor(investor.id, {
          name: name.trim(),
          firm: firm.trim(),
          bio: bio.trim(),
          fundingStages,
          sectors,
          ticketSize,
          dealCount: dealCount ? Number(dealCount) : 0,
          linkedinUrl: linkedinUrl.trim() || undefined,
          websiteUrl: websiteUrl.trim() || undefined,
          contactEmail: contactEmail.trim() || undefined,
        });
        toast.success("Investor updated");
      } else {
        await createInvestor({
          name: name.trim(),
          firm: firm.trim(),
          bio: bio.trim(),
          fundingStages,
          sectors,
          ticketSize,
          dealCount: dealCount ? Number(dealCount) : 0,
          linkedinUrl: linkedinUrl.trim() || undefined,
          websiteUrl: websiteUrl.trim() || undefined,
          contactEmail: contactEmail.trim() || undefined,
        });
        toast.success("Investor created");
      }
      onSaved();
      onClose();
    } catch (err: any) {
      toast.error(err.message || "Failed to save investor");
    } finally {
      setSaving(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={(v) => !v && onClose()}>
      <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{investor ? "Edit Investor" : "Add New Investor"}</DialogTitle>
        </DialogHeader>
        <div className="space-y-4 py-2">
          <div className="grid grid-cols-2 gap-3">
            <div>
              <Label className="text-xs">Name *</Label>
              <Input value={name} onChange={(e) => setName(e.target.value)} placeholder="John Doe" />
            </div>
            <div>
              <Label className="text-xs">Firm *</Label>
              <Input value={firm} onChange={(e) => setFirm(e.target.value)} placeholder="Sequoia Capital" />
            </div>
          </div>

          <div>
            <Label className="text-xs">Bio *</Label>
            <Textarea value={bio} onChange={(e) => setBio(e.target.value)} placeholder="Brief investor bio..." rows={3} />
          </div>

          <div>
            <Label className="text-xs mb-1.5 block">Funding Stages *</Label>
            <MultiSelectToggle options={FUNDING_STAGE_OPTIONS} selected={fundingStages} onToggle={toggleStage} />
          </div>

          <div>
            <Label className="text-xs mb-1.5 block">Sectors *</Label>
            <MultiSelectToggle
              options={SECTOR_OPTIONS.map((s) => ({ value: s, label: s }))}
              selected={sectors}
              onToggle={toggleSector}
            />
          </div>

          <div>
            <Label className="text-xs mb-1.5 block">Ticket Size Range</Label>
            <div className="flex items-center gap-2">
              <Select value={ticketCurrency} onValueChange={setTicketCurrency}>
                <SelectTrigger className="w-20">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="USD">USD</SelectItem>
                  <SelectItem value="INR">INR</SelectItem>
                </SelectContent>
              </Select>
              <Input value={ticketMin} onChange={(e) => setTicketMin(e.target.value)} placeholder="Min" type="number" className="flex-1" />
              <span className="text-muted-foreground">-</span>
              <Input value={ticketMax} onChange={(e) => setTicketMax(e.target.value)} placeholder="Max" type="number" className="flex-1" />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <Label className="text-xs">Deal Count</Label>
              <Input value={dealCount} onChange={(e) => setDealCount(e.target.value)} placeholder="0" type="number" />
            </div>
            <div>
              <Label className="text-xs">Contact Email</Label>
              <Input value={contactEmail} onChange={(e) => setContactEmail(e.target.value)} placeholder="email@firm.com" type="email" />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <Label className="text-xs">LinkedIn URL</Label>
              <Input value={linkedinUrl} onChange={(e) => setLinkedinUrl(e.target.value)} placeholder="https://linkedin.com/in/..." />
            </div>
            <div>
              <Label className="text-xs">Website URL</Label>
              <Input value={websiteUrl} onChange={(e) => setWebsiteUrl(e.target.value)} placeholder="https://..." />
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose} disabled={saving}>Cancel</Button>
          <Button onClick={handleSave} disabled={saving}>
            {saving ? "Saving..." : investor ? "Update" : "Create"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

/** Pitch deck feedback dialog */
function PitchDeckStatusDialog({
  open,
  onClose,
  onSaved,
  deck,
}: {
  open: boolean;
  onClose: () => void;
  onSaved: () => void;
  deck: AdminPitchDeck | null;
}) {
  const [status, setStatus] = useState("pending");
  const [feedback, setFeedback] = useState("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (deck) {
      setStatus(deck.status);
      setFeedback(deck.feedback || "");
    }
  }, [deck]);

  const handleSave = async () => {
    if (!deck) return;
    setSaving(true);
    try {
      await updatePitchDeckStatus(deck.id, status, feedback.trim() || undefined);
      toast.success("Pitch deck status updated");
      onSaved();
      onClose();
    } catch (err: any) {
      toast.error(err.message || "Failed to update status");
    } finally {
      setSaving(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={(v) => !v && onClose()}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>Review Pitch Deck</DialogTitle>
        </DialogHeader>
        {deck && (
          <div className="space-y-4 py-2">
            <div>
              <p className="text-sm font-medium">{deck.title}</p>
              <p className="text-xs text-muted-foreground">Submitted {formatDate(deck.created_at)}</p>
              {deck.file_url && (
                <a
                  href={deck.file_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-xs text-primary hover:underline flex items-center gap-1 mt-1"
                >
                  <IconExternalLink className="h-3 w-3" /> View File
                </a>
              )}
            </div>

            <div>
              <Label className="text-xs">Status</Label>
              <Select value={status} onValueChange={setStatus}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {PITCH_STATUS_OPTIONS.map((opt) => (
                    <SelectItem key={opt.value} value={opt.value}>{opt.label}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label className="text-xs">Feedback</Label>
              <Textarea value={feedback} onChange={(e) => setFeedback(e.target.value)} placeholder="Add feedback for the user..." rows={3} />
            </div>
          </div>
        )}
        <DialogFooter>
          <Button variant="outline" onClick={onClose} disabled={saving}>Cancel</Button>
          <Button onClick={handleSave} disabled={saving}>
            {saving ? "Saving..." : "Update Status"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

export default function InvestorsPage() {
  const [investors, setInvestors] = useState<AdminInvestor[]>([]);
  const [pitchDecks, setPitchDecks] = useState<AdminPitchDeck[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  // Dialogs
  const [formOpen, setFormOpen] = useState(false);
  const [editingInvestor, setEditingInvestor] = useState<AdminInvestor | null>(null);
  const [deckDialogOpen, setDeckDialogOpen] = useState(false);
  const [reviewingDeck, setReviewingDeck] = useState<AdminPitchDeck | null>(null);

  const loadInvestors = useCallback(async () => {
    const result = await getInvestors({ perPage: 100, search: search || undefined });
    setInvestors(result.data);
  }, [search]);

  const loadDecks = useCallback(async () => {
    const result = await getPitchDecks({ perPage: 100 });
    setPitchDecks(result.data);
  }, []);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      await Promise.all([loadInvestors(), loadDecks()]);
      setLoading(false);
    };
    load();
  }, [loadInvestors, loadDecks]);

  const handleToggleActive = async (inv: AdminInvestor) => {
    try {
      await toggleInvestorActive(inv.id, !inv.is_active);
      toast.success(inv.is_active ? "Investor deactivated" : "Investor activated");
      loadInvestors();
    } catch (err: any) {
      toast.error(err.message || "Failed to toggle status");
    }
  };

  const handleDelete = async (inv: AdminInvestor) => {
    try {
      await deactivateInvestor(inv.id);
      toast.success("Investor deactivated");
      loadInvestors();
    } catch (err: any) {
      toast.error(err.message || "Failed to deactivate");
    }
  };

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">Investors</h1>
        <p className="text-muted-foreground">Manage investors and review pitch decks</p>
      </div>

      <div className="px-4 lg:px-6">
        <Tabs defaultValue="investors">
          <TabsList>
            <TabsTrigger value="investors">Investors ({investors.length})</TabsTrigger>
            <TabsTrigger value="pitch-decks">Pitch Decks ({pitchDecks.length})</TabsTrigger>
          </TabsList>

          {/* Investors Tab */}
          <TabsContent value="investors" className="space-y-4 mt-4">
            <div className="flex items-center gap-3">
              <Input
                placeholder="Search investors..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="max-w-sm"
              />
              <Button onClick={() => { setEditingInvestor(null); setFormOpen(true); }}>
                <IconPlus className="h-4 w-4 mr-1" />
                Add Investor
              </Button>
            </div>

            {loading ? (
              <p className="text-sm text-muted-foreground py-8 text-center">Loading investors...</p>
            ) : investors.length === 0 ? (
              <p className="text-sm text-muted-foreground py-8 text-center">No investors found</p>
            ) : (
              <div className="border rounded-lg overflow-hidden">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Name</TableHead>
                      <TableHead>Firm</TableHead>
                      <TableHead>Stages</TableHead>
                      <TableHead>Sectors</TableHead>
                      <TableHead>Deals</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead className="w-12"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {investors.map((inv) => (
                      <TableRow key={inv.id}>
                        <TableCell className="font-medium">
                          <Link href={`/investors/${inv.id}`} className="hover:text-primary transition-colors">
                            {inv.name}
                          </Link>
                        </TableCell>
                        <TableCell className="text-muted-foreground">{inv.firm}</TableCell>
                        <TableCell>
                          <div className="flex flex-wrap gap-1">
                            {inv.funding_stages.slice(0, 2).map((s) => (
                              <Badge key={s} variant="outline" className="text-[10px] capitalize">{s}</Badge>
                            ))}
                            {inv.funding_stages.length > 2 && (
                              <Badge variant="outline" className="text-[10px]">+{inv.funding_stages.length - 2}</Badge>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="flex flex-wrap gap-1">
                            {inv.sectors.slice(0, 2).map((s) => (
                              <Badge key={s} variant="secondary" className="text-[10px]">{s}</Badge>
                            ))}
                            {inv.sectors.length > 2 && (
                              <Badge variant="secondary" className="text-[10px]">+{inv.sectors.length - 2}</Badge>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>{inv.deal_count}</TableCell>
                        <TableCell>
                          <Badge variant={inv.is_active ? "default" : "secondary"} className="text-[10px]">
                            {inv.is_active ? "Active" : "Inactive"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon" className="h-8 w-8">
                                <IconEdit className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuItem onClick={() => { setEditingInvestor(inv); setFormOpen(true); }}>
                                <IconEdit className="h-4 w-4 mr-2" />
                                Edit
                              </DropdownMenuItem>
                              <DropdownMenuItem onClick={() => handleToggleActive(inv)}>
                                {inv.is_active ? (
                                  <><IconToggleLeft className="h-4 w-4 mr-2" />Deactivate</>
                                ) : (
                                  <><IconToggleRight className="h-4 w-4 mr-2" />Activate</>
                                )}
                              </DropdownMenuItem>
                              <DropdownMenuSeparator />
                              <DropdownMenuItem className="text-red-600" onClick={() => handleDelete(inv)}>
                                <IconTrash className="h-4 w-4 mr-2" />
                                Delete
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            )}
          </TabsContent>

          {/* Pitch Decks Tab */}
          <TabsContent value="pitch-decks" className="space-y-4 mt-4">
            {loading ? (
              <p className="text-sm text-muted-foreground py-8 text-center">Loading pitch decks...</p>
            ) : pitchDecks.length === 0 ? (
              <p className="text-sm text-muted-foreground py-8 text-center">No pitch decks submitted yet</p>
            ) : (
              <div className="border rounded-lg overflow-hidden">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Title</TableHead>
                      <TableHead>Submitted</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Feedback</TableHead>
                      <TableHead>File</TableHead>
                      <TableHead className="w-12"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {pitchDecks.map((deck) => (
                      <TableRow key={deck.id}>
                        <TableCell className="font-medium">
                          {deck.title}
                          {deck.description && (
                            <p className="text-[10px] text-muted-foreground truncate max-w-xs">{deck.description}</p>
                          )}
                        </TableCell>
                        <TableCell className="text-muted-foreground text-xs">{formatDate(deck.created_at)}</TableCell>
                        <TableCell>
                          <Badge variant="outline" className={`text-[10px] capitalize ${statusColors[deck.status] || ""}`}>
                            {deck.status}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-xs text-muted-foreground max-w-xs truncate">
                          {deck.feedback || "-"}
                        </TableCell>
                        <TableCell>
                          {deck.file_url && (
                            <a
                              href={deck.file_url}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="text-primary hover:underline text-xs flex items-center gap-1"
                            >
                              <IconExternalLink className="h-3 w-3" />
                              View
                            </a>
                          )}
                        </TableCell>
                        <TableCell>
                          <Button
                            variant="ghost"
                            size="icon"
                            className="h-8 w-8"
                            onClick={() => {
                              setReviewingDeck(deck);
                              setDeckDialogOpen(true);
                            }}
                          >
                            <IconEye className="h-4 w-4" />
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            )}
          </TabsContent>
        </Tabs>
      </div>

      {/* Investor Form Dialog */}
      <InvestorFormDialog
        open={formOpen}
        onClose={() => { setFormOpen(false); setEditingInvestor(null); }}
        onSaved={loadInvestors}
        investor={editingInvestor}
      />

      {/* Pitch Deck Review Dialog */}
      <PitchDeckStatusDialog
        open={deckDialogOpen}
        onClose={() => { setDeckDialogOpen(false); setReviewingDeck(null); }}
        onSaved={loadDecks}
        deck={reviewingDeck}
      />
    </div>
  );
}
