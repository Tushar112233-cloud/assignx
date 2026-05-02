"use client";

import React from "react";
import { motion } from "framer-motion";
import { TrendingUp, Award, Trophy, Medal } from "lucide-react";

/**
 * Individual subject data structure
 */
interface SubjectData {
  /** Subject name */
  subject: string;
  /** Number of projects */
  count: number;
  /** Total earnings from this subject */
  earnings: number;
}

/**
 * Props for the TopSubjectsRanking component
 */
interface TopSubjectsRankingProps {
  /** Array of subject data sorted by rank */
  subjects: SubjectData[];
}

/**
 * Get medal/badge component based on rank
 */
const getRankBadge = (rank: number) => {
  switch (rank) {
    case 1:
      return (
        <div className="flex items-center justify-center w-8 h-8 rounded-full bg-gradient-to-br from-yellow-400 to-yellow-600 shadow-md">
          <Trophy className="w-4 h-4 text-white" strokeWidth={2.5} />
        </div>
      );
    case 2:
      return (
        <div className="flex items-center justify-center w-8 h-8 rounded-full bg-gradient-to-br from-slate-300 to-slate-500 shadow-md">
          <Medal className="w-4 h-4 text-white" strokeWidth={2.5} />
        </div>
      );
    case 3:
      return (
        <div className="flex items-center justify-center w-8 h-8 rounded-full bg-gradient-to-br from-orange-400 to-orange-600 shadow-md">
          <Award className="w-4 h-4 text-white" strokeWidth={2.5} />
        </div>
      );
    default:
      return (
        <div className="flex items-center justify-center w-8 h-8 rounded-full bg-slate-100">
          <span className="text-sm font-bold text-slate-600">{rank}</span>
        </div>
      );
  }
};

/**
 * Format currency for display
 */
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount);
};

/**
 * Container animation variants
 */
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.1,
    },
  },
};

/**
 * Item animation variants
 */
const itemVariants = {
  hidden: { opacity: 0, x: -20 },
  visible: {
    opacity: 1,
    x: 0,
    transition: {
      type: "spring" as const,
      stiffness: 100,
      damping: 12,
    },
  },
};

/**
 * TopSubjectsRanking Component
 *
 * Displays a ranked list of top subjects by project count and earnings.
 * Features medal badges for top 3 positions, stagger animations, and hover effects.
 *
 * @component
 * @example
 * ```tsx
 * <TopSubjectsRanking
 *   subjects={[
 *     { subject: "Mathematics", count: 45, earnings: 2250 },
 *     { subject: "Physics", count: 38, earnings: 1900 },
 *     { subject: "Chemistry", count: 32, earnings: 1600 }
 *   ]}
 * />
 * ```
 */
export const TopSubjectsRanking: React.FC<TopSubjectsRankingProps> = ({
  subjects,
}) => {
  // Limit to top 5 subjects
  const topSubjects = subjects.slice(0, 5);

  return (
    <motion.div
      className="rounded-[24px] bg-white/85 p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)]"
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.4 }}
    >
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center gap-2 mb-2">
          <TrendingUp className="w-5 h-5 text-blue-600" />
          <h3 className="text-xl font-bold text-slate-900">Top Subjects</h3>
        </div>
        <p className="text-sm text-slate-500">
          Most popular subjects by projects and earnings
        </p>
      </div>

      {/* Rankings list */}
      <motion.div
        className="space-y-3 max-h-[420px] overflow-y-auto scrollbar-thin scrollbar-thumb-slate-200 scrollbar-track-transparent"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {topSubjects.length === 0 ? (
          <div className="text-center py-8">
            <p className="text-slate-400 text-sm">No subjects data available</p>
          </div>
        ) : (
          topSubjects.map((subject, index) => {
            const rank = index + 1;
            return (
              <motion.div
                key={subject.subject}
                variants={itemVariants}
                className="group rounded-2xl bg-slate-50/80 px-4 py-3 transition-all duration-300 hover:bg-slate-100/90 hover:shadow-md cursor-pointer"
              >
                <div className="flex items-center gap-4">
                  {/* Rank badge */}
                  <div className="flex-shrink-0">
                    {getRankBadge(rank)}
                  </div>

                  {/* Subject info */}
                  <div className="flex-1 min-w-0">
                    <h4 className="font-semibold text-slate-900 truncate group-hover:text-blue-600 transition-colors">
                      {subject.subject}
                    </h4>
                    <div className="flex items-center gap-3 mt-1">
                      <span className="text-xs text-slate-500">
                        {subject.count} {subject.count === 1 ? "project" : "projects"}
                      </span>
                      <span className="text-xs text-slate-300">•</span>
                      <span className="text-xs font-medium text-emerald-600">
                        {formatCurrency(subject.earnings)}
                      </span>
                    </div>
                  </div>

                  {/* Progress indicator */}
                  <div className="flex-shrink-0">
                    <div className="w-12 text-right">
                      <span className="text-lg font-bold text-slate-900">
                        #{rank}
                      </span>
                    </div>
                  </div>
                </div>

                {/* Visual progress bar */}
                <div className="mt-3 h-1.5 bg-slate-200/50 rounded-full overflow-hidden">
                  <motion.div
                    className="h-full bg-gradient-to-r from-blue-500 to-blue-600 rounded-full"
                    initial={{ width: 0 }}
                    animate={{
                      width: `${Math.min((subject.count / (topSubjects[0]?.count || 1)) * 100, 100)}%`
                    }}
                    transition={{
                      duration: 0.8,
                      delay: index * 0.1 + 0.3,
                      ease: "easeOut"
                    }}
                  />
                </div>
              </motion.div>
            );
          })
        )}
      </motion.div>

      {/* Footer summary */}
      {topSubjects.length > 0 && (
        <motion.div
          className="mt-6 pt-4 border-t border-slate-100"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6 }}
        >
          <div className="flex items-center justify-between text-sm">
            <span className="text-slate-500">
              Total subjects tracked: {subjects.length}
            </span>
            <span className="font-medium text-slate-700">
              Top {topSubjects.length} shown
            </span>
          </div>
        </motion.div>
      )}
    </motion.div>
  );
};
