"use client";

import { useState, useEffect } from "react";
import { Loader2, BookOpen } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { apiClient } from "@/lib/api/client";

interface ApiSubject {
  _id: string;
  name: string;
  category: string;
}

interface SavedSubject {
  id: string;
  name: string;
  category: string;
}

export function SubjectsSection() {
  const [allSubjects, setAllSubjects] = useState<ApiSubject[]>([]);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [subjectsRes, userSubjectsRes] = await Promise.all([
          apiClient<{ subjects: ApiSubject[] }>("/api/subjects"),
          apiClient<{ subjects: SavedSubject[] }>("/api/users/me/subjects"),
        ]);
        setAllSubjects(subjectsRes.subjects || []);
        const savedIds = (userSubjectsRes.subjects || []).map((s) => s.id);
        setSelectedIds(new Set(savedIds));
      } catch {
        // Silently fall back to empty
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
  }, []);

  const toggleSubject = (id: string) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
    setHasChanges(true);
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      await apiClient("/api/users/me/subjects", {
        method: "PUT",
        body: JSON.stringify({ subjects: Array.from(selectedIds) }),
      });
      toast.success("Preferred subjects saved");
      setHasChanges(false);
    } catch {
      toast.error("Failed to save subjects");
    } finally {
      setIsSaving(false);
    }
  };

  // Group subjects by category
  const grouped = allSubjects.reduce<Record<string, ApiSubject[]>>((acc, s) => {
    const cat = s.category || "Other";
    if (!acc[cat]) acc[cat] = [];
    acc[cat].push(s);
    return acc;
  }, {});

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-2">
          <BookOpen className="h-5 w-5" />
          <CardTitle>Preferred Subjects</CardTitle>
        </div>
        <CardDescription>
          Select subjects you&apos;re comfortable with. This helps us match you
          with relevant projects.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {isLoading ? (
          <div className="flex items-center justify-center py-8">
            <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />
          </div>
        ) : (
          <>
            {Object.entries(grouped).map(([category, subjects]) => (
              <div key={category} className="space-y-2">
                <p className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
                  {category}
                </p>
                <div className="flex flex-wrap gap-2">
                  {subjects.map((subject) => {
                    const selected = selectedIds.has(subject._id);
                    return (
                      <button
                        key={subject._id}
                        type="button"
                        onClick={() => toggleSubject(subject._id)}
                        className={cn(
                          "px-3 py-1.5 rounded-full text-sm border transition-colors",
                          selected
                            ? "bg-primary text-primary-foreground border-primary"
                            : "bg-muted/50 border-border text-foreground hover:border-foreground/30"
                        )}
                      >
                        {subject.name}
                      </button>
                    );
                  })}
                </div>
              </div>
            ))}

            {allSubjects.length === 0 && (
              <p className="text-sm text-muted-foreground text-center py-4">
                No subjects available
              </p>
            )}

            <div className="flex justify-between items-center pt-4 border-t">
              <p className="text-xs text-muted-foreground">
                {selectedIds.size} subject{selectedIds.size !== 1 ? "s" : ""}{" "}
                selected
              </p>
              <Button
                onClick={handleSave}
                disabled={!hasChanges || isSaving}
              >
                {isSaving ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Saving...
                  </>
                ) : (
                  "Save Changes"
                )}
              </Button>
            </div>
          </>
        )}
      </CardContent>
    </Card>
  );
}
