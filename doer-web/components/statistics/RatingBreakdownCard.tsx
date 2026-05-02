"use client";

import { useEffect, useState } from "react";
import { Star, TrendingUp, Clock, MessageSquare, Award } from "lucide-react";

/**
 * Props for RatingBreakdownCard component
 */
export interface RatingBreakdownCardProps {
  /** Quality rating out of 5 */
  qualityRating: number;
  /** Timeliness rating out of 5 */
  timelinessRating: number;
  /** Communication rating out of 5 */
  communicationRating: number;
  /** Overall rating out of 5 */
  overallRating: number;
}

/**
 * Individual rating category with animated progress bar
 */
interface RatingCategoryProps {
  label: string;
  rating: number;
  icon: React.ElementType;
  color: string;
  delay: number;
}

function RatingCategory({
  label,
  rating,
  icon: Icon,
  color,
  delay,
}: RatingCategoryProps) {
  const [animatedWidth, setAnimatedWidth] = useState(0);
  const percentage = (rating / 5) * 100;

  useEffect(() => {
    const timer = setTimeout(() => {
      setAnimatedWidth(percentage);
    }, delay);

    return () => clearTimeout(timer);
  }, [percentage, delay]);

  const colorClasses = {
    teal: { bg: "bg-teal-500/10", text: "text-teal-500", bar: "bg-teal-500" },
    emerald: { bg: "bg-emerald-500/10", text: "text-emerald-500", bar: "bg-emerald-500" },
    cyan: { bg: "bg-cyan-500/10", text: "text-cyan-500", bar: "bg-cyan-500" },
    amber: { bg: "bg-amber-500/10", text: "text-amber-500", bar: "bg-amber-500" },
  };

  const colors = colorClasses[color as keyof typeof colorClasses];

  return (
    <div className="group">
      <div className="mb-2 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <div
            className={`rounded-lg ${colors.bg} p-1.5 transition-all duration-300 group-hover:scale-110`}
          >
            <Icon
              className={`h-4 w-4 ${colors.text}`}
            />
          </div>
          <span className="text-sm font-medium text-gray-700">{label}</span>
        </div>
        <div className="flex items-center gap-1">
          <span className="text-sm font-bold text-gray-900">
            {rating.toFixed(1)}
          </span>
          <span className="text-xs text-gray-500">/5</span>
          <Star className="ml-0.5 h-3.5 w-3.5 fill-amber-400 text-amber-400" />
        </div>
      </div>
      <div className="relative h-3 overflow-hidden rounded-full bg-muted">
        <div
          className={`h-full rounded-full ${colors.bar} transition-all duration-1000 ease-out`}
          style={{ width: `${animatedWidth}%` }}
        >
          {/* Shimmer effect */}
          <div className="absolute inset-0 animate-shimmer bg-gradient-to-r from-transparent via-white/30 to-transparent" />
        </div>
      </div>
    </div>
  );
}

/**
 * RatingBreakdownCard - Displays rating breakdown with animated progress bars
 *
 * Features:
 * - Four rating categories with individual progress bars
 * - Smooth animation on mount with staggered delays
 * - Color-coded categories with icons
 * - Hover effects on each category
 * - Overall rating summary at the top
 *
 * @example
 * ```tsx
 * <RatingBreakdownCard
 *   qualityRating={4.8}
 *   timelinessRating={4.5}
 *   communicationRating={4.9}
 *   overallRating={4.7}
 * />
 * ```
 */
export function RatingBreakdownCard({
  qualityRating,
  timelinessRating,
  communicationRating,
  overallRating,
}: RatingBreakdownCardProps) {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
  }, []);

  const categories = [
    {
      label: "Quality",
      rating: qualityRating,
      icon: Award,
      color: "teal",
      delay: 100,
    },
    {
      label: "Timeliness",
      rating: timelinessRating,
      icon: Clock,
      color: "emerald",
      delay: 200,
    },
    {
      label: "Communication",
      rating: communicationRating,
      icon: MessageSquare,
      color: "cyan",
      delay: 300,
    },
    {
      label: "Overall",
      rating: overallRating,
      icon: TrendingUp,
      color: "amber",
      delay: 400,
    },
  ];

  return (
    <div
      className={`
        rounded-[24px] bg-white/85 p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)] backdrop-blur-sm
        transition-all duration-500
        ${isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"}
        hover:shadow-[0_20px_40px_rgba(30,58,138,0.12)]
      `}
    >
      {/* Header */}
      <div className="mb-6 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="rounded-xl bg-gradient-to-br from-amber-400 to-orange-500 p-2.5 shadow-lg">
            <Star className="h-5 w-5 fill-white text-white" />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-900">
              Rating Breakdown
            </h3>
            <p className="text-sm text-gray-500">Performance metrics</p>
          </div>
        </div>

        {/* Overall rating badge */}
        <div className="rounded-xl bg-gradient-to-br from-amber-50 to-orange-50 px-4 py-2 shadow-sm">
          <div className="flex items-center gap-1.5">
            <Star className="h-5 w-5 fill-amber-400 text-amber-400" />
            <span className="text-2xl font-bold text-gray-900">
              {overallRating.toFixed(1)}
            </span>
            <span className="text-sm text-gray-500">/5</span>
          </div>
        </div>
      </div>

      {/* Rating categories */}
      <div className="space-y-5">
        {categories.map((category, index) => (
          <RatingCategory key={category.label} {...category} />
        ))}
      </div>

      {/* Summary footer */}
      <div className="mt-6 rounded-xl bg-gradient-to-r from-amber-50 to-orange-50 p-4 border border-amber-100">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <TrendingUp className="h-4 w-4 text-amber-600" />
            <span className="text-sm font-medium text-gray-700">
              Performance Status
            </span>
          </div>
          <span
            className={`
            text-sm font-semibold
            ${
              overallRating >= 4.5
                ? "text-emerald-600"
                : overallRating >= 4.0
                  ? "text-amber-600"
                  : "text-orange-600"
            }
          `}
          >
            {overallRating >= 4.5
              ? "Excellent"
              : overallRating >= 4.0
                ? "Good"
                : "Needs Improvement"}
          </span>
        </div>
      </div>
    </div>
  );
}
