'use client'

/**
 * Support Section component
 * Provides multiple support options and FAQ
 * @module components/profile/SupportSection
 */

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  HelpCircle,
  FileText,
  ExternalLink,
  ChevronRight,
  Send,
  Loader2,
  CheckCircle2,
  AlertTriangle,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { Alert, AlertDescription } from '@/components/ui/alert'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion'
import { cn } from '@/lib/utils'
import { supportOptions, ticketCategories, mockFAQs } from './constants'
import type { SupportTicket, FAQ } from '@/types/database'

/**
 * Ticket form data structure
 */
interface TicketFormData {
  subject: string
  description: string
  category: 'technical' | 'payment' | 'project' | 'account' | 'other'
  priority?: 'low' | 'medium' | 'high' | 'urgent'
}

/**
 * SupportSection component props
 */
interface SupportSectionProps {
  /** Existing support tickets */
  tickets?: SupportTicket[]
  /** FAQs */
  faqs?: FAQ[]
  /** WhatsApp number */
  whatsappNumber?: string
  /** Support email */
  supportEmail?: string
  /** Layout variant */
  variant?: 'default' | 'compact'
  /** Callback when ticket is created */
  onCreateTicket?: (ticket: TicketFormData) => Promise<void>
  /** Additional class name */
  className?: string
}

/**
 * Support Section component
 * Provides multiple support options and FAQ
 */
