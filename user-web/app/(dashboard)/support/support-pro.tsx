"use client";

import { useState, useEffect } from "react";
import {
  HelpCircle,
  MessageCircle,
  Mail,
  Ticket,
  Clock,
  CheckCircle2,
  AlertCircle,
  XCircle,
  Loader2,
  Send,
  BookOpen,
  ChevronDown,
  Search,
  Phone,
  ExternalLink,
  ChevronRight,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { toast } from "sonner";
import { formatDistanceToNow } from "date-fns";
import { createSupportTicket, getFAQs, getSupportTickets } from "@/lib/actions/data";

/**
 * FAQ interface
 */
interface FAQ {
  id: string;
  question: string;
  answer: string;
  category: string;
  is_active: boolean;
  display_order: number;
}

/**
 * Ticket status type
 */
type TicketStatus = "open" | "in_progress" | "resolved" | "closed";

/**
 * Support ticket interface
 */
interface SupportTicket {
  id: string;
  ticket_number: string;
  subject: string;
  description: string;
  category: string | null;
  status: TicketStatus;
  priority: string;
  created_at: string;
  updated_at: string;
}

/**
 * Contact form data interface
 */
interface ContactFormData {
  subject: string;
  message: string;
  category: string;
}

/**
 * Contact categories
 */
const contactCategories = [
  { value: "general", label: "General Inquiry" },
  { value: "billing", label: "Billing & Payments" },
  { value: "technical", label: "Technical Issue" },
  { value: "project", label: "Project Related" },
  { value: "account", label: "Account Issues" },
];

/**
 * Quick help action card - Minimalist
 */
function QuickHelpCard({
  icon: Icon,
  title,
  description,
  badge,
  onClick,
}: {
  icon: React.ElementType;
  title: string;
  description: string;
  badge?: string;
  onClick?: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        "flex flex-col items-start p-4 rounded-xl text-left w-full",
        "bg-card border border-border",
        "hover:border-foreground/20 transition-colors"
      )}
    >
      <div className="flex items-start justify-between w-full mb-3">
        <div className="h-9 w-9 rounded-lg bg-muted flex items-center justify-center">
          <Icon className="h-4.5 w-4.5 text-muted-foreground" />
        </div>
        {badge && (
          <span className="px-2 py-0.5 rounded text-xs font-medium bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400">
            {badge}
          </span>
        )}
      </div>
      <h3 className="text-sm font-medium text-foreground mb-0.5">{title}</h3>
      <p className="text-xs text-muted-foreground">{description}</p>
    </button>
  );
}

/**
 * Section card component - Minimalist
 */
function SectionCard({
  icon: Icon,
  title,
  description,
  children,
  className,
  headerAction,
}: {
  icon: React.ElementType;
  title: string;
  description?: string;
  children: React.ReactNode;
  className?: string;
  headerAction?: React.ReactNode;
}) {
  return (
    <div className={cn("rounded-xl border border-border bg-card overflow-hidden", className)}>
      <div className="flex items-center justify-between gap-3 p-4 border-b border-border">
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-lg bg-muted flex items-center justify-center shrink-0">
            <Icon className="h-4.5 w-4.5 text-muted-foreground" />
          </div>
          <div>
            <h3 className="text-sm font-medium text-foreground">{title}</h3>
            {description && <p className="text-xs text-muted-foreground">{description}</p>}
          </div>
        </div>
        {headerAction}
      </div>
      <div className="p-4">{children}</div>
    </div>
  );
}

/**
 * FAQ Accordion Item - Minimalist
 */
