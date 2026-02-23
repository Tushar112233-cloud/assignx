"use client";

import React, { useState, useMemo } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Search, ChevronDown, BookOpen, CreditCard, FolderKanban, UserCircle2 } from "lucide-react";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";

/**
 * FAQ item structure
 */
interface FAQItem {
  id: string;
  question: string;
  answer: string;
  category: FAQCategory;
  keywords: string[];
}

/**
 * FAQ categories
 */
type FAQCategory = "getting-started" | "payments" | "projects" | "account";

/**
 * Category configuration
 */
interface CategoryConfig {
  id: FAQCategory;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
  color: string;
  bgColor: string;
  iconColor: string;
}

/**
 * Props for the FAQSection component
 */
interface FAQSectionProps {
  /** Optional initial category filter */
  initialCategory?: FAQCategory | "all";
  /** Optional initial search query */
  initialSearchQuery?: string;
  /** Optional className for the container */
  className?: string;
}

/**
 * FAQ data with comprehensive questions and answers
 */
const FAQ_DATA: FAQItem[] = [
  // Getting Started
  {
    id: "gs-1",
    question: "How do I get started as a doer?",
    answer: "To get started as a doer, first create your account and complete your profile with your skills, experience, and qualifications. Then, verify your email and complete the skill verification process. Once approved, you can start browsing and applying for projects that match your expertise.",
    category: "getting-started",
    keywords: ["signup", "registration", "onboarding", "start", "begin", "new"],
  },
  {
    id: "gs-2",
    question: "What skills do I need to become a successful doer?",
    answer: "Success as a doer depends on your chosen field. Generally, you need strong technical or creative skills relevant to your domain, excellent communication abilities, time management skills, and a commitment to quality work. We recommend getting verified in at least one skill area to increase your visibility to supervisers.",
    category: "getting-started",
    keywords: ["skills", "requirements", "qualifications", "expertise", "abilities"],
  },
  {
    id: "gs-3",
    question: "How long does the verification process take?",
    answer: "The initial account verification typically takes 24-48 hours. Skill verification can take 3-5 business days as our team reviews your qualifications, portfolio, and any certifications you've provided. You'll receive email notifications at each stage of the verification process.",
    category: "getting-started",
    keywords: ["verification", "approval", "review", "time", "duration", "waiting"],
  },
  {
    id: "gs-4",
    question: "Can I work on multiple projects simultaneously?",
    answer: "Yes! You can work on multiple projects at the same time. However, we recommend being realistic about your capacity and deadlines. Maintaining a high on-time delivery rate (above 90%) is crucial for your reputation and future project opportunities.",
    category: "getting-started",
    keywords: ["multiple", "concurrent", "simultaneous", "capacity", "workload"],
  },

  // Payments
  {
    id: "pay-1",
    question: "When do I receive payments?",
    answer: "Payments are released once a superviser approves your completed work. The funds move from 'pending' to 'available' status in your account. You can then request a payout, which is processed within 2-3 business days to your registered bank account.",
    category: "payments",
    keywords: ["payment", "payout", "receive", "money", "earnings", "when"],
  },
  {
    id: "pay-2",
    question: "What are the minimum payout requirements?",
    answer: "You can request a payout once your available balance reaches ₹500 or more. There's no maximum limit for payouts, and you can withdraw your entire available balance at once or in smaller amounts as needed.",
    category: "payments",
    keywords: ["minimum", "threshold", "withdrawal", "limit", "requirements"],
  },
  {
    id: "pay-3",
    question: "How do I set up my bank account for payouts?",
    answer: "Go to your Profile > Bank Settings to add your bank account details. You'll need to provide your account holder name, account number, IFSC code, and bank name. We verify these details to ensure secure and accurate payments. Make sure all information matches your official bank records exactly.",
    category: "payments",
    keywords: ["bank", "account", "setup", "configure", "details", "ifsc"],
  },
  {
    id: "pay-4",
    question: "Are there any fees for receiving payments?",
    answer: "No, we don't charge any fees for processing payouts to doers. The amount you see in your available balance is exactly what you'll receive in your bank account. However, your bank may have their own charges for receiving transfers, which vary by institution.",
    category: "payments",
    keywords: ["fees", "charges", "cost", "commission", "deduction"],
  },
  {
    id: "pay-5",
    question: "What should I do if my payment is delayed?",
    answer: "Most payments are processed within 2-3 business days. If your payment is delayed beyond this timeframe, first check your bank account details are correct in your profile. Then, contact our support team with your transaction ID, and we'll investigate and resolve the issue promptly.",
    category: "payments",
    keywords: ["delayed", "late", "missing", "problem", "issue", "pending"],
  },

  // Projects
  {
    id: "proj-1",
    question: "How do I submit a completed project?",
    answer: "Once you've completed your work, go to the project page and click 'Submit Work'. Upload all deliverables, add a description of what you've completed, and submit for review. The superviser will review your submission and either approve it or request revisions.",
    category: "projects",
    keywords: ["submit", "delivery", "complete", "upload", "deliverables"],
  },
  {
    id: "proj-2",
    question: "What happens if a superviser requests revisions?",
    answer: "If revisions are requested, you'll receive a notification with specific feedback from the superviser. Review their comments, make the necessary changes, and resubmit your work. There's no limit to revision rounds, but maintaining clear communication helps resolve issues quickly.",
    category: "projects",
    keywords: ["revisions", "changes", "modifications", "feedback", "rejected"],
  },
  {
    id: "proj-3",
    question: "Can I communicate with the superviser during a project?",
    answer: "Absolutely! Clear communication is encouraged. Use the in-project messaging system to ask questions, request clarifications, or provide updates. Good communication often leads to better project outcomes and higher ratings.",
    category: "projects",
    keywords: ["communication", "message", "contact", "chat", "discuss"],
  },
  {
    id: "proj-4",
    question: "What if I can't meet a project deadline?",
    answer: "If you anticipate missing a deadline, communicate with the superviser immediately. Many supervisers are willing to extend deadlines if given reasonable notice and a valid reason. However, frequent missed deadlines will negatively impact your on-time delivery rate and profile ratings.",
    category: "projects",
    keywords: ["deadline", "extension", "late", "delay", "timeline"],
  },

  // Account
  {
    id: "acc-1",
    question: "How do I update my profile information?",
    answer: "Go to Profile > Edit Profile to update your personal information, bio, skills, experience level, education details, and profile picture. Keep your profile current and accurate to attract more relevant project opportunities.",
    category: "account",
    keywords: ["update", "edit", "change", "modify", "profile"],
  },
  {
    id: "acc-2",
    question: "How can I improve my doer rating?",
    answer: "Your rating is based on quality of work, timeliness, and communication. To improve: deliver high-quality work consistently, meet deadlines, maintain clear communication, respond promptly to messages, and be professional in all interactions. Getting skill verifications also boosts credibility.",
    category: "account",
    keywords: ["rating", "reputation", "review", "improve", "score", "feedback"],
  },
  {
    id: "acc-3",
    question: "Can I change my email address or phone number?",
    answer: "Yes, you can update your email and phone number in Profile > Edit Profile. For email changes, you'll need to verify the new email address. For security reasons, these changes may require additional verification steps to protect your account.",
    category: "account",
    keywords: ["email", "phone", "contact", "change", "update"],
  },
  {
    id: "acc-4",
    question: "What should I do if I forget my password?",
    answer: "Click 'Forgot Password' on the login page and enter your registered email address. You'll receive a password reset link within a few minutes. For security, the link expires after 1 hour. If you don't receive the email, check your spam folder or contact support.",
    category: "account",
    keywords: ["password", "reset", "forgot", "login", "access"],
  },
  {
    id: "acc-5",
    question: "How do I deactivate or delete my account?",
    answer: "To deactivate your account, go to Profile > Account Settings and select 'Deactivate Account'. This temporarily suspends your profile. For permanent deletion, contact our support team. Note that you must withdraw any available balance before account closure.",
    category: "account",
    keywords: ["deactivate", "delete", "close", "remove", "cancel"],
  },
];

