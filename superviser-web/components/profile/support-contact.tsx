/**
 * @fileoverview Support contact information and quick links component.
 * @module components/profile/support-contact
 */

"use client"

import { useState } from "react"
import {
  Phone,
  Mail,
  MessageCircle,
  Clock,
  ExternalLink,
  Copy,
  Check,
  HelpCircle,
  FileText,
  HeadphonesIcon,
} from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { toast } from "sonner"
import { cn } from "@/lib/utils"
import { SupportContact as SupportContactType } from "./types"

// Mock support contacts
const SUPPORT_CONTACTS: SupportContactType[] = [
  {
    type: "email",
    value: "support@adminx.com",
    label: "Email Support",
    available_hours: "24/7 - Response within 24 hours",
  },
  {
    type: "phone",
    value: "+91 1800-123-4567",
    label: "Phone Support",
    available_hours: "Mon-Sat, 9 AM - 6 PM IST",
  },
  {
    type: "chat",
    value: "Live Chat",
    label: "Live Chat",
    available_hours: "Mon-Sat, 9 AM - 9 PM IST",
  },
]

interface ContactCardProps {
  contact: SupportContactType
}

function ContactCard({ contact }: ContactCardProps) {
  const [copied, setCopied] = useState(false)

  const handleCopy = () => {
    if (contact.type === "chat") return
    navigator.clipboard.writeText(contact.value)
    setCopied(true)
    toast.success("Copied to clipboard")
    setTimeout(() => setCopied(false), 2000)
  }

  const getIcon = () => {
    switch (contact.type) {
      case "email":
        return <Mail className="h-6 w-6" />
      case "phone":
        return <Phone className="h-6 w-6" />
      case "chat":
        return <MessageCircle className="h-6 w-6" />
      default:
        return <HelpCircle className="h-6 w-6" />
    }
  }

  const getIconBg = () => {
    switch (contact.type) {
      case "email":
        return "bg-blue-100 text-blue-600"
      case "phone":
        return "bg-green-100 text-green-600"
      case "chat":
        return "bg-purple-100 text-purple-600"
      default:
        return "bg-muted text-muted-foreground"
    }
  }

  return (
    <Card className="transition-all hover:shadow-md">
      <CardContent className="pt-6">
        <div className="space-y-4">
          <div className="flex items-start justify-between gap-3">
            <div className="flex items-start gap-3">
              <div
                className={cn(
                  "h-12 w-12 rounded-lg flex items-center justify-center shrink-0",
                  getIconBg()
                )}
              >
                {getIcon()}
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="font-semibold text-base text-[#1C1C1C]">
                  {contact.label}
                </h3>
                {contact.type !== "chat" && (
                  <p className="text-base font-medium mt-1 text-[#1C1C1C] break-all">
                    {contact.value}
                  </p>
                )}
              </div>
            </div>
            {contact.type !== "chat" ? (
              <Button
                variant="outline"
                size="sm"
                onClick={handleCopy}
                className="shrink-0 h-9 px-3"
              >
                {copied ? (
                  <>
                    <Check className="h-4 w-4 mr-1.5" />
                    <span className="whitespace-nowrap">Copied</span>
                  </>
                ) : (
                  <>
                    <Copy className="h-4 w-4 mr-1.5" />
                    <span className="whitespace-nowrap">Copy</span>
                  </>
                )}
              </Button>
            ) : (
              <Button variant="default" size="sm" className="shrink-0 h-9 px-3 bg-[#1C1C1C] hover:bg-[#2C2C2C]">
                <ExternalLink className="h-4 w-4 mr-1.5" />
                <span className="whitespace-nowrap">Start Chat</span>
              </Button>
            )}
          </div>
          {contact.available_hours && (
            <div className="flex items-center gap-1.5 text-sm text-gray-500">
              <Clock className="h-3.5 w-3.5 shrink-0" />
              <span>{contact.available_hours}</span>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
}

export function SupportContact() {
  return (
    <div className="space-y-6">
      {/* Header */}
      <Card>
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="h-12 w-12 rounded-full bg-primary/10 flex items-center justify-center">
              <HeadphonesIcon className="h-6 w-6 text-primary" />
            </div>
            <div>
              <CardTitle>Need Help?</CardTitle>
              <CardDescription>
                Our support team is here to assist you
              </CardDescription>
            </div>
          </div>
        </CardHeader>
      </Card>

      {/* Contact Options */}
      <div className="grid gap-4 md:grid-cols-3">
        {SUPPORT_CONTACTS.map((contact, index) => (
          <ContactCard key={index} contact={contact} />
        ))}
      </div>

      {/* Quick Links */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Quick Links</CardTitle>
          <CardDescription>Helpful resources and documentation</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-3 md:grid-cols-2">
            <Button
              variant="outline"
              className="justify-start h-auto py-4"
              asChild
            >
              <a href="/support/faq">
                <HelpCircle className="h-5 w-5 mr-3 text-blue-600" />
                <div className="text-left">
                  <p className="font-medium">FAQs</p>
                  <p className="text-xs text-muted-foreground">
                    Find answers to common questions
                  </p>
                </div>
              </a>
            </Button>
            <Button
              variant="outline"
              className="justify-start h-auto py-4"
              asChild
            >
              <a href="/support/tickets">
                <FileText className="h-5 w-5 mr-3 text-green-600" />
                <div className="text-left">
                  <p className="font-medium">Support Tickets</p>
                  <p className="text-xs text-muted-foreground">
                    View or create support tickets
                  </p>
                </div>
              </a>
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Priority Support */}
      <Card className="border-amber-200 dark:border-amber-900 bg-amber-50/50 dark:bg-amber-950/20">
        <CardContent className="pt-6">
          <div className="flex items-start gap-4">
            <div className="h-12 w-12 rounded-lg bg-amber-100 flex items-center justify-center shrink-0">
              <Clock className="h-6 w-6 text-amber-600" />
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-1">
                <p className="font-semibold">Priority Support</p>
                <Badge variant="secondary" className="bg-amber-100 text-amber-700">
                  Urgent
                </Badge>
              </div>
              <p className="text-sm text-muted-foreground mb-3">
                For urgent issues affecting your active projects, use our priority
                support line for faster response times.
              </p>
              <Button variant="outline" className="bg-white dark:bg-background">
                <Phone className="h-4 w-4 mr-2" />
                +91 1800-123-9999
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
