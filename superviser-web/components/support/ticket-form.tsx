/**
 * @fileoverview Support ticket creation form with category selection.
 * Redesigned to match dashboard design system.
 * @module components/support/ticket-form
 */

"use client"

import { useState } from "react"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import * as z from "zod"
import { motion } from "framer-motion"
import {
  Wrench,
  CreditCard,
  Briefcase,
  User,
  HelpCircle,
  Upload,
  X,
  Loader2,
} from "lucide-react"

import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Button } from "@/components/ui/button"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Badge } from "@/components/ui/badge"
import { toast } from "sonner"
import { cn } from "@/lib/utils"
import { useCreateTicket } from "@/hooks/use-support"
import { useProjects } from "@/hooks/use-projects"
import { TicketCategory, TicketPriority, TICKET_CATEGORY_CONFIG, TICKET_PRIORITY_CONFIG } from "./types"

const ICONS: Record<string, React.ComponentType<{ className?: string }>> = {
  Wrench,
  CreditCard,
  Briefcase,
  User,
  HelpCircle,
}

const ticketSchema = z.object({
  subject: z.string().min(5, "Subject must be at least 5 characters"),
  category: z.enum(["technical", "payment", "project", "account", "other"]),
  priority: z.enum(["low", "medium", "high", "urgent"]),
  project_id: z.string().optional(),
  description: z.string().min(20, "Please provide more details (at least 20 characters)"),
})

type TicketFormData = z.infer<typeof ticketSchema>

interface TicketFormProps {
  onSuccess?: () => void
  onCancel?: () => void
}

