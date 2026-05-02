"use client";

import { motion } from "framer-motion";
import { FileText, BookOpen, ClipboardList, Edit3, type LucideIcon } from "lucide-react";

interface CommissionCategory {
  id: string;
  name: string;
  percentage: number;
  amount: number;
  icon: LucideIcon;
  color: string;
}


interface ProgressBarProps {
  category: CommissionCategory;
  index: number;
}

function ProgressBar({ category, index }: ProgressBarProps) {
  const Icon = category.icon;

  return (
    <div className="space-y-2">
      {/* Header: Icon, Name, Amount */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2.5">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-orange-50">
            <Icon className="h-4.5 w-4.5 text-orange-500" strokeWidth={2} />
          </div>
          <span className="text-sm font-medium text-gray-900">{category.name}</span>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-sm font-semibold text-gray-700">
            ₹{category.amount.toLocaleString("en-IN")}
          </span>
          <span className="min-w-[3rem] text-right text-xs font-medium text-gray-500">
            {category.percentage}%
          </span>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="relative h-3 w-full overflow-hidden rounded-full bg-gray-100">
        <motion.div
          className="h-full rounded-full bg-gradient-to-r from-orange-500 to-orange-400"
          initial={{ width: 0 }}
          animate={{ width: `${category.percentage}%` }}
          transition={{
            duration: 1.2,
            delay: index * 0.1,
            ease: [0.4, 0, 0.2, 1],
          }}
        />
      </div>
    </div>
  );
}

interface CommissionBreakdownV2Props {
  data?: CommissionCategory[]
}

export function CommissionBreakdownV2({ data = [] }: CommissionBreakdownV2Props) {
  const total = data.reduce((sum, cat) => sum + cat.amount, 0)

  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-6">
      {/* Header */}
      <div className="mb-6">
        <h3 className="text-lg font-semibold text-gray-900">Commission Breakdown</h3>
        <p className="mt-1 text-sm text-gray-500">By project type</p>
      </div>

      {data.length === 0 ? (
        <p className="py-8 text-center text-sm text-gray-400">No commission data yet</p>
      ) : (
        <>
          {/* Progress Bars */}
          <div className="space-y-6">
            {data.map((category, index) => (
              <ProgressBar key={category.id} category={category} index={index} />
            ))}
          </div>

          {/* Total Summary */}
          <div className="mt-6 flex items-center justify-between border-t border-gray-100 pt-5">
            <span className="text-sm font-medium text-gray-700">Total Commission</span>
            <span className="text-lg font-bold text-gray-900">
              ₹{total.toLocaleString("en-IN")}
            </span>
          </div>
        </>
      )}
    </div>
  );
}