/**
 * Category configurations
 */
const CATEGORIES: CategoryConfig[] = [
  {
    id: "getting-started",
    label: "Getting Started",
    icon: BookOpen,
    color: "text-[#4F6CF7]",
    bgColor: "bg-[#E3E9FF]",
    iconColor: "text-[#4F6CF7]",
  },
  {
    id: "payments",
    label: "Payments",
    icon: CreditCard,
    color: "text-[#43D1C5]",
    bgColor: "bg-[#E9FAFA]",
    iconColor: "text-[#43D1C5]",
  },
  {
    id: "projects",
    label: "Projects",
    icon: FolderKanban,
    color: "text-[#FF8B6A]",
    bgColor: "bg-[#FFE7E1]",
    iconColor: "text-[#FF8B6A]",
  },
  {
    id: "account",
    label: "Account",
    icon: UserCircle2,
    color: "text-[#5B7CFF]",
    bgColor: "bg-[#EEF2FF]",
    iconColor: "text-[#5B7CFF]",
  },
];

/**
 * Highlight search terms in text
 */
const highlightText = (text: string, searchTerm: string): React.ReactNode => {
  if (!searchTerm.trim()) return text;

  const regex = new RegExp(`(${searchTerm.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")})`, "gi");
  const parts = text.split(regex);

  return parts.map((part, index) =>
    regex.test(part) ? (
      <mark
        key={index}
        className="bg-[#FFE7E1] text-[#FF8B6A] rounded px-0.5"
      >
        {part}
      </mark>
    ) : (
      part
    )
  );
};

