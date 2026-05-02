/**
 * @fileoverview Resources & Learning Illustration
 * Modern flat design with learning/resources theme
 * @module components/resources/resources-illustration
 */

export function ResourcesIllustration() {
  return (
    <svg viewBox="0 0 400 300" fill="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-full">
      {/* Background circles - Orange theme */}
      <circle cx="200" cy="150" r="140" fill="#FFF7ED" opacity="0.3" />
      <circle cx="200" cy="150" r="100" fill="#FFEDD5" opacity="0.4" />

      {/* Desk surface */}
      <rect x="60" y="220" width="280" height="12" rx="4" fill="#E5E7EB" />
      <rect x="75" y="232" width="12" height="50" rx="3" fill="#D1D5DB" />
      <rect x="313" y="232" width="12" height="50" rx="3" fill="#D1D5DB" />

      {/* Stack of books - Left side */}
      <g id="books">
        {/* Book 1 - Bottom */}
        <rect x="85" y="195" width="65" height="12" rx="2" fill="#F97316" />
        <rect x="87" y="197" width="61" height="8" rx="1" fill="#EA580C" />
        <line x1="115" y1="195" x2="115" y2="207" stroke="#FDBA74" strokeWidth="1.5" />

        {/* Book 2 - Middle */}
        <rect x="90" y="178" width="55" height="17" rx="2" fill="#10B981" />
        <rect x="92" y="180" width="51" height="13" rx="1" fill="#34D399" />
        <line x1="117" y1="178" x2="117" y2="195" stroke="#D1FAE5" strokeWidth="1.5" />

        {/* Book 3 - Top */}
        <rect x="95" y="163" width="50" height="15" rx="2" fill="#3B82F6" />
        <rect x="97" y="165" width="46" height="11" rx="1" fill="#60A5FA" />
        <line x1="120" y1="163" x2="120" y2="178" stroke="#DBEAFE" strokeWidth="1.5" />
      </g>

      {/* Laptop - Center */}
      <g id="laptop">
        {/* Laptop base */}
        <rect x="170" y="208" width="130" height="12" rx="3" fill="#374151" />
        <rect x="175" y="210" width="120" height="8" rx="2" fill="#4B5563" />

        {/* Laptop screen */}
        <rect x="180" y="130" width="110" height="78" rx="4" fill="#1C1C1C" />
        <rect x="186" y="136" width="98" height="66" rx="2" fill="#2D2D2D" />

        {/* Screen content - Code/Learning interface */}
        {/* Header bar */}
        <rect x="191" y="141" width="88" height="8" rx="1" fill="#374151" />
        <circle cx="194" cy="145" r="1.5" fill="#EF4444" />
        <circle cx="199" cy="145" r="1.5" fill="#FBBF24" />
        <circle cx="204" cy="145" r="1.5" fill="#10B981" />

        {/* Content area with orange accents */}
        <rect x="191" y="152" width="30" height="4" rx="1" fill="#F97316" opacity="0.3" />
        <rect x="191" y="159" width="45" height="4" rx="1" fill="#6B7280" opacity="0.3" />
        <rect x="191" y="166" width="35" height="4" rx="1" fill="#6B7280" opacity="0.3" />
        <rect x="191" y="173" width="42" height="4" rx="1" fill="#10B981" opacity="0.3" />

        {/* Chart visualization */}
        <path d="M245 175 L255 165 L265 170 L275 160"
              stroke="#F97316" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" />
        <circle cx="255" cy="165" r="2.5" fill="#F97316" />
        <circle cx="275" cy="160" r="2.5" fill="#F97316" />
      </g>

      {/* Magnifying glass - Learning/Research tool */}
      <g id="magnifying-glass">
        <circle cx="315" cy="175" r="20" fill="white" stroke="#1C1C1C" strokeWidth="3" />
        <circle cx="315" cy="175" r="14" fill="#FFF7ED" />
        <line x1="328" y1="188" x2="345" y2="205" stroke="#1C1C1C" strokeWidth="4" strokeLinecap="round" />

        {/* Magnified text/content */}
        <line x1="310" y1="172" x2="320" y2="172" stroke="#F97316" strokeWidth="2" strokeLinecap="round" />
        <line x1="310" y1="178" x2="318" y2="178" stroke="#6B7280" strokeWidth="1.5" strokeLinecap="round" />
      </g>

      {/* Growth chart/graph - Right background */}
      <g id="growth-chart" opacity="0.6">
        <rect x="305" y="90" width="70" height="50" rx="3" fill="white" stroke="#E5E7EB" strokeWidth="2" />

        {/* Grid lines */}
        <line x1="310" y1="100" x2="370" y2="100" stroke="#E5E7EB" strokeWidth="1" />
        <line x1="310" y1="115" x2="370" y2="115" stroke="#E5E7EB" strokeWidth="1" />
        <line x1="310" y1="130" x2="370" y2="130" stroke="#E5E7EB" strokeWidth="1" />

        {/* Growth bars */}
        <rect x="315" y="120" width="10" height="15" rx="1" fill="#F97316" opacity="0.5" />
        <rect x="330" y="110" width="10" height="25" rx="1" fill="#F97316" opacity="0.7" />
        <rect x="345" y="100" width="10" height="35" rx="1" fill="#F97316" />

        {/* Trend arrow */}
        <path d="M360 105 L368 97 L362 97 L362 101" fill="#10B981" />
      </g>

      {/* Coffee mug - Study companion */}
      <g id="coffee">
        <ellipse cx="250" cy="208" rx="10" ry="3" fill="#EA580C" />
        <rect x="240" y="198" width="20" height="15" rx="2" fill="#F97316" />
        <path d="M260 203 Q268 205 260 210" stroke="#EA580C" strokeWidth="2.5" fill="none" />

        {/* Steam */}
        <path d="M245 192 Q247 187 245 183" stroke="#D1D5DB" strokeWidth="1.5" opacity="0.6" fill="none" strokeLinecap="round" />
        <path d="M255 192 Q257 187 255 183" stroke="#D1D5DB" strokeWidth="1.5" opacity="0.6" fill="none" strokeLinecap="round" />
      </g>

      {/* Plant - Growth/learning metaphor */}
      <g id="plant">
        <rect x="48" y="185" width="22" height="35" rx="3" fill="#E5E7EB" />
        <rect x="50" y="187" width="18" height="33" rx="2" fill="#F3F4F6" />

        {/* Leaves */}
        <circle cx="59" cy="175" r="18" fill="#10B981" />
        <circle cx="47" cy="168" r="13" fill="#34D399" />
        <circle cx="70" cy="170" r="11" fill="#34D399" />
        <circle cx="59" cy="160" r="9" fill="#6EE7B7" />
      </g>

      {/* Floating knowledge elements */}
      <g id="floating-icons">
        {/* Certificate/badge */}
        <circle cx="60" cy="100" r="18" fill="#FFF7ED" stroke="#F97316" strokeWidth="2" />
        <path d="M60 93 L63 102 L72 103 L65 109 L67 118 L60 113 L53 118 L55 109 L48 103 L57 102 Z"
              fill="#F97316" />

        {/* Document/notes */}
        <rect x="320" y="50" width="30" height="35" rx="3" fill="white" stroke="#E5E7EB" strokeWidth="2" />
        <line x1="325" y1="58" x2="345" y2="58" stroke="#F97316" strokeWidth="2" strokeLinecap="round" />
        <line x1="325" y1="65" x2="340" y2="65" stroke="#D1D5DB" strokeWidth="2" strokeLinecap="round" />
        <line x1="325" y1="72" x2="345" y2="72" stroke="#D1D5DB" strokeWidth="2" strokeLinecap="round" />

        {/* Lightbulb - Ideas */}
        <circle cx="90" cy="65" r="12" fill="#FEF3C7" stroke="#F59E0B" strokeWidth="2" />
        <path d="M85 77 L95 77 M86 80 L94 80" stroke="#F59E0B" strokeWidth="2" strokeLinecap="round" />
        <line x1="90" y1="50" x2="90" y2="46" stroke="#F59E0B" strokeWidth="2" strokeLinecap="round" />
        <line x1="102" y1="56" x2="105" y2="53" stroke="#F59E0B" strokeWidth="2" strokeLinecap="round" />
        <line x1="78" y1="56" x2="75" y2="53" stroke="#F59E0B" strokeWidth="2" strokeLinecap="round" />
      </g>

      {/* Decorative background dots */}
      <g id="decorative-dots">
        <circle cx="130" cy="45" r="5" fill="#FDBA74" opacity="0.6" />
        <circle cx="280" cy="240" r="7" fill="#FED7AA" opacity="0.5" />
        <circle cx="40" cy="150" r="4" fill="#FEF3C7" opacity="0.7" />
        <circle cx="360" cy="140" r="6" fill="#FFEDD5" opacity="0.6" />
        <circle cx="165" cy="95" r="3" fill="#FDBA74" opacity="0.5" />
      </g>

      {/* Floating notification badge - New resources */}
      <g id="notification">
        <rect x="150" y="115" width="50" height="25" rx="4" fill="white" stroke="#F97316" strokeWidth="2" opacity="0.95" />
        <circle cx="160" cy="125" r="3" fill="#10B981" />
        <line x1="168" y1="123" x2="190" y2="123" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />
        <line x1="168" y1="128" x2="183" y2="128" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />

        {/* Badge count */}
        <circle cx="195" cy="118" r="6" fill="#F97316" />
        <text x="195" y="121" fontSize="8" fill="white" textAnchor="middle" fontWeight="bold">5</text>
      </g>
    </svg>
  )
}
