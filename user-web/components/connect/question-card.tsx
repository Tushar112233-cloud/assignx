"use client";

import { MessageSquare, ThumbsUp, CheckCircle2 } from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { formatDistanceToNow } from "date-fns";
import type { Question } from "@/types/connect";

/** Props for QuestionCard component */
interface QuestionCardProps {
  question: Question;
  onClick?: () => void;
}

/** Question card for Q&A section */
export function QuestionCard({ question, onClick }: QuestionCardProps) {
  const getInitials = (name: string) => name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);
  const timeAgo = formatDistanceToNow(new Date(question.createdAt), { addSuffix: true });

  return (
    <Card className="cursor-pointer hover:shadow-md transition-shadow" onClick={onClick}>
      <CardContent className="p-4">
        <div className="flex items-start gap-3">
          <Avatar className="h-10 w-10">
            <AvatarImage src={question.author.avatar} />
            <AvatarFallback>{getInitials(question.author.name)}</AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2">
              <h3 className="font-medium line-clamp-2">{question.title}</h3>
              {question.isAnswered && (
                <CheckCircle2 className="h-5 w-5 text-green-500 shrink-0" />
              )}
            </div>
            <p className="text-sm text-muted-foreground line-clamp-2 mt-1">{question.content}</p>
            <div className="flex items-center gap-4 mt-3">
              <div className="flex items-center gap-1 text-sm text-muted-foreground">
                <ThumbsUp className="h-4 w-4" />
                <span>{question.upvotes}</span>
              </div>
              <div className="flex items-center gap-1 text-sm text-muted-foreground">
                <MessageSquare className="h-4 w-4" />
                <span>{question.answerCount} answers</span>
              </div>
              <span className="text-xs text-muted-foreground">{timeAgo}</span>
            </div>
            <div className="flex flex-wrap gap-1 mt-2">
              <Badge variant="secondary">{question.subject}</Badge>
              {question.tags.slice(0, 2).map((tag) => (
                <Badge key={tag} variant="outline" className="text-xs">{tag}</Badge>
              ))}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
