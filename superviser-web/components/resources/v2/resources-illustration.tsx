"use client"

/**
 * @fileoverview Resources Illustration for v2 resources page
 * Modern flat design featuring a person at desk with quality tools
 * Matches dashboard illustration style with orange accents
 * @module components/resources/v2/resources-illustration
 */

interface ResourcesIllustrationProps {
  className?: string
}

export function ResourcesIllustration({ className }: ResourcesIllustrationProps) {
  return (
    <svg
      viewBox="0 0 400 300"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      aria-label="Resources illustration showing a person working at a desk with quality checking tools"
    >
      {/* Background decorative circles */}
      <circle cx="200" cy="150" r="120" fill="#FFF7ED" fillOpacity="0.4" />
      <circle cx="280" cy="100" r="60" fill="#FFEDD5" fillOpacity="0.3" />
      <circle cx="100" cy="200" r="45" fill="#FFF7ED" fillOpacity="0.25" />

      {/* Small decorative dots */}
      <circle cx="50" cy="80" r="4" fill="#FDBA74" fillOpacity="0.5" />
      <circle cx="350" cy="60" r="5" fill="#FED7AA" fillOpacity="0.6" />
      <circle cx="320" cy="240" r="3" fill="#FDBA74" fillOpacity="0.4" />
      <circle cx="70" cy="250" r="6" fill="#FFEDD5" fillOpacity="0.5" />

      {/* Desk surface */}
      <rect x="80" y="220" width="240" height="10" rx="4" fill="#E5E7EB" />
      <rect x="90" y="230" width="10" height="35" rx="2" fill="#D1D5DB" />
      <rect x="300" y="230" width="10" height="35" rx="2" fill="#D1D5DB" />

      {/* Computer monitor */}
      <g id="monitor">
        {/* Monitor stand */}
        <rect x="185" y="200" width="30" height="20" rx="2" fill="#374151" />
        <rect x="175" y="215" width="50" height="5" rx="2" fill="#4B5563" />

        {/* Monitor body */}
        <rect x="140" y="120" width="120" height="85" rx="6" fill="#1C1C1C" />
        <rect x="148" y="128" width="104" height="69" rx="3" fill="#2D2D2D" />

        {/* Screen content - quality check interface */}
        {/* Header bar */}
        <rect x="154" y="134" width="92" height="10" rx="2" fill="#374151" />
        <circle cx="160" cy="139" r="2" fill="#EF4444" />
        <circle cx="167" cy="139" r="2" fill="#FBBF24" />
        <circle cx="174" cy="139" r="2" fill="#10B981" />

        {/* Checkmark icon in center */}
        <circle cx="200" cy="170" r="18" fill="#10B981" fillOpacity="0.15" />
        <path
          d="M191 170 L197 176 L210 163"
          stroke="#10B981"
          strokeWidth="3"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />

        {/* Progress bar */}
        <rect x="160" y="188" width="80" height="4" rx="2" fill="#374151" />
        <rect x="160" y="188" width="60" height="4" rx="2" fill="#10B981" />
      </g>

      {/* Person figure - simplified flat style */}
      <g id="person">
        {/* Body/torso */}
        <path
          d="M85 220 L85 175 Q85 165 95 165 L115 165 Q125 165 125 175 L125 220"
          fill="#F97316"
        />

        {/* Head */}
        <circle cx="105" cy="145" r="18" fill="#FCD34D" />

        {/* Hair */}
        <ellipse cx="105" cy="133" rx="16" ry="10" fill="#1C1C1C" />

        {/* Face details */}
        <circle cx="100" cy="143" r="2" fill="#1C1C1C" />
        <circle cx="110" cy="143" r="2" fill="#1C1C1C" />
        <path
          d="M102 150 Q105 153 108 150"
          stroke="#1C1C1C"
          strokeWidth="1.5"
          strokeLinecap="round"
          fill="none"
        />

        {/* Arms */}
        <path
          d="M85 175 L70 185 L75 195"
          stroke="#FCD34D"
          strokeWidth="8"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />
        <path
          d="M125 175 L140 180 L145 195"
          stroke="#FCD34D"
          strokeWidth="8"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />
      </g>

      {/* Floating magnifying glass - search tool */}
      <g id="magnifying-glass">
        <circle cx="310" cy="85" r="18" fill="white" stroke="#F97316" strokeWidth="3" />
        <circle cx="310" cy="85" r="12" fill="#FFF7ED" />
        <line
          x1="322"
          y1="97"
          x2="335"
          y2="110"
          stroke="#F97316"
          strokeWidth="4"
          strokeLinecap="round"
        />
        {/* Search lines inside */}
        <line x1="304" y1="82" x2="316" y2="82" stroke="#FDBA74" strokeWidth="2" strokeLinecap="round" />
        <line x1="304" y1="88" x2="312" y2="88" stroke="#FDBA74" strokeWidth="1.5" strokeLinecap="round" />
      </g>

      {/* Floating document icon */}
      <g id="document">
        <rect x="55" y="50" width="35" height="45" rx="4" fill="white" stroke="#E5E7EB" strokeWidth="2" />
        {/* Document lines */}
        <line x1="62" y1="62" x2="83" y2="62" stroke="#F97316" strokeWidth="2" strokeLinecap="round" />
        <line x1="62" y1="70" x2="78" y2="70" stroke="#D1D5DB" strokeWidth="2" strokeLinecap="round" />
        <line x1="62" y1="78" x2="83" y2="78" stroke="#D1D5DB" strokeWidth="2" strokeLinecap="round" />
        <line x1="62" y1="86" x2="75" y2="86" stroke="#D1D5DB" strokeWidth="2" strokeLinecap="round" />
        {/* Folded corner */}
        <path d="M80 50 L90 50 L90 60 L80 60 L90 50" fill="#E5E7EB" />
      </g>

      {/* Shield icon - quality/protection */}
      <g id="shield">
        <path
          d="M340 160 L340 180 Q340 195 355 200 Q370 195 370 180 L370 160 L355 152 L340 160 Z"
          fill="#10B981"
          fillOpacity="0.15"
          stroke="#10B981"
          strokeWidth="2.5"
        />
        {/* Shield checkmark */}
        <path
          d="M349 175 L354 180 L363 170"
          stroke="#10B981"
          strokeWidth="2.5"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />
      </g>

      {/* Small plant - growth/success metaphor */}
      <g id="plant">
        {/* Pot */}
        <rect x="275" y="200" width="24" height="20" rx="3" fill="#E5E7EB" />
        <rect x="272" y="197" width="30" height="6" rx="2" fill="#D1D5DB" />

        {/* Plant leaves */}
        <ellipse cx="287" cy="185" rx="8" ry="12" fill="#10B981" />
        <ellipse cx="278" cy="188" rx="6" ry="10" fill="#34D399" transform="rotate(-20 278 188)" />
        <ellipse cx="296" cy="188" rx="6" ry="10" fill="#34D399" transform="rotate(20 296 188)" />
        <ellipse cx="287" cy="178" rx="5" ry="8" fill="#6EE7B7" />
      </g>

      {/* Floating notification badge */}
      <g id="notification">
        <rect x="165" y="60" width="55" height="28" rx="5" fill="white" stroke="#F97316" strokeWidth="2" />
        <circle cx="178" cy="72" r="4" fill="#10B981" />
        <line x1="188" y1="69" x2="210" y2="69" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="188" y1="77" x2="203" y2="77" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />
        {/* New badge */}
        <circle cx="215" cy="63" r="7" fill="#F97316" />
        <text x="215" y="66" fontSize="8" fill="white" textAnchor="middle" fontWeight="bold">
          3
        </text>
      </g>

      {/* Subtle geometric accents */}
      <rect x="330" y="200" width="8" height="8" rx="1" fill="#FFEDD5" fillOpacity="0.6" transform="rotate(45 334 204)" />
      <rect x="45" y="140" width="6" height="6" rx="1" fill="#FED7AA" fillOpacity="0.5" transform="rotate(45 48 143)" />

      {/* Coffee cup on desk */}
      <g id="coffee">
        <ellipse cx="260" cy="210" rx="8" ry="3" fill="#EA580C" />
        <rect x="252" y="200" width="16" height="12" rx="2" fill="#F97316" />
        <path d="M268 203 Q274 206 268 210" stroke="#EA580C" strokeWidth="2" fill="none" />
        {/* Steam */}
        <path
          d="M257 195 Q259 190 257 186"
          stroke="#D1D5DB"
          strokeWidth="1.5"
          strokeLinecap="round"
          fill="none"
          opacity="0.5"
        />
        <path
          d="M263 195 Q265 190 263 186"
          stroke="#D1D5DB"
          strokeWidth="1.5"
          strokeLinecap="round"
          fill="none"
          opacity="0.5"
        />
      </g>
    </svg>
  )
}

export default ResourcesIllustration