export function SupportSection({
  tickets = [],
  faqs = mockFAQs,
  whatsappNumber = '+919876543210',
  supportEmail = 'support@talentconnect.com',
  variant = 'default',
  onCreateTicket,
  className,
}: SupportSectionProps) {
  const isCompact = variant === 'compact'
  const [showTicketDialog, setShowTicketDialog] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [ticketForm, setTicketForm] = useState<TicketFormData>({
    subject: '',
    description: '',
    category: 'other',
  })

  /** Handle WhatsApp click */
  const handleWhatsAppClick = () => {
    window.open(`https://wa.me/${whatsappNumber.replace(/\D/g, '')}`, '_blank')
  }

  /** Handle email click */
  const handleEmailClick = () => {
    window.location.href = `mailto:${supportEmail}`
  }

  /** Handle support option click */
  const handleOptionClick = (optionId: string) => {
    if (optionId === 'whatsapp') handleWhatsAppClick()
    else if (optionId === 'email') handleEmailClick()
    else setShowTicketDialog(true)
  }

  /** Handle ticket submit */
  const handleSubmitTicket = async () => {
    if (!ticketForm.subject.trim()) {
      setError('Subject is required')
      return
    }
    if (!ticketForm.description.trim()) {
      setError('Description is required')
      return
    }

    setIsSubmitting(true)
    setError(null)

    try {
      if (onCreateTicket) {
        await onCreateTicket(ticketForm)
      } else {
        await new Promise((resolve) => setTimeout(resolve, 1000))
      }
      setSuccess(true)
      setShowTicketDialog(false)
      setTicketForm({ subject: '', description: '', category: 'other' })
      setTimeout(() => setSuccess(false), 3000)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create ticket')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className={cn('space-y-6', className)}>
      {/* Success alert */}
      <AnimatePresence>
        {success && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
          >
            <Alert className="border-blue-500/30 bg-gradient-to-r from-blue-50/80 to-cyan-50/80 dark:from-blue-950/30 dark:to-cyan-950/30 shadow-sm">
              <CheckCircle2 className="h-4 w-4 text-blue-600 dark:text-blue-400" />
              <AlertDescription className="text-blue-700 dark:text-blue-300 font-medium">
                Support ticket created successfully! We'll respond within 24 hours.
              </AlertDescription>
            </Alert>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Support options */}
      <Card className="w-full max-w-full overflow-hidden border-blue-100/50 dark:border-blue-900/30 shadow-lg shadow-blue-500/5">
        <CardHeader className="p-6 pb-4">
          <CardTitle className="flex items-center gap-2 text-xl">
            <div className="w-10 h-10 flex-shrink-0 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-600 flex items-center justify-center shadow-lg shadow-blue-500/20">
              <HelpCircle className="h-5 w-5 text-white" />
            </div>
            <span className="truncate">Contact Support</span>
          </CardTitle>
          <CardDescription className="text-base line-clamp-2">Get help with any issues or questions</CardDescription>
        </CardHeader>
        <CardContent className="p-6">
          <div className={cn('grid gap-4', isCompact ? 'sm:grid-cols-2' : 'sm:grid-cols-3')}>
            {supportOptions.map((option) => {
              const Icon = option.icon
              return (
                <button
                  key={option.id}
                  onClick={() => handleOptionClick(option.id)}
                  className={cn(
                    'group relative rounded-2xl border border-blue-100/50 dark:border-blue-900/30 text-left transition-all duration-300',
                    'bg-gradient-to-br from-white to-blue-50/30 dark:from-gray-900 dark:to-blue-950/20',
                    'hover:shadow-xl hover:shadow-blue-500/10 hover:border-blue-300/50 dark:hover:border-blue-700/50',
                    'hover:-translate-y-1 hover:scale-[1.02]',
                    isCompact ? 'p-4' : 'p-5'
                  )}
                >
                  <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-blue-500/0 to-cyan-500/0 group-hover:from-blue-500/5 group-hover:to-cyan-500/5 transition-all duration-300" />

                  <div className="relative">
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-600 flex items-center justify-center mb-4 shadow-lg shadow-blue-500/25 group-hover:shadow-xl group-hover:shadow-blue-500/30 transition-all duration-300 group-hover:scale-110">
                      <Icon className="h-6 w-6 text-white" />
                    </div>
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-1.5 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
                      {option.title}
                    </h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400 mb-4 leading-relaxed">
                      {option.description}
                    </p>
                    <span className="inline-flex items-center gap-1.5 text-sm font-medium bg-gradient-to-r from-blue-600 to-cyan-600 bg-clip-text text-transparent group-hover:from-blue-700 group-hover:to-cyan-700 transition-all">
                      {option.action}
                      {option.id === 'ticket' ? (
                        <ChevronRight className="h-4 w-4 text-blue-600 group-hover:translate-x-0.5 transition-transform" />
                      ) : (
                        <ExternalLink className="h-4 w-4 text-blue-600 group-hover:-translate-y-0.5 group-hover:translate-x-0.5 transition-transform" />
                      )}
                    </span>
                  </div>
                </button>
              )
            })}
          </div>
        </CardContent>
      </Card>

      {/* Active tickets */}
      {tickets.length > 0 && !isCompact && (
        <Card className="w-full max-w-full overflow-hidden border-blue-100/50 dark:border-blue-900/30 shadow-lg shadow-blue-500/5">
          <CardHeader className="p-6">
            <CardTitle className="flex items-center gap-2">
              <div className="w-9 h-9 flex-shrink-0 rounded-lg bg-gradient-to-br from-blue-500 to-cyan-600 flex items-center justify-center shadow-md shadow-blue-500/20">
                <FileText className="h-4 w-4 text-white" />
              </div>
              <span className="truncate">Your Tickets</span>
            </CardTitle>
            <CardDescription className="line-clamp-2">Track your support requests</CardDescription>
          </CardHeader>
          <CardContent className="p-6">
            <div className="space-y-3">
              {tickets.slice(0, 3).map((ticket) => (
                <div
                  key={ticket.id}
                  className="group flex items-center justify-between p-4 rounded-xl border border-blue-100/50 dark:border-blue-900/30 bg-gradient-to-br from-white to-blue-50/20 dark:from-gray-900 dark:to-blue-950/10 hover:shadow-md hover:shadow-blue-500/5 transition-all duration-200 hover:border-blue-300/50 dark:hover:border-blue-700/50"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center group-hover:bg-blue-200 dark:group-hover:bg-blue-900/50 transition-colors">
                      <FileText className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                    </div>
                    <div>
                      <p className="font-medium text-gray-900 dark:text-white">{ticket.subject}</p>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        {new Date(ticket.created_at).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                  <Badge
                    variant="outline"
                    className={cn(
                      'font-medium shadow-sm',
                      ticket.status === 'open'
                        ? 'bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/30 dark:border-blue-500/50'
                        : ticket.status === 'in_progress'
                        ? 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/30 dark:border-amber-500/50'
                        : 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 dark:border-emerald-500/50'
                    )}
                  >
                    {ticket.status.replace('_', ' ')}
                  </Badge>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* FAQs */}
      <Card className="w-full max-w-full overflow-hidden border-blue-100/50 dark:border-blue-900/30 shadow-lg shadow-blue-500/5">
        <CardHeader className="p-6">
          <CardTitle className="flex items-center gap-2">
            <div className="w-10 h-10 flex-shrink-0 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-600 flex items-center justify-center shadow-lg shadow-blue-500/20">
              <HelpCircle className="h-5 w-5 text-white" />
            </div>
            <span className="truncate">Frequently Asked Questions</span>
          </CardTitle>
        </CardHeader>
        <CardContent className="p-6">
          <Accordion type="single" collapsible className="w-full space-y-2">
            {(isCompact ? faqs.slice(0, 3) : faqs).map((faq) => (
              <AccordionItem
                key={faq.id}
                value={faq.id}
                className="border border-blue-100/50 dark:border-blue-900/30 rounded-xl px-5 bg-gradient-to-br from-white to-blue-50/20 dark:from-gray-900 dark:to-blue-950/10 hover:shadow-md hover:shadow-blue-500/5 transition-all duration-200"
              >
                <AccordionTrigger className="text-left font-medium text-gray-900 dark:text-white hover:text-blue-600 dark:hover:text-blue-400 hover:no-underline py-4">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-gray-600 dark:text-gray-400 pb-4 leading-relaxed">
                  {faq.answer}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </CardContent>
      </Card>

      {/* Create ticket dialog */}
      <Dialog open={showTicketDialog} onOpenChange={setShowTicketDialog}>
        <DialogContent className="sm:max-w-lg border-blue-100/50 dark:border-blue-900/30 shadow-2xl">
          <DialogHeader className="space-y-3">
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-600 flex items-center justify-center mx-auto shadow-lg shadow-blue-500/30">
              <HelpCircle className="h-6 w-6 text-white" />
            </div>
            <DialogTitle className="text-xl text-center">Create Support Ticket</DialogTitle>
            <DialogDescription className="text-center text-base">
              Describe your issue and we'll get back to you within 24 hours
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-4">
            {error && (
              <Alert variant="destructive" className="border-red-200 dark:border-red-800">
                <AlertTriangle className="h-4 w-4" />
                <AlertDescription>{error}</AlertDescription>
              </Alert>
            )}

            <div className="space-y-2">
              <Label htmlFor="category" className="text-sm font-medium text-gray-700 dark:text-gray-300">
                Category
              </Label>
              <Select
                value={ticketForm.category}
                onValueChange={(v) => setTicketForm((prev) => ({ ...prev, category: v as TicketFormData['category'] }))}
              >
                <SelectTrigger className="border-blue-200/50 dark:border-blue-800/50 focus:ring-blue-500">
                  <SelectValue placeholder="Select category" />
                </SelectTrigger>
                <SelectContent>
                  {ticketCategories.map((cat) => (
                    <SelectItem key={cat.value} value={cat.value}>{cat.label}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="subject" className="text-sm font-medium text-gray-700 dark:text-gray-300">
                Subject
              </Label>
              <Input
                id="subject"
                value={ticketForm.subject}
                onChange={(e) => setTicketForm((prev) => ({ ...prev, subject: e.target.value }))}
                placeholder="Brief summary of your issue"
                className="border-blue-200/50 dark:border-blue-800/50 focus:ring-blue-500"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="description" className="text-sm font-medium text-gray-700 dark:text-gray-300">
                Description
              </Label>
              <Textarea
                id="description"
                value={ticketForm.description}
                onChange={(e) => setTicketForm((prev) => ({ ...prev, description: e.target.value }))}
                placeholder="Provide detailed information about your issue..."
                rows={4}
                className="border-blue-200/50 dark:border-blue-800/50 focus:ring-blue-500 resize-none"
              />
            </div>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              variant="outline"
              onClick={() => setShowTicketDialog(false)}
              className="border-blue-200 dark:border-blue-800 hover:bg-blue-50 dark:hover:bg-blue-950/50"
            >
              Cancel
            </Button>
            <Button
              onClick={handleSubmitTicket}
              disabled={isSubmitting}
              className="gap-2 bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-700 hover:to-cyan-700 text-white shadow-lg shadow-blue-500/30 hover:shadow-xl hover:shadow-blue-500/40 transition-all"
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Submitting...
                </>
              ) : (
                <>
                  <Send className="h-4 w-4" />
                  Submit Ticket
                </>
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
