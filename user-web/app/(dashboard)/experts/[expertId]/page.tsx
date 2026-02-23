"use client";

import { use, useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { format } from "date-fns";
import {
  ArrowLeft,
  Star,
  BadgeCheck,
  Clock,
  Video,
  MessageSquare,
  Shield,
  Globe,
  GraduationCap,
  Briefcase,
  Flag,
  ThumbsUp,
} from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { cn } from "@/lib/utils";
import { formatINR } from "@/lib/utils";
import { getExpertById, getExpertReviews } from "@/lib/data/experts";
import type { ExpertSpecialization } from "@/types/expert";

/**
 * Specialization labels
 */
const SPEC_LABELS: Record<ExpertSpecialization, string> = {
  academic_writing: "Academic Writing",
  research_methodology: "Research Methodology",
  data_analysis: "Data Analysis",
  programming: "Programming",
  mathematics: "Mathematics",
  science: "Science",
  business: "Business",
  engineering: "Engineering",
  law: "Law",
  medicine: "Medicine",
  arts: "Arts",
  other: "Other",
};

/**
 * Expert Profile Page
 * Displays full expert profile with reviews and booking option
 */
export default function ExpertProfilePage({
  params,
}: {
  params: Promise<{ expertId: string }>;
}) {
  const resolvedParams = use(params);
  const router = useRouter();
  const [activeTab, setActiveTab] = useState("about");

  const expert = getExpertById(resolvedParams.expertId);
  const reviews = getExpertReviews(resolvedParams.expertId);

  // Handle expert not found
  if (!expert) {
    return (
      <div className="container max-w-4xl mx-auto px-4 py-6">
        <Card className="p-8 text-center">
          <p className="text-muted-foreground">Expert not found</p>
          <Button
            variant="link"
            onClick={() => router.push("/experts")}
            className="mt-4"
          >
            Back to Experts
          </Button>
        </Card>
      </div>
    );
  }

  /**
   * Get initials from name
   */
  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  /**
   * Get availability color
   */
  const getAvailabilityColor = (status: typeof expert.availability) => {
    switch (status) {
      case "available":
        return "bg-green-500";
      case "busy":
        return "bg-yellow-500";
      case "offline":
        return "bg-gray-400";
    }
  };

  /**
   * Get availability text
   */
  const getAvailabilityText = (status: typeof expert.availability) => {
    switch (status) {
      case "available":
        return "Available Now";
      case "busy":
        return "Currently Busy";
      case "offline":
        return "Offline";
    }
  };

  return (
    <>
      {/* Enhanced Background with Mesh Gradient */}
      <div className="fixed inset-0 mesh-background mesh-gradient-bottom-right-animated" />

      {/* Main Content */}
      <div className="relative z-10 min-h-screen">
        <div className="container max-w-4xl mx-auto px-4 py-6 space-y-6">
        {/* Back Button */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
        >
          <Button
            variant="ghost"
            size="sm"
            onClick={() => router.push("/experts")}
            className="gap-1"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to Experts
          </Button>
        </motion.div>

        {/* Profile Header - Enhanced Design */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <div className="relative overflow-hidden rounded-[24px] p-6 md:p-8 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 shadow-xl">
            {/* Decorative gradient overlay */}
            <div className="absolute inset-0 bg-gradient-to-br from-violet-100/40 to-blue-50/20 dark:from-violet-900/10 dark:to-blue-900/5 pointer-events-none rounded-[24px]" />

            {/* Decorative circles */}
            <div className="absolute -top-10 -right-10 w-40 h-40 bg-gradient-to-br from-violet-400/20 to-blue-400/10 rounded-full blur-3xl" />
            <div className="absolute -bottom-8 -left-8 w-32 h-32 bg-gradient-to-tr from-blue-400/15 to-transparent rounded-full blur-2xl" />

            <div className="relative z-10 flex flex-col md:flex-row gap-6">
              {/* Avatar Section */}
              <div className="flex flex-col items-center md:items-start gap-4">
                <div className="relative">
                  <Avatar className="h-28 w-28 md:h-36 md:w-36 border-4 border-white/50 dark:border-white/20 shadow-lg">
                    <AvatarImage src={expert.avatar} alt={expert.name} />
                    <AvatarFallback className="text-3xl bg-gradient-to-br from-violet-500 to-blue-500 text-white">
                      {getInitials(expert.name)}
                    </AvatarFallback>
                  </Avatar>
                  <span
                    className={cn(
                      "absolute bottom-2 right-2 h-6 w-6 rounded-full border-4 border-white dark:border-gray-900 shadow-lg",
                      getAvailabilityColor(expert.availability)
                    )}
                  />
                </div>
                <div className="relative overflow-hidden rounded-xl px-3 py-1.5 bg-gradient-to-r from-emerald-500 to-green-600 shadow-lg shadow-emerald-500/30">
                  <div className="flex items-center gap-1.5">
                    <span
                      className={cn(
                        "h-2 w-2 rounded-full animate-pulse",
                        expert.availability === "available" ? "bg-white" : "bg-white/50"
                      )}
                    />
                    <span className="text-xs font-semibold text-white">
                      {getAvailabilityText(expert.availability)}
                    </span>
                  </div>
                </div>
              </div>

              {/* Info Section */}
              <div className="flex-1 text-center md:text-left">
                <div className="flex flex-col md:flex-row md:items-center gap-2 mb-2">
                  <h1 className="text-3xl font-bold tracking-tight">{expert.name}</h1>
                  {expert.verified && (
                    <div className="mx-auto md:mx-0 h-6 w-6 rounded-full bg-blue-500 flex items-center justify-center">
                      <BadgeCheck className="h-5 w-5 text-white" />
                    </div>
                  )}
                </div>
                <p className="text-muted-foreground text-lg mb-5">
                  {expert.designation}
                </p>

                <div className="flex flex-wrap justify-center md:justify-start gap-5 text-sm mb-5">
                  <div className="flex items-center gap-2">
                    <div className="h-9 w-9 rounded-xl bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
                      <Star className="h-4 w-4 fill-amber-500 text-amber-500" />
                    </div>
                    <div className="text-left">
                      <p className="font-bold text-base">{expert.rating}</p>
                      <p className="text-xs text-muted-foreground">
                        ({expert.reviewCount} reviews)
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="h-9 w-9 rounded-xl bg-violet-100 dark:bg-violet-900/30 flex items-center justify-center">
                      <Video className="h-4 w-4 text-violet-600 dark:text-violet-400" />
                    </div>
                    <div className="text-left">
                      <p className="font-bold text-base">{expert.totalSessions}</p>
                      <p className="text-xs text-muted-foreground">sessions</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="h-9 w-9 rounded-xl bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
                      <Clock className="h-4 w-4 text-blue-600 dark:text-blue-400" />
                    </div>
                    <div className="text-left">
                      <p className="font-bold text-sm">{expert.responseTime}</p>
                      <p className="text-xs text-muted-foreground">response</p>
                    </div>
                  </div>
                </div>

                <div className="flex flex-wrap justify-center md:justify-start gap-2 mb-6">
                  {expert.specializations.map((spec) => (
                    <div
                      key={spec}
                      className="px-3 py-1.5 rounded-full bg-white/50 dark:bg-white/5 border border-white/50 dark:border-white/10 text-xs font-medium"
                    >
                      {SPEC_LABELS[spec]}
                    </div>
                  ))}
                </div>

                <div className="flex flex-col sm:flex-row items-center gap-4 pt-4 border-t border-white/20">
                  <div className="text-center sm:text-left">
                    <p className="text-xs text-muted-foreground mb-1">Session Price</p>
                    <span className="text-3xl font-bold tracking-tight">
                      {formatINR(expert.pricePerSession)}
                    </span>
                    <span className="text-muted-foreground text-sm">/session</span>
                  </div>
                  <Button
                    size="lg"
                    onClick={() =>
                      router.push(`/experts/booking/${expert.id}`)
                    }
                    className="w-full sm:w-auto h-12 px-8 rounded-xl bg-gradient-to-r from-violet-600 to-blue-600 hover:from-violet-700 hover:to-blue-700 shadow-lg shadow-violet-500/30 hover:shadow-violet-500/50 transition-all"
                  >
                    Book Consultation
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Trust Badges - Premium Cards */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="grid grid-cols-2 md:grid-cols-4 gap-4"
        >
          {/* Verified Expert */}
          <motion.div
            whileHover={{ y: -3, scale: 1.02 }}
            className="relative overflow-hidden rounded-[16px] p-4 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 shadow-lg hover:shadow-xl transition-all cursor-pointer group"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-emerald-100/50 to-green-50/30 dark:from-emerald-900/20 dark:to-green-900/10 pointer-events-none rounded-[16px]" />
            <div className="relative z-10">
              <div className="h-11 w-11 rounded-xl bg-gradient-to-br from-emerald-500 to-green-600 flex items-center justify-center shadow-lg shadow-emerald-500/30 mb-3">
                <Shield className="h-5 w-5 text-white" strokeWidth={2} />
              </div>
              <p className="text-sm font-semibold text-foreground mb-0.5">Verified Expert</p>
              <p className="text-xs text-muted-foreground">ID verified & background checked</p>
            </div>
          </motion.div>

          {/* Google Meet Session */}
          <motion.div
            whileHover={{ y: -3, scale: 1.02 }}
            className="relative overflow-hidden rounded-[16px] p-4 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 shadow-lg hover:shadow-xl transition-all cursor-pointer group"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-blue-100/50 to-indigo-50/30 dark:from-blue-900/20 dark:to-indigo-900/10 pointer-events-none rounded-[16px]" />
            <div className="relative z-10">
              <div className="h-11 w-11 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center shadow-lg shadow-blue-500/30 mb-3">
                <Video className="h-5 w-5 text-white" strokeWidth={2} />
              </div>
              <p className="text-sm font-semibold text-foreground mb-0.5">Google Meet Session</p>
              <p className="text-xs text-muted-foreground">Secure video consultations</p>
            </div>
          </motion.div>

          {/* Money-back Guarantee */}
          <motion.div
            whileHover={{ y: -3, scale: 1.02 }}
            className="relative overflow-hidden rounded-[16px] p-4 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 shadow-lg hover:shadow-xl transition-all cursor-pointer group"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-amber-100/50 to-orange-50/30 dark:from-amber-900/20 dark:to-orange-900/10 pointer-events-none rounded-[16px]" />
            <div className="relative z-10">
              <div className="h-11 w-11 rounded-xl bg-gradient-to-br from-amber-500 to-orange-600 flex items-center justify-center shadow-lg shadow-amber-500/30 mb-3">
                <Shield className="h-5 w-5 text-white" strokeWidth={2} />
              </div>
              <p className="text-sm font-semibold text-foreground mb-0.5">Money-back Guarantee</p>
              <p className="text-xs text-muted-foreground">100% satisfaction or refund</p>
            </div>
          </motion.div>

          {/* 24/7 Support */}
          <motion.div
            whileHover={{ y: -3, scale: 1.02 }}
            className="relative overflow-hidden rounded-[16px] p-4 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 shadow-lg hover:shadow-xl transition-all cursor-pointer group"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-violet-100/50 to-purple-50/30 dark:from-violet-900/20 dark:to-purple-900/10 pointer-events-none rounded-[16px]" />
            <div className="relative z-10">
              <div className="h-11 w-11 rounded-xl bg-gradient-to-br from-violet-500 to-purple-600 flex items-center justify-center shadow-lg shadow-violet-500/30 mb-3">
                <MessageSquare className="h-5 w-5 text-white" strokeWidth={2} />
              </div>
              <p className="text-sm font-semibold text-foreground mb-0.5">24/7 Support</p>
              <p className="text-xs text-muted-foreground">Always here to help you</p>
            </div>
          </motion.div>
        </motion.div>

        {/* Tabs Section - Enhanced */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList className="w-full justify-start bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 p-1 rounded-xl">
              <TabsTrigger
                value="about"
                className="data-[state=active]:bg-gradient-to-r data-[state=active]:from-violet-500 data-[state=active]:to-blue-500 data-[state=active]:text-white rounded-lg"
              >
                About
              </TabsTrigger>
              <TabsTrigger
                value="reviews"
                className="data-[state=active]:bg-gradient-to-r data-[state=active]:from-violet-500 data-[state=active]:to-blue-500 data-[state=active]:text-white rounded-lg"
              >
                Reviews ({expert.reviewCount})
              </TabsTrigger>
            </TabsList>

            <TabsContent value="about" className="space-y-4 mt-6">
              {/* Bio */}
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="relative overflow-hidden rounded-[20px] p-6 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 shadow-lg"
              >
                <div className="absolute inset-0 bg-gradient-to-br from-violet-100/20 to-blue-50/10 dark:from-violet-900/5 dark:to-blue-900/5 pointer-events-none rounded-[20px]" />
                <div className="relative z-10">
                  <h3 className="text-lg font-bold mb-3 flex items-center gap-2">
                    <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center">
                      <span className="text-white text-sm">ℹ️</span>
                    </div>
                    About
                  </h3>
                  <p className="text-muted-foreground leading-relaxed">
                    {expert.bio}
                  </p>
                </div>
              </motion.div>

              {/* Details */}
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="relative overflow-hidden rounded-[20px] p-6 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 shadow-lg"
              >
                <div className="absolute inset-0 bg-gradient-to-br from-blue-100/20 to-indigo-50/10 dark:from-blue-900/5 dark:to-indigo-900/5 pointer-events-none rounded-[20px]" />
                <div className="relative z-10 space-y-5">
                  {expert.education && (
                    <div className="flex items-start gap-4">
                      <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-500 flex items-center justify-center shadow-lg shadow-blue-500/20 shrink-0">
                        <GraduationCap className="h-5 w-5 text-white" strokeWidth={2} />
                      </div>
                      <div>
                        <p className="font-semibold mb-1">Education</p>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                          {expert.education}
                        </p>
                      </div>
                    </div>
                  )}

                  {expert.experience && (
                    <div className="flex items-start gap-4">
                      <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-violet-500 to-purple-500 flex items-center justify-center shadow-lg shadow-violet-500/20 shrink-0">
                        <Briefcase className="h-5 w-5 text-white" strokeWidth={2} />
                      </div>
                      <div>
                        <p className="font-semibold mb-1">Experience</p>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                          {expert.experience}
                        </p>
                      </div>
                    </div>
                  )}

                  <div className="flex items-start gap-4">
                    <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-emerald-500 to-green-500 flex items-center justify-center shadow-lg shadow-emerald-500/20 shrink-0">
                      <Globe className="h-5 w-5 text-white" strokeWidth={2} />
                    </div>
                    <div>
                      <p className="font-semibold mb-1">Languages</p>
                      <p className="text-sm text-muted-foreground">
                        {expert.languages.join(", ")}
                      </p>
                    </div>
                  </div>
                </div>
              </motion.div>
            </TabsContent>

            <TabsContent value="reviews" className="space-y-4 mt-6">
              {reviews.length === 0 ? (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="relative overflow-hidden rounded-[20px] p-12 text-center bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10"
                >
                  <div className="absolute inset-0 bg-gradient-to-br from-violet-100/20 to-purple-50/10 dark:from-violet-900/5 dark:to-transparent pointer-events-none rounded-[20px]" />
                  <div className="relative z-10">
                    <div className="h-16 w-16 rounded-2xl bg-gradient-to-br from-violet-500 to-purple-500 flex items-center justify-center mx-auto mb-4 shadow-lg shadow-violet-500/20">
                      <Star className="h-8 w-8 text-white" />
                    </div>
                    <p className="text-muted-foreground">No reviews yet</p>
                  </div>
                </motion.div>
              ) : (
                reviews.map((review, index) => (
                  <motion.div
                    key={review.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.05 }}
                    className="relative overflow-hidden rounded-[18px] p-5 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 shadow-md hover:shadow-lg transition-all"
                  >
                    <div className="absolute inset-0 bg-gradient-to-br from-amber-50/30 to-orange-50/10 dark:from-amber-900/5 dark:to-orange-900/5 pointer-events-none rounded-[18px]" />
                    <div className="relative z-10">
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex items-center gap-3">
                          <Avatar className="h-10 w-10 border-2 border-white/50 dark:border-white/20">
                            <AvatarImage src={review.clientAvatar} />
                            <AvatarFallback className="bg-gradient-to-br from-violet-500 to-blue-500 text-white">
                              {review.clientName.charAt(0)}
                            </AvatarFallback>
                          </Avatar>
                          <div>
                            <p className="font-semibold text-sm">
                              {review.clientName}
                            </p>
                            <p className="text-xs text-muted-foreground">
                              {format(new Date(review.createdAt), "MMM d, yyyy")}
                            </p>
                          </div>
                        </div>
                        <div className="flex items-center gap-1">
                          {Array.from({ length: 5 }).map((_, i) => (
                            <Star
                              key={i}
                              className={cn(
                                "h-4 w-4",
                                i < review.rating
                                  ? "fill-amber-400 text-amber-400"
                                  : "text-muted-foreground/30"
                              )}
                            />
                          ))}
                        </div>
                      </div>
                      <p className="text-sm text-muted-foreground leading-relaxed">
                        {review.comment}
                      </p>
                      {review.helpful && review.helpful > 0 && (
                        <div className="flex items-center gap-1 mt-3 px-3 py-1.5 rounded-lg bg-blue-100 dark:bg-blue-900/30 w-fit">
                          <ThumbsUp className="h-3 w-3 text-blue-600 dark:text-blue-400" />
                          <span className="text-xs text-blue-700 dark:text-blue-300 font-medium">
                            {review.helpful} found this helpful
                          </span>
                        </div>
                      )}
                    </div>
                  </motion.div>
                ))
              )}
            </TabsContent>
          </Tabs>
        </motion.div>

        {/* Report Button */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="text-center"
        >
          <button className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/50 dark:bg-white/5 border border-white/50 dark:border-white/10 text-muted-foreground hover:bg-white/80 dark:hover:bg-white/10 transition-all text-sm">
            <Flag className="h-4 w-4" />
            Report Expert
          </button>
        </motion.div>

        {/* Sticky Book Button (Mobile) */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="fixed bottom-24 left-4 right-4 md:hidden z-40"
        >
          <button
            onClick={() => router.push(`/experts/booking/${expert.id}`)}
            className="w-full h-14 rounded-2xl bg-gradient-to-r from-violet-600 to-blue-600 hover:from-violet-700 hover:to-blue-700 shadow-2xl shadow-violet-500/40 text-white font-semibold flex items-center justify-center gap-2 transition-all"
          >
            <span>Book Consultation</span>
            <span className="text-white/90">•</span>
            <span>{formatINR(expert.pricePerSession)}</span>
          </button>
        </motion.div>
        </div>
      </div>
    </>
  );
}
