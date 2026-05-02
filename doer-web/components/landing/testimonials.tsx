/**
 * @fileoverview Testimonials — Dolancer Landing
 *
 * Two-row Marquee of Dolancer review cards, each highlighting monthly earnings.
 * Row 1 scrolls left, Row 2 scrolls right. Pauses on hover.
 */
"use client"

import { useRef } from "react"
import { motion, useReducedMotion, useInView } from "framer-motion"
import { Marquee } from "@/components/ui/marquee"
import { cn } from "@/lib/utils"
import { DOER_EASE } from "@/lib/animations/constants"
import { Star, IndianRupee } from "lucide-react"
import "@/app/landing.css"

const reviews = [
  {
    name: "Ananya S.",
    username: "@ananya_research",
    role: "PhD Scholar",
    earnings: "₹22,000/mo",
    rating: 5,
    body: "I work on research tasks during my free time. The pay is fair and supervisors are professional. Earned ₹22k last month — better than a part-time job.",
    img: "https://i.pravatar.cc/80?img=5",
  },
  {
    name: "Rahul K.",
    username: "@rahulk_data",
    role: "Data Analyst",
    earnings: "₹18,500/mo",
    rating: 5,
    body: "Perfect for someone who knows statistics inside out. Tasks are clearly defined and payouts are always on time. Highly recommend!",
    img: "https://i.pravatar.cc/80?img=3",
  },
  {
    name: "Priya M.",
    username: "@priya_writer",
    role: "English Grad",
    earnings: "₹14,000/mo",
    rating: 5,
    body: "Started part-time during my masters. Now I do it on weekends and earn more than my first job. Tasks always match my skills.",
    img: "https://i.pravatar.cc/80?img=1",
  },
  {
    name: "Vikram P.",
    username: "@vikram_mba",
    role: "MBA Student",
    earnings: "₹11,200/mo",
    rating: 5,
    body: "The task matching is great — I only see business/finance tasks. Earning while applying what I learn in class is incredible.",
    img: "https://i.pravatar.cc/80?img=8",
  },
  {
    name: "Sneha T.",
    username: "@sneha_bio",
    role: "Biology Teacher",
    earnings: "₹9,600/mo",
    rating: 5,
    body: "I help students in my domain. The platform is easy to use and the community is supportive. Payouts are always on time.",
    img: "https://i.pravatar.cc/80?img=9",
  },
  {
    name: "Arjun D.",
    username: "@arjun_tech",
    role: "Software Engineer",
    earnings: "₹26,000/mo",
    rating: 5,
    body: "Technical writing, code review, CS assignments — tons of tasks in my domain. The pay is well above market rate.",
    img: "https://i.pravatar.cc/80?img=11",
  },
]

const firstRow = reviews.slice(0, 3)
const secondRow = reviews.slice(3)

type Review = (typeof reviews)[0]

/** Individual review card */
function ReviewCard({ img, name, role, earnings, rating, body }: Review) {
  return (
    <figure
      className={cn(
        "relative h-full w-72 cursor-pointer overflow-hidden rounded-2xl p-5",
        "bg-white dark:bg-[var(--landing-bg-elevated)]",
        "border border-[var(--landing-border)]",
        "hover:border-[var(--landing-border-teal)] hover:shadow-lg hover:-translate-y-1",
        "transition-all duration-300"
      )}
    >
      {/* Header: avatar + name + earnings badge */}
      <div className="flex flex-row items-center gap-3 mb-3">
        <div className="w-10 h-10 flex-shrink-0 rounded-full overflow-hidden ring-2 ring-[var(--landing-accent-lighter)]">
          <img
            className="w-full h-full object-cover"
            alt={name}
            src={img}
            loading="lazy"
          />
        </div>
        <div className="flex-1 min-w-0">
          <figcaption className="text-sm font-semibold text-[var(--landing-text-primary)] truncate">
            {name}
          </figcaption>
          <p className="text-xs text-[var(--landing-text-muted)]">{role}</p>
        </div>
        {/* Earnings badge */}
        <div className="flex items-center gap-1 text-xs font-bold text-[var(--landing-accent-primary)] bg-[var(--landing-accent-lighter)] px-2 py-0.5 rounded-full shrink-0">
          <IndianRupee className="w-3 h-3" />
          {earnings.replace("₹", "")}
        </div>
      </div>

      {/* Star rating */}
      <div className="flex gap-0.5 mb-2" aria-label={`${rating} out of 5 stars`}>
        {Array.from({ length: rating }).map((_, i) => (
          <Star
            key={i}
            className="w-3.5 h-3.5 text-yellow-400 fill-yellow-400"
          />
        ))}
      </div>

      {/* Review body */}
      <blockquote className="text-sm text-[var(--landing-text-secondary)] leading-relaxed">
        &ldquo;{body}&rdquo;
      </blockquote>
    </figure>
  )
}

/** Testimonials Section */
export function Testimonials() {
  const sectionRef = useRef<HTMLElement>(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.3 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={sectionRef}
      id="testimonials"
      className="relative py-24 overflow-hidden"
      style={{ background: "var(--landing-bg-secondary)" }}
    >
      {/* Top separator */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--landing-border)] to-transparent" />

      {/* Section header */}
      <div className="max-w-5xl mx-auto px-4 text-center mb-12">
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: DOER_EASE }}
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border-teal)] mb-6">
            <span className="text-sm font-medium text-[var(--landing-accent-primary)]">
              Dolancer Stories
            </span>
          </span>
          <h2 className="landing-heading-lg text-[var(--landing-text-primary)] mb-4">
            Real Dolancers,{" "}
            <span className="landing-text-gradient">Real Earnings</span>
          </h2>
          <p className="text-lg text-[var(--landing-text-secondary)] max-w-2xl mx-auto">
            Join thousands of skilled experts already earning on Dolancer.
          </p>
        </motion.div>
      </div>

      {/* Two-row marquee */}
      <motion.div
        initial={prefersReducedMotion ? false : { opacity: 0 }}
        animate={isInView ? { opacity: 1 } : {}}
        transition={{ delay: 0.3, duration: 0.8, ease: DOER_EASE }}
        className="relative"
      >
        <div className="relative flex w-full flex-col items-center justify-center overflow-hidden">
          {/* Row 1 — left scroll */}
          <Marquee pauseOnHover className="[--duration:32s]">
            {firstRow.map((r) => (
              <ReviewCard key={r.username} {...r} />
            ))}
          </Marquee>

          {/* Row 2 — right scroll */}
          <Marquee reverse pauseOnHover className="[--duration:28s] mt-4">
            {secondRow.map((r) => (
              <ReviewCard key={r.username} {...r} />
            ))}
          </Marquee>

          {/* Fade edges */}
          <div className="pointer-events-none absolute inset-y-0 left-0 w-1/4 bg-gradient-to-r from-[var(--landing-bg-secondary)] to-transparent" />
          <div className="pointer-events-none absolute inset-y-0 right-0 w-1/4 bg-gradient-to-l from-[var(--landing-bg-secondary)] to-transparent" />
        </div>
      </motion.div>
    </section>
  )
}
