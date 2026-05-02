"use client";

import { motion } from "framer-motion";
import { Users, ArrowRight } from "lucide-react";
import { ClientNetworkIllustration } from "./client-network-illustration";

interface UsersHeroProps {
  totalUsers: number;
  onViewAll?: () => void;
}

export function UsersHero({ totalUsers, onViewAll }: UsersHeroProps) {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.2,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.5, ease: "easeOut" as const },
    },
  };

  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={containerVariants}
      className="relative overflow-hidden rounded-3xl border border-orange-100/70 bg-gradient-to-br from-white via-orange-50/70 to-white p-8 lg:p-10 mb-8"
    >
      <div className="pointer-events-none absolute -top-16 right-12 h-48 w-48 rounded-full bg-orange-200/30 blur-3xl" />
      <div className="pointer-events-none absolute bottom-0 left-10 h-40 w-40 rounded-full bg-amber-200/30 blur-3xl" />
      <div className="grid lg:grid-cols-2 gap-8 lg:gap-12 items-center">
        {/* Left Content */}
        <motion.div variants={itemVariants} className="space-y-6">
          {/* Greeting with User Count */}
          <div className="space-y-2">
            <motion.div
              variants={itemVariants}
              className="flex items-center gap-3"
            >
              <div className="bg-orange-100 p-2.5 rounded-xl">
                <Users className="w-6 h-6 text-orange-500" />
              </div>
              <div className="flex items-baseline gap-2">
                <span className="text-4xl sm:text-5xl lg:text-6xl font-bold text-[#1C1C1C]">
                  {totalUsers}
                </span>
                <span className="text-lg text-gray-600 font-medium">
                  {totalUsers === 1 ? "Client" : "Clients"}
                </span>
              </div>
            </motion.div>

            <motion.h1
              variants={itemVariants}
              className="text-3xl sm:text-4xl lg:text-5xl font-bold text-[#1C1C1C] leading-tight"
            >
              Your Client Network
            </motion.h1>
          </div>

          {/* Tagline */}
          <motion.p
            variants={itemVariants}
            className="text-lg text-gray-600 leading-relaxed max-w-md"
          >
            Manage your client relationships, track project assignments, and
            grow your supervisor network all in one place.
          </motion.p>

          {/* Stats Row */}
          <motion.div
            variants={itemVariants}
            className="flex flex-wrap gap-6 pt-2"
          >
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-green-500" />
              <span className="text-sm text-gray-600">
                Active Collaborations
              </span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-orange-500" />
              <span className="text-sm text-gray-600">
                Real-time Sync
              </span>
            </div>
          </motion.div>

          {/* CTA Button */}
          <motion.button
            variants={itemVariants}
            onClick={onViewAll}
            className="group inline-flex items-center gap-2 bg-orange-500 hover:bg-orange-600 text-white px-6 py-3.5 rounded-2xl font-semibold transition-all duration-200 shadow-lg shadow-orange-500/25 hover:shadow-xl hover:shadow-orange-500/30"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            View All Clients
            <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
          </motion.button>

          {/* Quick Actions Hint */}
          <motion.div
            variants={itemVariants}
            className="pt-4 border-t border-orange-100"
          >
            <p className="text-sm text-gray-500">
              Quick actions: Add clients, assign projects, track earnings
            </p>
          </motion.div>
        </motion.div>

        {/* Right Illustration */}
        <motion.div
          variants={itemVariants}
          className="relative"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, ease: "easeOut" }}
        >
          <div className="relative w-full max-w-md mx-auto lg:max-w-none">
            {/* Glow Effect */}
            <motion.div
              className="absolute inset-0 bg-gradient-to-br from-orange-500/10 to-orange-600/5 rounded-3xl blur-3xl"
              animate={{
                scale: [1, 1.1, 1],
                opacity: [0.3, 0.5, 0.3],
              }}
              transition={{
                duration: 4,
                repeat: Infinity,
                ease: "easeInOut",
              }}
            />

            {/* Illustration Container */}
            <div className="relative bg-white rounded-2xl p-8 shadow-xl border border-gray-100">
              <ClientNetworkIllustration />
            </div>

            {/* Floating Badge */}
            <motion.div
              className="absolute -top-4 -right-4 bg-white rounded-xl px-4 py-2 shadow-lg border border-gray-100"
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 1.5, duration: 0.5 }}
              whileHover={{ scale: 1.05 }}
            >
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
                <span className="text-sm font-semibold text-[#1C1C1C]">
                  All Connected
                </span>
              </div>
            </motion.div>

            {/* Bottom Badge */}
            <motion.div
              className="absolute -bottom-4 left-8 bg-orange-500 text-white rounded-xl px-4 py-2 shadow-lg"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 1.7, duration: 0.5 }}
              whileHover={{ scale: 1.05 }}
            >
              <div className="flex items-center gap-2">
                <span className="text-sm font-semibold">
                  {totalUsers} Active Network{totalUsers !== 1 ? "s" : ""}
                </span>
              </div>
            </motion.div>
          </div>
        </motion.div>
      </div>
    </motion.div>
  );
}
