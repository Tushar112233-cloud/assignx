"use client";

/**
 * @fileoverview Landing Page - Redesigned with smooth section transitions
 *
 * Features:
 * - Seamless flowing sections with no visual breaks
 * - Magic UI components (AnimatedBeam, Marquee, DottedMap)
 * - OpenPeeps illustrations without circles
 * - Actual UI mockups in How It Works section
 * - Coffee Bean color palette throughout
 */

import "./landing.css";
import React, { forwardRef, useRef } from "react";
import { motion, useReducedMotion, useInView } from "framer-motion";
import { LenisProvider } from "@/components/providers/lenis-provider";
import {
  Navigation,
  HeroSection,
  UserTypeCards,
  TrustStats,
  ValueProposition,
  CTASection,
  Footer,
  HowItWorks,
} from "@/components/landing";
import { cn } from "@/lib/utils";
import { Marquee } from "@/components/ui/marquee";
import { DottedMap } from "@/components/ui/dotted-map";
import { AnimatedBeam } from "@/components/ui/animated-beam";
import Peep from "react-peeps";
import { ASSIGNX_EASE } from "@/lib/animations/constants";

/**
 * Get time-based gradient class for dynamic theming
 */
function getTimeBasedGradientClass(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "mesh-gradient-morning";
  if (hour >= 12 && hour < 18) return "mesh-gradient-afternoon";
  return "mesh-gradient-evening";
}

// ============== DOTTED MAP MARKERS ==============
const markers = [
  { lat: 40.7128, lng: -74.006, size: 0.3 }, // New York
  { lat: 34.0522, lng: -118.2437, size: 0.3 }, // Los Angeles
  { lat: 51.5074, lng: -0.1278, size: 0.3 }, // London
  { lat: -33.8688, lng: 151.2093, size: 0.3 }, // Sydney
  { lat: 48.8566, lng: 2.3522, size: 0.3 }, // Paris
  { lat: 35.6762, lng: 139.6503, size: 0.3 }, // Tokyo
  { lat: 55.7558, lng: 37.6176, size: 0.3 }, // Moscow
  { lat: 39.9042, lng: 116.4074, size: 0.3 }, // Beijing
  { lat: 28.6139, lng: 77.209, size: 0.3 }, // New Delhi
  { lat: -23.5505, lng: -46.6333, size: 0.3 }, // São Paulo
  { lat: 1.3521, lng: 103.8198, size: 0.3 }, // Singapore
  { lat: 25.2048, lng: 55.2708, size: 0.3 }, // Dubai
  { lat: 52.52, lng: 13.405, size: 0.3 }, // Berlin
  { lat: 19.4326, lng: -99.1332, size: 0.3 }, // Mexico City
  { lat: -26.2041, lng: 28.0473, size: 0.3 }, // Johannesburg
];

// ============== ANIMATED BEAM WITH OPEN PEEPS (NO CIRCLES) ==============
const PeepContainer = forwardRef<
  HTMLDivElement,
  { className?: string; children?: React.ReactNode; highlight?: boolean }
>(({ className, children, highlight }, ref) => {
  return (
    <div
      ref={ref}
      className={cn(
        "z-10 flex items-center justify-center transition-transform duration-300 hover:scale-110",
        highlight && "drop-shadow-[0_0_20px_rgba(118,83,65,0.4)]",
        className
      )}
    >
      {children}
    </div>
  );
});
PeepContainer.displayName = "PeepContainer";

