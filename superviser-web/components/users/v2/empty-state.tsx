"use client";

import { motion } from "framer-motion";
import { Users } from "lucide-react";
import { Button } from "@/components/ui/button";

interface UsersEmptyStateProps {
  onClear: () => void;
}

export function UsersEmptyState({ onClear }: UsersEmptyStateProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="p-12 text-center"
    >
      <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mx-auto mb-4">
        <Users className="h-8 w-8 text-gray-400" />
      </div>
      <p className="text-gray-600 font-medium">No users found</p>
      <p className="text-gray-400 text-sm mt-1">Try adjusting your search or filters</p>
      <Button
        onClick={onClear}
        className="mt-6 bg-[#F97316] hover:bg-[#EA580C] text-white rounded-2xl px-6 h-10 font-medium shadow-lg shadow-orange-500/20"
      >
        Clear Filters
      </Button>
    </motion.div>
  );
}
