/**
 * @fileoverview Main chat window component with message display and input.
 * @module components/chat/chat-window
 */

"use client"

import { useState } from "react"
import { format } from "date-fns"
import {
  Users,
  User,
  UserCog,
  MoreVertical,
  AlertOctagon,
  ShieldAlert,
  CheckCircle,
  Phone,
  Video,
  Info,
  ArrowLeft,
} from "lucide-react"
import Link from "next/link"

import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Separator } from "@/components/ui/separator"
import { cn } from "@/lib/utils"
import { MessageList } from "./message-list"
import { MessageInput } from "./message-input"
import {
  ChatRoom,
  ChatMessage,
  ChatParticipant,
  ChatRoomType,
  CHAT_ROOM_TYPE_CONFIG,
} from "./types"

interface ChatWindowProps {
  projectId: string
  projectNumber: string
  rooms: ChatRoom[]
  currentUserId: string
  onSendMessage: (roomId: string, content: string, file?: File) => Promise<void>
  onSuspendChat: (roomId: string, reason: string) => Promise<void>
  onResumeChat: (roomId: string) => Promise<void>
  onDownloadFile?: (message: ChatMessage) => void
}

function getRoomIcon(type: ChatRoomType) {
  switch (type) {
    case "project_user_supervisor":
      return User
    case "project_supervisor_doer":
      return UserCog
    case "project_all":
      return Users
    default:
      return Users
  }
}

function ParticipantsList({ participants }: { participants: ChatParticipant[] }) {
  return (
    <div className="space-y-3">
      {participants.map((participant) => (
        <div key={participant.id} className="flex items-center gap-3">
          <div className="relative">
            <Avatar className="h-10 w-10">
              <AvatarImage src={participant.avatar_url} />
              <AvatarFallback>
                {participant.name
                  .split(" ")
                  .map((n) => n[0])
                  .join("")
                  .toUpperCase()
                  .slice(0, 2)}
              </AvatarFallback>
            </Avatar>
            {participant.is_online && (
              <span className="absolute bottom-0 right-0 h-3 w-3 rounded-full bg-green-500 border-2 border-background" />
            )}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">{participant.name}</p>
            <div className="flex items-center gap-2">
              <Badge variant="outline" className="text-[10px] px-1.5 py-0">
                {participant.role}
              </Badge>
              {!participant.is_online && participant.last_seen_at && (
                <span className="text-[10px] text-muted-foreground">
                  Last seen {format(new Date(participant.last_seen_at), "MMM d, h:mm a")}
                </span>
              )}
            </div>
          </div>
        </div>
      ))}
    </div>
  )
}