function ConnectWithExperts() {
  const containerRef = useRef<HTMLDivElement>(null);
  const sectionRef = useRef<HTMLElement>(null);
  const isInView = useInView(sectionRef, { once: true, amount: 0.3 });
  const prefersReducedMotion = useReducedMotion();

  // User refs (left side)
  const user1Ref = useRef<HTMLDivElement>(null);
  const user2Ref = useRef<HTMLDivElement>(null);
  const user3Ref = useRef<HTMLDivElement>(null);

  // Supervisor ref (center)
  const supervisorRef = useRef<HTMLDivElement>(null);

  // Expert refs (right side)
  const expert1Ref = useRef<HTMLDivElement>(null);
  const expert2Ref = useRef<HTMLDivElement>(null);
  const expert3Ref = useRef<HTMLDivElement>(null);

  return (
    <section
      ref={sectionRef}
      className="relative py-24 md:py-32 overflow-hidden"
      style={{
        background: "var(--landing-bg-secondary)",
      }}
    >
      {/* Top separator line */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--landing-border)] to-transparent" />

      {/* Background decoration */}
      <div className="absolute inset-0 landing-grid-pattern opacity-20" />

      {/* Floating gradient orbs */}
      <motion.div
        className="absolute top-20 left-10 w-72 h-72 bg-[var(--landing-accent-primary)]/10 rounded-full blur-3xl"
        animate={{
          scale: [1, 1.2, 1],
          opacity: [0.1, 0.2, 0.1]
        }}
        transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
      />
      <motion.div
        className="absolute bottom-20 right-10 w-96 h-96 bg-[var(--landing-accent-light)]/15 rounded-full blur-3xl"
        animate={{
          scale: [1.2, 1, 1.2],
          opacity: [0.15, 0.25, 0.15]
        }}
        transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
      />
      <motion.div
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-gradient-to-br from-[var(--landing-accent-primary)]/5 to-[var(--landing-accent-light)]/10 rounded-full blur-3xl"
        animate={{
          rotate: [0, 360]
        }}
        transition={{ duration: 60, repeat: Infinity, ease: "linear" }}
      />

      <div className="container mx-auto px-4 relative z-10">
        {/* Section Header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: ASSIGNX_EASE }}
          className="text-center mb-16 md:mb-20"
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border)] mb-6">
            <motion.span
              className="w-2 h-2 rounded-full bg-[var(--landing-accent-primary)]"
              animate={{ scale: [1, 1.5, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
            />
            <span className="text-sm font-medium text-[var(--landing-text-secondary)]">
              From Request to Delivery
            </span>
          </span>
          <h2 className="landing-heading-lg text-[var(--landing-text-primary)] mb-4">
            One Request, <span className="landing-text-gradient">Endless Expertise</span>
          </h2>
          <p className="text-lg text-[var(--landing-text-secondary)] max-w-2xl mx-auto">
            Your supervisor orchestrates the perfect team of experts, ensuring quality and seamless communication throughout.
          </p>
        </motion.div>

        {/* Main Visualization Container */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, scale: 0.95 }}
          animate={isInView ? { opacity: 1, scale: 1 } : {}}
          transition={{ delay: 0.2, duration: 0.8, ease: ASSIGNX_EASE }}
          className="relative max-w-5xl mx-auto"
        >
          {/* Glassmorphic container */}
          <div className="relative rounded-3xl overflow-hidden bg-white/5 backdrop-blur-sm border border-[var(--landing-border)] p-8 md:p-12">
            {/* Inner glow */}
            <div className="absolute inset-0 bg-gradient-to-br from-[var(--landing-accent-primary)]/5 via-transparent to-[var(--landing-accent-light)]/5" />

            {/* Column labels */}
            <div className="flex justify-between mb-8 relative z-10">
              <motion.div
                className="text-center flex-1"
                initial={{ opacity: 0, y: -10 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{ delay: 0.3 }}
              >
                <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#34312D]/10 border border-[#34312D]/20">
                  <span className="w-2 h-2 rounded-full bg-[#34312D]" />
                  <span className="text-xs font-medium text-[var(--landing-text-secondary)]">Students</span>
                </div>
              </motion.div>
              <motion.div
                className="text-center flex-1"
                initial={{ opacity: 0, y: -10 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{ delay: 0.4 }}
              >
                <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#765341]/10 border border-[#765341]/20">
                  <span className="w-2 h-2 rounded-full bg-[#765341]" />
                  <span className="text-xs font-medium text-[var(--landing-text-secondary)]">Supervisor</span>
                </div>
              </motion.div>
              <motion.div
                className="text-center flex-1"
                initial={{ opacity: 0, y: -10 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{ delay: 0.5 }}
              >
                <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#A07A65]/10 border border-[#A07A65]/20">
                  <span className="w-2 h-2 rounded-full bg-[#A07A65]" />
                  <span className="text-xs font-medium text-[var(--landing-text-secondary)]">Experts</span>
                </div>
              </motion.div>
            </div>

            {/* Animated Beam Container */}
            <div
              ref={containerRef}
              className="relative flex h-[380px] md:h-[420px] w-full items-center justify-center"
            >
              {/* Three-column layout */}
              <div className="flex w-full items-center justify-between px-2 md:px-8">
                {/* Left: Users with labels */}
                <div className="flex flex-col items-center justify-center gap-8 md:gap-12">
                  {[
                    { ref: user1Ref, label: "Research", body: "Hoodie", face: "Cute", hair: "BunCurly" },
                    { ref: user2Ref, label: "Writing", body: "Sweater", face: "Calm", hair: "Long" },
                    { ref: user3Ref, label: "Analysis", body: "Thunder", face: "Cheeky", hair: "Afro", accessory: "SunglassWayfarer" },
                  ].map((user, i) => (
                    <motion.div
                      key={i}
                      initial={{ opacity: 0, x: -20 }}
                      animate={isInView ? { opacity: 1, x: 0 } : {}}
                      transition={{ delay: 0.3 + i * 0.1 }}
                      className="flex flex-col items-center"
                    >
                      <PeepContainer ref={user.ref}>
                        <Peep
                          style={{ width: 65, height: 65 }}
                          accessory={user.accessory as any}
                          body={user.body as any}
                          face={user.face as any}
                          hair={user.hair as any}
                          strokeColor="#34312D"
                        />
                      </PeepContainer>
                      <span className="mt-1 text-[10px] font-medium text-[var(--landing-text-muted)] bg-[var(--landing-bg-elevated)]/50 px-2 py-0.5 rounded-full">
                        {user.label}
                      </span>
                    </motion.div>
                  ))}
                </div>

                {/* Center: Supervisor */}
                <motion.div
                  className="flex items-center justify-center"
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={isInView ? { opacity: 1, scale: 1 } : {}}
                  transition={{ delay: 0.4, type: "spring", stiffness: 200 }}
                >
                  <PeepContainer ref={supervisorRef} highlight className="relative">
                    {/* Pulsing ring */}
                    <motion.div
                      className="absolute inset-0 w-28 h-28 -m-2 rounded-full border-2 border-[#765341]/30"
                      animate={{ scale: [1, 1.3, 1], opacity: [0.5, 0, 0.5] }}
                      transition={{ duration: 2, repeat: Infinity }}
                    />
                    <motion.div
                      className="absolute inset-0 w-28 h-28 -m-2 rounded-full border-2 border-[#765341]/20"
                      animate={{ scale: [1, 1.5, 1], opacity: [0.3, 0, 0.3] }}
                      transition={{ duration: 2, repeat: Infinity, delay: 0.5 }}
                    />
                    {/* Glow background */}
                    <div className="absolute inset-0 w-36 h-36 -m-6 rounded-full bg-gradient-to-br from-[#765341]/20 to-[#A07A65]/30 blur-xl" />
                    <Peep
                      style={{ width: 90, height: 90 }}
                      accessory="GlassRoundThick"
                      body="BlazerBlackTee"
                      face="SmileBig"
                      hair="Pomp"
                      strokeColor="#765341"
                    />
                    {/* Badge */}
                    <motion.div
                      className="absolute -bottom-2 left-1/2 -translate-x-1/2 bg-gradient-to-r from-[#765341] to-[#5C4233] text-white text-[9px] font-bold px-2 py-0.5 rounded-full shadow-lg"
                      initial={{ scale: 0 }}
                      animate={isInView ? { scale: 1 } : {}}
                      transition={{ delay: 0.6, type: "spring" }}
                    >
                      SUPERVISOR
                    </motion.div>
                  </PeepContainer>
                </motion.div>

                {/* Right: Experts with labels */}
                <div className="flex flex-col items-center justify-center gap-8 md:gap-12">
                  {[
                    { ref: expert1Ref, label: "PhD Writer", body: "Shirt", face: "Smile", hair: "Short", accessory: "GlassRound" },
                    { ref: expert2Ref, label: "Data Analyst", body: "Turtleneck", face: "Explaining", hair: "Medium" },
                    { ref: expert3Ref, label: "Editor", body: "ButtonShirt", face: "Driven", hair: "ShortVolumed" },
                  ].map((expert, i) => (
                    <motion.div
                      key={i}
                      initial={{ opacity: 0, x: 20 }}
                      animate={isInView ? { opacity: 1, x: 0 } : {}}
                      transition={{ delay: 0.3 + i * 0.1 }}
                      className="flex flex-col items-center"
                    >
                      <PeepContainer ref={expert.ref}>
                        <Peep
                          style={{ width: 65, height: 65 }}
                          accessory={expert.accessory as any}
                          body={expert.body as any}
                          face={expert.face as any}
                          hair={expert.hair as any}
                          strokeColor="#5C4233"
                        />
                      </PeepContainer>
                      <span className="mt-1 text-[10px] font-medium text-[var(--landing-text-muted)] bg-[var(--landing-bg-elevated)]/50 px-2 py-0.5 rounded-full">
                        {expert.label}
                      </span>
                    </motion.div>
                  ))}
                </div>
              </div>

              {/* Animated Beams - Users to Supervisor (curved) */}
              <AnimatedBeam
                containerRef={containerRef}
                fromRef={user1Ref}
                toRef={supervisorRef}
                curvature={-120}
                endYOffset={-10}
                gradientStartColor="#E4E1C7"
                gradientStopColor="#765341"
                pathWidth={3}
                pathOpacity={0.2}
              />
              <AnimatedBeam
                containerRef={containerRef}
                fromRef={user2Ref}
                toRef={supervisorRef}
                curvature={0}
                gradientStartColor="#E4E1C7"
                gradientStopColor="#765341"
                pathWidth={3}
                pathOpacity={0.2}
              />
              <AnimatedBeam
                containerRef={containerRef}
                fromRef={user3Ref}
                toRef={supervisorRef}
                curvature={120}
                endYOffset={10}
                gradientStartColor="#E4E1C7"
                gradientStopColor="#765341"
                pathWidth={3}
                pathOpacity={0.2}
              />

              {/* Animated Beams - Experts to Supervisor (same curvatures as left, mirrored visually) */}
              <AnimatedBeam
                containerRef={containerRef}
                fromRef={expert1Ref}
                toRef={supervisorRef}
                curvature={120}
                endYOffset={-10}
                gradientStartColor="#A07A65"
                gradientStopColor="#765341"
                pathWidth={3}
                pathOpacity={0.2}
              />
              <AnimatedBeam
                containerRef={containerRef}
                fromRef={expert2Ref}
                toRef={supervisorRef}
                curvature={0}
                gradientStartColor="#A07A65"
                gradientStopColor="#765341"
                pathWidth={3}
                pathOpacity={0.2}
              />
              <AnimatedBeam
                containerRef={containerRef}
                fromRef={expert3Ref}
                toRef={supervisorRef}
                curvature={-120}
                endYOffset={10}
                gradientStartColor="#A07A65"
                gradientStopColor="#765341"
                pathWidth={3}
                pathOpacity={0.2}
              />
            </div>
          </div>
        </motion.div>

        {/* Bottom Features */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ delay: 0.6, duration: 0.6, ease: ASSIGNX_EASE }}
          className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-12 max-w-4xl mx-auto"
        >
          {[
            { title: "Smart Matching", desc: "AI-powered expert selection based on your needs" },
            { title: "Quality Control", desc: "Every deliverable reviewed before you receive it" },
            { title: "24/7 Support", desc: "Your supervisor is always available for updates" },
          ].map((feature, i) => (
            <motion.div
              key={feature.title}
              initial={{ opacity: 0, y: 10 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ delay: 0.7 + i * 0.1 }}
              className="text-center p-4 rounded-xl bg-[var(--landing-bg-elevated)]/50 border border-[var(--landing-border)] hover:border-[var(--landing-accent-light)] transition-colors"
            >
              <h4 className="text-sm font-semibold text-[var(--landing-text-primary)] mb-1">{feature.title}</h4>
              <p className="text-xs text-[var(--landing-text-muted)]">{feature.desc}</p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}

// ============== TESTIMONIALS MARQUEE ==============
const reviews = [
  {
    name: "Priya S.",
    username: "@priya_student",
    body: "The supervisor system is amazing! I always knew exactly what was happening with my project. Got an A on my research paper!",
    img: "https://i.pravatar.cc/80?img=1",
  },
  {
    name: "Rahul M.",
    username: "@rahul_eng",
    body: "Fast delivery and excellent quality. The expert understood exactly what I needed for my thesis proposal.",
    img: "https://i.pravatar.cc/80?img=3",
  },
  {
    name: "Ananya K.",
    username: "@ananya_k",
    body: "I was skeptical at first, but the quality of work exceeded my expectations. Will definitely use again!",
    img: "https://i.pravatar.cc/80?img=5",
  },
  {
    name: "Vikram P.",
    username: "@vikram_mba",
    body: "The proofreading service saved my dissertation. Caught errors I completely missed. Highly recommend!",
    img: "https://i.pravatar.cc/80?img=8",
  },
  {
    name: "Sneha R.",
    username: "@sneha_r",
    body: "Professional communication throughout. My supervisor kept me updated at every stage. Great experience!",
    img: "https://i.pravatar.cc/80?img=9",
  },
  {
    name: "Arjun D.",
    username: "@arjun_dev",
    body: "Got my technical documentation done perfectly. The expert really knew their stuff. 10/10 would recommend.",
    img: "https://i.pravatar.cc/80?img=11",
  },
];

const firstRow = reviews.slice(0, reviews.length / 2);
const secondRow = reviews.slice(reviews.length / 2);

const ReviewCard = ({
  img,
  name,
  username,
  body,
}: {
  img: string;
  name: string;
  username: string;
  body: string;
}) => {
  return (
    <figure
      className={cn(
        "relative h-full w-72 cursor-pointer overflow-hidden rounded-2xl p-5",
        "bg-[var(--landing-bg-elevated)] border border-[var(--landing-border)]",
        "hover:border-[var(--landing-accent-light)] transition-all duration-300",
        "hover:shadow-lg hover:-translate-y-1"
      )}
    >
      <div className="flex flex-row items-center gap-3">
        <div className="w-10 h-10 flex-shrink-0 rounded-full overflow-hidden ring-2 ring-[var(--landing-accent-light)]">
          <img
            className="w-full h-full object-cover"
            alt={name}
            src={img}
          />
        </div>
        <div className="flex flex-col">
          <figcaption className="text-sm font-semibold text-[var(--landing-text-primary)]">
            {name}
          </figcaption>
          <p className="text-xs text-[var(--landing-text-muted)]">{username}</p>
        </div>
      </div>
      <blockquote className="mt-3 text-sm text-[var(--landing-text-secondary)] leading-relaxed">
        "{body}"
      </blockquote>
    </figure>
  );
};

function TestimonialsSection() {
  const sectionRef = useRef<HTMLElement>(null);
  const isInView = useInView(sectionRef, { once: true, amount: 0.3 });
  const prefersReducedMotion = useReducedMotion();

  return (
    <section
      ref={sectionRef}
      className="relative py-24 overflow-hidden"
      style={{
        background: "var(--landing-bg-primary)",
      }}
    >
      {/* Top separator - creates visual break from previous section */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--landing-border)] to-transparent" />
      <div className="container mx-auto px-4">
        {/* Section Header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: ASSIGNX_EASE }}
          className="text-center mb-12"
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border)] mb-6">
            <span className="text-sm font-medium text-[var(--landing-text-secondary)]">
              Student Reviews
            </span>
          </span>
          <h2 className="landing-heading-lg text-[var(--landing-text-primary)] mb-4">
            What <span className="landing-text-gradient">Students Say</span>
          </h2>
          <p className="text-lg text-[var(--landing-text-secondary)] max-w-2xl mx-auto">
            Join thousands of satisfied students who've trusted us with their academic success.
          </p>
        </motion.div>

        {/* Marquee */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0 }}
          animate={isInView ? { opacity: 1 } : {}}
          transition={{ delay: 0.3, duration: 0.8, ease: ASSIGNX_EASE }}
          className="relative"
        >
          <div className="relative flex w-full flex-col items-center justify-center overflow-hidden">
            <Marquee pauseOnHover className="[--duration:30s]">
              {firstRow.map((review) => (
                <ReviewCard key={review.username} {...review} />
              ))}
            </Marquee>
            <Marquee reverse pauseOnHover className="[--duration:30s] mt-4">
              {secondRow.map((review) => (
                <ReviewCard key={review.username} {...review} />
              ))}
            </Marquee>
            {/* Fade edges */}
            <div className="pointer-events-none absolute inset-y-0 left-0 w-1/4 bg-gradient-to-r from-[var(--landing-bg-primary)] via-[var(--landing-bg-primary)]/50 to-transparent" />
            <div className="pointer-events-none absolute inset-y-0 right-0 w-1/4 bg-gradient-to-l from-[var(--landing-bg-primary)] via-[var(--landing-bg-primary)]/50 to-transparent" />
          </div>
        </motion.div>
      </div>
    </section>
  );
}

// ============== GLOBAL REACH SECTION ==============
function GlobalReachSection() {
  const sectionRef = useRef<HTMLElement>(null);
  const isInView = useInView(sectionRef, { once: true, amount: 0.3 });
  const prefersReducedMotion = useReducedMotion();

  return (
    <section
      ref={sectionRef}
      className="relative py-24 overflow-hidden"
      style={{
        background: "var(--landing-bg-secondary)",
      }}
    >
      {/* Top separator line */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--landing-border)] to-transparent" />

      {/* Decorative elements */}
      <div className="absolute inset-0 landing-grid-pattern opacity-20" />

      <div className="container mx-auto px-4 relative z-10">
        {/* Section Header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: ASSIGNX_EASE }}
          className="text-center mb-12"
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border)] mb-6">
            <span className="text-sm font-medium text-[var(--landing-text-secondary)]">
              Global Network
            </span>
          </span>
          <h2 className="landing-heading-lg text-[var(--landing-text-primary)] mb-4">
            Available <span className="landing-text-gradient">Worldwide</span>
          </h2>
          <p className="text-lg text-[var(--landing-text-secondary)] max-w-2xl mx-auto">
            Our experts span across the globe, ready to help with your projects 24/7.
          </p>
        </motion.div>

        {/* Map */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, scale: 0.95 }}
          animate={isInView ? { opacity: 1, scale: 1 } : {}}
          transition={{ delay: 0.2, duration: 0.8, ease: ASSIGNX_EASE }}
          className="relative h-[400px] md:h-[500px] w-full overflow-hidden rounded-2xl border border-[var(--landing-border)] bg-[var(--landing-bg-elevated)]"
        >
          <div className="absolute inset-0 bg-radial from-transparent via-transparent to-[var(--landing-bg-elevated)] opacity-60 z-10" />
          <DottedMap markers={markers} />
        </motion.div>

        {/* Stats */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ delay: 0.4, duration: 0.6, ease: ASSIGNX_EASE }}
          className="grid grid-cols-3 gap-6 mt-12 max-w-2xl mx-auto"
        >
          {[
            { value: "50+", label: "Countries" },
            { value: "24/7", label: "Support" },
            { value: "15+", label: "Languages" },
          ].map((stat) => (
            <div key={stat.label} className="text-center">
              <div className="text-3xl md:text-4xl font-bold text-[var(--landing-accent-primary)] tabular-nums">
                {stat.value}
              </div>
              <div className="text-sm text-[var(--landing-text-muted)]">
                {stat.label}
              </div>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}

// ============== MAIN PAGE ==============
export default function Home() {
  return (
    <LenisProvider>
      <div className="landing-page min-h-screen bg-[var(--landing-bg-primary)]">
        <Navigation />

        <main>
          {/* Hero + HowItWorks wrapper - shares the same mesh gradient background */}
          <div className={cn("relative mesh-background mesh-gradient-bottom-right-animated", getTimeBasedGradientClass())}>
            <HeroSection />
            <HowItWorks />
          </div>

          {/* User Type Cards */}
          <UserTypeCards />

          {/* Connect With Experts - Animated Beam */}
          <ConnectWithExperts />

          {/* Trust Statistics */}
          <TrustStats />

          {/* Global Reach - Map */}
          <GlobalReachSection />

          {/* Testimonials - Marquee */}
          <TestimonialsSection />

          {/* Value Proposition */}
          <ValueProposition />

          {/* Final CTA */}
          <CTASection />
        </main>

        <Footer />
      </div>
    </LenisProvider>
  );
}
