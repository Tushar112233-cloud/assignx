/**
 * @fileoverview Compact floating quick access panel for resources
 * @module components/resources/quick-access-sidebar
 */

"use client"

import { ReactNode } from "react"
import {
  Sparkles,
  FileCheck,
  BookOpen,
  Star,
  Bookmark
} from "lucide-react"

interface QuickAccessItem {
  id: string
  name: string
  icon: ReactNode
  onClick: () => void
}

interface QuickAccessSidebarProps {
  mostUsed?: QuickAccessItem[]
  bookmarks?: QuickAccessItem[]
}

const defaultMostUsed: QuickAccessItem[] = [
  {
    id: "plagiarism",
    name: "Plagiarism Checker",
    icon: <FileCheck className="h-4 w-4 text-orange-600" />,
    onClick: () => console.log("Navigate to Plagiarism Checker")
  },
  {
    id: "ai-detector",
    name: "AI Detector",
    icon: <Sparkles className="h-4 w-4 text-orange-600" />,
    onClick: () => console.log("Navigate to AI Detector")
  },
  {
    id: "training",
    name: "Training Library",
    icon: <BookOpen className="h-4 w-4 text-orange-600" />,
    onClick: () => console.log("Navigate to Training")
  }
]

const defaultBookmarks: QuickAccessItem[] = [
  {
    id: "pricing",
    name: "Pricing Guide",
    icon: <Star className="h-4 w-4 text-orange-600" />,
    onClick: () => console.log("Navigate to Pricing")
  },
  {
    id: "grammar",
    name: "Grammar Checker",
    icon: <Bookmark className="h-4 w-4 text-orange-600" />,
    onClick: () => console.log("Navigate to Grammar")
  }
]

export function QuickAccessSidebar({
  mostUsed = defaultMostUsed,
  bookmarks = defaultBookmarks
}: QuickAccessSidebarProps) {
  return (
    <div className="sticky top-24">
      <div className="bg-white rounded-2xl border border-gray-200 shadow-md p-4">
        {/* Most Used Section */}
        <div className="mb-4">
          <h3 className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">
            Most Used
          </h3>
          <div className="flex flex-col gap-2">
            {mostUsed.map((item) => (
              <button
                key={item.id}
                onClick={item.onClick}
                className="flex items-center gap-2 p-2 rounded-lg hover:bg-gray-50 transition-colors group"
              >
                <div className="flex-shrink-0">
                  {item.icon}
                </div>
                <span className="text-sm text-gray-700 group-hover:text-orange-600 transition-colors truncate">
                  {item.name}
                </span>
              </button>
            ))}
          </div>
        </div>

        {/* Divider */}
        <div className="h-px bg-gray-200 my-4" />

        {/* Bookmarks Section */}
        <div>
          <h3 className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">
            Bookmarks
          </h3>
          <div className="flex flex-col gap-2">
            {bookmarks.map((item) => (
              <button
                key={item.id}
                onClick={item.onClick}
                className="flex items-center gap-2 p-2 rounded-lg hover:bg-gray-50 transition-colors group"
              >
                <div className="flex-shrink-0">
                  {item.icon}
                </div>
                <span className="text-sm text-gray-700 group-hover:text-orange-600 transition-colors truncate">
                  {item.name}
                </span>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
