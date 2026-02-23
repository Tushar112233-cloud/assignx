/**
 * @fileoverview FAQ accordion component with searchable questions.
 * Redesigned to match dashboard design system.
 * @module components/support/faq-accordion
 */

"use client"

import { useState, useMemo } from "react"
import { motion } from "framer-motion"
import { Search, HelpCircle } from "lucide-react"

import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion"
import { cn } from "@/lib/utils"
import { FAQ } from "./types"

const STATIC_FAQS: FAQ[] = [
  {
    id: "faq-1",
    question: "How do I get started as a supervisor?",
    answer: "To get started, complete the registration process by providing your professional details and banking information. After verification, you'll need to complete the training modules and pass the supervisor test to unlock your dashboard.",
    category: "Getting Started",
    order: 1,
  },
  {
    id: "faq-2",
    question: "What are the requirements to become a supervisor?",
    answer: "You need to have relevant academic qualifications (minimum post-graduate), at least 3 years of experience in your field, and pass our verification process. You'll also need to complete the training modules and score at least 80% on the supervisor test.",
    category: "Getting Started",
    order: 2,
  },
  {
    id: "faq-3",
    question: "How do I quote a project?",
    answer: "When you receive a new project request, click 'Analyze & Quote' to review the requirements. Consider factors like word count, complexity, deadline, and subject matter. Use the pricing guide as reference and set a fair price that covers the doer payout, your commission, and platform fees.",
    category: "Projects",
    order: 1,
  },
  {
    id: "faq-4",
    question: "How do I assign a doer to a project?",
    answer: "After a project is paid, go to 'Ready to Assign' section, click 'Assign Doer', and browse available experts. Filter by subject, availability, and rating. Review their profile and past performance before making an assignment.",
    category: "Projects",
    order: 2,
  },
  {
    id: "faq-5",
    question: "What should I check during quality control (QC)?",
    answer: "During QC, verify: 1) The work meets all project requirements, 2) Plagiarism check results are acceptable (<15%), 3) AI detection is within limits if applicable, 4) Formatting follows guidelines, 5) The work is complete and professionally presented.",
    category: "Projects",
    order: 3,
  },
  {
    id: "faq-6",
    question: "How is my commission calculated?",
    answer: "Your commission is 15% of the user's payment amount. For example, if a user pays \u20B92,000 for a project, your commission would be \u20B9300. The doer receives 65% (\u20B91,300) and the platform takes 20% (\u20B9400).",
    category: "Payments",
    order: 1,
  },
  {
    id: "faq-7",
    question: "When can I withdraw my earnings?",
    answer: "You can withdraw your available balance once it reaches the minimum threshold of \u20B9500. Withdrawals are processed within 24-48 hours on business days. Make sure your bank details are up to date.",
    category: "Payments",
    order: 2,
  },
  {
    id: "faq-8",
    question: "Why is some of my balance shown as 'pending'?",
    answer: "Balance shows as pending when a project is still in progress or awaiting client approval. Once the project is completed and approved by the client, the amount moves to your available balance.",
    category: "Payments",
    order: 3,
  },
  {
    id: "faq-9",
    question: "How do I blacklist a doer?",
    answer: "Go to Doer Management or the doer's profile, click 'Add to Blacklist' and provide a reason. Blacklisted doers won't appear in your assignment list. You can remove them from the blacklist later if needed.",
    category: "Doers",
    order: 1,
  },
  {
    id: "faq-10",
    question: "What if a doer misses the deadline?",
    answer: "Contact the doer immediately to understand the situation. If the delay is significant, you may need to reassign the project. Report recurring issues to support and consider blacklisting repeatedly problematic doers.",
    category: "Doers",
    order: 2,
  },
  {
    id: "faq-11",
    question: "How do I update my bank details?",
    answer: "Go to Profile > Edit Profile > Banking Details. Update your information and save. Bank detail changes may require re-verification before you can make withdrawals.",
    category: "Account",
    order: 1,
  },
  {
    id: "faq-12",
    question: "How do I toggle my availability?",
    answer: "Use the availability toggle in the menu drawer or your profile. When set to 'Busy', you won't receive new project notifications. Set to 'Available' when you're ready to take on new projects.",
    category: "Account",
    order: 2,
  },
]