export function TicketForm({ onSuccess, onCancel }: TicketFormProps) {
  const [attachments, setAttachments] = useState<File[]>([])
  const { projects, isLoading: projectsLoading } = useProjects()
  const { createTicket, isCreating } = useCreateTicket()

  const form = useForm<TicketFormData>({
    resolver: zodResolver(ticketSchema),
    defaultValues: {
      subject: "",
      category: "other",
      priority: "medium",
      project_id: "",
      description: "",
    },
  })

  const handleSubmit = async (data: TicketFormData) => {
    try {
      await createTicket({
        subject: data.subject,
        description: data.description,
        category: data.category,
        priority: data.priority as TicketPriority,
        project_id: data.project_id || undefined,
      })

      toast.success("Ticket created successfully!")
      form.reset()
      setAttachments([])
      onSuccess?.()
    } catch {
      toast.error("Failed to create ticket. Please try again.")
    }
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || [])
    const maxSize = 5 * 1024 * 1024
    const validFiles = files.filter((file) => {
      if (file.size > maxSize) {
        toast.error(`${file.name} is too large. Max size is 5MB.`)
        return false
      }
      return true
    })
    setAttachments((prev) => [...prev, ...validFiles].slice(0, 5))
  }

  const removeAttachment = (index: number) => {
    setAttachments((prev) => prev.filter((_, i) => i !== index))
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
      className="rounded-2xl border border-gray-200 bg-white overflow-hidden"
    >
      <div className="p-6 border-b border-gray-100">
        <h3 className="text-lg font-semibold text-[#1C1C1C]">Create Support Ticket</h3>
        <p className="text-sm text-gray-500 mt-1">
          Describe your issue and our support team will get back to you within 24 hours.
        </p>
      </div>

      <div className="p-6">
        <Form {...form}>
          <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-6">
            {/* Category Selection */}
            <FormField
              control={form.control}
              name="category"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-medium text-[#1C1C1C]">Category</FormLabel>
                  <div className="grid grid-cols-2 md:grid-cols-5 gap-2">
                    {(Object.entries(TICKET_CATEGORY_CONFIG) as [TicketCategory, { label: string; icon: string }][]).map(
                      ([key, config]) => {
                        const IconComponent = ICONS[config.icon] || HelpCircle
                        const isSelected = field.value === key
                        return (
                          <button
                            key={key}
                            type="button"
                            className={cn(
                              "flex flex-col items-center gap-1.5 py-3 px-2 rounded-xl border text-sm font-medium transition-all duration-200",
                              isSelected
                                ? "bg-orange-50 border-orange-200 text-[#F97316]"
                                : "bg-white border-gray-200 text-gray-600 hover:border-gray-300 hover:bg-gray-50"
                            )}
                            onClick={() => field.onChange(key)}
                          >
                            <IconComponent className="h-5 w-5" />
                            <span className="text-xs">{config.label}</span>
                          </button>
                        )
                      }
                    )}
                  </div>
                  <FormMessage />
                </FormItem>
              )}
            />

            {/* Subject */}
            <FormField
              control={form.control}
              name="subject"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-medium text-[#1C1C1C]">Subject</FormLabel>
                  <FormControl>
                    <Input
                      placeholder="Brief summary of your issue"
                      className="rounded-xl border-gray-200 focus:border-orange-300 focus:ring-orange-200"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="grid gap-4 md:grid-cols-2">
              {/* Priority */}
              <FormField
                control={form.control}
                name="priority"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-sm font-medium text-[#1C1C1C]">Priority</FormLabel>
                    <Select value={field.value} onValueChange={field.onChange}>
                      <FormControl>
                        <SelectTrigger className="rounded-xl border-gray-200">
                          <SelectValue placeholder="Select priority" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {(Object.entries(TICKET_PRIORITY_CONFIG) as [TicketPriority, { label: string; color: string }][]).map(
                          ([key, config]) => (
                            <SelectItem key={key} value={key}>
                              <div className="flex items-center gap-2">
                                <Badge variant="outline" className={cn("text-xs", config.color)}>
                                  {config.label}
                                </Badge>
                              </div>
                            </SelectItem>
                          )
                        )}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* Related Project */}
              <FormField
                control={form.control}
                name="project_id"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-sm font-medium text-[#1C1C1C]">Related Project (Optional)</FormLabel>
                    <Select value={field.value || ""} onValueChange={field.onChange}>
                      <FormControl>
                        <SelectTrigger className="rounded-xl border-gray-200">
                          <SelectValue placeholder="Select a project" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {projectsLoading ? (
                          <SelectItem value="_loading" disabled>Loading projects...</SelectItem>
                        ) : projects.length === 0 ? (
                          <SelectItem value="_empty" disabled>No projects found</SelectItem>
                        ) : (
                          projects.map((p) => (
                            <SelectItem key={p.id} value={p.id}>
                              {p.project_number ? `${p.project_number} — ` : ""}{p.subjects?.name || p.title || "Untitled Project"}
                            </SelectItem>
                          ))
                        )}
                      </SelectContent>
                    </Select>
                    <FormDescription className="text-xs">
                      If this is about a specific project
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            {/* Description */}
            <FormField
              control={form.control}
              name="description"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-medium text-[#1C1C1C]">Description</FormLabel>
                  <FormControl>
                    <Textarea
                      placeholder="Please describe your issue in detail. Include any error messages, steps to reproduce, and what you've already tried."
                      className="min-h-[150px] rounded-xl border-gray-200 focus:border-orange-300 focus:ring-orange-200"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            {/* Attachments */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-[#1C1C1C]">Attachments (Optional)</label>
              <div className="flex flex-wrap gap-2">
                {attachments.map((file, index) => (
                  <span
                    key={index}
                    className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-gray-100 text-xs text-gray-700"
                  >
                    {file.name}
                    <X
                      className="h-3 w-3 cursor-pointer hover:text-red-500 transition-colors"
                      onClick={() => removeAttachment(index)}
                    />
                  </span>
                ))}
                {attachments.length < 5 && (
                  <label className="cursor-pointer">
                    <input
                      type="file"
                      className="hidden"
                      multiple
                      accept="image/*,.pdf,.doc,.docx,.txt"
                      onChange={handleFileChange}
                    />
                    <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full border border-dashed border-gray-300 text-xs text-gray-500 hover:border-orange-300 hover:text-[#F97316] transition-colors cursor-pointer">
                      <Upload className="h-3 w-3" />
                      Add file
                    </span>
                  </label>
                )}
              </div>
              <p className="text-xs text-gray-400">
                Max 5 files, 5MB each. Accepted: Images, PDF, DOC, TXT
              </p>
            </div>

            {/* Actions */}
            <div className="flex justify-end gap-3 pt-2">
              {onCancel && (
                <Button
                  type="button"
                  variant="outline"
                  onClick={onCancel}
                  className="rounded-full px-6 border-gray-200"
                >
                  Cancel
                </Button>
              )}
              <Button
                type="submit"
                disabled={isCreating}
                className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-full px-6 font-medium shadow-lg shadow-orange-500/20 hover:shadow-xl hover:shadow-orange-500/30 transition-all duration-200"
              >
                {isCreating ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Creating...
                  </>
                ) : (
                  "Create Ticket"
                )}
              </Button>
            </div>
          </form>
        </Form>
      </div>
    </motion.div>
  )
}
