"use client";

import { Clock, CheckCircle, Star, Headphones } from "lucide-react";

const stats = [
  {
    icon: Clock,
    label: "Average Response Time",
    value: "< 2 hours",
    description: "Typical first response",
    iconBg: "bg-[#E3E9FF]",
    iconColor: "text-[#4F6CF7]",
  },
  {
    icon: CheckCircle,
    label: "Tickets Resolved",
    value: "95%",
    description: "First contact resolution",
    iconBg: "bg-green-500/10",
    iconColor: "text-green-600",
  },
  {
    icon: Star,
    label: "Satisfaction Rating",
    value: "4.8/5",
    description: "Customer feedback score",
    iconBg: "bg-[#FFF1EC]",
    iconColor: "text-[#FF8B6A]",
  },
  {
    icon: Headphones,
    label: "Support Agents",
    value: "24/7",
    description: "Always available",
    iconBg: "bg-[#EEF2FF]",
    iconColor: "text-[#6B5BFF]",
  },
];

export function SupportStats() {
  return (
    <div className="relative overflow-hidden bg-white/85 backdrop-blur-sm rounded-[28px] p-6 lg:p-8 shadow-[0_16px_35px_rgba(30,58,138,0.08)] border border-gray-100/50">
      {/* Gradient Background */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-50/50 via-purple-50/30 to-pink-50/50" />

      {/* Radial Overlay */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,_rgba(59,130,246,0.08),transparent_50%)]" />
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_bottom_left,_rgba(168,85,247,0.06),transparent_50%)]" />

      {/* Content */}
      <div className="relative">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 lg:gap-8">
          {stats.map((stat) => {
            const Icon = stat.icon;
            return (
              <div
                key={stat.label}
                className="flex flex-col items-center text-center group"
              >
                {/* Icon */}
                <div
                  className={`${stat.iconBg} ${stat.iconColor} w-14 h-14 rounded-2xl flex items-center justify-center mb-4 transition-all duration-300 group-hover:scale-110 group-hover:shadow-lg`}
                >
                  <Icon className="w-7 h-7" />
                </div>

                {/* Label */}
                <p className="text-xs font-semibold uppercase tracking-[0.2em] text-gray-500 mb-2">
                  {stat.label}
                </p>

                {/* Value */}
                <p className="text-3xl lg:text-4xl font-bold bg-gradient-to-br from-gray-900 via-gray-800 to-gray-700 bg-clip-text text-transparent mb-1">
                  {stat.value}
                </p>

                {/* Description */}
                <p className="text-sm text-gray-600">{stat.description}</p>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

export default SupportStats;
