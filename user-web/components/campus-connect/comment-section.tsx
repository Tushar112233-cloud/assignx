"use client";

import { useState, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  MessageCircle,
  Heart,
  Reply,
  Send,
  MoreHorizontal,
  BadgeCheck,
  Loader2,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import type { CampusConnectComment } from "@/types/campus-connect";

interface CommentSectionProps {
  comments: CampusConnectComment[];
  postId: string;
  onAddComment: (content: string, parentId?: string | null) => Promise<void>;
  onLikeComment: (commentId: string) => void;
  isVerified: boolean;
  isLoading?: boolean;
  className?: string;
}

/**
 * CommentSection - Full comment section with nested replies
 */
export function CommentSection({
  comments,
  postId,
  onAddComment,
  onLikeComment,
  isVerified,
  isLoading = false,
  className,
}: CommentSectionProps) {
  const [newComment, setNewComment] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [replyingTo, setReplyingTo] = useState<string | null>(null);

  const handleSubmit = async () => {
    if (!newComment.trim() || isSubmitting) return;

    setIsSubmitting(true);
    try {
      await onAddComment(newComment.trim(), replyingTo);
      setNewComment("");
      setReplyingTo(null);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) {
      e.preventDefault();
      handleSubmit();
    }
  };

  return (
    <div className={cn("space-y-6", className)}>
      {/* Comment Input */}
      <div className="space-y-3">
        <div className="flex items-center gap-2 text-sm font-medium text-foreground">
          <MessageCircle className="h-5 w-5" />
          <span>{comments.length} Comments</span>
        </div>

        {isVerified ? (
          <div className="space-y-2">
            {replyingTo && (
              <div className="flex items-center gap-2 px-3 py-2 bg-muted/50 rounded-lg text-sm">
                <Reply className="h-4 w-4 text-muted-foreground" />
                <span className="text-muted-foreground">Replying to comment</span>
                <button
                  onClick={() => setReplyingTo(null)}
                  className="ml-auto text-xs text-primary hover:underline"
                >
                  Cancel
                </button>
              </div>
            )}
            <div className="relative">
              <Textarea
                placeholder="Write a comment..."
                value={newComment}
                onChange={(e) => setNewComment(e.target.value)}
                onKeyDown={handleKeyDown}
                className="min-h-[80px] pr-12 resize-none"
                disabled={isSubmitting}
              />
              <Button
                size="icon"
                className="absolute bottom-2 right-2 h-8 w-8 rounded-full"
                onClick={handleSubmit}
                disabled={!newComment.trim() || isSubmitting}
              >
                {isSubmitting ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <Send className="h-4 w-4" />
                )}
              </Button>
            </div>
            <p className="text-xs text-muted-foreground">
              Press {navigator.platform.includes("Mac") ? "Cmd" : "Ctrl"}+Enter to submit
            </p>
          </div>
        ) : (
          <div className="p-4 bg-muted/50 rounded-xl text-center">
            <p className="text-sm text-muted-foreground">
              Only verified college students can comment.
            </p>
          </div>
        )}
      </div>

      {/* Comments List */}
      <div className="space-y-4">
        {isLoading ? (
          <div className="flex items-center justify-center py-8">
            <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
          </div>
        ) : comments.length === 0 ? (
          <div className="text-center py-8">
            <MessageCircle className="h-10 w-10 text-muted-foreground/50 mx-auto mb-2" />
            <p className="text-sm text-muted-foreground">No comments yet. Be the first!</p>
          </div>
        ) : (
          <AnimatePresence initial={false}>
            {comments.map((comment) => (
              <CommentItem
                key={comment.id}
                comment={comment}
                onLike={onLikeComment}
                onReply={(id) => setReplyingTo(id)}
                isVerified={isVerified}
              />
            ))}
          </AnimatePresence>
        )}
      </div>
    </div>
  );
}

/**
 * CommentItem - Single comment with replies
 */
