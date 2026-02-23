"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { Search, HelpCircle, Clock, CheckCircle2 } from "lucide-react";

/**
 * Props for the HelpHeader component
 */
interface HelpHeaderProps {
  /** Callback when search is performed */
  onSearch?: (query: string) => void;
  /** Initial search query */
  initialQuery?: string;
}

/**
 * Stat item configuration
 */
interface StatItem {
  icon: React.ReactNode;
  label: string;
  value: string;
  color: string;
}

/**
 * HelpHeader Component
 *
 * Hero header for the help center with gradient background, search functionality,
 * and quick stats. Features glassmorphism design and smooth animations.
 *
 * @component
 * @example
 * ```tsx
 * <HelpHeader
 *   onSearch={(query) => console.log(query)}
 *   initialQuery=""
 * />
 * ```
 */
export const HelpHeader: React.FC<HelpHeaderProps> = ({
  onSearch,
  initialQuery = "",
}) => {
  const [searchQuery, setSearchQuery] = useState(initialQuery);

  /**
   * Handle search form submission
   */
  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (onSearch && searchQuery.trim()) {
      onSearch(searchQuery.trim());
    }
  };

  /**
   * Quick stats configuration
   */
  const stats: StatItem[] = [
    {
      icon: <Clock className="h-4 w-4" />,
      label: "Response time",
      value: "<2hrs",
      color: "from-[#5A7CFF] to-[#5B86FF]",
    },
    {
      icon: <CheckCircle2 className="h-4 w-4" />,
      label: "Tickets resolved",
      value: "95%",
      color: "from-[#43D1C5] to-[#49C5FF]",
    },
  ];

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, ease: "easeOut" }}
      className="relative overflow-hidden rounded-[32px] bg-gradient-to-br from-[#EEF2FF] via-[#F3F5FF] to-[#E9FAFA] p-8 shadow-[0_28px_70px_rgba(30,58,138,0.12)]"
    >
      {/* Radial gradient overlay */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,rgba(90,124,255,0.08),transparent_50%),radial-gradient(circle_at_bottom_left,rgba(67,209,197,0.08),transparent_50%)]" />

      {/* Decorative gradient orbs */}
      <div className="absolute -right-20 -top-20 h-64 w-64 rounded-full bg-gradient-to-br from-[#5A7CFF]/20 to-[#5B86FF]/10 blur-3xl" />
      <div className="absolute -bottom-20 -left-20 h-64 w-64 rounded-full bg-gradient-to-tr from-[#43D1C5]/20 to-[#49C5FF]/10 blur-3xl" />

      {/* Content grid */}
      <div className="relative grid grid-cols-1 gap-8 lg:grid-cols-5">
        {/* Left content - 60% */}
        <div className="lg:col-span-3 space-y-6">
          {/* Badge */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2, duration: 0.4 }}
            className="inline-flex"
          >
            <span className="inline-flex items-center rounded-full bg-[#E6F4FF] px-4 py-1.5 text-sm font-medium text-[#4F6CF7]">
              <HelpCircle className="mr-2 h-4 w-4" />
              Help Center
            </span>
          </motion.div>

          {/* Title */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.5 }}
            className="space-y-2"
          >
            <h1 className="text-3xl font-semibold tracking-tight text-slate-900 lg:text-4xl">
              How can we help you?
            </h1>
            <p className="text-base text-slate-600 lg:text-lg">
              Search our knowledge base or get in touch with our support team
            </p>
          </motion.div>

          {/* Search bar */}
          <motion.form
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4, duration: 0.5 }}
            onSubmit={handleSearch}
            className="relative"
          >
            <div className="relative flex items-center">
              <Search className="absolute left-5 h-5 w-5 text-gray-400" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search for articles, guides, and FAQs..."
                className="h-14 w-full rounded-full border border-white/40 bg-white/60 pl-14 pr-6 text-slate-900 placeholder:text-slate-500 backdrop-blur-xl transition-all duration-200 focus:border-[#5A7CFF]/30 focus:bg-white/80 focus:outline-none focus:ring-4 focus:ring-[#E7ECFF]"
              />
            </div>
          </motion.form>

          {/* Quick stats pills */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.5 }}
            className="flex flex-wrap gap-3"
          >
            {stats.map((stat, index) => (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.6 + index * 0.1, duration: 0.4 }}
                className="flex items-center gap-2 rounded-full border border-white/40 bg-white/70 px-4 py-2 backdrop-blur-xl shadow-[0_8px_20px_rgba(148,163,184,0.08)]"
              >
                <div
                  className={`flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br ${stat.color} text-white shadow-lg`}
                >
                  {stat.icon}
                </div>
                <div className="flex flex-col">
                  <span className="text-xs text-slate-600">{stat.label}</span>
                  <span className="text-sm font-semibold text-slate-900">
                    {stat.value}
                  </span>
                </div>
              </motion.div>
            ))}
          </motion.div>
        </div>

        {/* Right content - 40% */}
        <div className="lg:col-span-2 flex items-center justify-center">
          <motion.div
            initial={{ opacity: 0, scale: 0.8, rotate: -10 }}
            animate={{ opacity: 1, scale: 1, rotate: 0 }}
            transition={{ delay: 0.4, duration: 0.6, ease: "easeOut" }}
            className="relative"
          >
            {/* Large icon circle */}
            <div className="relative flex h-32 w-32 items-center justify-center rounded-full bg-gradient-to-br from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] p-1 shadow-[0_20px_50px_rgba(90,124,255,0.3)]">
              <div className="flex h-full w-full items-center justify-center rounded-full bg-white">
                <HelpCircle className="h-16 w-16 text-[#5A7CFF]" strokeWidth={1.5} />
              </div>
            </div>

            {/* Decorative rings */}
            <motion.div
              animate={{
                scale: [1, 1.2, 1],
                opacity: [0.3, 0.1, 0.3],
              }}
              transition={{
                duration: 3,
                repeat: Infinity,
                ease: "easeInOut",
              }}
              className="absolute inset-0 -z-10 rounded-full border-2 border-[#5A7CFF]/30"
            />
            <motion.div
              animate={{
                scale: [1, 1.4, 1],
                opacity: [0.2, 0.05, 0.2],
              }}
              transition={{
                duration: 3,
                repeat: Infinity,
                ease: "easeInOut",
                delay: 0.5,
              }}
              className="absolute inset-0 -z-10 rounded-full border-2 border-[#49C5FF]/20"
            />

            {/* Floating particles */}
            <motion.div
              animate={{
                y: [-10, 10, -10],
                x: [-5, 5, -5],
              }}
              transition={{
                duration: 4,
                repeat: Infinity,
                ease: "easeInOut",
              }}
              className="absolute -right-4 -top-4 h-6 w-6 rounded-full bg-gradient-to-br from-[#FF8B6A] to-[#FF9B7A] opacity-60 blur-sm"
            />
            <motion.div
              animate={{
                y: [10, -10, 10],
                x: [5, -5, 5],
              }}
              transition={{
                duration: 5,
                repeat: Infinity,
                ease: "easeInOut",
              }}
              className="absolute -bottom-4 -left-4 h-8 w-8 rounded-full bg-gradient-to-br from-[#43D1C5] to-[#49C5FF] opacity-50 blur-sm"
            />
          </motion.div>
        </div>
      </div>
    </motion.div>
  );
};

export default HelpHeader;
