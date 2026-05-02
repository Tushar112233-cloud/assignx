"use client";

import { motion } from "framer-motion";
import { Search, Brain, Sparkles } from "lucide-react";

interface FeaturedToolsSectionProps {
  onLaunchPlagiarismChecker: () => void;
  onLaunchAIDetector: () => void;
  onLaunchGrammarChecker: () => void;
}

export function FeaturedToolsSection({
  onLaunchPlagiarismChecker,
  onLaunchAIDetector,
  onLaunchGrammarChecker,
}: FeaturedToolsSectionProps) {
  const tools = [
    {
      icon: Search,
      iconBg: "bg-blue-100",
      iconColor: "text-blue-600",
      title: "Plagiarism Checker",
      description: "Scan assignments for originality and detect copied content across the web",
      stat: "24 checks this month",
      badge: "Essential",
      onClick: onLaunchPlagiarismChecker,
    },
    {
      icon: Brain,
      iconBg: "bg-purple-100",
      iconColor: "text-purple-600",
      title: "AI Content Detector",
      description: "Identify AI-generated text and ensure authentic student work",
      stat: "18 scans",
      badge: "Essential",
      onClick: onLaunchAIDetector,
    },
    {
      icon: Sparkles,
      iconBg: "bg-green-100",
      iconColor: "text-green-600",
      title: "Grammar Checker",
      description: "Review grammar, spelling, and writing quality in student submissions",
      stat: "15 reviews",
      badge: null,
      onClick: onLaunchGrammarChecker,
    },
  ];

  return (
    <section className="space-y-4">
      <div>
        <h2 className="text-2xl font-bold text-[#1C1C1C]">Featured Tools</h2>
        <p className="text-sm text-gray-500 mt-1">Quick access to your most-used resources</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {tools.map((tool, index) => {
          const Icon = tool.icon;
          return (
            <motion.div
              key={tool.title}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 * index, duration: 0.3 }}
              className="group relative bg-white rounded-2xl border border-gray-200 p-6 hover:border-orange-200 hover:shadow-lg hover:-translate-y-1 active:translate-y-0 transition-all duration-300"
            >
              {/* Essential Badge */}
              {tool.badge && (
                <div className="absolute top-4 right-4">
                  <span className="px-2.5 py-1 bg-orange-100 text-orange-700 text-xs font-semibold rounded-full">
                    {tool.badge}
                  </span>
                </div>
              )}

              {/* Icon */}
              <div className={`w-12 h-12 ${tool.iconBg} rounded-xl flex items-center justify-center mb-4`}>
                <Icon className={`h-6 w-6 ${tool.iconColor}`} />
              </div>

              {/* Content */}
              <div className="space-y-3">
                <div>
                  <h3 className="text-lg font-semibold text-[#1C1C1C] group-hover:text-orange-600 transition-colors">
                    {tool.title}
                  </h3>
                  <p className="text-sm text-gray-600 mt-1 leading-relaxed">
                    {tool.description}
                  </p>
                </div>

                {/* Mini Stat */}
                <div className="flex items-center gap-2">
                  <div className="h-1.5 w-1.5 rounded-full bg-orange-500"></div>
                  <p className="text-xs text-gray-500 font-medium">{tool.stat}</p>
                </div>
              </div>

              {/* Launch Button */}
              <button
                onClick={tool.onClick}
                className="mt-4 w-full px-4 py-2.5 bg-[#F97316] text-white text-sm font-semibold rounded-xl shadow-lg shadow-orange-500/20 hover:bg-[#EA580C] hover:shadow-xl hover:shadow-orange-500/30 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200"
              >
                Launch Tool
              </button>
            </motion.div>
          );
        })}
      </div>
    </section>
  );
}
