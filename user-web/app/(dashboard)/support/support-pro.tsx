"use client";

/**
 * Support Pro - Glassmorphic Design System
 * Matches dashboard bento grid style with warm blue accent
 * Coffee bean palette with glassmorphic cards
 */

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
  ChevronRight,
  ClipboardList,
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
 * Contact categories for ticket creation
 */
const contactCategories = [
  { value: "general", label: "General Inquiry" },
  { value: "technical", label: "Technical Issue" },
  { value: "billing", label: "Billing & Payments" },
  { value: "feature", label: "Feature Request" },
];

/**
 * Glassmorphic card base classes - shared across all cards
 */
const GLASS_CARD =
  "bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 rounded-[20px] shadow-sm";

const GLASS_CARD_HOVER =
  "hover:shadow-xl hover:shadow-black/5 transition-all duration-300";

/**
 * FAQ Accordion Item with glassmorphic styling
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
        "rounded-2xl border transition-all duration-300",
        isOpen
          ? "border-blue-200 dark:border-blue-500/20 bg-blue-50/50 dark:bg-blue-900/10"
          : "border-white/40 dark:border-white/10 hover:border-blue-100 dark:hover:border-blue-500/10"
      )}
    >
      <button
        onClick={onToggle}
        className="flex items-center justify-between w-full p-4 text-left"
      >
        <span className="text-sm font-medium text-foreground pr-4">{question}</span>
        <ChevronDown
          className={cn(
            "h-4 w-4 text-muted-foreground transition-transform duration-300 shrink-0",
            isOpen && "rotate-180 text-blue-500"
          )}
        />
      </button>
      <div
        className={cn(
          "overflow-hidden transition-all duration-300",
          isOpen ? "max-h-96 opacity-100" : "max-h-0 opacity-0"
        )}
      >
        <div className="px-4 pb-4 text-sm text-muted-foreground leading-relaxed">
          {answer}
        </div>
      </div>
    </div>
  );
}

/**
 * Status style helper for ticket badges
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
 * Status icon for ticket display
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
 * Glassmorphic Support Page Component
 * Matches dashboard bento grid design with warm blue accent
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
        const uniqueCategories = [...new Set(data.map((f: FAQ) => f.category))] as string[];
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
    <main className="flex-1 p-4 md:p-6 lg:p-8 max-w-6xl mx-auto space-y-8">
      {/* ====== HERO SECTION ====== */}
      <section className="text-center space-y-4 pt-4 md:pt-8">
        <h1 className="text-3xl md:text-4xl lg:text-5xl font-light tracking-tight text-foreground/90">
          How can we{" "}
          <span className="font-semibold text-blue-500">help</span>?
        </h1>
        <p className="text-base md:text-lg text-muted-foreground max-w-md mx-auto">
          Get help from our support team or browse FAQs
        </p>
      </section>

      {/* ====== STATS PILLS ====== */}
      <section className="flex flex-wrap items-center justify-center gap-3">
        <div
          className={cn(
            "flex items-center gap-2 px-4 py-2 rounded-full",
            GLASS_CARD
          )}
        >
          <Clock className="h-4 w-4 text-blue-500" />
          <span className="text-sm font-medium text-foreground">&lt;2hr Response</span>
        </div>
        <div
          className={cn(
            "flex items-center gap-2 px-4 py-2 rounded-full",
            GLASS_CARD
          )}
        >
          <CheckCircle2 className="h-4 w-4 text-emerald-500" />
          <span className="text-sm font-medium text-foreground">98% Resolved</span>
        </div>
      </section>

      {/* ====== SUPPORT OPTIONS - 2x2 BENTO GRID ====== */}
      <section className="grid grid-cols-2 md:grid-cols-4 gap-3 lg:gap-4">
        {/* Live Chat */}
        <button
          onClick={handleLiveChat}
          className={cn(
            "group relative overflow-hidden p-5 lg:p-6 text-left",
            GLASS_CARD,
            GLASS_CARD_HOVER,
            "hover:-translate-y-1 hover:bg-white/90 dark:hover:bg-white/10"
          )}
        >
          <div className="absolute inset-0 bg-gradient-to-br from-blue-100/30 to-cyan-50/10 dark:from-blue-900/10 dark:to-transparent pointer-events-none rounded-[20px]" />
          <div className="relative z-10">
            <div className="flex items-start justify-between mb-4">
              <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-blue-400 to-cyan-500 flex items-center justify-center shadow-lg shadow-blue-500/20">
                <MessageCircle className="h-5 w-5 text-white" strokeWidth={1.5} />
              </div>
              <span className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-emerald-100/80 dark:bg-emerald-900/40">
                <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                <span className="text-[10px] font-medium text-emerald-700 dark:text-emerald-300">Online</span>
              </span>
            </div>
            <h3 className="font-semibold text-foreground text-[15px] mb-0.5">Live Chat</h3>
            <p className="text-xs text-muted-foreground/80">Chat with support now</p>
          </div>
          <ChevronRight className="absolute bottom-4 right-4 h-4 w-4 text-muted-foreground/40 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0.5" />
        </button>

        {/* Email Support */}
        <button
          onClick={() => (window.location.href = "mailto:support@assignx.in")}
          className={cn(
            "group relative overflow-hidden p-5 lg:p-6 text-left",
            GLASS_CARD,
            GLASS_CARD_HOVER,
            "hover:-translate-y-1 hover:bg-white/90 dark:hover:bg-white/10"
          )}
        >
          <div className="absolute inset-0 bg-gradient-to-br from-violet-100/30 to-purple-50/10 dark:from-violet-900/10 dark:to-transparent pointer-events-none rounded-[20px]" />
          <div className="relative z-10">
            <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-violet-400 to-purple-500 flex items-center justify-center mb-4 shadow-lg shadow-violet-500/20">
              <Mail className="h-5 w-5 text-white" strokeWidth={1.5} />
            </div>
            <h3 className="font-semibold text-foreground text-[15px] mb-0.5">Email Support</h3>
            <p className="text-xs text-muted-foreground/80">Get help via email</p>
          </div>
          <ChevronRight className="absolute bottom-4 right-4 h-4 w-4 text-muted-foreground/40 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0.5" />
        </button>

        {/* Knowledge Base */}
        <button
          onClick={() => toast.info("Knowledge base coming soon!")}
          className={cn(
            "group relative overflow-hidden p-5 lg:p-6 text-left",
            GLASS_CARD,
            GLASS_CARD_HOVER,
            "hover:-translate-y-1 hover:bg-white/90 dark:hover:bg-white/10"
          )}
        >
          <div className="absolute inset-0 bg-gradient-to-br from-amber-100/30 to-orange-50/10 dark:from-amber-900/10 dark:to-transparent pointer-events-none rounded-[20px]" />
          <div className="relative z-10">
            <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center mb-4 shadow-lg shadow-amber-500/20">
              <BookOpen className="h-5 w-5 text-white" strokeWidth={1.5} />
            </div>
            <h3 className="font-semibold text-foreground text-[15px] mb-0.5">Knowledge Base</h3>
            <p className="text-xs text-muted-foreground/80">Browse help articles</p>
          </div>
          <ChevronRight className="absolute bottom-4 right-4 h-4 w-4 text-muted-foreground/40 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0.5" />
        </button>

        {/* Schedule Call */}
        <button
          onClick={() => toast.info("Call scheduling coming soon!")}
          className={cn(
            "group relative overflow-hidden p-5 lg:p-6 text-left",
            GLASS_CARD,
            GLASS_CARD_HOVER,
            "hover:-translate-y-1 hover:bg-white/90 dark:hover:bg-white/10"
          )}
        >
          <div className="absolute inset-0 bg-gradient-to-br from-emerald-100/30 to-teal-50/10 dark:from-emerald-900/10 dark:to-transparent pointer-events-none rounded-[20px]" />
          <div className="relative z-10">
            <div className="h-11 w-11 rounded-2xl bg-gradient-to-br from-emerald-400 to-teal-500 flex items-center justify-center mb-4 shadow-lg shadow-emerald-500/20">
              <Phone className="h-5 w-5 text-white" strokeWidth={1.5} />
            </div>
            <h3 className="font-semibold text-foreground text-[15px] mb-0.5">Schedule Call</h3>
            <p className="text-xs text-muted-foreground/80">Book a callback</p>
          </div>
          <ChevronRight className="absolute bottom-4 right-4 h-4 w-4 text-muted-foreground/40 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0.5" />
        </button>
      </section>

      {/* ====== FAQ + TICKET FORM - TWO COLUMN LAYOUT ====== */}
      <section className="grid gap-4 lg:gap-6 lg:grid-cols-2">
        {/* LEFT: FAQ Accordion */}
        <div className={cn(GLASS_CARD, "overflow-hidden")}>
          {/* Header */}
          <div className="flex items-center justify-between gap-3 p-5 border-b border-white/30 dark:border-white/10">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-2xl bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center shadow-lg shadow-blue-500/20">
                <HelpCircle className="h-5 w-5 text-white" strokeWidth={1.5} />
              </div>
              <div>
                <h3 className="text-sm font-semibold text-foreground">Frequently Asked Questions</h3>
                <p className="text-xs text-muted-foreground">Find quick answers</p>
              </div>
            </div>
          </div>

          {/* Search bar */}
          <div className="px-5 pt-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search FAQs..."
                value={faqSearch}
                onChange={(e) => setFaqSearch(e.target.value)}
                className="pl-10 h-10 rounded-xl bg-white/50 dark:bg-white/5 border-white/40 dark:border-white/10 focus:border-blue-300 dark:focus:border-blue-500/30"
              />
            </div>
          </div>

          {/* FAQ Content */}
          <div className="p-5">
            {isFaqLoading ? (
              <div className="flex items-center justify-center py-12">
                <Loader2 className="h-5 w-5 animate-spin text-blue-500" />
              </div>
            ) : faqs.length === 0 ? (
              <div className="text-center py-12">
                <div className="h-12 w-12 rounded-2xl bg-gradient-to-br from-blue-100 to-blue-50 dark:from-blue-900/20 dark:to-blue-800/10 flex items-center justify-center mx-auto mb-3">
                  <HelpCircle className="h-6 w-6 text-blue-400" />
                </div>
                <p className="text-sm font-medium text-muted-foreground">No FAQs available yet</p>
                <p className="text-xs text-muted-foreground/70 mt-1">Check back soon for answers to common questions</p>
              </div>
            ) : (
              <div className="space-y-4">
                {/* Category Filter */}
                <div className="flex flex-wrap gap-2">
                  <button
                    onClick={() => setSelectedFaqCategory("all")}
                    className={cn(
                      "px-3 py-1.5 rounded-full text-xs font-medium transition-all duration-200",
                      selectedFaqCategory === "all"
                        ? "bg-blue-500 text-white shadow-md shadow-blue-500/25"
                        : "bg-white/50 dark:bg-white/5 text-muted-foreground hover:bg-white/80 dark:hover:bg-white/10 border border-white/40 dark:border-white/10"
                    )}
                  >
                    All
                  </button>
                  {faqCategories.map((cat) => (
                    <button
                      key={cat}
                      onClick={() => setSelectedFaqCategory(cat)}
                      className={cn(
                        "px-3 py-1.5 rounded-full text-xs font-medium capitalize transition-all duration-200",
                        selectedFaqCategory === cat
                          ? "bg-blue-500 text-white shadow-md shadow-blue-500/25"
                          : "bg-white/50 dark:bg-white/5 text-muted-foreground hover:bg-white/80 dark:hover:bg-white/10 border border-white/40 dark:border-white/10"
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
          </div>
        </div>

        {/* RIGHT: Create Support Ticket */}
        <div className={cn(GLASS_CARD, "overflow-hidden")}>
          {/* Header */}
          <div className="flex items-center gap-3 p-5 border-b border-white/30 dark:border-white/10">
            <div className="h-10 w-10 rounded-2xl bg-gradient-to-br from-blue-400 to-indigo-500 flex items-center justify-center shadow-lg shadow-blue-500/20">
              <Send className="h-5 w-5 text-white" strokeWidth={1.5} />
            </div>
            <div>
              <h3 className="text-sm font-semibold text-foreground">Create Support Ticket</h3>
              <p className="text-xs text-muted-foreground">We'll respond within 24 hours</p>
            </div>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="p-5 space-y-4">
            {/* Category */}
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-muted-foreground">Category</label>
              <Select
                value={form.category}
                onValueChange={(v) => setForm((p) => ({ ...p, category: v }))}
              >
                <SelectTrigger className="h-10 rounded-xl bg-white/50 dark:bg-white/5 border-white/40 dark:border-white/10">
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
                className="h-10 rounded-xl bg-white/50 dark:bg-white/5 border-white/40 dark:border-white/10 focus:border-blue-300 dark:focus:border-blue-500/30"
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
                rows={5}
                className="resize-none text-sm rounded-xl bg-white/50 dark:bg-white/5 border-white/40 dark:border-white/10 focus:border-blue-300 dark:focus:border-blue-500/30"
              />
            </div>

            {/* Submit Button */}
            <Button
              type="submit"
              disabled={isSubmitting}
              className="w-full h-11 gap-2 rounded-xl bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white shadow-lg shadow-blue-500/25 transition-all duration-300 hover:shadow-xl hover:shadow-blue-500/30 hover:-translate-y-0.5"
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Creating...
                </>
              ) : (
                <>
                  <Send className="h-4 w-4" />
                  Create Ticket
                </>
              )}
            </Button>
          </form>
        </div>
      </section>

      {/* ====== YOUR TICKETS SECTION ====== */}
      <section className={cn(GLASS_CARD, "overflow-hidden")}>
        {/* Header */}
        <div className="flex items-center justify-between gap-3 p-5 border-b border-white/30 dark:border-white/10">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-2xl bg-gradient-to-br from-stone-600 to-stone-800 flex items-center justify-center shadow-lg shadow-stone-500/20">
              <ClipboardList className="h-5 w-5 text-white" strokeWidth={1.5} />
            </div>
            <div>
              <h3 className="text-sm font-semibold text-foreground">Your Tickets</h3>
              <p className="text-xs text-muted-foreground">Track your support requests</p>
            </div>
          </div>
          {tickets.length > 0 && (
            <span className="text-xs px-2.5 py-1 rounded-full bg-blue-100/80 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 font-medium">
              {tickets.length} ticket{tickets.length !== 1 ? "s" : ""}
            </span>
          )}
        </div>

        {/* Tickets Content */}
        <div className="p-5">
          {isTicketsLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="h-5 w-5 animate-spin text-blue-500" />
            </div>
          ) : tickets.length === 0 ? (
            <div className="text-center py-12">
              <div className="h-12 w-12 rounded-2xl bg-gradient-to-br from-stone-100 to-stone-50 dark:from-stone-900/20 dark:to-stone-800/10 flex items-center justify-center mx-auto mb-3">
                <Ticket className="h-6 w-6 text-stone-400" />
              </div>
              <p className="text-sm font-medium text-muted-foreground">No tickets yet</p>
              <p className="text-xs text-muted-foreground/70 mt-1">Create a ticket above and it will appear here</p>
            </div>
          ) : (
            <div className="space-y-2">
              {tickets.slice(0, 5).map((ticket) => (
                <div
                  key={ticket.id}
                  className={cn(
                    "p-4 rounded-2xl border border-white/40 dark:border-white/10",
                    "bg-white/40 dark:bg-white/[0.02]",
                    "hover:bg-white/70 dark:hover:bg-white/5 hover:shadow-md hover:shadow-black/5",
                    "transition-all duration-300 cursor-pointer group"
                  )}
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-start gap-3 min-w-0">
                      <div className="h-9 w-9 rounded-xl bg-white/60 dark:bg-white/5 border border-white/40 dark:border-white/10 flex items-center justify-center shrink-0">
                        <StatusIcon status={ticket.status} />
                      </div>
                      <div className="min-w-0">
                        <p className="text-sm font-medium text-foreground truncate">
                          {ticket.subject}
                        </p>
                        <p className="text-xs text-muted-foreground mt-0.5">
                          #{ticket.ticket_number} · {ticket.category || "General"}
                        </p>
                        <p className="text-xs text-muted-foreground/70 mt-0.5">
                          {formatDistanceToNow(new Date(ticket.updated_at), { addSuffix: true })}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      <span
                        className={cn(
                          "px-2.5 py-1 rounded-full text-[11px] font-medium capitalize",
                          getStatusStyle(ticket.status)
                        )}
                      >
                        {ticket.status.replace("_", " ")}
                      </span>
                      <ChevronRight className="h-4 w-4 text-muted-foreground opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-0.5" />
                    </div>
                  </div>
                </div>
              ))}

              {tickets.length > 5 && (
                <button className={cn(
                  "w-full p-3 rounded-2xl text-sm font-medium text-blue-600 dark:text-blue-400",
                  "bg-blue-50/50 dark:bg-blue-900/10 border border-blue-100/50 dark:border-blue-500/10",
                  "hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-all duration-300"
                )}>
                  View All {tickets.length} Tickets
                </button>
              )}
            </div>
          )}
        </div>
      </section>
    </main>
  );
}
