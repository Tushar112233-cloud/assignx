"use client";

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { FileText, BookOpen, Hash, Calendar, IndianRupee } from "lucide-react";
import { AttachedFiles } from "./attached-files";
import { cn } from "@/lib/utils";
import type { ProjectDetail } from "@/types/project";

interface ProjectBriefAccordionProps {
  project: ProjectDetail;
  className?: string;
}

/**
 * Collapsible project brief section
 */
export function ProjectBriefAccordion({
  project,
  className,
}: ProjectBriefAccordionProps) {
  return (
    <Card className={cn(className)}>
      <Accordion type="single" collapsible className="w-full">
        <AccordionItem value="brief" className="border-0">
          <CardHeader className="p-0">
            <AccordionTrigger className="px-4 py-3 hover:no-underline">
              <CardTitle className="flex items-center gap-2 text-base font-medium">
                <FileText className="h-5 w-5 text-primary" />
                Project Brief
              </CardTitle>
            </AccordionTrigger>
          </CardHeader>

          <AccordionContent>
            <CardContent className="space-y-4 pt-0">
              {/* Subject */}
              <div className="flex items-start gap-3">
                <BookOpen className="mt-0.5 h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="text-xs text-muted-foreground">Subject</p>
                  <p className="text-sm font-medium">{project.subjectName}</p>
                </div>
              </div>

              {/* Word Count */}
              {project.wordCount && (
                <div className="flex items-start gap-3">
                  <Hash className="mt-0.5 h-4 w-4 text-muted-foreground" />
                  <div>
                    <p className="text-xs text-muted-foreground">Word Count</p>
                    <p className="text-sm font-medium">
                      {project.wordCount.toLocaleString()} words
                    </p>
                  </div>
                </div>
              )}

              {/* Reference Style */}
              {project.referenceStyle && (
                <div className="flex items-start gap-3">
                  <BookOpen className="mt-0.5 h-4 w-4 text-muted-foreground" />
                  <div>
                    <p className="text-xs text-muted-foreground">
                      Reference Style
                    </p>
                    <p className="text-sm font-medium">
                      {project.referenceStyle}
                    </p>
                  </div>
                </div>
              )}

              {/* Budget */}
              {project.budget && (
                <div className="flex items-start gap-3">
                  <IndianRupee className="mt-0.5 h-4 w-4 text-muted-foreground" />
                  <div>
                    <p className="text-xs text-muted-foreground">Budget</p>
                    <p className="text-sm font-medium">{project.budget}</p>
                  </div>
                </div>
              )}

              {/* Deadline */}
              {project.deadline && (
                <div className="flex items-start gap-3">
                  <Calendar className="mt-0.5 h-4 w-4 text-muted-foreground" />
                  <div>
                    <p className="text-xs text-muted-foreground">Deadline</p>
                    <p className="text-sm font-medium">
                      {new Date(project.deadline).toLocaleDateString("en-IN", {
                        weekday: "long",
                        day: "numeric",
                        month: "long",
                        year: "numeric",
                      })}
                    </p>
                  </div>
                </div>
              )}

              <Separator />

              {/* Instructions */}
              <div>
                <p className="mb-2 text-xs font-medium text-muted-foreground">
                  Instructions
                </p>
                <p className="text-sm leading-relaxed">{project.instructions}</p>
              </div>

              <Separator />

              {/* Attached Files */}
              <div>
                <p className="mb-2 text-xs font-medium text-muted-foreground">
                  Attached Files ({project.attachedFiles.length})
                </p>
                <AttachedFiles files={project.attachedFiles} />
              </div>
            </CardContent>
          </AccordionContent>
        </AccordionItem>
      </Accordion>
    </Card>
  );
}
