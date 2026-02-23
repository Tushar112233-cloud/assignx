/**
 * @fileoverview Chat message input with file attachment support.
 * @module components/chat/message-input
 */

"use client"

import { useState, useRef, useCallback } from "react"
import {
  Send,
  Paperclip,
  X,
  FileText,
  AlertTriangle,
  Loader2,
} from "lucide-react"

import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { cn } from "@/lib/utils"
import { detectContactInfo, ContactDetectionResult } from "./types"

interface MessageInputProps {
  onSendMessage: (content: string, file?: File) => Promise<void>
  disabled?: boolean
  placeholder?: string
  maxFileSize?: number // in bytes
  allowedFileTypes?: string[]
}

interface AttachedFile {
  file: File
  preview?: string
  isImage: boolean
}

export function MessageInput({
  onSendMessage,
  disabled = false,
  placeholder = "Type a message...",
  maxFileSize = 10 * 1024 * 1024, // 10MB
  allowedFileTypes = [
    "image/*",
    "application/pdf",
    ".doc",
    ".docx",
    ".xls",
    ".xlsx",
    ".ppt",
    ".pptx",
    ".txt",
  ],
}: MessageInputProps) {
  const [message, setMessage] = useState("")
  const [attachedFile, setAttachedFile] = useState<AttachedFile | null>(null)
  const [isSending, setIsSending] = useState(false)
  const [contactWarning, setContactWarning] = useState<ContactDetectionResult | null>(null)
  const [showContactAlert, setShowContactAlert] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const textareaRef = useRef<HTMLTextAreaElement>(null)

  const handleFileSelect = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const file = e.target.files?.[0]
      if (!file) return

      // Validate file size
      if (file.size > maxFileSize) {
        alert(`File size must be less than ${maxFileSize / 1024 / 1024}MB`)
        return
      }

      const isImage = file.type.startsWith("image/")
      const preview = isImage ? URL.createObjectURL(file) : undefined

      setAttachedFile({ file, preview, isImage })

      // Reset input
      if (fileInputRef.current) {
        fileInputRef.current.value = ""
      }
    },
    [maxFileSize]
  )

  const removeAttachment = useCallback(() => {
    if (attachedFile?.preview) {
      URL.revokeObjectURL(attachedFile.preview)
    }
    setAttachedFile(null)
  }, [attachedFile])

  const handleMessageChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const value = e.target.value
    setMessage(value)

    // Check for contact info
    const detection = detectContactInfo(value)
    if (detection.detected) {
      setContactWarning(detection)
    } else {
      setContactWarning(null)
    }
  }

  const handleSend = async () => {
    if ((!message.trim() && !attachedFile) || disabled || isSending) return

    // If contact info detected, show warning
    if (contactWarning?.detected) {
      setShowContactAlert(true)
      return
    }

    await sendMessage()
  }

  const sendMessage = async () => {
    setIsSending(true)
    try {
      await onSendMessage(message.trim(), attachedFile?.file)
      setMessage("")
      removeAttachment()
      setContactWarning(null)
      textareaRef.current?.focus()
    } catch (error) {
      console.error("Failed to send message:", error)
    } finally {
      setIsSending(false)
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  return (
    <div className="border-t bg-background p-4">
      {/* Attached File Preview */}
      {attachedFile && (
        <div className="mb-3 p-3 rounded-lg bg-muted flex items-center gap-3">
          {attachedFile.isImage && attachedFile.preview ? (
            <img
              src={attachedFile.preview}
              alt="Preview"
              className="h-16 w-16 object-cover rounded-md"
            />
          ) : (
            <div className="h-16 w-16 rounded-md bg-background flex items-center justify-center">
              <FileText className="h-8 w-8 text-muted-foreground" />
            </div>
          )}
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">{attachedFile.file.name}</p>
            <p className="text-xs text-muted-foreground">
              {(attachedFile.file.size / 1024).toFixed(1)} KB
            </p>
          </div>
          <Button
            variant="ghost"
            size="icon"
            className="shrink-0"
            onClick={removeAttachment}
          >
            <X className="h-4 w-4" />
          </Button>
        </div>
      )}

      {/* Contact Warning Banner */}
      {contactWarning?.detected && (
        <div className="mb-3 p-3 rounded-lg bg-destructive/10 border border-destructive/20 flex items-start gap-2">
          <AlertTriangle className="h-4 w-4 text-destructive shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="text-sm font-medium text-destructive">
              Contact information detected
            </p>
            <p className="text-xs text-muted-foreground mt-0.5">
              Sharing contact details ({contactWarning.type}) is not allowed. Your
              message will be flagged if sent.
            </p>
          </div>
        </div>
      )}

      {/* Input Area */}
      <div className="flex items-end gap-2">
        {/* File Attachment Button */}
        <input
          ref={fileInputRef}
          type="file"
          className="hidden"
          accept={allowedFileTypes.join(",")}
          onChange={handleFileSelect}
        />
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="shrink-0"
                onClick={() => fileInputRef.current?.click()}
                disabled={disabled || isSending}
              >
                <Paperclip className="h-5 w-5" />
              </Button>
            </TooltipTrigger>
            <TooltipContent>Attach file</TooltipContent>
          </Tooltip>
        </TooltipProvider>

        {/* Message Input */}
        <div className="flex-1 relative">
          <Textarea
            ref={textareaRef}
            value={message}
            onChange={handleMessageChange}
            onKeyDown={handleKeyDown}
            placeholder={placeholder}
            disabled={disabled || isSending}
            className={cn(
              "min-h-[44px] max-h-[200px] resize-none pr-12",
              contactWarning?.detected && "border-destructive focus-visible:ring-destructive"
            )}
            rows={1}
          />
        </div>

        {/* Send Button */}
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger asChild>
              <Button
                size="icon"
                className="shrink-0"
                onClick={handleSend}
                disabled={(!message.trim() && !attachedFile) || disabled || isSending}
              >
                {isSending ? (
                  <Loader2 className="h-5 w-5 animate-spin" />
                ) : (
                  <Send className="h-5 w-5" />
                )}
              </Button>
            </TooltipTrigger>
            <TooltipContent>Send message</TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </div>

      {/* Contact Alert Dialog */}
      <AlertDialog open={showContactAlert} onOpenChange={setShowContactAlert}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2 text-destructive">
              <AlertTriangle className="h-5 w-5" />
              Contact Information Detected
            </AlertDialogTitle>
            <AlertDialogDescription>
              Your message appears to contain contact information (
              {contactWarning?.type}). Sharing personal contact details is against
              our policies and may result in account suspension.
              <br />
              <br />
              If you send this message, it will be flagged for review.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Edit Message</AlertDialogCancel>
            <AlertDialogAction
              className="bg-destructive hover:bg-destructive/90"
              onClick={() => {
                setShowContactAlert(false)
                sendMessage()
              }}
            >
              Send Anyway (Will be flagged)
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
