"use client";

/**
 * DeviceFrame - Reusable device frame component
 * Renders realistic browser chrome or mobile device bezels
 * with shadow and reflection effects
 */

import { ReactNode } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import {
  Circle,
  Minus,
  Square,
  X,
  Wifi,
  Battery,
  Signal,
} from "lucide-react";

interface DeviceFrameProps {
  /** Device type to render */
  type: "desktop" | "mobile" | "tablet";
  /** Content to display inside the device frame */
  children: ReactNode;
  /** Optional className for additional styling */
  className?: string;
  /** URL to display in browser bar (desktop only) */
  url?: string;
  /** Show device reflections and shadows */
  showEffects?: boolean;
  /** Animation delay for staggered entrance */
  delay?: number;
}

/**
 * Desktop browser chrome component
 */
function BrowserChrome({
  url = "assignx.in/dashboard",
}: {
  url?: string;
}) {
  return (
    <div className="flex items-center gap-2 px-4 py-2.5 bg-gradient-to-b from-slate-100 to-slate-50 dark:from-slate-800 dark:to-slate-900 border-b border-slate-200 dark:border-slate-700 rounded-t-xl">
      {/* Traffic lights */}
      <div className="flex items-center gap-1.5">
        <div className="w-3 h-3 rounded-full bg-red-400 hover:bg-red-500 transition-colors cursor-pointer flex items-center justify-center group">
          <X className="w-2 h-2 text-red-800 opacity-0 group-hover:opacity-100 transition-opacity" />
        </div>
        <div className="w-3 h-3 rounded-full bg-yellow-400 hover:bg-yellow-500 transition-colors cursor-pointer flex items-center justify-center group">
          <Minus className="w-2 h-2 text-yellow-800 opacity-0 group-hover:opacity-100 transition-opacity" />
        </div>
        <div className="w-3 h-3 rounded-full bg-green-400 hover:bg-green-500 transition-colors cursor-pointer flex items-center justify-center group">
          <Square className="w-1.5 h-1.5 text-green-800 opacity-0 group-hover:opacity-100 transition-opacity" />
        </div>
      </div>

      {/* URL bar */}
      <div className="flex-1 mx-4">
        <div className="flex items-center gap-2 px-3 py-1.5 bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-600">
          <div className="flex items-center gap-1">
            <div className="w-3.5 h-3.5 rounded-full bg-green-500 flex items-center justify-center">
              <svg className="w-2 h-2 text-white" fill="currentColor" viewBox="0 0 16 16">
                <path fillRule="evenodd" d="M8 0a8 8 0 100 16A8 8 0 008 0zm3.28 5.78a.75.75 0 00-1.06-1.06L7 7.94 5.78 6.72a.75.75 0 00-1.06 1.06l1.75 1.75a.75.75 0 001.06 0l3.75-3.75z" />
              </svg>
            </div>
          </div>
          <span className="text-xs text-slate-600 dark:text-slate-300 font-medium truncate">
            {url}
          </span>
        </div>
      </div>

      {/* Browser actions */}
      <div className="flex items-center gap-1">
        <Circle className="w-4 h-4 text-slate-400" />
        <Circle className="w-4 h-4 text-slate-400" />
      </div>
    </div>
  );
}

/**
 * Mobile device status bar component
 */
function MobileStatusBar() {
  return (
    <div className="flex items-center justify-between px-5 py-2 bg-slate-900 text-white">
      <span className="text-xs font-semibold">9:41</span>
      <div className="flex items-center gap-1">
        <Signal className="w-3.5 h-3.5" />
        <Wifi className="w-3.5 h-3.5" />
        <Battery className="w-4 h-4" />
      </div>
    </div>
  );
}

/**
 * Mobile device home indicator
 */
function MobileHomeIndicator() {
  return (
    <div className="flex items-center justify-center py-2 bg-slate-900">
      <div className="w-28 h-1 rounded-full bg-white/30" />
    </div>
  );
}

/**
 * DeviceFrame - Main component for rendering device mockups
 */
