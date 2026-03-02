"use client";

/**
 * ProHero - Gradient hero section for the Pro Network page
 * Features animated stats and a call-to-action button
 */

import Link from "next/link";
import { motion } from "framer-motion";
import { Briefcase, Users, TrendingUp, Zap } from "lucide-react";
import { Button } from "@/components/ui/button";

interface ProHeroProps {
  /** Total number of posts */
  totalPosts: number;
}

export function ProHero({ totalPosts }: ProHeroProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-blue-600 via-indigo-600 to-violet-700 p-6 md:p-8 text-white"
    >
      {/* Background pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-0 right-0 w-64 h-64 bg-white rounded-full -translate-y-1/2 translate-x-1/2" />
        <div className="absolute bottom-0 left-0 w-48 h-48 bg-white rounded-full translate-y-1/2 -translate-x-1/2" />
      </div>

      <div className="relative z-10">
        {/* Header */}
        <div className="flex items-start justify-between gap-4">
          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <div className="h-10 w-10 rounded-xl bg-white/20 backdrop-blur-sm flex items-center justify-center">
                <Briefcase className="h-5 w-5" />
              </div>
              <h1 className="text-2xl md:text-3xl font-bold tracking-tight">
                Professional Network
              </h1>
            </div>
            <p className="text-blue-100 text-sm md:text-base max-w-md">
              Connect with industry professionals, share insights, and grow your
              career network.
            </p>
          </div>

          <Button
            asChild
            className="bg-white text-indigo-700 hover:bg-blue-50 shadow-lg hidden sm:flex"
          >
            <Link href="/pro-network/create">Create Post</Link>
          </Button>
        </div>

        {/* Stats */}
        <div className="flex flex-wrap gap-4 mt-6">
          <div className="flex items-center gap-2 bg-white/15 backdrop-blur-sm rounded-lg px-3 py-2">
            <Users className="h-4 w-4 text-blue-200" />
            <span className="text-sm font-medium">Professionals</span>
          </div>
          <div className="flex items-center gap-2 bg-white/15 backdrop-blur-sm rounded-lg px-3 py-2">
            <TrendingUp className="h-4 w-4 text-blue-200" />
            <span className="text-sm font-medium">
              {totalPosts} {totalPosts === 1 ? "Post" : "Posts"}
            </span>
          </div>
          <div className="flex items-center gap-2 bg-white/15 backdrop-blur-sm rounded-lg px-3 py-2">
            <Zap className="h-4 w-4 text-blue-200" />
            <span className="text-sm font-medium">Active Network</span>
          </div>
        </div>

        {/* Mobile CTA */}
        <div className="mt-4 sm:hidden">
          <Button
            asChild
            className="w-full bg-white text-indigo-700 hover:bg-blue-50 shadow-lg"
          >
            <Link href="/pro-network/create">Create Post</Link>
          </Button>
        </div>
      </div>
    </motion.div>
  );
}
