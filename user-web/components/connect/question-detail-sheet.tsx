"use client";

import { useState } from "react";
import { ThumbsUp, MessageSquare, CheckCircle2, User, Send, Clock } from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetFooter,
} from "@/components/ui/sheet";
import { formatDistanceToNow } from "date-fns";
import { motion } from "framer-motion";
import type { Question } from "@/types/connect";

interface QuestionDetailSheetProps {
  question: Question | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

/**
 * Question detail sheet for Q&A section
 */
export function QuestionDetailSheet({
  question,
  open,
  onOpenChange,
}: QuestionDetailSheetProps) {
  const [answer, setAnswer] = useState("");

  if (!question) return null;

  const getInitials = (name: string) =>
    name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);

  const timeAgo = formatDistanceToNow(new Date(question.createdAt), {
    addSuffix: true,
  });

  const handleSubmitAnswer = () => {
    if (!answer.trim()) return;
    // TODO: Implement answer submission
    setAnswer("");
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="h-[90vh] rounded-t-xl flex flex-col">
        <SheetHeader>
          <SheetTitle className="flex items-start gap-2 text-left">
            <span className="flex-1">{question.title}</span>
            {question.isAnswered && (
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: "spring", stiffness: 500, damping: 30 }}
              >
                <CheckCircle2 className="h-5 w-5 text-green-500 shrink-0 mt-1" />
              </motion.div>
            )}
          </SheetTitle>
        </SheetHeader>

        <div className="flex-1 overflow-y-auto px-4 space-y-6">
          {/* Author info */}
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10">
              <AvatarImage src={question.author.avatar} />
              <AvatarFallback>{getInitials(question.author.name)}</AvatarFallback>
            </Avatar>
            <div className="flex-1 min-w-0">
              <p className="font-medium text-sm">{question.author.name}</p>
              <p className="text-xs text-muted-foreground flex items-center gap-1">
                <Clock className="h-3 w-3" />
                {timeAgo}
              </p>
            </div>
          </div>

          {/* Question content */}
          <div className="space-y-3">
            <p className="text-sm text-foreground leading-relaxed">
              {question.content}
            </p>

            {/* Tags */}
            <div className="flex flex-wrap gap-1.5">
              <Badge variant="secondary">{question.subject}</Badge>
              {question.tags.map((tag) => (
                <Badge key={tag} variant="outline" className="text-xs">
                  {tag}
                </Badge>
              ))}
            </div>

            {/* Stats */}
            <div className="flex items-center gap-4 pt-2">
              <button className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors">
                <ThumbsUp className="h-4 w-4" />
                <span>{question.upvotes}</span>
              </button>
              <div className="flex items-center gap-1.5 text-sm text-muted-foreground">
                <MessageSquare className="h-4 w-4" />
                <span>{question.answerCount} answers</span>
              </div>
            </div>
          </div>

          {/* Divider */}
          <div className="border-t border-border" />

          {/* Answers section */}
          <div className="space-y-4">
            <h3 className="font-medium text-sm">
              {question.answerCount > 0
                ? `${question.answerCount} Answers`
                : "No answers yet"}
            </h3>

            {question.answerCount === 0 && (
              <p className="text-sm text-muted-foreground">
                Be the first to answer this question!
              </p>
            )}

            {/* Placeholder answers - in real app, these would come from the database */}
            {question.isAnswered && (
              <div className="p-3 rounded-lg bg-muted/50 border border-border space-y-2">
                <div className="flex items-center gap-2">
                  <Avatar className="h-6 w-6">
                    <AvatarFallback className="text-xs">
                      <User className="h-3 w-3" />
                    </AvatarFallback>
                  </Avatar>
                  <span className="text-xs font-medium">Community Member</span>
                  <Badge variant="outline" className="text-[10px] h-4">
                    Top Answer
                  </Badge>
                </div>
                <p className="text-sm text-muted-foreground">
                  This is a placeholder answer. In a full implementation, answers would be fetched from the database.
                </p>
              </div>
            )}
          </div>

        </div>

        <SheetFooter>
          <h3 className="font-medium text-sm">Your Answer</h3>
          <Textarea
            placeholder="Write your answer here..."
            value={answer}
            onChange={(e) => setAnswer(e.target.value)}
            className="min-h-[100px] resize-none"
          />
          <motion.div whileTap={{ scale: 0.98 }}>
            <Button
              onClick={handleSubmitAnswer}
              disabled={!answer.trim()}
              className="w-full"
            >
              <Send className="h-4 w-4 mr-2" />
              Submit Answer
            </Button>
          </motion.div>
        </SheetFooter>
      </SheetContent>
    </Sheet>
  );
}
