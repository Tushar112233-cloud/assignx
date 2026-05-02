/**
 * @fileoverview Support center page - Modern minimal design
 * Charcoal + Orange accent palette matching dashboard design system
 * @module app/(dashboard)/support/page
 */

"use client"

import { useState, useCallback } from "react"
import { motion, AnimatePresence } from "framer-motion"
import {
  MessageSquare,
  HelpCircle,
  Plus,
  ArrowLeft,
  Headphones,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  TicketForm,
  TicketList,
  TicketDetail,
  FAQAccordion,
} from "@/components/support"
import { SupportTicket } from "@/types/database"
import { cn } from "@/lib/utils"

type SupportView = "list" | "create" | "detail"

const tabs = [
  { id: "tickets", label: "My Tickets", icon: MessageSquare },
  { id: "faq", label: "FAQ", icon: HelpCircle },
] as const

export default function SupportPage() {
  const [activeTab, setActiveTab] = useState<"tickets" | "faq">("tickets")
  const [currentView, setCurrentView] = useState<SupportView>("list")
  const [selectedTicket, setSelectedTicket] = useState<SupportTicket | null>(null)
  const [refreshKey, setRefreshKey] = useState(0)

  const handleTicketSelect = (ticket: SupportTicket) => {
    setSelectedTicket(ticket)
    setCurrentView("detail")
  }

  const handleBack = () => {
    setCurrentView("list")
    setSelectedTicket(null)
  }

  const handleTicketCreated = useCallback(() => {
    setRefreshKey(prev => prev + 1)
    handleBack()
  }, [])

  const renderTicketContent = () => {
    switch (currentView) {
      case "create":
        return (
          <motion.div
            key="create"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.3 }}
            className="space-y-6"
          >
            <button
              onClick={handleBack}
              className="group flex items-center gap-2 text-gray-500 hover:text-[#1C1C1C] transition-colors"
            >
              <div className="w-8 h-8 rounded-lg bg-gray-100 group-hover:bg-orange-50 flex items-center justify-center transition-colors">
                <ArrowLeft className="h-4 w-4 group-hover:text-[#F97316] transition-colors" />
              </div>
              <span className="text-sm font-medium">Back to Tickets</span>
            </button>
            <div>
              <p className="text-xs uppercase tracking-[0.2em] text-gray-400">Support</p>
              <h2 className="text-2xl font-semibold text-[#1C1C1C] mt-1">New Ticket</h2>
            </div>
            <TicketForm
              onSuccess={handleTicketCreated}
              onCancel={handleBack}
            />
          </motion.div>
        )
      case "detail":
        return selectedTicket ? (
          <motion.div
            key="detail"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.3 }}
          >
            <TicketDetail
              ticket={selectedTicket}
              onBack={handleBack}
              onStatusChange={() => {
                setRefreshKey(prev => prev + 1)
              }}
            />
          </motion.div>
        ) : null
      default:
        return (
          <motion.div
            key="list"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.3 }}
          >
            <TicketList
              key={refreshKey}
              onTicketSelect={handleTicketSelect}
              onCreateNew={() => setCurrentView("create")}
            />
          </motion.div>
        )
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="relative">
        {/* Subtle background blurs */}
        <div className="pointer-events-none absolute inset-0">
          <div className="absolute -top-32 left-8 h-64 w-64 rounded-full bg-orange-100/60 blur-3xl" />
          <div className="absolute top-32 right-10 h-56 w-56 rounded-full bg-amber-100/50 blur-3xl" />
        </div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.4 }}
          className="relative max-w-[1400px] mx-auto px-8 lg:px-10 pt-4 pb-8"
        >
          {/* Hero Section */}
          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.5 }}
            className="relative overflow-hidden rounded-3xl border border-gray-200 bg-white p-8 lg:p-10 mb-8"
          >
            <div className="pointer-events-none absolute -top-24 right-0 h-52 w-52 rounded-full bg-orange-100/60 blur-3xl" />
            <div className="pointer-events-none absolute bottom-0 left-6 h-40 w-40 rounded-full bg-amber-100/40 blur-3xl" />

            <div className="relative flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6">
              <div className="flex items-center gap-5">
                <div className="w-14 h-14 rounded-2xl bg-orange-50 flex items-center justify-center">
                  <Headphones className="h-7 w-7 text-[#F97316]" />
                </div>
                <div>
                  <h1 className="text-3xl lg:text-4xl font-bold text-[#1C1C1C] tracking-tight">
                    Support Center
                  </h1>
                  <p className="text-gray-500 mt-1">
                    Get help, manage tickets, or browse common questions
                  </p>
                </div>
              </div>

              {activeTab === "tickets" && currentView === "list" && (
                <Button
                  onClick={() => setCurrentView("create")}
                  className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-full px-6 h-11 font-medium shadow-lg shadow-orange-500/20 hover:shadow-xl hover:shadow-orange-500/30 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200"
                >
                  <Plus className="mr-2 h-4 w-4" />
                  New Ticket
                </Button>
              )}
            </div>
          </motion.section>

          {/* Tab Navigation */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.5 }}
            className="flex items-center gap-2 mb-6"
          >
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => {
                  setActiveTab(tab.id)
                  if (tab.id === "tickets") {
                    setCurrentView("list")
                    setSelectedTicket(null)
                  }
                }}
                className={cn(
                  "flex items-center gap-2 px-5 py-2.5 rounded-full text-sm font-medium transition-all duration-200",
                  activeTab === tab.id
                    ? "bg-[#1C1C1C] text-white shadow-md"
                    : "bg-white text-gray-600 border border-gray-200 hover:border-gray-300 hover:bg-gray-50"
                )}
              >
                <tab.icon className="h-4 w-4" />
                {tab.label}
              </button>
            ))}
          </motion.div>

          {/* Content */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.5 }}
          >
            <AnimatePresence mode="wait">
              {activeTab === "tickets" ? (
                renderTicketContent()
              ) : (
                <motion.div
                  key="faq"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.3 }}
                >
                  <FAQAccordion />
                </motion.div>
              )}
            </AnimatePresence>
          </motion.div>
        </motion.div>
      </div>
    </div>
  )
}