export function DeviceFrame({
  type,
  children,
  className,
  url,
  showEffects = true,
  delay = 0,
}: DeviceFrameProps) {
  const frameVariants = {
    hidden: {
      opacity: 0,
      y: 40,
      scale: 0.95,
    },
    visible: {
      opacity: 1,
      y: 0,
      scale: 1,
      transition: {
        duration: 0.8,
        delay,
        ease: [0.16, 1, 0.3, 1] as [number, number, number, number],
      },
    },
  };

  if (type === "desktop") {
    return (
      <motion.div
        variants={frameVariants}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: "-100px" }}
        className={cn(
          "relative rounded-xl overflow-hidden",
          showEffects && "shadow-2xl shadow-slate-900/20 dark:shadow-black/40",
          className
        )}
      >
        {/* Outer frame with gradient border */}
        <div className="relative bg-gradient-to-b from-slate-200 via-slate-100 to-slate-200 dark:from-slate-700 dark:via-slate-800 dark:to-slate-700 p-0.5 rounded-xl">
          <div className="bg-white dark:bg-slate-900 rounded-xl overflow-hidden">
            {/* Browser chrome */}
            <BrowserChrome url={url} />

            {/* Content area */}
            <div className="relative bg-slate-50 dark:bg-slate-950 overflow-hidden">
              {children}
            </div>
          </div>
        </div>

        {/* Reflection effect */}
        {showEffects && (
          <div className="absolute inset-0 bg-gradient-to-br from-white/10 via-transparent to-transparent pointer-events-none rounded-xl" />
        )}

        {/* Screen glare */}
        {showEffects && (
          <motion.div
            className="absolute top-0 -left-1/2 w-full h-full bg-gradient-to-r from-transparent via-white/5 to-transparent skew-x-12 pointer-events-none"
            initial={{ x: "-100%" }}
            animate={{ x: "200%" }}
            transition={{
              duration: 3,
              repeat: Infinity,
              repeatDelay: 5,
              ease: "easeInOut",
            }}
          />
        )}
      </motion.div>
    );
  }

  if (type === "mobile") {
    return (
      <motion.div
        variants={frameVariants}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: "-100px" }}
        className={cn(
          "relative w-[280px] rounded-[2.5rem] overflow-hidden",
          showEffects && "shadow-2xl shadow-slate-900/25 dark:shadow-black/50",
          className
        )}
      >
        {/* Device frame */}
        <div className="relative bg-gradient-to-b from-slate-800 via-slate-900 to-black p-2 rounded-[2.5rem]">
          {/* Inner bezel */}
          <div className="relative bg-slate-900 rounded-[2rem] overflow-hidden">
            {/* Notch */}
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-28 h-6 bg-black rounded-b-2xl z-20 flex items-center justify-center gap-2">
              <div className="w-2 h-2 rounded-full bg-slate-700" />
              <div className="w-12 h-3 rounded-full bg-slate-800" />
            </div>

            {/* Status bar */}
            <MobileStatusBar />

            {/* Content area */}
            <div className="relative bg-white dark:bg-slate-950 overflow-hidden min-h-[500px]">
              {children}
            </div>

            {/* Home indicator */}
            <MobileHomeIndicator />
          </div>
        </div>

        {/* Reflection effect */}
        {showEffects && (
          <div className="absolute inset-0 bg-gradient-to-br from-white/10 via-transparent to-transparent pointer-events-none rounded-[2.5rem]" />
        )}

        {/* Side button */}
        <div className="absolute right-[-2px] top-24 w-1 h-12 bg-slate-700 rounded-l-sm" />
        <div className="absolute left-[-2px] top-20 w-1 h-6 bg-slate-700 rounded-r-sm" />
        <div className="absolute left-[-2px] top-32 w-1 h-10 bg-slate-700 rounded-r-sm" />
      </motion.div>
    );
  }

  // Tablet frame
  return (
    <motion.div
      variants={frameVariants}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: "-100px" }}
      className={cn(
        "relative w-[500px] rounded-[1.5rem] overflow-hidden",
        showEffects && "shadow-2xl shadow-slate-900/20 dark:shadow-black/40",
        className
      )}
    >
      {/* Device frame */}
      <div className="relative bg-gradient-to-b from-slate-200 via-slate-100 to-slate-200 dark:from-slate-700 dark:via-slate-800 dark:to-slate-700 p-3 rounded-[1.5rem]">
        <div className="relative bg-white dark:bg-slate-900 rounded-xl overflow-hidden">
          {/* Status bar */}
          <div className="flex items-center justify-between px-6 py-2 bg-slate-50 dark:bg-slate-900 border-b border-slate-100 dark:border-slate-800">
            <span className="text-xs font-medium text-slate-600 dark:text-slate-400">9:41 AM</span>
            <div className="flex items-center gap-1.5">
              <Wifi className="w-4 h-4 text-slate-600 dark:text-slate-400" />
              <Battery className="w-5 h-5 text-slate-600 dark:text-slate-400" />
            </div>
          </div>

          {/* Content area */}
          <div className="relative bg-slate-50 dark:bg-slate-950 overflow-hidden min-h-[350px]">
            {children}
          </div>
        </div>
      </div>

      {/* Camera */}
      <div className="absolute top-6 left-1/2 -translate-x-1/2 w-2.5 h-2.5 rounded-full bg-slate-400 dark:bg-slate-600" />

      {/* Reflection */}
      {showEffects && (
        <div className="absolute inset-0 bg-gradient-to-br from-white/10 via-transparent to-transparent pointer-events-none rounded-[1.5rem]" />
      )}
    </motion.div>
  );
}

/**
 * DeviceFrameGroup - Container for displaying multiple devices together
 */
export function DeviceFrameGroup({
  children,
  className,
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("flex items-center justify-center gap-6 py-8", className)}>
      {children}
    </div>
  );
}
