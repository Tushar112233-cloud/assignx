/**
 * @fileoverview Type definitions for the chat module.
 * @module components/chat/types
 */

// Re-export shared types from central database types
export type { ChatRoomType, MessageType } from "@/types/database"
import type { ChatRoomType, MessageType } from "@/types/database"

export interface ChatRoom {
  id: string
  project_id?: string
  project_number?: string
  type: ChatRoomType
  name: string
  participants: ChatParticipant[]
  last_message?: ChatMessage
  unread_count: number
  is_suspended?: boolean
  suspension_reason?: string
  created_at: string
  updated_at: string
}

export interface ChatParticipant {
  id: string
  user_id: string
  name: string
  avatar_url?: string
  role: "user" | "supervisor" | "doer" | "support"
  is_online?: boolean
  last_seen_at?: string
  joined_at: string
}

export interface ChatMessage {
  id: string
  room_id: string
  sender_id: string
  sender_name: string
  sender_role: "user" | "supervisor" | "doer" | "support" | "system"
  type: MessageType
  content: string
  file_url?: string
  file_name?: string
  file_size?: number
  file_type?: string
  is_contact_flagged?: boolean
  is_read: boolean
  read_at?: string
  created_at: string
  updated_at?: string
}

export interface ContactDetectionResult {
  detected: boolean
  type?: "phone" | "email" | "social" | "url"
  value?: string
}

export const CHAT_ROOM_TYPE_CONFIG: Record<
  ChatRoomType,
  { label: string; description: string; icon: string }
> = {
  project_user_supervisor: {
    label: "Client Chat",
    description: "Private chat with the client",
    icon: "user",
  },
  project_supervisor_doer: {
    label: "Expert Chat",
    description: "Private chat with the expert",
    icon: "user-cog",
  },
  project_all: {
    label: "Group Chat",
    description: "All parties can see messages",
    icon: "users",
  },
  support: {
    label: "Support",
    description: "Support ticket conversation",
    icon: "life-buoy",
  },
  direct: {
    label: "Direct Message",
    description: "Direct conversation",
    icon: "message-circle",
  },
}

// Contact detection patterns
export const CONTACT_PATTERNS = {
  phone: /(?:\+?[\d\s\-()]{10,})/g,
  email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g,
  social: /(?:@[\w]+|(?:instagram|twitter|facebook|linkedin|whatsapp|telegram|discord)[\s:]*[\w@/.]+)/gi,
  url: /(?:https?:\/\/)?(?:www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\/\S*)?/gi,
}

export function detectContactInfo(text: string): ContactDetectionResult {
  for (const [type, pattern] of Object.entries(CONTACT_PATTERNS)) {
    const match = text.match(pattern)
    if (match) {
      return {
        detected: true,
        type: type as ContactDetectionResult["type"],
        value: match[0],
      }
    }
  }
  return { detected: false }
}