export function ChatWindow({
  projectId,
  projectNumber,
  rooms,
  currentUserId,
  onSendMessage,
  onSuspendChat,
  onResumeChat,
  onDownloadFile,
}: ChatWindowProps) {
  const [activeRoomId, setActiveRoomId] = useState(rooms[0]?.id || "")
  const [suspendDialogOpen, setSuspendDialogOpen] = useState(false)
  const [suspendReason, setSuspendReason] = useState("")
  const [roomToSuspend, setRoomToSuspend] = useState<string | null>(null)

  const activeRoom = rooms.find((r) => r.id === activeRoomId)

  const handleSuspend = async () => {
    if (!roomToSuspend || !suspendReason.trim()) return
    await onSuspendChat(roomToSuspend, suspendReason)
    setSuspendDialogOpen(false)
    setSuspendReason("")
    setRoomToSuspend(null)
  }

  const openSuspendDialog = (roomId: string) => {
    setRoomToSuspend(roomId)
    setSuspendDialogOpen(true)
  }

  return (
    <div className="flex flex-col h-full bg-gradient-to-br from-gray-50 via-orange-50/20 to-gray-50">
      {/* Header */}
      <div className="relative bg-white/80 backdrop-blur-sm border-b border-gray-200/80 shadow-sm">
        <div className="absolute inset-0 bg-gradient-to-r from-orange-500/5 via-transparent to-orange-500/5" />
        <div className="relative flex items-center gap-4 p-6">
          <Button
            variant="ghost"
            size="icon"
            asChild
            className="rounded-full hover:bg-orange-50 hover:text-orange-600 transition-colors"
          >
            <Link href={`/projects/${projectId}`}>
              <ArrowLeft className="h-5 w-5" />
            </Link>
          </Button>

          <div className="flex-1 min-w-0">
            <h2 className="text-xl font-bold text-[#1C1C1C] truncate">Project Chat</h2>
            <p className="text-sm text-gray-600 font-medium">{projectNumber}</p>
          </div>

          {/* Room Info Sheet */}
          <Sheet>
            <SheetTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="rounded-full hover:bg-orange-50 hover:text-orange-600 transition-colors"
              >
                <Info className="h-5 w-5" />
              </Button>
            </SheetTrigger>
          <SheetContent>
            <SheetHeader>
              <SheetTitle>Chat Details</SheetTitle>
              <SheetDescription>
                Participants and chat information
              </SheetDescription>
            </SheetHeader>
            <div className="mt-6 space-y-6">
              {activeRoom && (
                <>
                  <div>
                    <h4 className="text-sm font-medium mb-3">Chat Type</h4>
                    <div className="flex items-center gap-2">
                      {(() => {
                        const Icon = getRoomIcon(activeRoom.type)
                        return <Icon className="h-4 w-4" />
                      })()}
                      <span className="text-sm">
                        {CHAT_ROOM_TYPE_CONFIG[activeRoom.type].label}
                      </span>
                    </div>
                    <p className="text-xs text-muted-foreground mt-1">
                      {CHAT_ROOM_TYPE_CONFIG[activeRoom.type].description}
                    </p>
                  </div>

                  <Separator />

                  <div>
                    <h4 className="text-sm font-medium mb-3">
                      Participants ({activeRoom.participants.length})
                    </h4>
                    <ParticipantsList participants={activeRoom.participants} />
                  </div>

                  {activeRoom.is_suspended && (
                    <>
                      <Separator />
                      <div className="p-3 rounded-lg bg-destructive/10 border border-destructive/20">
                        <div className="flex items-center gap-2 text-destructive">
                          <ShieldAlert className="h-4 w-4" />
                          <span className="text-sm font-medium">
                            Chat Suspended
                          </span>
                        </div>
                        {activeRoom.suspension_reason && (
                          <p className="text-xs text-muted-foreground mt-2">
                            Reason: {activeRoom.suspension_reason}
                          </p>
                        )}
                      </div>
                    </>
                  )}
                </>
              )}
            </div>
          </SheetContent>
        </Sheet>

          {/* Chat Actions */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="rounded-full hover:bg-orange-50 hover:text-orange-600 transition-colors"
              >
                <MoreVertical className="h-5 w-5" />
              </Button>
            </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            {activeRoom?.is_suspended ? (
              <DropdownMenuItem onClick={() => onResumeChat(activeRoom.id)}>
                <CheckCircle className="h-4 w-4 mr-2" />
                Resume Chat
              </DropdownMenuItem>
            ) : (
              <DropdownMenuItem
                className="text-destructive"
                onClick={() => activeRoom && openSuspendDialog(activeRoom.id)}
              >
                <AlertOctagon className="h-4 w-4 mr-2" />
                Suspend Chat
              </DropdownMenuItem>
            )}
            <DropdownMenuSeparator />
            <DropdownMenuItem>
              <Phone className="h-4 w-4 mr-2" />
              Voice Call
            </DropdownMenuItem>
            <DropdownMenuItem>
              <Video className="h-4 w-4 mr-2" />
              Video Call
            </DropdownMenuItem>
          </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Chat Room Tabs */}
      {rooms.length > 1 && (
        <div className="bg-white/60 backdrop-blur-sm border-b border-gray-200/80 px-6">
          <Tabs
            value={activeRoomId}
            onValueChange={setActiveRoomId}
          >
            <TabsList className="w-full justify-start rounded-none bg-transparent h-auto p-0 gap-1">
              {rooms.map((room) => {
                const Icon = getRoomIcon(room.type)
                const config = CHAT_ROOM_TYPE_CONFIG[room.type]
                return (
                  <TabsTrigger
                    key={room.id}
                    value={room.id}
                    className={cn(
                      "relative rounded-t-xl border-b-2 border-transparent px-6 py-3 font-semibold text-gray-600 transition-all data-[state=active]:border-orange-500 data-[state=active]:bg-orange-50/50 data-[state=active]:text-orange-700 hover:bg-gray-50",
                      room.is_suspended && "text-destructive"
                    )}
                  >
                    <Icon className="h-4 w-4 mr-2" />
                    <span className="hidden sm:inline">{config.label}</span>
                    {room.unread_count > 0 && (
                      <Badge
                        variant="destructive"
                        className="ml-2 h-5 px-1.5 text-[10px]"
                      >
                        {room.unread_count}
                      </Badge>
                    )}
                    {room.is_suspended && (
                      <ShieldAlert className="h-3.5 w-3.5 ml-1 text-destructive" />
                    )}
                  </TabsTrigger>
                )
              })}
            </TabsList>
          </Tabs>
        </div>
      )}

      {/* Messages Area */}
      <div className="flex-1 flex flex-col min-h-0">
        {activeRoom ? (
          <>
            {/* Suspension Banner */}
            {activeRoom.is_suspended && (
              <div className="flex items-center gap-2 p-3 bg-destructive/10 border-b border-destructive/20">
                <ShieldAlert className="h-4 w-4 text-destructive shrink-0" />
                <div className="flex-1">
                  <p className="text-sm font-medium text-destructive">
                    Chat has been suspended
                  </p>
                  {activeRoom.suspension_reason && (
                    <p className="text-xs text-muted-foreground">
                      {activeRoom.suspension_reason}
                    </p>
                  )}
                </div>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => onResumeChat(activeRoom.id)}
                >
                  Resume
                </Button>
              </div>
            )}

            {/* Message List */}
            <MessageList
              messages={activeRoom.last_message ? [activeRoom.last_message] : []}
              participants={activeRoom.participants}
              currentUserId={currentUserId}
              onDownloadFile={onDownloadFile}
            />

            {/* Message Input */}
            <MessageInput
              onSendMessage={(content, file) =>
                onSendMessage(activeRoom.id, content, file)
              }
              disabled={activeRoom.is_suspended}
              placeholder={
                activeRoom.is_suspended
                  ? "Chat is suspended"
                  : "Type a message..."
              }
            />
          </>
        ) : (
          <div className="flex-1 flex items-center justify-center text-muted-foreground">
            <p>Select a chat room to start messaging</p>
          </div>
        )}
      </div>

      {/* Suspend Dialog */}
      <Dialog open={suspendDialogOpen} onOpenChange={setSuspendDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-destructive">
              <AlertOctagon className="h-5 w-5" />
              Suspend Chat
            </DialogTitle>
            <DialogDescription>
              Suspending the chat will prevent all participants from sending
              messages. This action can be reversed.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="suspend-reason">
                Reason for Suspension <span className="text-destructive">*</span>
              </Label>
              <Textarea
                id="suspend-reason"
                value={suspendReason}
                onChange={(e) => setSuspendReason(e.target.value)}
                placeholder="e.g., Contact information sharing detected..."
                rows={3}
              />
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setSuspendDialogOpen(false)
                setSuspendReason("")
              }}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={handleSuspend}
              disabled={!suspendReason.trim()}
            >
              Suspend Chat
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
