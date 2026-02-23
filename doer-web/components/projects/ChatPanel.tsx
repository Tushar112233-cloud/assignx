'use client'

import { useState, useRef, useEffect, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Send,
  Paperclip,
  Image as ImageIcon,
  File,
  Loader2,
  CheckCheck,
  Clock,
  X,
} from 'lucide-react'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { ScrollArea } from '@/components/ui/scroll-area'
import { cn } from '@/lib/utils'
import type { ChatMessage } from '@/types/database'

interface ChatPanelProps {
  /** Chat room ID */
  roomId: string
  /** Current user ID */
  currentUserId: string
  /** Current user name */
  currentUserName: string
  /** Current user avatar */
  currentUserAvatar?: string
  /** Messages to display */
  messages: ChatMessage[]
  /** Loading state */
  isLoading?: boolean
  /** Sending state */
  isSending?: boolean
  /** Has more messages to load */
  hasMore?: boolean
  /** Callback to send message */
  onSendMessage?: (content: string) => Promise<void>
  /** Callback to send file */
  onSendFile?: (file: File) => Promise<void>
  /** Callback to load more messages */
  onLoadMore?: () => void
  /** Additional class name */
  className?: string
}

/**
 * Chat panel component for supervisor communication
 * Real-time messaging with file attachments
 */
