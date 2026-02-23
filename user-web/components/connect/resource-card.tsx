"use client";

import { FileText, Download, Star, Lock, BookOpen, FileCode, Video, ClipboardList } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import type { Resource } from "@/types/connect";

interface ResourceCardProps {
  resource: Resource;
  onClick?: () => void;
  onDownload?: () => void;
  className?: string;
}

/**
 * Resource card component displaying shared resource information
 */
export function ResourceCard({
  resource,
  onClick,
  onDownload,
  className,
}: ResourceCardProps) {
  const getTypeIcon = (type: Resource["type"]) => {
    switch (type) {
      case "notes":
        return FileText;
      case "template":
        return FileCode;
      case "guide":
        return BookOpen;
      case "practice":
        return ClipboardList;
      case "video":
        return Video;
      default:
        return FileText;
    }
  };

  const getTypeColor = (type: Resource["type"]) => {
    switch (type) {
      case "notes":
        return "bg-blue-500/10 text-blue-500";
      case "template":
        return "bg-purple-500/10 text-purple-500";
      case "guide":
        return "bg-green-500/10 text-green-500";
      case "practice":
        return "bg-orange-500/10 text-orange-500";
      case "video":
        return "bg-red-500/10 text-red-500";
      default:
        return "bg-gray-500/10 text-gray-500";
    }
  };

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  const formatDownloads = (count: number) => {
    if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}k`;
    }
    return count.toString();
  };

  const TypeIcon = getTypeIcon(resource.type);

  return (
    <Card
      className={cn("cursor-pointer transition-shadow hover:shadow-md", className)}
      onClick={onClick}
    >
      <CardContent className="p-4">
        <div className="flex gap-4">
          {/* Type Icon */}
          <div
            className={cn(
              "flex h-12 w-12 shrink-0 items-center justify-center rounded-lg",
              getTypeColor(resource.type)
            )}
          >
            <TypeIcon className="h-6 w-6" />
          </div>

          {/* Content */}
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2 mb-1">
              <h3 className="font-medium line-clamp-2">{resource.title}</h3>
              {resource.isPremium && (
                <Badge variant="secondary" className="shrink-0 gap-1">
                  <Lock className="h-3 w-3" />
                  ${resource.price}
                </Badge>
              )}
            </div>

            <p className="text-sm text-muted-foreground line-clamp-2 mb-2">
              {resource.description}
            </p>

            <div className="flex items-center gap-3 text-xs text-muted-foreground mb-3">
              <Badge variant="outline" className="capitalize">
                {resource.type}
              </Badge>
              <span>{resource.subject}</span>
              {resource.fileSize && (
                <>
                  <span>•</span>
                  <span>{resource.fileSize}</span>
                </>
              )}
            </div>

            <div className="flex items-center justify-between">
              {/* Author */}
              <div className="flex items-center gap-2">
                <Avatar className="h-6 w-6">
                  <AvatarImage src={resource.author.avatar} alt={resource.author.name} />
                  <AvatarFallback className="text-xs">
                    {getInitials(resource.author.name)}
                  </AvatarFallback>
                </Avatar>
                <span className="text-sm text-muted-foreground truncate max-w-[120px]">
                  {resource.author.name}
                </span>
              </div>

              {/* Stats and Action */}
              <div className="flex items-center gap-3">
                <div className="flex items-center gap-1 text-sm">
                  <Star className="h-3.5 w-3.5 fill-yellow-400 text-yellow-400" />
                  <span>{resource.rating}</span>
                </div>
                <div className="flex items-center gap-1 text-sm text-muted-foreground">
                  <Download className="h-3.5 w-3.5" />
                  <span>{formatDownloads(resource.downloads)}</span>
                </div>
                <Button
                  size="sm"
                  variant={resource.isPremium ? "default" : "outline"}
                  onClick={(e) => {
                    e.stopPropagation();
                    onDownload?.();
                  }}
                >
                  {resource.isPremium ? "Buy" : "Get"}
                </Button>
              </div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
