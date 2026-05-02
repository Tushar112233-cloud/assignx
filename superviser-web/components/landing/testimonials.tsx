/**
 * @fileoverview Testimonials — Supervisor Landing
 *
 * Two-row marquee of supervisor review cards. Row 1 left, row 2 right.
 */
"use client"

import { useRef } from "react"
import { motion, useReducedMotion, useInView } from "framer-motion"
import { Marquee } from "@/components/ui/marquee"
import { cn } from "@/lib/utils"
import { SV_EASE } from "@/lib/animations/constants"
import { Star, IndianRupee } from "lucide-react"
import "@/app/landing.css"

const reviews = [
  {
    name: "Dr. Priya S.",
    username: "@priya_phd",
    role: "PhD — Biology",
    earnings: "₹28,000/mo",
    rating: 5,
    body: "Supervising biology projects fits perfectly alongside my research. The platform is smooth, payouts are always on time, and I genuinely enjoy the work.",
    img: "https://i.pravatar.cc/80?img=5",
  },
  {
    name: "Rahul M.",
    username: "@rahul_cs",
    role: "MS — Computer Science",
    earnings: "₹32,000/mo",
    rating: 5,
    body: "The CS task volume is incredible. I earn more supervising here than consulting for most startups, and I set my own hours.",
    img: "https://i.pravatar.cc/80?img=11",
  },
  {
    name: "Anjali K.",
    username: "@anjali_law",
    role: "LLM — Corporate Law",
    earnings: "₹19,500/mo",
    rating: 5,
    body: "Legal tasks are well-defined and the clients are serious. AssignX has given me a reliable side income that actually respects my expertise.",
    img: "https://i.pravatar.cc/80?img=1",
  },
  {
    name: "Vikram T.",
    username: "@vikram_fin",
    role: "MBA — Finance",
    earnings: "₹24,000/mo",
    rating: 5,
    body: "Finance and business tasks are abundant. I approved 14 projects last month alone. The QC workflow is intuitive and fast.",
    img: "https://i.pravatar.cc/80?img=8",
  },
  {
    name: "Sneha R.",
    username: "@sneha_medic",
    role: "MBBS + MD",
    earnings: "₹21,000/mo",
    rating: 5,
    body: "Medical tasks are always high quality and pay well. I supervise 2–3 projects a week and the 48-hour payout is real — no delays ever.",
    img: "https://i.pravatar.cc/80?img=9",
  },
  {
    name: "Arjun D.",
    username: "@arjun_stats",
    role: "MSc — Statistics",
    earnings: "₹18,000/mo",
    rating: 5,
    body: "Data analysis and stats tasks are plentiful. The briefs are clear and DoLancers follow instructions well. Great system overall.",
    img: "https://i.pravatar.cc/80?img=3",
  },
]

const firstRow = reviews.slice(0, 3)
const secondRow = reviews.slice(3)

type Review = (typeof reviews)[0]

function ReviewCard({ img, name, role, earnings, rating, body }: Review) {
  return (
    <figure
      className={cn(
        "relative h-full w-72 cursor-pointer overflow-hidden rounded-2xl p-5",
        "bg-white dark:bg-[var(--sv-bg-dark-surface)]",
        "border border-[var(--sv-border)]",
        "hover:border-[var(--sv-border-accent)] hover:shadow-lg hover:-translate-y-1",
        "transition-all duration-300"
      )}
    >
      <div className="flex flex-row items-center gap-3 mb-3">
        <div className="w-10 h-10 flex-shrink-0 rounded-full overflow-hidden ring-2 ring-[var(--sv-accent-light)]">
          <img
            className="w-full h-full object-cover"
            alt={name}
            src={img}
            loading="lazy"
          />
        </div>
        <div className="flex-1 min-w-0">
          <figcaption className="text-sm font-semibold text-[var(--sv-text-primary)] truncate">
            {name}
          </figcaption>
          <p className="text-xs text-[var(--sv-text-muted)]">{role}</p>
        </div>
        <div className="flex items-center gap-1 text-xs font-bold text-[var(--sv-accent)] bg-[var(--sv-accent-lighter)] px-2 py-0.5 rounded-full shrink-0">
          <IndianRupee className="w-3 h-3" />
          {earnings.replace("₹", "")}
        </div>
      </div>

      <div className="flex gap-0.5 mb-2" aria-label={`${rating} out of 5 stars`}>
        {Array.from({ length: rating }).map((_, i) => (
          <Star key={i} className="w-3.5 h-3.5 text-yellow-400 fill-yellow-400" />
        ))}
      </div>

      <blockquote className="text-sm text-[var(--sv-text-secondary)] leading-relaxed">
        &ldquo;{body}&rdquo;
      </blockquote>
    </figure>
  )
}

export function Testimonials() {
  const sectionRef = useRef<HTMLElement>(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.3 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={sectionRef}
      id="testimonials"
      className="relative py-24 overflow-hidden"
      style={{ background: "var(--sv-bg-primary)" }}
    >
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--sv-border)] to-transparent" />

      <div className="max-w-5xl mx-auto px-4 text-center mb-12">
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: SV_EASE }}
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--sv-accent-lighter)] border border-[var(--sv-border-accent)] mb-6">
            <span className="text-sm font-medium text-[var(--sv-accent)]">
              Supervisor Stories
            </span>
          </span>
          <h2 className="sv-heading-lg text-[var(--sv-text-primary)] mb-4">
            Real Supervisors,{" "}
            <span className="sv-text-gradient">Real Earnings</span>
          </h2>
          <p className="text-lg text-[var(--sv-text-secondary)] max-w-2xl mx-auto">
            Join hundreds of verified experts already earning on SupervisorX.
          </p>
        </motion.div>
      </div>

      <motion.div
        initial={prefersReducedMotion ? false : { opacity: 0 }}
        animate={isInView ? { opacity: 1 } : {}}
        transition={{ delay: 0.3, duration: 0.8, ease: SV_EASE }}
        className="relative"
      >
        <div className="relative flex w-full flex-col items-center justify-center overflow-hidden">
          <Marquee pauseOnHover className="[--duration:32s]">
            {firstRow.map((r) => (
              <ReviewCard key={r.username} {...r} />
            ))}
          </Marquee>
          <Marquee reverse pauseOnHover className="[--duration:28s] mt-4">
            {secondRow.map((r) => (
              <ReviewCard key={r.username} {...r} />
            ))}
          </Marquee>

          {/* Fade edges */}
          <div className="pointer-events-none absolute inset-y-0 left-0 w-1/4 bg-gradient-to-r from-[var(--sv-bg-primary)] to-transparent" />
          <div className="pointer-events-none absolute inset-y-0 right-0 w-1/4 bg-gradient-to-l from-[var(--sv-bg-primary)] to-transparent" />
        </div>
      </motion.div>
    </section>
  )
}
