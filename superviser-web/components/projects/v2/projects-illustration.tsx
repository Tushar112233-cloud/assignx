/**
 * @fileoverview Projects Page Illustration - Pipeline queue motif
 * @module components/projects/v2/projects-illustration
 */

export function ProjectsIllustration() {
  return (
    <svg viewBox="0 0 400 300" fill="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-full">
      {/* Soft backdrop */}
      <circle cx="95" cy="90" r="60" fill="#FFF7ED" opacity="0.7" />
      <circle cx="320" cy="60" r="48" fill="#FFEDD5" opacity="0.7" />
      <circle cx="320" cy="240" r="55" fill="#FEF3C7" opacity="0.6" />

      {/* Pipeline tower */}
      <rect x="150" y="40" width="100" height="160" rx="16" fill="#1C1C1C" />
      <rect x="158" y="48" width="84" height="144" rx="12" fill="#2D2D2D" />

      {/* Pipeline stages */}
      <rect x="170" y="62" width="60" height="28" rx="10" fill="#F97316" opacity="0.2" />
      <rect x="170" y="98" width="60" height="28" rx="10" fill="#3B82F6" opacity="0.2" />
      <rect x="170" y="134" width="60" height="28" rx="10" fill="#10B981" opacity="0.2" />

      {/* Stage labels */}
      <rect x="176" y="70" width="38" height="4" rx="2" fill="#F97316" />
      <rect x="176" y="106" width="42" height="4" rx="2" fill="#3B82F6" />
      <rect x="176" y="142" width="36" height="4" rx="2" fill="#10B981" />

      {/* Cards flowing into tray */}
      <rect x="70" y="120" width="58" height="36" rx="10" fill="white" stroke="#E5E7EB" strokeWidth="2" />
      <rect x="78" y="130" width="32" height="4" rx="2" fill="#F97316" opacity="0.7" />
      <rect x="78" y="138" width="38" height="3" rx="1.5" fill="#E5E7EB" />

      <rect x="265" y="118" width="58" height="38" rx="10" fill="white" stroke="#E5E7EB" strokeWidth="2" />
      <rect x="272" y="129" width="30" height="4" rx="2" fill="#10B981" opacity="0.7" />
      <rect x="272" y="137" width="36" height="3" rx="1.5" fill="#E5E7EB" />

      {/* Output tray */}
      <rect x="110" y="210" width="180" height="28" rx="12" fill="#FFFFFF" stroke="#E5E7EB" strokeWidth="2" />
      <rect x="122" y="217" width="70" height="14" rx="7" fill="#F97316" opacity="0.15" />
      <rect x="200" y="217" width="70" height="14" rx="7" fill="#10B981" opacity="0.15" />

      {/* Floating status badges */}
      <rect x="36" y="60" width="44" height="26" rx="8" fill="white" stroke="#FDBA74" strokeWidth="2" />
      <circle cx="48" cy="73" r="4" fill="#F97316" />
      <rect x="56" y="70" width="18" height="4" rx="2" fill="#E5E7EB" />

      <rect x="320" y="140" width="46" height="26" rx="8" fill="white" stroke="#10B981" strokeWidth="2" />
      <path d="M336 152 L340 156 L348 146" stroke="#10B981" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" />

      {/* Accent dots */}
      <circle cx="92" cy="200" r="6" fill="#FDBA74" opacity="0.6" />
      <circle cx="320" cy="200" r="5" fill="#A7F3D0" opacity="0.6" />
      <circle cx="210" cy="260" r="7" fill="#FED7AA" opacity="0.7" />
    </svg>
  )
}
