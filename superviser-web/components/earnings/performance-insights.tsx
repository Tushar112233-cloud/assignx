"use client";

import { motion } from "framer-motion";
import { TrendingUp, TrendingDown, Target } from "lucide-react";
import { useEarningsStats } from "@/hooks/use-wallet";
import { Skeleton } from "@/components/ui/skeleton";

interface AchievementBadge {
  icon: string;
  label: string;
  condition: (progress: number, trend: number) => boolean;
}

const achievementBadges: AchievementBadge[] = [
  {
    icon: "🎯",
    label: "On Track",
    condition: (progress) => progress >= 25 && progress < 100,
  },
  {
    icon: "⚡",
    label: "Fast Start",
    condition: (progress, trend) => progress >= 15 && trend > 0,
  },
  {
    icon: "🏆",
    label: "Goal Achieved",
    condition: (progress) => progress >= 100,
  },
  {
    icon: "🔥",
    label: "Hot Streak",
    condition: (progress, trend) => trend > 20,
  },
  {
    icon: "💪",
    label: "Strong Growth",
    condition: (progress, trend) => trend > 10 && progress > 30,
  },
];

const getMotivationalMessage = (progress: number, trend: number): string => {
  if (progress >= 100) {
    return "🎉 Congratulations! You've achieved your monthly goal!";
  } else if (progress >= 75) {
    return "Almost there! Keep up the excellent work!";
  } else if (progress >= 50) {
    return "Halfway to your goal! You're doing great!";
  } else if (progress >= 25) {
    return "Good start! Stay consistent to reach your goal.";
  } else if (trend > 0) {
    return "You're on the right track! Keep the momentum going.";
  } else {
    return "Let's build momentum! Every project counts.";
  }
};

export function PerformanceInsights() {
  const { stats, isLoading } = useEarningsStats();

  // Mock monthly goal
  const monthlyGoal = 30000;

  // Calculate progress using stats from the hook
  const currentEarnings = stats?.thisMonth || 0;
  const progress = Math.min((currentEarnings / monthlyGoal) * 100, 100);

  // Use monthly growth from the hook (calculated from real historical data)
  const trendPercentage = stats?.monthlyGrowth || 0;
  const isPositiveTrend = trendPercentage >= 0;

  // Get active achievement badges
  const activeAchievements = achievementBadges.filter((badge) =>
    badge.condition(progress, trendPercentage)
  );

  const motivationalMessage = getMotivationalMessage(
    progress,
    trendPercentage
  );

  if (isLoading) {
    return (
      <div className="rounded-2xl border border-gray-200 bg-white p-6">
        <div className="space-y-4">
          <Skeleton className="h-6 w-48" />
          <Skeleton className="h-4 w-32" />
          <Skeleton className="h-16 w-full" />
          <Skeleton className="h-8 w-full" />
        </div>
      </div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className="rounded-2xl border border-gray-200 bg-white p-6"
    >
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-2">
          <h3 className="text-lg font-semibold text-gray-900">
            Performance Insights
          </h3>
          <Target className="w-5 h-5 text-orange-500" />
        </div>
        <p className="text-sm text-gray-600">Your monthly progress</p>
      </div>

      {/* Earnings Progress */}
      <div className="mb-6">
        <div className="flex items-end justify-between mb-3">
          <div>
            <motion.div
              initial={{ scale: 0.5, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="text-4xl font-bold text-gray-900"
            >
              ₹{currentEarnings.toLocaleString("en-IN")}
            </motion.div>
            <p className="text-sm text-gray-600 mt-1">
              of ₹{monthlyGoal.toLocaleString("en-IN")} goal
            </p>
          </div>

          <motion.div
            initial={{ scale: 0, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="px-3 py-1 rounded-full bg-orange-100 text-orange-700 text-sm font-semibold"
          >
            {progress.toFixed(0)}%
          </motion.div>
        </div>

        {/* Progress Bar */}
        <div className="relative h-3 bg-gray-100 rounded-full overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ duration: 1, delay: 0.4, ease: "easeOut" }}
            className="absolute top-0 left-0 h-full bg-gradient-to-r from-orange-500 to-orange-400 rounded-full"
          >
            {/* Shimmer effect */}
            <motion.div
              animate={{
                x: ["-100%", "200%"],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "linear",
              }}
              className="absolute top-0 left-0 h-full w-1/2 bg-gradient-to-r from-transparent via-white/30 to-transparent"
            />
          </motion.div>
        </div>
      </div>

      {/* Trend Comparison */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.6 }}
        className="mb-6 p-4 rounded-xl bg-gray-50"
      >
        <div className="flex items-center gap-2 mb-2">
          {isPositiveTrend ? (
            <div className="flex items-center text-green-600">
              <TrendingUp className="w-5 h-5 mr-1" />
              <span className="font-semibold">
                +{trendPercentage.toFixed(1)}%
              </span>
            </div>
          ) : (
            <div className="flex items-center text-red-600">
              <TrendingDown className="w-5 h-5 mr-1" />
              <span className="font-semibold">
                {trendPercentage.toFixed(1)}%
              </span>
            </div>
          )}
          <span className="text-sm text-gray-600">vs last month</span>
        </div>

        <p className="text-sm text-gray-700">{motivationalMessage}</p>
      </motion.div>

      {/* Achievement Badges */}
      {activeAchievements.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.8 }}
        >
          <p className="text-xs font-medium text-gray-600 mb-3">
            Achievements
          </p>
          <div className="flex flex-wrap gap-2">
            {activeAchievements.map((badge, index) => (
              <motion.div
                key={badge.label}
                initial={{ scale: 0, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                transition={{
                  duration: 0.3,
                  delay: 0.8 + index * 0.1,
                  type: "spring",
                  stiffness: 200,
                }}
                className="px-3 py-1.5 rounded-full bg-gradient-to-r from-orange-50 to-yellow-50 border border-orange-200 text-sm font-medium text-gray-700 flex items-center gap-1.5"
              >
                <span>{badge.icon}</span>
                <span>{badge.label}</span>
              </motion.div>
            ))}
          </div>
        </motion.div>
      )}
    </motion.div>
  );
}