function FAQItem({
  question,
  answer,
  isOpen,
  onToggle,
}: {
  question: string;
  answer: string;
  isOpen: boolean;
  onToggle: () => void;
}) {
  return (
    <div
      className={cn(
        "rounded-xl border transition-colors",
        isOpen ? "border-foreground/20 bg-muted/30" : "border-border hover:border-foreground/10"
      )}
    >
      <button
        onClick={onToggle}
        className="flex items-center justify-between w-full p-3 text-left"
      >
        <span className="text-sm font-medium text-foreground pr-4">{question}</span>
        <ChevronDown
          className={cn(
            "h-4 w-4 text-muted-foreground transition-transform shrink-0",
            isOpen && "rotate-180"
          )}
        />
      </button>
      <div
        className={cn(
          "overflow-hidden transition-all",
          isOpen ? "max-h-96 opacity-100" : "max-h-0 opacity-0"
        )}
      >
        <div className="px-3 pb-3 text-sm text-muted-foreground leading-relaxed">
          {answer}
        </div>
      </div>
    </div>
  );
}

/**
 * Status style helper
 */
function getStatusStyle(status: TicketStatus) {
  switch (status) {
    case "open":
      return "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400";
    case "in_progress":
      return "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400";
    case "resolved":
      return "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400";
    case "closed":
      return "bg-muted text-muted-foreground";
    default:
      return "bg-muted text-muted-foreground";
  }
}

/**
 * Status icon helper
 */
function StatusIcon({ status }: { status: TicketStatus }) {
  const iconClass = "h-4 w-4";
  switch (status) {
    case "open":
      return <AlertCircle className={cn(iconClass, "text-blue-600")} />;
    case "in_progress":
      return <Clock className={cn(iconClass, "text-amber-600")} />;
    case "resolved":
      return <CheckCircle2 className={cn(iconClass, "text-emerald-600")} />;
    case "closed":
      return <XCircle className={cn(iconClass, "text-muted-foreground")} />;
    default:
      return <AlertCircle className={cn(iconClass, "text-blue-600")} />;
  }
}

/**
 * Minimalist Support Page Component
 */