export function ChatPanel({
  roomId,
  currentUserId,
  currentUserName,
  currentUserAvatar,
  messages,
  isLoading = false,
  isSending = false,
  hasMore = false,
  onSendMessage,
  onSendFile,
  onLoadMore,
  className,
}: ChatPanelProps) {
  const [inputValue, setInputValue] = useState('')
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const scrollRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  /** Auto-scroll to bottom on new messages */
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight
    }
  }, [messages])

  /** Handle send message */
  const handleSend = useCallback(async () => {
    if (!onSendMessage || (!inputValue.trim() && !selectedFile)) return

    try {
      if (selectedFile && onSendFile) {
        await onSendFile(selectedFile)
        setSelectedFile(null)
      }

      if (inputValue.trim()) {
        await onSendMessage(inputValue.trim())
        setInputValue('')
      }

      inputRef.current?.focus()
    } catch (error) {
      console.error('Failed to send message:', error)
    }
  }, [inputValue, selectedFile, onSendMessage, onSendFile])

  /** Handle key press */
  const handleKeyPress = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault()
        handleSend()
      }
    },
    [handleSend]
  )

  /** Handle file selection */
  const handleFileSelect = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const file = e.target.files?.[0]
      if (file) {
        setSelectedFile(file)
      }
    },
    []
  )

  /** Format timestamp */
  const formatTime = (timestamp: string) => {
    const date = new Date(timestamp)
    return date.toLocaleTimeString('en-IN', {
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  /** Format date for separator */
  const formatDate = (timestamp: string) => {
    const date = new Date(timestamp)
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(yesterday.getDate() - 1)

    if (date.toDateString() === today.toDateString()) {
      return 'Today'
    }
    if (date.toDateString() === yesterday.toDateString()) {
      return 'Yesterday'
    }
    return date.toLocaleDateString('en-IN', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    })
  }

  /** Check if should show date separator */
  const shouldShowDateSeparator = (
    current: ChatMessage,
    previous: ChatMessage | null
  ) => {
    if (!previous) return true
    const currentDate = new Date(current.created_at).toDateString()
    const previousDate = new Date(previous.created_at).toDateString()
    return currentDate !== previousDate
  }

  /** Render message bubble */
  const renderMessage = (message: ChatMessage, index: number) => {
    const isOwn = message.sender_id === currentUserId
    const previous = index > 0 ? messages[index - 1] : null
    const showDateSeparator = shouldShowDateSeparator(message, previous)
    const showAvatar = !previous || previous.sender_id !== message.sender_id

    return (
      <div key={message.id}>
        {/* Date separator */}
        {showDateSeparator && (
          <div className="flex items-center justify-center my-4">
            <span className="text-xs text-muted-foreground bg-muted px-3 py-1 rounded-full">
              {formatDate(message.created_at)}
            </span>
          </div>
        )}

        {/* Message */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          className={cn(
            'flex gap-2 mb-2',
            isOwn ? 'flex-row-reverse' : 'flex-row'
          )}
        >
          {/* Avatar */}
          {showAvatar && !isOwn ? (
            <Avatar className="h-8 w-8 flex-shrink-0">
              <AvatarImage src={message.sender_avatar || undefined} />
              <AvatarFallback className="text-xs">
                {message.sender_name
                  ?.split(' ')
                  .map((n) => n[0])
                  .join('')}
              </AvatarFallback>
            </Avatar>
          ) : (
            <div className="w-8" />
          )}

          {/* Bubble */}
          <div
            className={cn(
              'max-w-[70%] rounded-2xl px-4 py-2',
              isOwn
                ? 'bg-primary text-primary-foreground rounded-br-md'
                : 'bg-muted rounded-bl-md'
            )}
          >
            {/* Sender name */}
            {showAvatar && !isOwn && (
              <p className="text-xs font-medium mb-1 opacity-70">
                {message.sender_name}
              </p>
            )}

            {/* Content */}
            {message.message_type === 'text' && (
              <p className="text-sm whitespace-pre-wrap break-words">
                {message.content}
              </p>
            )}

            {/* File attachment */}
            {message.message_type === 'file' && (
              <a
                href={message.file_url || '#'}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 hover:opacity-80"
              >
                <File className="h-4 w-4" />
                <span className="text-sm underline">{message.file_name}</span>
              </a>
            )}

            {/* Image attachment */}
            {message.message_type === 'image' && message.file_url && (
              <a
                href={message.file_url}
                target="_blank"
                rel="noopener noreferrer"
              >
                <img
                  src={message.file_url}
                  alt={message.file_name || 'Image'}
                  className="max-w-full rounded-lg max-h-48 object-cover"
                />
              </a>
            )}

            {/* System message */}
            {message.message_type === 'system' && (
              <p className="text-sm italic opacity-70">{message.content}</p>
            )}

            {/* Timestamp and status */}
            <div
              className={cn(
                'flex items-center gap-1 mt-1',
                isOwn ? 'justify-end' : 'justify-start'
              )}
            >
              <span className="text-[10px] opacity-60">
                {formatTime(message.created_at)}
              </span>
              {isOwn && (
                <span className="opacity-60">
                  {(message.read_by?.length || 0) > 1 ? (
                    <CheckCheck className="h-3 w-3" />
                  ) : (
                    <Clock className="h-3 w-3" />
                  )}
                </span>
              )}
            </div>
          </div>
        </motion.div>
      </div>
    )
  }

  return (
    <div className={cn('flex flex-col h-full', className)}>
      {/* Messages area */}
      <ScrollArea ref={scrollRef} className="flex-1 p-4">
        {/* Load more button */}
        {hasMore && (
          <div className="text-center mb-4">
            <Button
              variant="ghost"
              size="sm"
              onClick={onLoadMore}
              disabled={isLoading}
            >
              {isLoading ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                'Load older messages'
              )}
            </Button>
          </div>
        )}

        {/* Loading state */}
        {isLoading && messages.length === 0 && (
          <div className="flex items-center justify-center h-full">
            <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
          </div>
        )}

        {/* Empty state */}
        {!isLoading && messages.length === 0 && (
          <div className="flex flex-col items-center justify-center h-full text-center">
            <p className="text-muted-foreground">No messages yet</p>
            <p className="text-sm text-muted-foreground mt-1">
              Start the conversation with your supervisor
            </p>
          </div>
        )}

        {/* Messages */}
        <AnimatePresence initial={false}>
          {messages.map((message, index) => renderMessage(message, index))}
        </AnimatePresence>

        {/* Sending indicator */}
        {isSending && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="flex justify-end mb-2"
          >
            <div className="bg-primary/10 rounded-full px-3 py-1">
              <Loader2 className="h-4 w-4 animate-spin text-primary" />
            </div>
          </motion.div>
        )}
      </ScrollArea>

      {/* Selected file preview */}
      {selectedFile && (
        <div className="px-4 py-2 bg-muted/50 flex items-center gap-2">
          {selectedFile.type.startsWith('image/') ? (
            <ImageIcon className="h-4 w-4 text-muted-foreground" />
          ) : (
            <File className="h-4 w-4 text-muted-foreground" />
          )}
          <span className="text-sm flex-1 truncate">{selectedFile.name}</span>
          <Button
            variant="ghost"
            size="icon"
            className="h-6 w-6"
            onClick={() => setSelectedFile(null)}
          >
            <X className="h-4 w-4" />
          </Button>
        </div>
      )}

      {/* Input area */}
      <div className="p-4 border-t bg-background">
        <div className="flex items-center gap-2">
          {/* File attachment button */}
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*,.pdf,.doc,.docx"
            onChange={handleFileSelect}
            className="hidden"
          />
          <Button
            variant="ghost"
            size="icon"
            onClick={() => fileInputRef.current?.click()}
            disabled={isSending}
          >
            <Paperclip className="h-5 w-5" />
          </Button>

          {/* Message input */}
          <Input
            ref={inputRef}
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            onKeyDown={handleKeyPress}
            placeholder="Type a message..."
            disabled={isSending}
            className="flex-1"
          />

          {/* Send button */}
          <Button
            size="icon"
            onClick={handleSend}
            disabled={isSending || (!inputValue.trim() && !selectedFile)}
          >
            {isSending ? (
              <Loader2 className="h-5 w-5 animate-spin" />
            ) : (
              <Send className="h-5 w-5" />
            )}
          </Button>
        </div>
      </div>
    </div>
  )
}
