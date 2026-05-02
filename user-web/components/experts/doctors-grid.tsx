"use client";

/**
 * DoctorsGrid - Clean uniform grid for doctors
 * Responsive card grid with consistent sizing
 */

import { motion, AnimatePresence } from "framer-motion";
import { Search, UserX } from "lucide-react";
import { cn } from "@/lib/utils";
import { DoctorCard } from "./doctor-card";
import type { Expert } from "@/types/expert";

interface DoctorsGridProps {
  doctors: Expert[];
  onDoctorClick?: (doctor: Expert) => void;
  onBookClick?: (doctor: Expert) => void;
  className?: string;
}

/**
 * Empty state component
 */
function EmptyState() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      className="flex flex-col items-center justify-center py-20 text-center"
    >
      <div className="h-14 w-14 rounded-2xl bg-stone-100 dark:bg-stone-800 flex items-center justify-center mb-4">
        <UserX className="h-6 w-6 text-stone-400" />
      </div>
      <h3 className="text-lg font-semibold text-foreground mb-1">
        No doctors found
      </h3>
      <p className="text-sm text-muted-foreground max-w-xs">
        Try adjusting your search or filters to find what you&apos;re looking for
      </p>
    </motion.div>
  );
}

/**
 * DoctorsGrid component - Uniform responsive grid
 */
export function DoctorsGrid({
  doctors,
  onDoctorClick,
  onBookClick,
  className,
}: DoctorsGridProps) {
  if (doctors.length === 0) {
    return <EmptyState />;
  }

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={doctors.map((d) => d.id).join("-")}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className={cn(
          "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4",
          className
        )}
      >
        {doctors.map((doctor, index) => (
          <motion.div
            key={doctor.id}
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{
              duration: 0.3,
              delay: index * 0.04,
              ease: [0.25, 0.1, 0.25, 1],
            }}
          >
            <DoctorCard
              doctor={doctor}
              onClick={() => onDoctorClick?.(doctor)}
              onBookClick={() => onBookClick?.(doctor)}
            />
          </motion.div>
        ))}
      </motion.div>
    </AnimatePresence>
  );
}

/**
 * Alternative list layout for doctors
 */
export function DoctorsSimpleGrid({
  doctors,
  onDoctorClick,
  onBookClick,
  className,
}: DoctorsGridProps) {
  if (doctors.length === 0) {
    return <EmptyState />;
  }

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={doctors.map((d) => d.id).join("-")}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className={cn("space-y-3", className)}
      >
        {doctors.map((doctor, index) => (
          <motion.div
            key={doctor.id}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{
              duration: 0.3,
              delay: index * 0.03,
              ease: [0.25, 0.1, 0.25, 1],
            }}
          >
            <DoctorCard
              doctor={doctor}
              variant="list"
              onClick={() => onDoctorClick?.(doctor)}
              onBookClick={() => onBookClick?.(doctor)}
            />
          </motion.div>
        ))}
      </motion.div>
    </AnimatePresence>
  );
}

export default DoctorsGrid;
