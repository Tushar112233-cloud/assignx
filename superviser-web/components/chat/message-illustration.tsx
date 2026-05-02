/**
 * @fileoverview Messages Page Illustration - Modern minimal SVG
 * Matches dashboard illustration style with chat/messaging theme
 * Uses charcoal + orange/amber accent palette
 * @module components/chat/message-illustration
 */

interface MessageIllustrationProps {
  className?: string;
}

export function MessageIllustration({ className }: MessageIllustrationProps) {
  return (
    <svg viewBox="0 0 400 300" fill="none" xmlns="http://www.w3.org/2000/svg" className={className || "w-full h-full"}>
      {/* Background circles */}
      <circle cx="200" cy="150" r="140" fill="#FFF7ED" opacity="0.3" />
      <circle cx="200" cy="150" r="100" fill="#FFEDD5" opacity="0.4" />
      <circle cx="75" cy="75" r="35" fill="#FDBA74" opacity="0.2" />
      <circle cx="330" cy="230" r="45" fill="#FED7AA" opacity="0.25" />

      {/* Desk */}
      <rect x="80" y="215" width="240" height="10" rx="3" fill="#E5E7EB" />
      <rect x="95" y="225" width="10" height="50" rx="2" fill="#D1D5DB" />
      <rect x="295" y="225" width="10" height="50" rx="2" fill="#D1D5DB" />

      {/* Large phone/device on desk */}
      <rect x="170" y="150" width="60" height="65" rx="5" fill="#1C1C1C" />
      <rect x="174" y="156" width="52" height="50" rx="2" fill="#2D2D2D" />
      {/* Phone screen content - mini chat bubbles */}
      <rect x="178" y="162" width="28" height="8" rx="3" fill="#F97316" opacity="0.7" />
      <rect x="194" y="174" width="28" height="8" rx="3" fill="#E5E7EB" />
      <rect x="178" y="186" width="24" height="8" rx="3" fill="#F97316" opacity="0.7" />
      <rect x="198" y="198" width="24" height="6" rx="2" fill="#E5E7EB" />
      {/* Phone notch */}
      <rect x="190" y="152" width="20" height="3" rx="1.5" fill="#374151" />
      {/* Phone home button */}
      <rect x="193" y="208" width="14" height="3" rx="1.5" fill="#374151" />

      {/* Person - Modern minimalist style */}
      {/* Head */}
      <circle cx="200" cy="80" r="22" fill="#FCD34D" />

      {/* Hair - Modern style */}
      <path d="M178 75 Q180 58 200 62 Q220 58 222 75 Q225 70 222 85 L178 85 Q175 70 178 75" fill="#1C1C1C" />

      {/* Face features */}
      <circle cx="193" cy="78" r="2" fill="#1C1C1C" />
      <circle cx="207" cy="78" r="2" fill="#1C1C1C" />
      <path d="M195 88 Q200 92 205 88" stroke="#1C1C1C" strokeWidth="2" fill="none" strokeLinecap="round" />

      {/* Glasses */}
      <rect x="188" y="76" width="10" height="8" rx="2" fill="none" stroke="#1C1C1C" strokeWidth="1.5" />
      <rect x="202" y="76" width="10" height="8" rx="2" fill="none" stroke="#1C1C1C" strokeWidth="1.5" />
      <line x1="198" y1="80" x2="202" y2="80" stroke="#1C1C1C" strokeWidth="1.5" />

      {/* Body - Orange sweater */}
      <path d="M178 102 L170 205 L185 205 L200 135 L215 205 L230 205 L222 102 Z" fill="#F97316" />

      {/* Collar detail */}
      <path d="M185 102 Q200 112 215 102" stroke="#EA580C" strokeWidth="2" fill="none" />

      {/* Arms - reaching toward phone */}
      <path d="M175 110 L155 160 L163 168 L180 125" fill="#FCD34D" />
      <path d="M225 110 L245 160 L237 168 L220 125" fill="#FCD34D" />

      {/* Hands */}
      <ellipse cx="158" cy="163" rx="8" ry="6" fill="#FCD34D" />
      <ellipse cx="242" cy="163" rx="8" ry="6" fill="#FCD34D" />

      {/* Chat bubble 1 - Large top left */}
      <g opacity="0.95">
        <rect x="35" y="55" width="80" height="50" rx="8" fill="white" stroke="#F97316" strokeWidth="2.5" />
        <circle cx="55" cy="75" r="5" fill="#F97316" />
        <line x1="66" y1="70" x2="100" y2="70" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="66" y1="78" x2="95" y2="78" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="66" y1="86" x2="88" y2="86" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        {/* Tail */}
        <path d="M85 105 L90 115 L100 105" fill="white" stroke="#F97316" strokeWidth="2.5" strokeLinejoin="round" />
      </g>

      {/* Chat bubble 2 - Top right with notification */}
      <g opacity="0.95">
        <rect x="280" y="45" width="85" height="55" rx="8" fill="white" stroke="#EA580C" strokeWidth="2.5" />
        <circle cx="300" cy="68" r="5" fill="#EA580C" />
        <line x1="312" y1="63" x2="350" y2="63" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="312" y1="71" x2="345" y2="71" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="312" y1="79" x2="338" y2="79" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="312" y1="87" x2="348" y2="87" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        {/* Notification badge */}
        <circle cx="358" cy="50" r="8" fill="#F97316" />
        <text x="358" y="54" fontSize="10" fill="white" textAnchor="middle" fontWeight="bold">3</text>
      </g>

      {/* Chat bubble 3 - Left side */}
      <g opacity="0.95">
        <rect x="25" y="145" width="70" height="45" rx="8" fill="white" stroke="#F97316" strokeWidth="2.5" />
        <circle cx="42" cy="163" r="4" fill="#10B981" />
        <line x1="52" y1="158" x2="82" y2="158" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="52" y1="166" x2="78" y2="166" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="52" y1="174" x2="72" y2="174" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
      </g>

      {/* Chat bubble 4 - Right side larger */}
      <g opacity="0.95">
        <rect x="305" y="130" width="75" height="55" rx="8" fill="white" stroke="#EA580C" strokeWidth="2.5" />
        <circle cx="322" cy="152" r="4" fill="#F97316" />
        <line x1="332" y1="147" x2="365" y2="147" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="332" y1="155" x2="360" y2="155" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="332" y1="163" x2="368" y2="163" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="332" y1="171" x2="355" y2="171" stroke="#E5E7EB" strokeWidth="2.5" strokeLinecap="round" />
        {/* Tail pointing left */}
        <path d="M305 155 L295 160 L305 165" fill="white" stroke="#EA580C" strokeWidth="2.5" strokeLinejoin="round" />
      </g>

      {/* Small typing indicator bubble - bottom left */}
      <g opacity="0.9">
        <rect x="45" y="210" width="55" height="30" rx="6" fill="white" stroke="#FDBA74" strokeWidth="2" />
        {/* Typing dots */}
        <circle cx="60" cy="225" r="4" fill="#F97316" opacity="0.6" />
        <circle cx="73" cy="225" r="4" fill="#F97316" opacity="0.8" />
        <circle cx="86" cy="225" r="4" fill="#F97316" />
      </g>

      {/* Send button indicator - bottom right */}
      <circle cx="355" cy="210" r="15" fill="#F97316" />
      <path d="M350 210 L360 210 M355 205 L355 215 M355 205 L362 212" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />

      {/* Floating notification card - top center */}
      <rect x="155" y="20" width="50" height="32" rx="5" fill="#FDBA74" opacity="0.2" />
      <circle cx="170" cy="32" r="4" fill="#F97316" opacity="0.5" />
      <line x1="180" y1="30" x2="198" y2="30" stroke="#EA580C" strokeWidth="2" strokeLinecap="round" opacity="0.4" />
      <line x1="180" y1="38" x2="192" y2="38" stroke="#EA580C" strokeWidth="2" strokeLinecap="round" opacity="0.4" />

      {/* Green online indicator - small floating element */}
      <circle cx="260" cy="125" r="10" fill="#10B981" opacity="0.2" />
      <circle cx="260" cy="125" r="6" fill="#34D399" opacity="0.4" />
      <circle cx="260" cy="125" r="3" fill="#10B981" />

      {/* Coffee mug on desk */}
      <rect x="260" y="195" width="18" height="20" rx="2" fill="#374151" />
      <rect x="263" y="198" width="12" height="14" rx="1" fill="#4B5563" />
      <path d="M278 200 Q285 200 285 205 Q285 210 278 210" stroke="#374151" strokeWidth="2" fill="none" />
      {/* Steam */}
      <path d="M266 190 Q268 185 266 180" stroke="#D1D5DB" strokeWidth="1.5" fill="none" strokeLinecap="round" />
      <path d="M272 192 Q274 187 272 182" stroke="#D1D5DB" strokeWidth="1.5" fill="none" strokeLinecap="round" />

      {/* Decorative dots */}
      <circle cx="135" cy="120" r="5" fill="#FDBA74" opacity="0.6" />
      <circle cx="270" cy="85" r="4" fill="#FED7AA" opacity="0.5" />
      <circle cx="115" cy="195" r="6" fill="#FEF3C7" opacity="0.7" />
      <circle cx="340" cy="195" r="5" fill="#FDBA74" opacity="0.5" />
      <circle cx="140" cy="55" r="3" fill="#34D399" opacity="0.4" />

      {/* Floating plus icons */}
      <g opacity="0.3">
        <line x1="365" y1="85" x2="375" y2="85" stroke="#F97316" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="370" y1="80" x2="370" y2="90" stroke="#F97316" strokeWidth="2.5" strokeLinecap="round" />
      </g>
      <g opacity="0.3">
        <line x1="125" y1="240" x2="133" y2="240" stroke="#EA580C" strokeWidth="2.5" strokeLinecap="round" />
        <line x1="129" y1="236" x2="129" y2="244" stroke="#EA580C" strokeWidth="2.5" strokeLinecap="round" />
      </g>

      {/* Connection lines (subtle) */}
      <path d="M115 80 Q145 95 170 150" stroke="#F97316" strokeWidth="1.5" strokeDasharray="3 3" opacity="0.15" />
      <path d="M280 75 Q255 100 230 150" stroke="#EA580C" strokeWidth="1.5" strokeDasharray="3 3" opacity="0.15" />
    </svg>
  );
}
