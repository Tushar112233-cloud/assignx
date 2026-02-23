"use client";

import { motion } from "framer-motion";

export function ClientNetworkIllustration() {
  return (
    <svg
      viewBox="0 0 350 280"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className="w-full h-full"
    >
      {/* Background Gradient Circles */}
      <motion.circle
        cx="175"
        cy="140"
        r="120"
        fill="#F97316"
        opacity="0.05"
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 0.05 }}
        transition={{ duration: 1.2, ease: "easeOut" }}
      />
      <motion.circle
        cx="175"
        cy="140"
        r="80"
        fill="#F97316"
        opacity="0.08"
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 0.08 }}
        transition={{ duration: 1, ease: "easeOut", delay: 0.2 }}
      />

      {/* Growth Chart in Background */}
      <motion.g
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, delay: 0.3 }}
      >
        <path
          d="M50 200 L90 180 L130 160 L170 140 L210 130 L250 110 L290 90"
          stroke="#F97316"
          strokeWidth="2"
          strokeLinecap="round"
          opacity="0.3"
          strokeDasharray="4 4"
        />
        {[50, 90, 130, 170, 210, 250, 290].map((x, i) => (
          <motion.circle
            key={i}
            cx={x}
            cy={200 - i * 18 - (i > 3 ? 10 : 0)}
            r="3"
            fill="#F97316"
            opacity="0.4"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ duration: 0.3, delay: 0.5 + i * 0.1 }}
          />
        ))}
      </motion.g>

      {/* Floating Documents/Projects */}
      <motion.g
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.8, delay: 0.6 }}
      >
        {/* Document 1 */}
        <rect
          x="30"
          y="50"
          width="40"
          height="50"
          rx="4"
          fill="white"
          stroke="#E5E7EB"
          strokeWidth="1.5"
        />
        <line x1="38" y1="62" x2="62" y2="62" stroke="#D1D5DB" strokeWidth="2" />
        <line x1="38" y1="70" x2="58" y2="70" stroke="#D1D5DB" strokeWidth="2" />
        <line x1="38" y1="78" x2="62" y2="78" stroke="#D1D5DB" strokeWidth="2" />

        {/* Document 2 */}
        <rect
          x="280"
          y="60"
          width="40"
          height="50"
          rx="4"
          fill="white"
          stroke="#E5E7EB"
          strokeWidth="1.5"
        />
        <line x1="288" y1="72" x2="312" y2="72" stroke="#D1D5DB" strokeWidth="2" />
        <line x1="288" y1="80" x2="308" y2="80" stroke="#D1D5DB" strokeWidth="2" />
        <line x1="288" y1="88" x2="312" y2="88" stroke="#D1D5DB" strokeWidth="2" />
      </motion.g>

      {/* Connection Lines */}
      <motion.g
        initial={{ pathLength: 0, opacity: 0 }}
        animate={{ pathLength: 1, opacity: 0.3 }}
        transition={{ duration: 1.5, delay: 0.8, ease: "easeInOut" }}
      >
        <motion.path
          d="M175 80 L120 120"
          stroke="#F97316"
          strokeWidth="2"
          strokeDasharray="4 4"
        />
        <motion.path
          d="M175 80 L230 120"
          stroke="#F97316"
          strokeWidth="2"
          strokeDasharray="4 4"
        />
        <motion.path
          d="M175 80 L175 140"
          stroke="#F97316"
          strokeWidth="2"
          strokeDasharray="4 4"
        />
        <motion.path
          d="M120 120 L90 180"
          stroke="#F97316"
          strokeWidth="2"
          strokeDasharray="4 4"
        />
        <motion.path
          d="M230 120 L260 180"
          stroke="#F97316"
          strokeWidth="2"
          strokeDasharray="4 4"
        />
        <motion.path
          d="M175 140 L120 180"
          stroke="#F97316"
          strokeWidth="2"
          strokeDasharray="4 4"
        />
        <motion.path
          d="M175 140 L230 180"
          stroke="#F97316"
          strokeWidth="2"
          strokeDasharray="4 4"
        />
      </motion.g>

      {/* User Avatars - Central Hub (Supervisor) */}
      <motion.g
        initial={{ scale: 0, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5, delay: 1 }}
      >
        <circle cx="175" cy="80" r="24" fill="#F97316" />
        <circle cx="175" cy="80" r="20" fill="white" />
        <path
          d="M175 74 C179 74 182 77 182 81 C182 85 179 88 175 88 C171 88 168 85 168 81 C168 77 171 74 175 74 Z"
          fill="#F97316"
        />
        <path
          d="M165 92 C165 88 169 85 175 85 C181 85 185 88 185 92"
          stroke="#F97316"
          strokeWidth="2"
          strokeLinecap="round"
        />
      </motion.g>

      {/* Secondary User Avatars - Layer 2 */}
      {[
        { cx: 120, cy: 120, delay: 1.1 },
        { cx: 230, cy: 120, delay: 1.15 },
        { cx: 175, cy: 140, delay: 1.2 },
      ].map((avatar, i) => (
        <motion.g
          key={i}
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.4, delay: avatar.delay }}
        >
          <circle cx={avatar.cx} cy={avatar.cy} r="20" fill="#EA580C" />
          <circle cx={avatar.cx} cy={avatar.cy} r="16" fill="white" />
          <path
            d={`M${avatar.cx} ${avatar.cy - 4} C${avatar.cx + 3} ${avatar.cy - 4} ${avatar.cx + 5} ${avatar.cy - 1} ${avatar.cx + 5} ${avatar.cy + 2} C${avatar.cx + 5} ${avatar.cy + 5} ${avatar.cx + 3} ${avatar.cy + 8} ${avatar.cx} ${avatar.cy + 8} C${avatar.cx - 3} ${avatar.cy + 8} ${avatar.cx - 5} ${avatar.cy + 5} ${avatar.cx - 5} ${avatar.cy + 2} C${avatar.cx - 5} ${avatar.cy - 1} ${avatar.cx - 3} ${avatar.cy - 4} ${avatar.cx} ${avatar.cy - 4} Z`}
            fill="#EA580C"
          />
          <path
            d={`M${avatar.cx - 8} ${avatar.cy + 12} C${avatar.cx - 8} ${avatar.cy + 9} ${avatar.cx - 4} ${avatar.cy + 7} ${avatar.cx} ${avatar.cy + 7} C${avatar.cx + 4} ${avatar.cy + 7} ${avatar.cx + 8} ${avatar.cy + 9} ${avatar.cx + 8} ${avatar.cy + 12}`}
            stroke="#EA580C"
            strokeWidth="1.5"
            strokeLinecap="round"
          />
        </motion.g>
      ))}

      {/* Tertiary User Avatars - Layer 3 (Clients) */}
      {[
        { cx: 90, cy: 180, delay: 1.25 },
        { cx: 260, cy: 180, delay: 1.3 },
        { cx: 120, cy: 180, delay: 1.35 },
        { cx: 230, cy: 180, delay: 1.4 },
      ].map((avatar, i) => (
        <motion.g
          key={i}
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.4, delay: avatar.delay }}
        >
          <circle cx={avatar.cx} cy={avatar.cy} r="16" fill="#D1D5DB" />
          <circle cx={avatar.cx} cy={avatar.cy} r="13" fill="white" />
          <path
            d={`M${avatar.cx} ${avatar.cy - 3} C${avatar.cx + 2} ${avatar.cy - 3} ${avatar.cx + 4} ${avatar.cy - 1} ${avatar.cx + 4} ${avatar.cy + 2} C${avatar.cx + 4} ${avatar.cy + 4} ${avatar.cx + 2} ${avatar.cy + 6} ${avatar.cx} ${avatar.cy + 6} C${avatar.cx - 2} ${avatar.cy + 6} ${avatar.cx - 4} ${avatar.cy + 4} ${avatar.cx - 4} ${avatar.cy + 2} C${avatar.cx - 4} ${avatar.cy - 1} ${avatar.cx - 2} ${avatar.cy - 3} ${avatar.cx} ${avatar.cy - 3} Z`}
            fill="#9CA3AF"
          />
          <path
            d={`M${avatar.cx - 6} ${avatar.cy + 9} C${avatar.cx - 6} ${avatar.cy + 7} ${avatar.cx - 3} ${avatar.cy + 5} ${avatar.cx} ${avatar.cy + 5} C${avatar.cx + 3} ${avatar.cy + 5} ${avatar.cx + 6} ${avatar.cy + 7} ${avatar.cx + 6} ${avatar.cy + 9}`}
            stroke="#9CA3AF"
            strokeWidth="1.2"
            strokeLinecap="round"
          />
        </motion.g>
      ))}

      {/* Activity Indicators - Floating Dots */}
      {[
        { cx: 140, cy: 100, delay: 1.5 },
        { cx: 210, cy: 100, delay: 1.6 },
        { cx: 105, cy: 150, delay: 1.7 },
        { cx: 245, cy: 150, delay: 1.8 },
      ].map((dot, i) => (
        <motion.circle
          key={i}
          cx={dot.cx}
          cy={dot.cy}
          r="4"
          fill="#F97316"
          initial={{ scale: 0, opacity: 0 }}
          animate={{
            scale: [1, 1.3, 1],
            opacity: [0.6, 1, 0.6]
          }}
          transition={{
            duration: 2,
            delay: dot.delay,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
      ))}

      {/* Success Checkmark Badge */}
      <motion.g
        initial={{ scale: 0, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5, delay: 1.9 }}
      >
        <circle cx="195" cy="60" r="12" fill="#10B981" />
        <path
          d="M190 60 L193 63 L200 56"
          stroke="white"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </motion.g>

      {/* Team Collaboration Icons */}
      <motion.g
        initial={{ opacity: 0, scale: 0.8 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.6, delay: 2 }}
      >
        {/* Message Icon */}
        <rect
          x="50"
          y="230"
          width="30"
          height="24"
          rx="4"
          fill="white"
          stroke="#F97316"
          strokeWidth="1.5"
        />
        <line x1="56" y1="238" x2="74" y2="238" stroke="#F97316" strokeWidth="1.5" />
        <line x1="56" y1="244" x2="68" y2="244" stroke="#F97316" strokeWidth="1.5" />

        {/* Star Icon */}
        <path
          d="M285 235 L287 241 L293 241 L288 245 L290 251 L285 247 L280 251 L282 245 L277 241 L283 241 Z"
          fill="#F97316"
          opacity="0.8"
        />
      </motion.g>
    </svg>
  );
}