/**
 * FAQSection Component
 *
 * Comprehensive FAQ accordion section with category filtering and search functionality.
 * Features smooth animations, highlighted search terms, and glassmorphism design.
 *
 * @component
 * @example
 * ```tsx
 * <FAQSection
 *   initialCategory="all"
 *   initialSearchQuery=""
 * />
 * ```
 */
export const FAQSection: React.FC<FAQSectionProps> = ({
  initialCategory = "all",
  initialSearchQuery = "",
  className,
}) => {
  const [selectedCategory, setSelectedCategory] = useState<FAQCategory | "all">(initialCategory);
  const [searchQuery, setSearchQuery] = useState(initialSearchQuery);
  const [openItems, setOpenItems] = useState<string[]>([]);

  /**
   * Filter FAQs based on category and search query
   */
  const filteredFAQs = useMemo(() => {
    let faqs = FAQ_DATA;

    // Filter by category
    if (selectedCategory !== "all") {
      faqs = faqs.filter((faq) => faq.category === selectedCategory);
    }

    // Filter by search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      faqs = faqs.filter(
        (faq) =>
          faq.question.toLowerCase().includes(query) ||
          faq.answer.toLowerCase().includes(query) ||
          faq.keywords.some((keyword) => keyword.toLowerCase().includes(query))
      );
    }

    return faqs;
  }, [selectedCategory, searchQuery]);

  /**
   * Get category count
   */
  const getCategoryCount = (category: FAQCategory | "all"): number => {
    if (category === "all") {
      return FAQ_DATA.length;
    }
    return FAQ_DATA.filter((faq) => faq.category === category).length;
  };

  /**
   * Handle category selection
   */
  const handleCategorySelect = (category: FAQCategory | "all") => {
    setSelectedCategory(category);
    setOpenItems([]);
  };

  return (
    <div className={cn("space-y-8", className)}>
      {/* Header */}
      <div className="text-center space-y-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <Badge className="mb-4 bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white border-0 shadow-[0_8px_20px_rgba(90,124,255,0.25)]">
            Frequently Asked Questions
          </Badge>
          <h2 className="text-3xl font-semibold text-slate-900 lg:text-4xl">
            Find answers to common questions
          </h2>
          <p className="mt-3 text-base text-slate-600 lg:text-lg">
            Browse by category or search for specific topics
          </p>
        </motion.div>

        {/* Search bar */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1, duration: 0.5 }}
          className="mx-auto max-w-2xl"
        >
          <div className="relative">
            <Search className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-400" />
            <Input
              type="text"
              placeholder="Search FAQs..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="h-12 pl-12 pr-4 rounded-full border-white/70 bg-white/85 backdrop-blur-sm focus:bg-white focus:border-[#5A7CFF] focus:ring-4 focus:ring-[#E7ECFF] transition-all shadow-[0_8px_20px_rgba(148,163,184,0.08)]"
            />
          </div>
        </motion.div>
      </div>

      {/* Category tabs */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="flex flex-wrap gap-3 justify-center"
      >
        {/* All categories */}
        <button
          onClick={() => handleCategorySelect("all")}
          className={cn(
            "group flex items-center gap-2 rounded-full px-5 py-2.5 text-sm font-medium transition-all duration-200",
            selectedCategory === "all"
              ? "bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white shadow-[0_8px_20px_rgba(90,124,255,0.25)]"
              : "bg-white/85 text-slate-700 hover:bg-white hover:shadow-[0_10px_22px_rgba(30,58,138,0.08)] border border-white/70"
          )}
        >
          <span>All Topics</span>
          <Badge
            variant="secondary"
            className={cn(
              "rounded-full px-2 py-0.5 text-xs",
              selectedCategory === "all"
                ? "bg-white/20 text-white"
                : "bg-slate-100 text-slate-700"
            )}
          >
            {getCategoryCount("all")}
          </Badge>
        </button>

        {/* Individual categories */}
        {CATEGORIES.map((category) => {
          const Icon = category.icon;
          const isActive = selectedCategory === category.id;

          return (
            <button
              key={category.id}
              onClick={() => handleCategorySelect(category.id)}
              className={cn(
                "group flex items-center gap-2 rounded-full px-5 py-2.5 text-sm font-medium transition-all duration-200",
                isActive
                  ? `${category.bgColor} ${category.color} shadow-lg`
                  : "bg-white/85 text-slate-700 hover:bg-white hover:shadow-[0_10px_22px_rgba(30,58,138,0.08)] border border-white/70"
              )}
            >
              <Icon
                className={cn(
                  "h-4 w-4 transition-colors",
                  isActive ? category.iconColor : "text-slate-500"
                )}
              />
              <span>{category.label}</span>
              <Badge
                variant="secondary"
                className={cn(
                  "rounded-full px-2 py-0.5 text-xs",
                  isActive
                    ? "bg-white/60 text-slate-900"
                    : "bg-slate-100 text-slate-700"
                )}
              >
                {getCategoryCount(category.id)}
              </Badge>
            </button>
          );
        })}
      </motion.div>

      {/* FAQ Accordion */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="mx-auto max-w-4xl"
      >
        <AnimatePresence mode="wait">
          {filteredFAQs.length > 0 ? (
            <motion.div
              key={selectedCategory + searchQuery}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.3 }}
              className="rounded-3xl border border-white/70 bg-white/85 backdrop-blur-sm shadow-[0_16px_35px_rgba(30,58,138,0.08)] overflow-hidden"
            >
              <Accordion
                type="multiple"
                value={openItems}
                onValueChange={setOpenItems}
                className="divide-y divide-slate-100"
              >
                {filteredFAQs.map((faq, index) => {
                  const category = CATEGORIES.find((c) => c.id === faq.category);
                  const Icon = category?.icon;

                  return (
                    <AccordionItem
                      key={faq.id}
                      value={faq.id}
                      className="border-0 px-6 hover:bg-slate-50/50 transition-colors"
                    >
                      <AccordionTrigger className="py-5 hover:no-underline group">
                        <div className="flex items-start gap-4 text-left w-full pr-4">
                          {/* Category icon */}
                          {Icon && (
                            <div
                              className={cn(
                                "flex-shrink-0 mt-0.5 h-10 w-10 rounded-xl flex items-center justify-center",
                                category?.bgColor
                              )}
                            >
                              <Icon
                                className={cn("h-5 w-5", category?.iconColor)}
                              />
                            </div>
                          )}

                          {/* Question */}
                          <div className="flex-1 min-w-0">
                            <h3 className="text-base font-medium text-gray-900 group-hover:text-gray-700">
                              {highlightText(faq.question, searchQuery)}
                            </h3>
                            <Badge
                              variant="secondary"
                              className={cn(
                                "mt-2 text-xs capitalize",
                                category?.bgColor,
                                category?.color
                              )}
                            >
                              {category?.label}
                            </Badge>
                          </div>
                        </div>
                      </AccordionTrigger>

                      <AccordionContent className="pb-6 pt-2 pl-14">
                        <motion.div
                          initial={{ opacity: 0 }}
                          animate={{ opacity: 1 }}
                          transition={{ duration: 0.3 }}
                          className="text-gray-600 leading-relaxed"
                        >
                          {highlightText(faq.answer, searchQuery)}
                        </motion.div>
                      </AccordionContent>
                    </AccordionItem>
                  );
                })}
              </Accordion>
            </motion.div>
          ) : (
            <motion.div
              key="no-results"
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              transition={{ duration: 0.3 }}
              className="rounded-3xl border border-gray-200 bg-white/85 backdrop-blur-sm p-12 text-center shadow-[0_16px_35px_rgba(30,58,138,0.08)]"
            >
              <div className="mx-auto w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-4">
                <Search className="h-8 w-8 text-gray-400" />
              </div>
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                No FAQs found
              </h3>
              <p className="text-gray-600 mb-6">
                We couldn't find any FAQs matching your search.
                <br />
                Try adjusting your filters or search terms.
              </p>
              <button
                onClick={() => {
                  setSearchQuery("");
                  setSelectedCategory("all");
                }}
                className="inline-flex items-center gap-2 rounded-full bg-gradient-to-r from-emerald-500 to-teal-600 px-6 py-2.5 text-sm font-medium text-white hover:from-emerald-600 hover:to-teal-700 transition-all shadow-lg shadow-emerald-500/25"
              >
                Clear all filters
              </button>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>

      {/* Result count */}
      {filteredFAQs.length > 0 && (
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4, duration: 0.5 }}
          className="text-center text-sm text-gray-600"
        >
          Showing <span className="font-medium text-gray-900">{filteredFAQs.length}</span>{" "}
          {filteredFAQs.length === 1 ? "question" : "questions"}
          {searchQuery && (
            <>
              {" for "}
              <span className="font-medium text-gray-900">"{searchQuery}"</span>
            </>
          )}
        </motion.p>
      )}
    </div>
  );
};

export default FAQSection;
