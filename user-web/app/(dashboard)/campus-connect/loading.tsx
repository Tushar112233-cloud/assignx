"use client";

import { Loader2 } from "lucide-react";

/**
 * Loading state for Campus Connect pages
 */
export default function CampusConnectLoading() {
  return (
    <div className="min-h-[calc(100vh-3.5rem)] bg-background">
      {/* Curved Hero Banner */}
      <div className="connect-curved-hero">
        <div className="relative h-52 md:h-64" />
      </div>

      {/* Illustration placeholder */}
      <div className="relative z-10 -mt-16 md:-mt-20 flex justify-center px-6">
        <div className="w-28 h-28 md:w-36 md:h-36 bg-card rounded-3xl shadow-xl animate-pulse" />
      </div>

      {/* Title placeholder */}
      <div className="text-center pt-6 pb-4 px-6">
        <div className="h-12 w-64 bg-muted rounded-lg mx-auto animate-pulse" />
      </div>

      {/* Search bar placeholder */}
      <div className="px-6 md:px-8 pb-4">
        <div className="max-w-3xl mx-auto h-14 bg-muted rounded-2xl animate-pulse" />
      </div>

      {/* Category tabs placeholder */}
      <div className="px-6 md:px-8 py-4">
        <div className="flex justify-center gap-2">
          {[1, 2, 3, 4, 5, 6, 7].map((i) => (
            <div key={i} className="h-10 w-20 bg-muted rounded-full animate-pulse" />
          ))}
        </div>
      </div>

      {/* Loading spinner */}
      <div className="flex items-center justify-center py-12">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    </div>
  );
}
