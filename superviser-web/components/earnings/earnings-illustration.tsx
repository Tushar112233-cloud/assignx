export function EarningsIllustration({ className = "" }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 400 300"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      aria-hidden="true"
    >
      {/* Background circles - matching dashboard style */}
      <circle cx="200" cy="150" r="140" fill="#FFF7ED" opacity="0.3" />
      <circle cx="200" cy="150" r="100" fill="#FFEDD5" opacity="0.4" />

      {/* Desk */}
      <rect x="80" y="210" width="240" height="10" rx="3" fill="#E5E7EB" />
      <rect x="95" y="220" width="10" height="55" rx="2" fill="#D1D5DB" />
      <rect x="295" y="220" width="10" height="55" rx="2" fill="#D1D5DB" />

      {/* Large Monitor - Modern flat design */}
      <rect x="120" y="110" width="160" height="100" rx="6" fill="#1C1C1C" />
      <rect x="127" y="117" width="146" height="80" rx="3" fill="#2D2D2D" />
      <rect x="190" y="205" width="20" height="12" fill="#374151" />
      <rect x="170" y="210" width="60" height="4" rx="2" fill="#6B7280" />

      {/* Screen content - Rising Chart with gradient */}
      <defs>
        <linearGradient id="chartFill" x1="135" y1="125" x2="135" y2="190">
          <stop offset="0%" stopColor="#F97316" stopOpacity="0.4" />
          <stop offset="100%" stopColor="#F97316" stopOpacity="0" />
        </linearGradient>
      </defs>

      {/* Chart area fill */}
      <path
        d="M135 185 L155 175 L175 180 L195 160 L215 165 L235 145 L255 140 L265 135 L265 190 L135 190 Z"
        fill="url(#chartFill)"
      />

      {/* Chart line */}
      <path
        d="M135 185 L155 175 L175 180 L195 160 L215 165 L235 145 L255 140 L265 135"
        stroke="#F97316"
        strokeWidth="3"
        fill="none"
        strokeLinecap="round"
        strokeLinejoin="round"
      />

      {/* Chart dots */}
      <circle cx="155" cy="175" r="3" fill="#F97316" />
      <circle cx="195" cy="160" r="3" fill="#F97316" />
      <circle cx="235" cy="145" r="4" fill="#F97316" />
      <circle cx="265" cy="135" r="4" fill="#FFFFFF" stroke="#F97316" strokeWidth="2" />

      {/* Rupee indicator on screen */}
      <rect x="135" y="125" width="35" height="22" rx="3" fill="#F97316" opacity="0.2" />
      <text x="152" y="141" fontSize="14" fontWeight="bold" fill="#F97316" textAnchor="middle">
        ₹
      </text>

      {/* Growth percentage badge */}
      <rect x="230" y="125" width="32" height="16" rx="3" fill="#10B981" opacity="0.2" />
      <text x="246" y="137" fontSize="8" fontWeight="bold" fill="#10B981" textAnchor="middle">
        +24%
      </text>

      {/* Person - Modern minimalist style */}
      {/* Head */}
      <circle cx="200" cy="60" r="22" fill="#FCD34D" />

      {/* Hair - Modern style */}
      <path
        d="M178 55 Q180 38 200 42 Q220 38 222 55 Q225 50 222 65 L178 65 Q175 50 178 55"
        fill="#1C1C1C"
      />

      {/* Face features */}
      <circle cx="193" cy="58" r="2" fill="#1C1C1C" />
      <circle cx="207" cy="58" r="2" fill="#1C1C1C" />
      <path
        d="M195 68 Q200 72 205 68"
        stroke="#1C1C1C"
        strokeWidth="2"
        fill="none"
        strokeLinecap="round"
      />

      {/* Glasses */}
      <rect x="188" y="56" width="10" height="8" rx="2" fill="none" stroke="#1C1C1C" strokeWidth="1.5" />
      <rect x="202" y="56" width="10" height="8" rx="2" fill="none" stroke="#1C1C1C" strokeWidth="1.5" />
      <line x1="198" y1="60" x2="202" y2="60" stroke="#1C1C1C" strokeWidth="1.5" />

      {/* Body - Orange shirt */}
      <path d="M178 82 L170 190 L185 190 L200 115 L215 190 L230 190 L222 82 Z" fill="#F97316" />

      {/* Arms */}
      <path d="M175 90 L140 130 L148 138 L178 105" fill="#FCD34D" />
      <path d="M225 90 L260 130 L252 138 L222 105" fill="#FCD34D" />

      {/* Laptop on desk */}
      <rect x="150" y="195" width="100" height="10" rx="2" fill="#374151" />
      <rect x="155" y="197" width="90" height="6" rx="1" fill="#4B5563" />

      {/* Laptop screen glow */}
      <rect x="160" y="175" width="80" height="18" rx="1" fill="#F97316" opacity="0.1" />

      {/* Floating Rupee Coins - Left side */}
      <g>
        {/* Large coin */}
        <circle cx="55" cy="100" r="22" fill="#F97316" />
        <circle cx="55" cy="100" r="16" fill="none" stroke="#FFFFFF" strokeWidth="2" opacity="0.3" />
        <text x="55" y="108" fontSize="20" fontWeight="bold" fill="#FFFFFF" textAnchor="middle">
          ₹
        </text>
        {/* Coin shadow */}
        <ellipse cx="55" cy="125" rx="18" ry="4" fill="#1C1C1C" opacity="0.1" />
      </g>

      {/* Medium coin */}
      <g>
        <circle cx="75" cy="165" r="16" fill="#FB923C" />
        <circle cx="75" cy="165" r="11" fill="none" stroke="#FFFFFF" strokeWidth="1.5" opacity="0.3" />
        <text x="75" y="171" fontSize="14" fontWeight="bold" fill="#FFFFFF" textAnchor="middle">
          ₹
        </text>
        <ellipse cx="75" cy="183" rx="12" ry="3" fill="#1C1C1C" opacity="0.08" />
      </g>

      {/* Floating Rupee Coins - Right side */}
      <g>
        {/* Large coin */}
        <circle cx="340" cy="85" r="20" fill="#F97316" />
        <circle cx="340" cy="85" r="14" fill="none" stroke="#FFFFFF" strokeWidth="2" opacity="0.3" />
        <text x="340" y="92" fontSize="18" fontWeight="bold" fill="#FFFFFF" textAnchor="middle">
          ₹
        </text>
        <ellipse cx="340" cy="108" rx="16" ry="4" fill="#1C1C1C" opacity="0.1" />
      </g>

      {/* Medium coin right */}
      <g>
        <circle cx="325" cy="160" r="14" fill="#FDBA74" />
        <circle cx="325" cy="160" r="10" fill="none" stroke="#FFFFFF" strokeWidth="1.5" opacity="0.4" />
        <text x="325" y="166" fontSize="12" fontWeight="bold" fill="#EA580C" textAnchor="middle">
          ₹
        </text>
      </g>

      {/* Small floating coin top */}
      <g>
        <circle cx="290" cy="45" r="12" fill="#FFEDD5" stroke="#F97316" strokeWidth="2" />
        <text x="290" y="51" fontSize="11" fontWeight="bold" fill="#F97316" textAnchor="middle">
          ₹
        </text>
      </g>

      {/* Stack of coins bottom right */}
      <g>
        <ellipse cx="350" cy="230" rx="18" ry="6" fill="#EA580C" />
        <rect x="332" y="220" width="36" height="10" fill="#F97316" />
        <ellipse cx="350" cy="220" rx="18" ry="6" fill="#FB923C" />
        <rect x="332" y="212" width="36" height="8" fill="#F97316" />
        <ellipse cx="350" cy="212" rx="18" ry="6" fill="#FDBA74" />
        <text x="350" y="217" fontSize="10" fontWeight="bold" fill="#EA580C" textAnchor="middle">
          ₹₹₹
        </text>
      </g>

      {/* Growth arrow floating */}
      <g>
        <path
          d="M45 200 L45 160 L38 170 M45 160 L52 170"
          stroke="#10B981"
          strokeWidth="3"
          fill="none"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <circle cx="45" cy="155" r="8" fill="#10B981" opacity="0.2" />
      </g>

      {/* Floating UI element - Earnings badge */}
      <rect x="310" y="190" width="50" height="35" rx="4" fill="white" stroke="#F97316" strokeWidth="2" opacity="0.9" />
      <rect x="317" y="197" width="20" height="8" rx="2" fill="#F97316" opacity="0.2" />
      <line x1="317" y1="211" x2="353" y2="211" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />
      <line x1="317" y1="217" x2="340" y2="217" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />

      {/* Notification badge with amount */}
      <circle cx="358" cy="192" r="8" fill="#F97316" />
      <text x="358" y="195" fontSize="7" fill="white" textAnchor="middle" fontWeight="bold">
        +5K
      </text>

      {/* Calculator/document on desk */}
      <rect x="285" y="195" width="22" height="18" rx="2" fill="#E5E7EB" />
      <rect x="288" y="198" width="16" height="6" rx="1" fill="#D1D5DB" />
      <circle cx="291" cy="209" r="2" fill="#9CA3AF" />
      <circle cx="296" cy="209" r="2" fill="#9CA3AF" />
      <circle cx="301" cy="209" r="2" fill="#9CA3AF" />

      {/* Plant - Modern minimal */}
      <rect x="65" y="185" width="18" height="28" rx="2" fill="#E5E7EB" />
      <circle cx="74" cy="175" r="16" fill="#10B981" />
      <circle cx="62" cy="168" r="11" fill="#34D399" />
      <circle cx="85" cy="170" r="9" fill="#34D399" />

      {/* Decorative dots */}
      <circle cx="50" cy="55" r="5" fill="#FDBA74" opacity="0.6" />
      <circle cx="365" cy="140" r="7" fill="#FED7AA" opacity="0.5" />
      <circle cx="115" cy="85" r="4" fill="#FEF3C7" opacity="0.7" />
      <circle cx="30" cy="150" r="3" fill="#FDBA74" opacity="0.4" />
      <circle cx="380" cy="250" r="4" fill="#FFEDD5" opacity="0.6" />

      {/* Sparkle effects near coins */}
      <g opacity="0.6">
        <path d="M80 85 L82 90 L87 92 L82 94 L80 99 L78 94 L73 92 L78 90 Z" fill="#FCD34D" />
        <path d="M360 60 L361 63 L364 64 L361 65 L360 68 L359 65 L356 64 L359 63 Z" fill="#FCD34D" />
        <path d="M310 130 L311 132 L313 133 L311 134 L310 136 L309 134 L307 133 L309 132 Z" fill="#FDBA74" />
      </g>
    </svg>
  );
}
