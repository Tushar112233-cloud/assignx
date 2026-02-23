"use client"

/**
 * @fileoverview Users Page Illustration - Modern minimal SVG
 * Features a community theme with 2-3 people representing user management
 * Matches dashboard illustration style with orange accents
 * @module components/users/v2/users-illustration
 */

interface UsersIllustrationProps {
  className?: string
}

export default function UsersIllustration({ className = "w-full h-full" }: UsersIllustrationProps) {
  return (
    <svg
      viewBox="0 0 400 300"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      aria-label="Users illustration showing a group of people representing team collaboration"
    >
      {/* Background decorative circles */}
      <circle cx="200" cy="150" r="140" fill="#FFF7ED" fillOpacity="0.3" />
      <circle cx="200" cy="150" r="100" fill="#FFEDD5" fillOpacity="0.4" />
      <circle cx="320" cy="80" r="50" fill="#FFF7ED" fillOpacity="0.25" />
      <circle cx="80" cy="200" r="40" fill="#FFEDD5" fillOpacity="0.3" />

      {/* Small decorative dots */}
      <circle cx="45" cy="70" r="5" fill="#FDBA74" fillOpacity="0.5" />
      <circle cx="360" cy="50" r="4" fill="#FED7AA" fillOpacity="0.6" />
      <circle cx="340" cy="250" r="6" fill="#FDBA74" fillOpacity="0.4" />
      <circle cx="55" cy="240" r="4" fill="#FFEDD5" fillOpacity="0.5" />
      <circle cx="370" cy="180" r="5" fill="#FEF3C7" fillOpacity="0.7" />

      {/* Desk surface */}
      <rect x="90" y="220" width="220" height="10" rx="4" fill="#E5E7EB" />
      <rect x="100" y="230" width="10" height="40" rx="2" fill="#D1D5DB" />
      <rect x="290" y="230" width="10" height="40" rx="2" fill="#D1D5DB" />

      {/* Monitor with dashboard */}
      <g id="monitor">
        {/* Monitor stand */}
        <rect x="185" y="200" width="30" height="20" rx="2" fill="#374151" />
        <rect x="175" y="215" width="50" height="5" rx="2" fill="#4B5563" />

        {/* Monitor body */}
        <rect x="130" y="110" width="140" height="95" rx="6" fill="#1C1C1C" />
        <rect x="138" y="118" width="124" height="79" rx="3" fill="#2D2D2D" />

        {/* Screen content - user management interface */}
        {/* Header bar */}
        <rect x="144" y="124" width="112" height="10" rx="2" fill="#374151" />
        <circle cx="150" cy="129" r="2" fill="#EF4444" />
        <circle cx="157" cy="129" r="2" fill="#FBBF24" />
        <circle cx="164" cy="129" r="2" fill="#10B981" />

        {/* User avatar grid */}
        <circle cx="165" cy="155" r="10" fill="#F97316" fillOpacity="0.2" />
        <circle cx="165" cy="155" r="6" fill="#FCD34D" />

        <circle cx="200" cy="155" r="10" fill="#10B981" fillOpacity="0.2" />
        <circle cx="200" cy="155" r="6" fill="#FCD34D" />

        <circle cx="235" cy="155" r="10" fill="#F97316" fillOpacity="0.2" />
        <circle cx="235" cy="155" r="6" fill="#FCD34D" />

        {/* User list rows */}
        <rect x="152" y="172" width="96" height="8" rx="2" fill="#374151" />
        <rect x="156" y="174" width="40" height="4" rx="1" fill="#F97316" fillOpacity="0.5" />
        <rect x="200" y="174" width="30" height="4" rx="1" fill="#10B981" fillOpacity="0.5" />
        <circle cx="241" cy="176" r="3" fill="#10B981" />

        <rect x="152" y="184" width="96" height="8" rx="2" fill="#374151" />
        <rect x="156" y="186" width="35" height="4" rx="1" fill="#E5E7EB" fillOpacity="0.5" />
        <rect x="195" y="186" width="25" height="4" rx="1" fill="#FDBA74" fillOpacity="0.5" />
        <circle cx="241" cy="188" r="3" fill="#F97316" />
      </g>

      {/* Main person - center, at desk */}
      <g id="main-person">
        {/* Body/torso - Orange shirt */}
        <path
          d="M185 220 L185 175 Q185 165 195 165 L205 165 Q215 165 215 175 L215 220"
          fill="#F97316"
        />

        {/* Collar detail */}
        <path d="M192 165 Q200 172 208 165" stroke="#EA580C" strokeWidth="1.5" fill="none" />

        {/* Head */}
        <circle cx="200" cy="145" r="18" fill="#FCD34D" />

        {/* Hair - Modern short style */}
        <ellipse cx="200" cy="133" rx="16" ry="10" fill="#1C1C1C" />
        <path d="M184 140 Q184 128 200 130 Q216 128 216 140" fill="#1C1C1C" />

        {/* Face details */}
        <circle cx="194" cy="143" r="2" fill="#1C1C1C" />
        <circle cx="206" cy="143" r="2" fill="#1C1C1C" />
        <path
          d="M196 152 Q200 155 204 152"
          stroke="#1C1C1C"
          strokeWidth="1.5"
          strokeLinecap="round"
          fill="none"
        />

        {/* Arms - reaching toward keyboard */}
        <path
          d="M185 175 L165 195 L175 200"
          stroke="#FCD34D"
          strokeWidth="8"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />
        <path
          d="M215 175 L235 195 L225 200"
          stroke="#FCD34D"
          strokeWidth="8"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />
      </g>

      {/* Second person - standing left */}
      <g id="person-left">
        {/* Body - gray/charcoal shirt */}
        <path
          d="M75 220 L75 165 Q75 155 85 155 L100 155 Q110 155 110 165 L110 220"
          fill="#374151"
        />

        {/* Head */}
        <circle cx="92" cy="132" r="20" fill="#FCD34D" />

        {/* Hair - Longer style */}
        <path d="M72 130 Q72 110 92 115 Q112 110 112 130 Q118 125 115 140 L69 140 Q66 125 72 130" fill="#1C1C1C" />

        {/* Face details */}
        <circle cx="86" cy="130" r="2.5" fill="#1C1C1C" />
        <circle cx="98" cy="130" r="2.5" fill="#1C1C1C" />
        <path
          d="M88 140 Q92 144 96 140"
          stroke="#1C1C1C"
          strokeWidth="1.5"
          strokeLinecap="round"
          fill="none"
        />

        {/* Earring accent */}
        <circle cx="72" cy="135" r="2" fill="#F97316" />

        {/* Arm pointing toward screen */}
        <path
          d="M110 165 L135 145 L140 150"
          stroke="#FCD34D"
          strokeWidth="8"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />

        {/* Hand */}
        <ellipse cx="140" cy="148" rx="6" ry="5" fill="#FCD34D" />

        {/* Other arm at side */}
        <path
          d="M75 165 L60 185"
          stroke="#FCD34D"
          strokeWidth="8"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />
      </g>

      {/* Third person - standing right */}
      <g id="person-right">
        {/* Body - orange-ish shirt */}
        <path
          d="M290 220 L290 170 Q290 160 300 160 L315 160 Q325 160 325 170 L325 220"
          fill="#FDBA74"
        />

        {/* Head */}
        <circle cx="307" cy="138" r="19" fill="#FCD34D" />

        {/* Hair - Modern styled */}
        <ellipse cx="307" cy="126" rx="17" ry="11" fill="#1C1C1C" />

        {/* Face details */}
        <circle cx="301" cy="136" r="2" fill="#1C1C1C" />
        <circle cx="313" cy="136" r="2" fill="#1C1C1C" />
        <path
          d="M303 145 Q307 148 311 145"
          stroke="#1C1C1C"
          strokeWidth="1.5"
          strokeLinecap="round"
          fill="none"
        />

        {/* Arm with clipboard */}
        <path
          d="M290 170 L270 180 L275 195"
          stroke="#FCD34D"
          strokeWidth="8"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />

        {/* Clipboard in hand */}
        <rect x="260" y="175" width="22" height="30" rx="2" fill="white" stroke="#E5E7EB" strokeWidth="1.5" />
        <rect x="264" y="180" width="14" height="2" rx="1" fill="#F97316" />
        <rect x="264" y="185" width="14" height="1.5" rx="0.5" fill="#E5E7EB" />
        <rect x="264" y="189" width="10" height="1.5" rx="0.5" fill="#E5E7EB" />
        <rect x="264" y="193" width="12" height="1.5" rx="0.5" fill="#E5E7EB" />
        <circle x="274" cy="199" r="2" fill="#10B981" />
        <path d="M272 199 L274 201 L278 197" stroke="#10B981" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round" />

        {/* Other arm at side */}
        <path
          d="M325 170 L340 185"
          stroke="#FCD34D"
          strokeWidth="8"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />
      </g>

      {/* Floating notification card - top right */}
      <g id="notification-card">
        <rect x="320" y="55" width="55" height="40" rx="5" fill="white" stroke="#F97316" strokeWidth="2" />
        {/* User icon */}
        <circle cx="335" cy="70" r="6" fill="#FCD34D" />
        <circle cx="335" cy="66" r="4" fill="#FCD34D" />
        {/* Text lines */}
        <rect x="345" y="65" width="24" height="3" rx="1" fill="#E5E7EB" />
        <rect x="345" y="72" width="18" height="2" rx="1" fill="#D1D5DB" />
        <rect x="345" y="78" width="22" height="2" rx="1" fill="#D1D5DB" />
        {/* Notification badge */}
        <circle cx="371" cy="58" r="8" fill="#F97316" />
        <text x="371" y="61" fontSize="9" fill="white" textAnchor="middle" fontWeight="bold">+3</text>
      </g>

      {/* Floating user avatar card - top left */}
      <g id="avatar-card">
        <rect x="40" y="45" width="45" height="50" rx="5" fill="white" stroke="#FDBA74" strokeWidth="2" />
        <circle cx="62" cy="63" r="12" fill="#FFF7ED" />
        <circle cx="62" cy="60" r="6" fill="#FCD34D" />
        <ellipse cx="62" cy="72" rx="8" ry="5" fill="#F97316" fillOpacity="0.3" />
        {/* Status indicator */}
        <circle cx="70" cy="70" r="4" fill="#10B981" />
        {/* Name line */}
        <rect x="48" y="82" width="28" height="3" rx="1" fill="#E5E7EB" />
        <rect x="52" y="88" width="20" height="2" rx="1" fill="#D1D5DB" />
      </g>

      {/* Team stats card - floating left */}
      <g id="stats-card">
        <rect x="30" y="130" width="50" height="35" rx="4" fill="white" stroke="#10B981" strokeWidth="1.5" />
        <text x="55" y="148" fontSize="14" fill="#1C1C1C" textAnchor="middle" fontWeight="bold">12</text>
        <text x="55" y="158" fontSize="7" fill="#6B7280" textAnchor="middle">Active</text>
      </g>

      {/* Connection lines - representing team connections */}
      <g id="connections" opacity="0.4">
        <line x1="92" y1="155" x2="140" y2="155" stroke="#FDBA74" strokeWidth="1.5" strokeDasharray="4 2" />
        <line x1="260" y1="155" x2="307" y2="158" stroke="#FDBA74" strokeWidth="1.5" strokeDasharray="4 2" />
      </g>

      {/* Small decorative elements */}
      {/* Orange accent dots */}
      <circle cx="125" cy="100" r="4" fill="#FDBA74" fillOpacity="0.6" />
      <circle cx="280" cy="95" r="5" fill="#FED7AA" fillOpacity="0.5" />

      {/* Success checkmark badge */}
      <g id="checkmark-badge">
        <circle cx="355" cy="140" r="12" fill="#10B981" fillOpacity="0.15" />
        <path d="M349 140 L353 144 L361 136" stroke="#10B981" strokeWidth="2.5" fill="none" strokeLinecap="round" strokeLinejoin="round" />
      </g>

      {/* Keyboard on desk */}
      <g id="keyboard">
        <rect x="165" y="205" width="70" height="12" rx="2" fill="#374151" />
        <rect x="170" y="208" width="60" height="6" rx="1" fill="#4B5563" />
        {/* Key rows */}
        <rect x="172" y="209" width="4" height="3" rx="0.5" fill="#6B7280" />
        <rect x="178" y="209" width="4" height="3" rx="0.5" fill="#6B7280" />
        <rect x="184" y="209" width="4" height="3" rx="0.5" fill="#6B7280" />
        <rect x="190" y="209" width="4" height="3" rx="0.5" fill="#6B7280" />
        <rect x="196" y="209" width="4" height="3" rx="0.5" fill="#6B7280" />
        <rect x="202" y="209" width="20" height="3" rx="0.5" fill="#6B7280" />
        <rect x="224" y="209" width="4" height="3" rx="0.5" fill="#6B7280" />
      </g>

      {/* Coffee mug on desk */}
      <g id="coffee">
        <ellipse cx="330" cy="212" rx="8" ry="3" fill="#EA580C" />
        <rect x="322" y="200" width="16" height="14" rx="2" fill="#F97316" />
        <path d="M338 203 Q344 206 338 211" stroke="#EA580C" strokeWidth="2" fill="none" />
        {/* Steam */}
        <path d="M327 195 Q329 190 327 186" stroke="#D1D5DB" strokeWidth="1.5" strokeLinecap="round" fill="none" opacity="0.5" />
        <path d="M333 195 Q335 190 333 186" stroke="#D1D5DB" strokeWidth="1.5" strokeLinecap="round" fill="none" opacity="0.5" />
      </g>

      {/* Small geometric accents */}
      <rect x="360" cy="220" width="8" height="8" rx="1" fill="#FFEDD5" fillOpacity="0.6" transform="rotate(45 364 224)" />
      <rect x="25" cy="180" width="6" height="6" rx="1" fill="#FED7AA" fillOpacity="0.5" transform="rotate(45 28 183)" />
    </svg>
  )
}

export { UsersIllustration }
