"use client";

import { useState, useEffect, useCallback } from "react";
import { Loader2, GraduationCap, Users, BookOpen } from "lucide-react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { TutorCard } from "./tutor-card";
import { StudyGroupCard } from "./study-group-card";
import { ResourceCard } from "./resource-card";
import { BookSessionSheet } from "./book-session-sheet";
import { TutorProfileSheet } from "./tutor-profile-sheet";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { apiClient } from "@/lib/api/client";
import type { Tutor, StudyGroup, Resource } from "@/types/connect";

/**
 * Tab types for connect section
 */
type ConnectTab = "tutors" | "study-groups" | "resources";

interface ConnectTabsProps {
  className?: string;
}

/**
 * ConnectTabs - Tab container for switching between Tutors, Study Groups, and Resources
 * Uses Shadcn Tabs component for navigation
 * Fetches data from appropriate tables for each tab
 */
export function ConnectTabs({ className }: ConnectTabsProps) {
  const [activeTab, setActiveTab] = useState<ConnectTab>("tutors");
  const [isLoading, setIsLoading] = useState(false);

  // Data states
  const [tutors, setTutors] = useState<Tutor[]>([]);
  const [studyGroups, setStudyGroups] = useState<StudyGroup[]>([]);
  const [resources, setResources] = useState<Resource[]>([]);

  // Tutor interaction state
  const [selectedTutor, setSelectedTutor] = useState<Tutor | null>(null);
  const [showBookSession, setShowBookSession] = useState(false);
  const [showTutorProfile, setShowTutorProfile] = useState(false);

  /**
   * Load data from API for each tab
   * Queries experts table for tutors, learning_resources for resources,
   * and falls back to empty array for study groups if the table doesn't exist yet.
   */
  const loadTabData = useCallback(async (tab: ConnectTab) => {
    setIsLoading(true);

    try {
      switch (tab) {
        case "tutors": {
          try {
            const data = await apiClient("/api/experts?is_active=true&limit=12");
            if (Array.isArray(data)) {
              setTutors(
                data.map((expert: any) => ({
                  id: expert.id || expert._id,
                  name: expert.profile?.full_name || expert.full_name || "Unknown Tutor",
                  avatar: expert.profile?.avatar_url || expert.avatar_url || undefined,
                  verified: true,
                  rating: expert.rating ?? 0,
                  reviewCount: 0,
                  subjects: Array.isArray(expert.specializations) && expert.specializations.length > 0
                    ? expert.specializations
                    : [],
                  expertise: "expert" as const,
                  hourlyRate: expert.hourly_rate ?? expert.hourlyRate ?? 0,
                  currency: "ZAR",
                  availability: "available" as const,
                  bio: expert.bio || "",
                  completedSessions: expert.total_sessions ?? expert.totalSessions ?? 0,
                  responseTime: "< 1 hour",
                  languages: ["English"],
                }))
              );
            }
          } catch (err) {
            console.warn("Failed to fetch tutors:", err);
            setTutors([]);
          }
          break;
        }

        case "study-groups": {
          try {
            const data = await apiClient("/api/study-groups?limit=12");
            if (Array.isArray(data)) {
              setStudyGroups(
                data.map((group: any) => ({
                  id: group.id || group._id,
                  name: group.name || "Study Group",
                  description: group.description || "",
                  subject: group.subject || "General",
                  memberCount: group.member_count ?? group.memberCount ?? 0,
                  maxMembers: group.max_members ?? group.maxMembers ?? 10,
                  status: (group.status as "open" | "full" | "private") || "open",
                  createdBy: {
                    id: group.created_by || group.createdBy || "",
                    name: "Organizer",
                  },
                  nextSession: group.next_session || group.nextSession
                    ? new Date(group.next_session || group.nextSession)
                    : undefined,
                  topics: group.topics || [],
                }))
              );
            }
          } catch (err) {
            console.warn("Study groups endpoint not available:", err);
            setStudyGroups([]);
          }
          break;
        }

        case "resources": {
          try {
            const data = await apiClient("/api/learning-resources?is_active=true&limit=12");
            if (Array.isArray(data)) {
              setResources(
                data.map((res: any) => ({
                  id: res.id || res._id,
                  title: res.title || "Untitled Resource",
                  description: res.description || "",
                  type: (res.resource_type as Resource["type"]) || "notes",
                  subject: "General",
                  author: {
                    id: "",
                    name: "Community",
                  },
                  downloads: 0,
                  rating: 0,
                  ratingCount: 0,
                  createdAt: new Date(res.created_at || res.createdAt),
                  previewUrl: res.thumbnail_url || res.thumbnailUrl || undefined,
                  isPremium: false,
                }))
              );
            }
          } catch (err) {
            console.warn("Failed to fetch learning resources:", err);
            setResources([]);
          }
          break;
        }
      }
    } catch (error) {
      toast.error(`Failed to load ${tab}`);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    loadTabData(activeTab);
  }, [activeTab, loadTabData]);

  /**
   * Handle tutor card click - opens profile sheet
   */
  const handleTutorClick = (tutor: Tutor) => {
    setSelectedTutor(tutor);
    setShowTutorProfile(true);
  };

  /**
   * Handle booking a session with a tutor
   */
  const handleBookSession = (tutor: Tutor) => {
    setSelectedTutor(tutor);
    setShowBookSession(true);
  };

  /**
   * Handle joining a study group
   */
  const handleJoinGroup = (group: StudyGroup) => {
    toast.info(`Join request sent to ${group.name}`);
  };

  /**
   * Handle resource download
   */
  const handleDownloadResource = (resource: Resource) => {
    toast.info(`Downloading ${resource.title}...`);
  };

  /**
   * Render empty state for a tab
   */
  const renderEmptyState = (
    icon: React.ReactNode,
    title: string,
    description: string
  ) => (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="h-14 w-14 rounded-2xl bg-muted/60 flex items-center justify-center mb-4">
        {icon}
      </div>
      <h3 className="font-medium mb-1">{title}</h3>
      <p className="text-sm text-muted-foreground max-w-xs">{description}</p>
    </div>
  );

  return (
    <div className={cn("w-full", className)}>
      <Tabs
        value={activeTab}
        onValueChange={(v) => setActiveTab(v as ConnectTab)}
        className="w-full"
      >
        <TabsList className="w-full grid grid-cols-3">
          <TabsTrigger value="tutors" className="gap-2">
            <GraduationCap className="h-4 w-4" />
            Tutors
          </TabsTrigger>
          <TabsTrigger value="study-groups" className="gap-2">
            <Users className="h-4 w-4" />
            Study Groups
          </TabsTrigger>
          <TabsTrigger value="resources" className="gap-2">
            <BookOpen className="h-4 w-4" />
            Resources
          </TabsTrigger>
        </TabsList>

        {/* Loading state */}
        {isLoading && (
          <div className="flex items-center justify-center py-16">
            <Loader2 className="h-6 w-6 animate-spin text-primary" />
          </div>
        )}

        {/* Tutors Tab */}
        {!isLoading && (
          <TabsContent value="tutors" className="mt-6">
            {tutors.length === 0
              ? renderEmptyState(
                  <GraduationCap className="h-7 w-7 text-muted-foreground" />,
                  "No tutors available",
                  "Check back soon for expert tutors in your subjects"
                )
              : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {tutors.map((tutor) => (
                    <TutorCard
                      key={tutor.id}
                      tutor={tutor}
                      onClick={() => handleTutorClick(tutor)}
                      onBook={() => handleBookSession(tutor)}
                    />
                  ))}
                </div>
              )}
          </TabsContent>
        )}

        {/* Study Groups Tab */}
        {!isLoading && (
          <TabsContent value="study-groups" className="mt-6">
            {studyGroups.length === 0
              ? renderEmptyState(
                  <Users className="h-7 w-7 text-muted-foreground" />,
                  "No study groups yet",
                  "Create or join study groups to collaborate with classmates"
                )
              : (
                <div className="space-y-4">
                  {studyGroups.map((group) => (
                    <StudyGroupCard
                      key={group.id}
                      group={group}
                      onJoin={() => handleJoinGroup(group)}
                    />
                  ))}
                </div>
              )}
          </TabsContent>
        )}

        {/* Resources Tab */}
        {!isLoading && (
          <TabsContent value="resources" className="mt-6">
            {resources.length === 0
              ? renderEmptyState(
                  <BookOpen className="h-7 w-7 text-muted-foreground" />,
                  "No resources shared yet",
                  "Share notes, templates, and study materials with your peers"
                )
              : (
                <div className="space-y-4">
                  {resources.map((resource) => (
                    <ResourceCard
                      key={resource.id}
                      resource={resource}
                      onDownload={() => handleDownloadResource(resource)}
                    />
                  ))}
                </div>
              )}
          </TabsContent>
        )}
      </Tabs>

      {/* Tutor Sheets */}
      {selectedTutor && (
        <>
          <BookSessionSheet
            open={showBookSession}
            onOpenChange={setShowBookSession}
            tutor={selectedTutor}
          />
          <TutorProfileSheet
            open={showTutorProfile}
            onOpenChange={setShowTutorProfile}
            tutor={selectedTutor}
            onBook={() => {
              setShowTutorProfile(false);
              setShowBookSession(true);
            }}
          />
        </>
      )}
    </div>
  );
}
