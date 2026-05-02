/**
 * @fileoverview Doer Network Radar Illustration
 * Distinct motif from dashboard while keeping palette consistency
 * @module components/doers/doer-illustration
 */

export default function DoerIllustration() {
  return (
    <svg viewBox="0 0 400 300" fill="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-full">
      <circle cx="200" cy="150" r="130" fill="#FFF7ED" opacity="0.35" />
      <circle cx="200" cy="150" r="95" fill="#FFEDD5" opacity="0.45" />

      <circle cx="200" cy="150" r="90" stroke="#F97316" strokeWidth="2" opacity="0.35" />
      <circle cx="200" cy="150" r="65" stroke="#FDBA74" strokeWidth="2" opacity="0.4" />
      <circle cx="200" cy="150" r="40" stroke="#FEC89A" strokeWidth="2" opacity="0.5" />

      <line x1="110" y1="150" x2="290" y2="150" stroke="#F97316" strokeWidth="2" opacity="0.25" />
      <line x1="200" y1="60" x2="200" y2="240" stroke="#F97316" strokeWidth="2" opacity="0.25" />
      <line x1="140" y1="90" x2="260" y2="210" stroke="#FDBA74" strokeWidth="2" opacity="0.2" />
      <line x1="260" y1="90" x2="140" y2="210" stroke="#FDBA74" strokeWidth="2" opacity="0.2" />

      <circle cx="200" cy="150" r="8" fill="#1C1C1C" />
      <circle cx="200" cy="150" r="4" fill="#F97316" />

      <g>
        <circle cx="280" cy="110" r="16" fill="white" stroke="#F97316" strokeWidth="2" />
        <circle cx="280" cy="105" r="6" fill="#FCD34D" />
        <rect x="272" y="112" width="16" height="10" rx="4" fill="#1C1C1C" />
      </g>

      <g>
        <circle cx="125" cy="130" r="14" fill="white" stroke="#10B981" strokeWidth="2" />
        <circle cx="125" cy="125" r="5" fill="#FCD34D" />
        <rect x="118" y="132" width="14" height="9" rx="4" fill="#10B981" />
      </g>

      <g>
        <circle cx="240" cy="210" r="14" fill="white" stroke="#3B82F6" strokeWidth="2" />
        <circle cx="240" cy="205" r="5" fill="#FCD34D" />
        <rect x="232" y="212" width="16" height="9" rx="4" fill="#3B82F6" />
      </g>

      <g>
        <circle cx="160" cy="205" r="12" fill="white" stroke="#F59E0B" strokeWidth="2" />
        <circle cx="160" cy="201" r="4" fill="#FCD34D" />
        <rect x="154" y="207" width="12" height="8" rx="4" fill="#F59E0B" />
      </g>

      <g>
        <rect x="62" y="86" width="54" height="34" rx="8" fill="white" stroke="#F97316" strokeWidth="2" />
        <circle cx="77" cy="103" r="6" fill="#F97316" />
        <line x1="88" y1="98" x2="110" y2="98" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />
        <line x1="88" y1="108" x2="104" y2="108" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />
      </g>

      <g>
        <rect x="285" y="170" width="56" height="36" rx="8" fill="white" stroke="#F97316" strokeWidth="2" />
        <path d="M296 192 L302 198 L312 186" stroke="#10B981" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
        <line x1="318" y1="188" x2="334" y2="188" stroke="#E5E7EB" strokeWidth="2" strokeLinecap="round" />
      </g>

      <circle cx="90" cy="200" r="4" fill="#FDBA74" opacity="0.6" />
      <circle cx="315" cy="125" r="5" fill="#FED7AA" opacity="0.5" />
      <circle cx="210" cy="65" r="4" fill="#FEF3C7" opacity="0.7" />
      <circle cx="110" cy="165" r="3" fill="#34D399" opacity="0.6" />
      <circle cx="265" cy="150" r="3" fill="#93C5FD" opacity="0.6" />
    </svg>
  )
}