const CATEGORIES = ["All", "Getting Started", "Projects", "Payments", "Doers", "Account"]

export function FAQAccordion() {
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("All")

  const filteredFAQs = useMemo(() => {
    let result = [...STATIC_FAQS]

    if (selectedCategory !== "All") {
      result = result.filter((faq) => faq.category === selectedCategory)
    }

    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      result = result.filter(
        (faq) =>
          faq.question.toLowerCase().includes(query) ||
          faq.answer.toLowerCase().includes(query)
      )
    }

    return result.sort((a, b) => a.order - b.order)
  }, [searchQuery, selectedCategory])

  const groupedFAQs = useMemo(() => {
    const groups: Record<string, FAQ[]> = {}
    filteredFAQs.forEach((faq) => {
      if (!groups[faq.category]) {
        groups[faq.category] = []
      }
      groups[faq.category].push(faq)
    })
    return groups
  }, [filteredFAQs])

  return (
    <div className="space-y-6">
      {/* Search and Category Filter */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3 }}
        className="space-y-4"
      >
        <div className="relative max-w-md">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <Input
            placeholder="Search FAQs..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10 rounded-xl border-gray-200 bg-white h-10 focus:border-orange-300 focus:ring-orange-200"
          />
        </div>
        <div className="flex flex-wrap gap-2">
          {CATEGORIES.map((category) => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              className={cn(
                "px-4 py-1.5 rounded-full text-xs font-medium transition-all duration-200",
                selectedCategory === category
                  ? "bg-[#1C1C1C] text-white"
                  : "bg-white text-gray-600 border border-gray-200 hover:border-gray-300"
              )}
            >
              {category}
            </button>
          ))}
        </div>
      </motion.div>

      {/* FAQ List */}
      {filteredFAQs.length === 0 ? (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white rounded-2xl border border-gray-200 p-12 text-center"
        >
          <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mx-auto mb-4">
            <HelpCircle className="h-8 w-8 text-gray-400" />
          </div>
          <h3 className="text-lg font-semibold text-[#1C1C1C]">No FAQs found</h3>
          <p className="text-sm text-gray-500 mt-1">
            Try searching with different keywords
          </p>
        </motion.div>
      ) : (
        <div className="space-y-5">
          {Object.entries(groupedFAQs).map(([category, faqs], groupIndex) => (
            <motion.div
              key={category}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.05 * groupIndex, duration: 0.3 }}
              className="rounded-2xl border border-gray-200 bg-white overflow-hidden"
            >
              <div className="px-6 pt-5 pb-2 flex items-center gap-2">
                <h3 className="text-sm font-semibold text-[#1C1C1C]">{category}</h3>
                <Badge variant="secondary" className="text-[10px] bg-gray-100 text-gray-500">
                  {faqs.length}
                </Badge>
              </div>
              <div className="px-6 pb-4">
                <Accordion type="single" collapsible className="space-y-2">
                  {faqs.map((faq) => (
                    <AccordionItem
                      key={faq.id}
                      value={faq.id}
                      className="border border-gray-100 rounded-xl px-4 data-[state=open]:border-orange-200 data-[state=open]:bg-orange-50/30 transition-colors"
                    >
                      <AccordionTrigger className="text-sm font-medium text-[#1C1C1C] text-left hover:no-underline py-3.5">
                        {faq.question}
                      </AccordionTrigger>
                      <AccordionContent className="text-sm text-gray-600 pb-3.5 leading-relaxed">
                        {faq.answer}
                      </AccordionContent>
                    </AccordionItem>
                  ))}
                </Accordion>
              </div>
            </motion.div>
          ))}
        </div>
      )}
    </div>
  )
}