interface CommentItemProps {
  comment: CampusConnectComment;
  onLike: (commentId: string) => void;
  onReply: (commentId: string) => void;
  isVerified: boolean;
  isReply?: boolean;
}

function CommentItem({
  comment,
  onLike,
  onReply,
  isVerified,
  isReply = false,
}: CommentItemProps) {
  const [isLiking, setIsLiking] = useState(false);
  const [showReplies, setShowReplies] = useState(true);

  const handleLike = async () => {
    if (isLiking) return;
    setIsLiking(true);
    onLike(comment.id);
    setTimeout(() => setIsLiking(false), 300);
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      className={cn("group", isReply && "ml-10 mt-3")}
    >
      <div className="flex gap-3">
        {/* Avatar */}
        <Avatar className={cn("shrink-0", isReply ? "h-8 w-8" : "h-10 w-10")}>
          <AvatarImage src={comment.authorAvatar || undefined} alt={comment.authorName} />
          <AvatarFallback className={isReply ? "text-xs" : "text-sm"}>
            {comment.authorName.slice(0, 2).toUpperCase()}
          </AvatarFallback>
        </Avatar>

        {/* Content */}
        <div className="flex-1 min-w-0">
          {/* Header */}
          <div className="flex items-center gap-2 mb-1">
            <span className={cn("font-medium", isReply ? "text-sm" : "text-base")}>
              {comment.authorName}
            </span>
            {comment.isAuthorVerified && (
              <BadgeCheck className="h-4 w-4 text-blue-500" />
            )}
            <span className="text-xs text-muted-foreground">{comment.timeAgo}</span>
          </div>

          {/* Comment Text */}
          <p className={cn("text-foreground/90 whitespace-pre-wrap", isReply ? "text-sm" : "")}>
            {comment.content}
          </p>

          {/* Actions */}
          <div className="flex items-center gap-4 mt-2">
            {/* Like */}
            <motion.button
              onClick={handleLike}
              whileTap={{ scale: 0.9 }}
              className={cn(
                "flex items-center gap-1 text-xs transition-colors",
                comment.isLiked
                  ? "text-red-500"
                  : "text-muted-foreground hover:text-red-500"
              )}
            >
              <motion.div
                animate={isLiking ? { scale: [1, 1.4, 1] } : {}}
                transition={{ duration: 0.2 }}
              >
                <Heart
                  className={cn(
                    "h-4 w-4",
                    comment.isLiked && "fill-red-500"
                  )}
                />
              </motion.div>
              <span>{comment.likeCount}</span>
            </motion.button>

            {/* Reply */}
            {isVerified && !isReply && (
              <button
                onClick={() => onReply(comment.id)}
                className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground transition-colors"
              >
                <Reply className="h-4 w-4" />
                <span>Reply</span>
              </button>
            )}

            {/* More Options */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <button className="p-1 text-muted-foreground hover:text-foreground opacity-0 group-hover:opacity-100 transition-opacity">
                  <MoreHorizontal className="h-4 w-4" />
                </button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="start">
                <DropdownMenuItem>Report</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>

          {/* Replies */}
          {comment.replies && comment.replies.length > 0 && (
            <div className="mt-3">
              {comment.replies.length > 2 && !showReplies && (
                <button
                  onClick={() => setShowReplies(true)}
                  className="text-xs text-primary hover:underline mb-2"
                >
                  View {comment.replies.length} replies
                </button>
              )}
              <AnimatePresence>
                {showReplies && comment.replies.map((reply) => (
                  <CommentItem
                    key={reply.id}
                    comment={reply}
                    onLike={onLike}
                    onReply={onReply}
                    isVerified={isVerified}
                    isReply
                  />
                ))}
              </AnimatePresence>
              {showReplies && comment.replies.length > 2 && (
                <button
                  onClick={() => setShowReplies(false)}
                  className="text-xs text-muted-foreground hover:text-foreground mt-2"
                >
                  Hide replies
                </button>
              )}
            </div>
          )}
        </div>
      </div>
    </motion.div>
  );
}

export default CommentSection;