export function SupportPro() {
  // FAQ State
  const [faqs, setFaqs] = useState<FAQ[]>([]);
  const [faqCategories, setFaqCategories] = useState<string[]>([]);
  const [selectedFaqCategory, setSelectedFaqCategory] = useState<string>("all");
  const [openFaqId, setOpenFaqId] = useState<string | null>(null);
  const [isFaqLoading, setIsFaqLoading] = useState(true);
  const [faqSearch, setFaqSearch] = useState("");

  // Ticket State
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [isTicketsLoading, setIsTicketsLoading] = useState(true);

  // Contact Form State
  const [form, setForm] = useState<ContactFormData>({
    subject: "",
    message: "",
    category: "general",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Fetch FAQs
  useEffect(() => {
    const fetchFAQsData = async () => {
      try {
        const data = await getFAQs();
        setFaqs(data);
        const uniqueCategories = [...new Set(data.map((f: FAQ) => f.category))];
        setFaqCategories(uniqueCategories);
      } catch {
        // Silently handle
      } finally {
        setIsFaqLoading(false);
      }
    };
    fetchFAQsData();
  }, []);

  // Fetch Tickets
  useEffect(() => {
    const fetchTicketsData = async () => {
      try {
        const data = await getSupportTickets();
        setTickets(data);
      } catch {
        // Silently handle
      } finally {
        setIsTicketsLoading(false);
      }
    };
    fetchTicketsData();
  }, []);

  // Filter FAQs
  const filteredFAQs = faqs.filter((faq) => {
    const matchesCategory = selectedFaqCategory === "all" || faq.category === selectedFaqCategory;
    const matchesSearch =
      faqSearch === "" ||
      faq.question.toLowerCase().includes(faqSearch.toLowerCase()) ||
      faq.answer.toLowerCase().includes(faqSearch.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  // Handle form submit
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!form.subject.trim() || !form.message.trim()) {
      toast.error("Please fill in all required fields");
      return;
    }

    setIsSubmitting(true);
    try {
      const result = await createSupportTicket({
        subject: form.subject,
        description: form.message,
        category: form.category,
      });

      if (result.error) {
        toast.error(result.error);
        return;
      }

      toast.success("Ticket created! We'll get back to you soon.");
      setForm({ subject: "", message: "", category: "general" });
      window.location.reload();
    } catch {
      toast.error("Failed to create ticket");
    } finally {
      setIsSubmitting(false);
    }
  };

  // Handle live chat
  const handleLiveChat = () => {
    toast.info("Live chat coming soon!");
  };

  return (
    <main className="flex-1 p-6 md:p-8 max-w-5xl mx-auto space-y-6">
      {/* Header */}
      <section className="space-y-1">
        <h1 className="text-xl font-semibold text-foreground">Help & Support</h1>
        <p className="text-sm text-muted-foreground">
          Get help from our support team or browse FAQs
        </p>
      </section>

      {/* Support Stats */}
      <section className="flex flex-wrap gap-3">
        <div className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-muted text-sm">
          <Clock className="h-3.5 w-3.5 text-muted-foreground" />
          <span className="text-muted-foreground">&lt;2hr Response</span>
        </div>
        <div className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-muted text-sm">
          <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600" />
          <span className="text-muted-foreground">98% Resolved</span>
        </div>
      </section>

      {/* Quick Help Actions */}
      <section className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
        <QuickHelpCard
          icon={MessageCircle}
          title="Live Chat"
          description="Chat with support now"
          badge="Online"
          onClick={handleLiveChat}
        />
        <QuickHelpCard
          icon={Mail}
          title="Email Support"
          description="Get help via email"
          onClick={() => window.location.href = "mailto:support@assignx.in"}
        />
        <QuickHelpCard
          icon={BookOpen}
          title="Knowledge Base"
          description="Browse help articles"
          onClick={() => toast.info("Knowledge base coming soon!")}
        />
        <QuickHelpCard
          icon={Phone}
          title="Schedule Call"
          description="Book a callback"
          onClick={() => toast.info("Call scheduling coming soon!")}
        />
      </section>

      {/* Main Content Grid */}
      <div className="grid gap-6 lg:grid-cols-2">
        {/* FAQ Section */}
        <SectionCard
          icon={HelpCircle}
          title="Frequently Asked Questions"
          description="Find quick answers"
          className="lg:row-span-2"
          headerAction={
            <div className="relative">
              <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground" />
              <Input
                placeholder="Search..."
                value={faqSearch}
                onChange={(e) => setFaqSearch(e.target.value)}
                className="pl-8 h-8 w-32 text-sm"
              />
            </div>
          }
        >
          {isFaqLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />
            </div>
          ) : faqs.length === 0 ? (
            <div className="text-center py-12">
              <div className="h-10 w-10 rounded-lg bg-muted flex items-center justify-center mx-auto mb-3">
                <HelpCircle className="h-5 w-5 text-muted-foreground" />
              </div>
              <p className="text-sm text-muted-foreground">No FAQs available yet</p>
            </div>
          ) : (
            <div className="space-y-4">
              {/* Category Filter */}
              <div className="flex flex-wrap gap-2">
                <button
                  onClick={() => setSelectedFaqCategory("all")}
                  className={cn(
                    "px-2.5 py-1 rounded-lg text-xs font-medium transition-colors",
                    selectedFaqCategory === "all"
                      ? "bg-foreground text-background"
                      : "bg-muted text-muted-foreground hover:bg-muted/80"
                  )}
                >
                  All
                </button>
                {faqCategories.map((cat) => (
                  <button
                    key={cat}
                    onClick={() => setSelectedFaqCategory(cat)}
                    className={cn(
                      "px-2.5 py-1 rounded-lg text-xs font-medium capitalize transition-colors",
                      selectedFaqCategory === cat
                        ? "bg-foreground text-background"
                        : "bg-muted text-muted-foreground hover:bg-muted/80"
                    )}
                  >
                    {cat}
                  </button>
                ))}
              </div>

              {/* FAQ List */}
              <div className="space-y-2">
                {filteredFAQs.length === 0 ? (
                  <p className="text-center py-8 text-sm text-muted-foreground">
                    No FAQs match your search
                  </p>
                ) : (
                  filteredFAQs.map((faq) => (
                    <FAQItem
                      key={faq.id}
                      question={faq.question}
                      answer={faq.answer}
                      isOpen={openFaqId === faq.id}
                      onToggle={() => setOpenFaqId(openFaqId === faq.id ? null : faq.id)}
                    />
                  ))
                )}
              </div>
            </div>
          )}
        </SectionCard>

        {/* Contact Form */}
        <SectionCard
          icon={Mail}
          title="Create Support Ticket"
          description="We'll respond within 24 hours"
        >
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Category Selection */}
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-muted-foreground">Category</label>
              <Select
                value={form.category}
                onValueChange={(v) => setForm((p) => ({ ...p, category: v }))}
              >
                <SelectTrigger className="h-9">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {contactCategories.map((cat) => (
                    <SelectItem key={cat.value} value={cat.value}>
                      {cat.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Subject */}
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-muted-foreground">
                Subject <span className="text-red-500">*</span>
              </label>
              <Input
                value={form.subject}
                onChange={(e) => setForm((p) => ({ ...p, subject: e.target.value }))}
                placeholder="Brief summary of your issue"
                className="h-9"
              />
            </div>

            {/* Message */}
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-muted-foreground">
                Message <span className="text-red-500">*</span>
              </label>
              <Textarea
                value={form.message}
                onChange={(e) => setForm((p) => ({ ...p, message: e.target.value }))}
                placeholder="Describe your issue in detail..."
                rows={4}
                className="resize-none text-sm"
              />
            </div>

            {/* Submit */}
            <Button type="submit" disabled={isSubmitting} className="w-full h-9 gap-2">
              {isSubmitting ? (
                <>
                  <Loader2 className="h-3.5 w-3.5 animate-spin" />
                  Creating...
                </>
              ) : (
                <>
                  <Send className="h-3.5 w-3.5" />
                  Create Ticket
                </>
              )}
            </Button>
          </form>
        </SectionCard>

        {/* Ticket History */}
        <SectionCard
          icon={Ticket}
          title="Your Tickets"
          description="Track your support requests"
        >
          {isTicketsLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />
            </div>
          ) : tickets.length === 0 ? (
            <div className="text-center py-12">
              <div className="h-10 w-10 rounded-lg bg-muted flex items-center justify-center mx-auto mb-3">
                <Ticket className="h-5 w-5 text-muted-foreground" />
              </div>
              <p className="text-sm text-muted-foreground">No tickets yet</p>
            </div>
          ) : (
            <div className="space-y-2">
              {tickets.slice(0, 5).map((ticket) => (
                <div
                  key={ticket.id}
                  className={cn(
                    "p-3 rounded-xl border border-border",
                    "hover:border-foreground/20 transition-colors cursor-pointer group"
                  )}
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-start gap-3 min-w-0">
                      <div className="h-8 w-8 rounded-lg bg-muted flex items-center justify-center shrink-0">
                        <StatusIcon status={ticket.status} />
                      </div>
                      <div className="min-w-0">
                        <p className="text-sm font-medium text-foreground truncate">
                          {ticket.subject}
                        </p>
                        <p className="text-xs text-muted-foreground mt-0.5">
                          #{ticket.ticket_number} · {ticket.category || "General"}
                        </p>
                        <p className="text-xs text-muted-foreground mt-0.5">
                          {formatDistanceToNow(new Date(ticket.updated_at), { addSuffix: true })}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      <span
                        className={cn(
                          "px-2 py-0.5 rounded text-xs font-medium capitalize",
                          getStatusStyle(ticket.status)
                        )}
                      >
                        {ticket.status.replace("_", " ")}
                      </span>
                      <ChevronRight className="h-4 w-4 text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity" />
                    </div>
                  </div>
                </div>
              ))}

              {tickets.length > 5 && (
                <Button variant="outline" size="sm" className="w-full gap-2 h-8">
                  <ExternalLink className="h-3.5 w-3.5" />
                  View All {tickets.length} Tickets
                </Button>
              )}
            </div>
          )}
        </SectionCard>
      </div>
    </main>
  );
}
