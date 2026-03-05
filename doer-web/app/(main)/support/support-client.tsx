'use client'

import { useState, useEffect, useCallback } from 'react'
import { motion } from 'framer-motion'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  HelpCircle,
  Mail,
  MessageSquare,
  FileText,
  Send,
  Loader2,
  Clock,
  CheckCircle2,
  BookOpen,
  CreditCard,
  Shield,
  ChevronRight,
  RefreshCw,
  Wrench,
  Briefcase
} from 'lucide-react'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import { apiClient, getAccessToken } from '@/lib/api/client'
import { getFAQs } from '@/services/support.service'
import { useAuth } from '@/hooks/useAuth'

type SupportClientProps = {
  userEmail: string
}

/** FAQ item type */
interface FAQItem {
  question: string
  answer: string
  category: string
}

/**
 * Support client component
 * Professional design with contact form and FAQ
 */
export function SupportClient({ userEmail }: SupportClientProps) {
  const { user } = useAuth()
  const [subject, setSubject] = useState('')
  const [message, setMessage] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [faqs, setFaqs] = useState<FAQItem[]>([])
  const [category, setCategory] = useState('other')
  const [priority, setPriority] = useState('medium')
  const [projectId, setProjectId] = useState('')
  const [projects, setProjects] = useState<Array<{ id: string; project_number: string; subject: string }>>([])
  const [tickets, setTickets] = useState<Array<{ id: string; subject: string; status: string; category: string; priority: string; created_at?: string; createdAt?: string }>>([])
  const [ticketsLoading, setTicketsLoading] = useState(true)

  /** Load FAQs from database */
  useEffect(() => {
    const loadFaqs = async () => {
      try {
        const data = await getFAQs()
        setFaqs(data.map((faq) => ({
          question: faq.question,
          answer: faq.answer,
          category: faq.category,
        })))
      } catch (error) {
        console.error('Error loading FAQs:', error)
      }
    }
    loadFaqs()
  }, [])

  /** Load doer's projects */
  useEffect(() => {
    if (!user?.id) return
    const loadProjects = async () => {
      try {
        // Get the doer's ID
        const doerData = await apiClient<{ id: string }>(`/api/doers/me`)
        if (!doerData) return
        const data = await apiClient<Array<{ id: string; project_number: string; title: string }>>(
          `/api/projects?doer_id=${doerData.id}&fields=id,project_number,title&sort=-created_at`
        )
        if (data) setProjects(data.map((p: any) => ({ ...p, subject: p.title })) as any)
      } catch (error) {
        console.error('Error loading projects:', error)
      }
    }
    loadProjects()
  }, [user?.id])

  /** Load doer's support tickets */
  const loadTickets = useCallback(async () => {
    if (!user?.id) return
    setTicketsLoading(true)
    try {
      const data = await apiClient<any>(
        `/api/support/tickets?requester_id=${user.id}&sort=-created_at`
      )
      if (data) {
        const ticketsList = Array.isArray(data) ? data : (data.tickets || [])
        setTickets(ticketsList)
      }
    } catch (error) {
      console.error('Error loading tickets:', error)
    }
    setTicketsLoading(false)
  }, [user?.id])

  useEffect(() => {
    if (!user?.id) return
    loadTickets()

    // Poll for ticket updates every 30 seconds
    const interval = setInterval(loadTickets, 30000)
    return () => clearInterval(interval)
  }, [user?.id, loadTickets])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!subject.trim() || !message.trim()) {
      toast.error('Please fill in all fields')
      return
    }

    setIsSubmitting(true)

    try {
      await apiClient('/api/support/tickets', {
        method: 'POST',
        body: JSON.stringify({
          requester_id: user?.id,
          subject: subject.trim(),
          description: message.trim(),
          category,
          priority,
          project_id: projectId || null,
          status: 'open',
          source_role: 'doer',
        }),
      })

      toast.success('Support ticket submitted successfully!')
      setSubject('')
      setMessage('')
      setCategory('other')
      setPriority('medium')
      setProjectId('')
      loadTickets()
    } catch (error) {
      toast.error('Failed to submit support ticket')
      console.error('Error submitting ticket:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  /** Get category icon */
  const getCategoryIcon = (category: FAQItem['category']) => {
    switch (category) {
      case 'tasks':
        return FileText
      case 'payment':
        return CreditCard
      case 'quality':
        return Shield
      default:
        return HelpCircle
    }
  }

  return (
    <div className="relative space-y-8">
      {/* Radial gradient background overlay */}
      <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top,rgba(90,124,255,0.18),transparent_55%),radial-gradient(circle_at_80%_20%,rgba(67,209,197,0.16),transparent_50%)]" />

      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight text-slate-900">Help & Support</h1>
          <p className="text-slate-500">
            Get help with your tasks and platform features
          </p>
        </div>
        <Badge variant="secondary" className="w-fit gap-2 py-1.5 px-3 bg-[#E9FAFA] text-[#43D1C5] border-0">
          <Clock className="h-4 w-4 text-[#43D1C5]" />
          <span>Avg. response: 4 hours</span>
        </Badge>
      </div>

      {/* Quick Help Cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {[
          {
            icon: FileText,
            title: 'Accepting Tasks',
            description: 'Browse Open Pool and click Accept',
            bgColor: 'bg-[#E3E9FF]',
            iconColor: 'text-[#5A7CFF]',
          },
          {
            icon: CheckCircle2,
            title: 'Submit Work',
            description: 'Upload in project workspace',
            bgColor: 'bg-[#E9FAFA]',
            iconColor: 'text-[#43D1C5]',
          },
          {
            icon: CreditCard,
            title: 'Payments',
            description: 'Weekly payouts on Fridays',
            bgColor: 'bg-[#FFE7E1]',
            iconColor: 'text-[#FF8B6A]',
          },
          {
            icon: BookOpen,
            title: 'Resources',
            description: 'Guidelines and templates',
            bgColor: 'bg-[#EEF2FF]',
            iconColor: 'text-[#5B7CFF]',
          },
        ].map((item, index) => {
          const Icon = item.icon
          return (
            <motion.div
              key={item.title}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.1 }}
            >
              <Card className="cursor-pointer transition-all hover:shadow-lg hover:-translate-y-0.5 border-white/70 bg-white/85 shadow-[0_12px_28px_rgba(30,58,138,0.08)]">
                <CardContent className="p-4">
                  <div className="flex items-start gap-3">
                    <div className={cn(
                      "w-10 h-10 rounded-xl flex items-center justify-center shrink-0 shadow-sm",
                      item.bgColor
                    )}>
                      <Icon className={cn("h-5 w-5", item.iconColor)} />
                    </div>
                    <div>
                      <h3 className="font-medium text-sm text-slate-900">{item.title}</h3>
                      <p className="text-xs text-slate-600 mt-0.5">
                        {item.description}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          )
        })}
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        {/* Left Column: Contact Support + Contact Information */}
        <div className="space-y-6">
          {/* Contact Support Card */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.2 }}
          >
            <Card className="border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
              <CardHeader>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#5A7CFF] to-[#5B86FF] flex items-center justify-center shadow-lg">
                    <MessageSquare className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <CardTitle className="text-slate-900">Contact Support</CardTitle>
                    <CardDescription className="text-slate-600">
                      Submit a ticket and we'll respond within 24 hours
                    </CardDescription>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmit} className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="email">Your Email</Label>
                    <Input
                      id="email"
                      type="email"
                      value={userEmail}
                      disabled
                      className="bg-muted/50"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="subject">Subject</Label>
                    <Input
                      id="subject"
                      placeholder="Brief description of your issue"
                      value={subject}
                      onChange={(e) => setSubject(e.target.value)}
                      required
                    />
                  </div>

                  <div className="grid gap-4 sm:grid-cols-3">
                    <div className="space-y-2">
                      <Label>Category</Label>
                      <Select value={category} onValueChange={setCategory}>
                        <SelectTrigger>
                          <SelectValue placeholder="Select category" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="technical">Technical</SelectItem>
                          <SelectItem value="payment">Payment</SelectItem>
                          <SelectItem value="project">Project</SelectItem>
                          <SelectItem value="account">Account</SelectItem>
                          <SelectItem value="other">Other</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label>Priority</Label>
                      <Select value={priority} onValueChange={setPriority}>
                        <SelectTrigger>
                          <SelectValue placeholder="Select priority" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="low">Low</SelectItem>
                          <SelectItem value="medium">Medium</SelectItem>
                          <SelectItem value="high">High</SelectItem>
                          <SelectItem value="urgent">Urgent</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label>Related Project</Label>
                      <Select value={projectId || "none"} onValueChange={(val) => setProjectId(val === "none" ? "" : val)}>
                        <SelectTrigger>
                          <SelectValue placeholder="Select project (optional)" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="none">None</SelectItem>
                          {projects.map((p) => (
                            <SelectItem key={p.id} value={p.id}>
                              {p.project_number ? `${p.project_number} — ` : ''}{p.subject || 'Untitled'}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="message">Message</Label>
                    <Textarea
                      id="message"
                      placeholder="Describe your issue in detail..."
                      value={message}
                      onChange={(e) => setMessage(e.target.value)}
                      rows={5}
                      required
                    />
                  </div>

                  <Button
                    type="submit"
                    className="w-full gap-2 bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white shadow-[0_8px_20px_rgba(90,124,255,0.25)] hover:shadow-[0_12px_28px_rgba(90,124,255,0.35)] transition-all"
                    disabled={isSubmitting}
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
                </form>
              </CardContent>
            </Card>
          </motion.div>

          {/* Contact Information */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.3 }}
          >
            <Card className="border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
              <CardHeader>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-[#E9FAFA] flex items-center justify-center shadow-sm">
                    <Mail className="h-5 w-5 text-[#43D1C5]" />
                  </div>
                  <div>
                    <CardTitle className="text-slate-900">Contact Information</CardTitle>
                    <CardDescription className="text-slate-600">Other ways to reach us</CardDescription>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="grid gap-4 grid-cols-1 md:grid-cols-2 xl:grid-cols-3">
                <div className="p-3 rounded-xl bg-[#EEF2FF] border border-white/70 min-w-0">
                  <p className="text-xs text-slate-500 mb-1">Email Support</p>
                  <p className="font-medium text-sm text-slate-900 break-words">support@assignx.com</p>
                </div>
                <div className="p-3 rounded-xl bg-[#EEF2FF] border border-white/70 min-w-0">
                  <p className="text-xs text-slate-500 mb-1">Response Time</p>
                  <p className="font-medium text-sm text-slate-900 break-words">Within 24 hours</p>
                </div>
                <div className="p-3 rounded-xl bg-[#EEF2FF] border border-white/70 min-w-0">
                  <p className="text-xs text-slate-500 mb-1">Available</p>
                  <p className="font-medium text-sm text-slate-900 break-words">Mon-Fri, 9AM-6PM IST</p>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>

        {/* Right Column: FAQs */}
        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.4 }}
        >
          <Card className="border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
            <CardHeader>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#FFE7E1] flex items-center justify-center shadow-sm">
                  <HelpCircle className="h-5 w-5 text-[#FF8B6A]" />
                </div>
                <div>
                  <CardTitle className="text-slate-900">Frequently Asked Questions</CardTitle>
                  <CardDescription className="text-slate-600">Quick answers to common questions</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-2">
              {faqs.map((faq, index) => {
                const Icon = getCategoryIcon(faq.category)
                return (
                  <details
                    key={index}
                    className="group rounded-xl border border-white/70 bg-white/85 p-3 transition-all hover:bg-slate-50/50"
                  >
                    <summary className="flex items-center gap-3 cursor-pointer list-none">
                      <Icon className="h-4 w-4 text-slate-500 shrink-0" />
                      <span className="font-medium text-sm flex-1 text-slate-900">{faq.question}</span>
                      <ChevronRight className="h-4 w-4 text-slate-400 transition-transform group-open:rotate-90" />
                    </summary>
                    <p className="text-sm text-slate-600 mt-3 ml-7">
                      {faq.answer}
                    </p>
                  </details>
                )
              })}
            </CardContent>
          </Card>
        </motion.div>
      </div>

      {/* Ticket History */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
      >
        <Card className="border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
          <CardHeader>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-[#E3E9FF] flex items-center justify-center shadow-sm">
                <FileText className="h-5 w-5 text-[#5A7CFF]" />
              </div>
              <div>
                <CardTitle className="text-slate-900">My Tickets</CardTitle>
                <CardDescription className="text-slate-600">Track your support requests</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            {ticketsLoading ? (
              <div className="flex items-center justify-center py-8">
                <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
              </div>
            ) : tickets.length === 0 ? (
              <p className="text-sm text-slate-500 text-center py-8">No tickets yet. Submit a ticket above to get help.</p>
            ) : (
              <div className="space-y-3">
                {tickets.map((ticket) => (
                  <div
                    key={ticket.id}
                    className="flex items-center justify-between p-3 rounded-xl border border-white/70 bg-white/85 hover:bg-slate-50/50 transition-colors"
                  >
                    <div className="min-w-0 flex-1">
                      <p className="text-sm font-medium text-slate-900 truncate">{ticket.subject}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <Badge variant="outline" className="text-xs capitalize">{ticket.category}</Badge>
                        <Badge
                          variant="outline"
                          className={cn("text-xs capitalize", {
                            'border-green-200 text-green-700': ticket.status === 'resolved',
                            'border-blue-200 text-blue-700': ticket.status === 'open',
                            'border-yellow-200 text-yellow-700': ticket.status === 'in_progress',
                            'border-slate-200 text-slate-700': ticket.status === 'closed',
                          })}
                        >
                          {(ticket.status || '').replace('_', ' ')}
                        </Badge>
                        <span className="text-xs text-slate-400">
                          {new Date(ticket.createdAt || ticket.created_at || '').toLocaleDateString()}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </motion.div>
    </div>
  )
}
