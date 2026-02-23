"use client";

/**
 * ActivityGlobe - 3D Interactive Globe showing campus network
 * Uses Magic UI Globe component configured for India-centric view
 * Shows major college cities with glowing connection arcs
 */

import { useReducedMotion } from "framer-motion";
import { Globe } from "@/components/ui/globe";
import { cn } from "@/lib/utils";
import type { COBEOptions } from "cobe";

interface ActivityGlobeProps {
  className?: string;
}

// Major Indian college city markers
const indiaCollegeMarkers = [
  { location: [28.6139, 77.209] as [number, number], size: 0.12 }, // Delhi (IIT Delhi, DTU, NSUT)
  { location: [19.076, 72.8777] as [number, number], size: 0.12 }, // Mumbai (IIT Bombay, VJTI)
  { location: [12.9716, 77.5946] as [number, number], size: 0.11 }, // Bangalore (IISc, RVCE)
  { location: [13.0827, 80.2707] as [number, number], size: 0.1 }, // Chennai (IIT Madras)
  { location: [17.385, 78.4867] as [number, number], size: 0.1 }, // Hyderabad (IIIT-H)
  { location: [22.5726, 88.3639] as [number, number], size: 0.09 }, // Kolkata (IIT KGP)
  { location: [18.5204, 73.8567] as [number, number], size: 0.09 }, // Pune (COEP)
  { location: [23.0225, 72.5714] as [number, number], size: 0.07 }, // Ahmedabad (IIT-GN)
  { location: [28.367, 75.604] as [number, number], size: 0.08 }, // Pilani (BITS)
  { location: [12.9165, 79.1325] as [number, number], size: 0.08 }, // Vellore (VIT)
  { location: [10.7905, 78.7047] as [number, number], size: 0.06 }, // Trichy (NIT)
  { location: [26.8467, 80.9462] as [number, number], size: 0.08 }, // Kanpur (IIT-K)
  { location: [29.8644, 77.8964] as [number, number], size: 0.07 }, // Roorkee (IIT-R)
  { location: [25.4358, 81.8463] as [number, number], size: 0.06 }, // Allahabad (IIIT-A)
  { location: [21.1702, 72.8311] as [number, number], size: 0.06 }, // Surat (SVNIT)
];

// Globe configuration for India-centric view
// Colors tuned to match hero background (slate-900 via-violet-950 to-indigo-950)
const globeConfig: COBEOptions = {
  width: 800,
  height: 800,
  onRender: () => {},
  devicePixelRatio: 2,
  // Initial view centered on India
  phi: 0,
  theta: 0.25,
  dark: 1,
  diffuse: 1.4,
  mapSamples: 16000,
  mapBrightness: 4,
  // Colors matching violet-950 (#1e1b4b) and indigo-950 (#1e1b4b)
  baseColor: [0.12, 0.11, 0.29], // Matches violet-950
  markerColor: [0.55, 0.36, 0.98], // Violet-500 for markers
  glowColor: [0.2, 0.15, 0.4], // Subtle violet glow
  markers: indiaCollegeMarkers,
};

export function ActivityGlobe({ className }: ActivityGlobeProps) {
  const prefersReducedMotion = useReducedMotion();

  // For reduced motion, show a static simplified representation
  if (prefersReducedMotion) {
    return (
      <div
        className={cn(
          "relative w-full h-full flex items-center justify-center",
          className
        )}
      >
        <div className="relative">
          {/* Static globe representation */}
          <div className="h-64 w-64 rounded-full bg-gradient-to-br from-violet-600/30 to-fuchsia-600/30 border border-violet-500/20" />
          {/* Center glow */}
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="h-32 w-32 rounded-full bg-gradient-to-br from-violet-500/40 to-fuchsia-500/40 blur-xl" />
          </div>
          {/* Static markers representation */}
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="text-sm text-white/60">15 Colleges Active</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div
      className={cn(
        "relative w-full h-full",
        className
      )}
    >
      {/* Glow effect behind globe */}
      <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
        <div className="h-72 w-72 rounded-full bg-gradient-to-br from-violet-500/15 to-fuchsia-500/15 blur-3xl" />
      </div>

      {/* The 3D Globe */}
      <Globe config={globeConfig} className="opacity-80" />

      {/* Connection indicator */}
      <div className="absolute bottom-4 left-1/2 -translate-x-1/2 z-20">
        <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/[0.06] backdrop-blur-sm border border-white/[0.08]">
          <span className="relative flex h-1.5 w-1.5">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
            <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-emerald-500" />
          </span>
          <span className="text-[10px] text-white/60">
            15 cities connected
          </span>
        </div>
      </div>
    </div>
  );
}

export default ActivityGlobe;
