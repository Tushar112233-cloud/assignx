/**
 * @fileoverview HorizontalScroll - Premium GSAP horizontal scrolling experience
 *
 * Clean, professional horizontal scroll with refined typography and smooth animations.
 * Tells the story: Learning transformed → Expert guidance → Your success
 * Adapted for AssignX as an educational platform.
 */

"use client";

import { useRef, useEffect } from "react";
import { useReducedMotion } from "framer-motion";
import { cn } from "@/lib/utils";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import "@/app/landing.css";

// Register GSAP plugin
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

interface HorizontalScrollProps {
  className?: string;
}

export function HorizontalScroll({ className }: HorizontalScrollProps) {
  const sectionRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLDivElement>(null);
  const textTrackRef = useRef<HTMLDivElement>(null);
  const prefersReducedMotion = useReducedMotion();

  useEffect(() => {
    if (prefersReducedMotion) return;

    const section = sectionRef.current;
    const trigger = triggerRef.current;
    const textTrack = textTrackRef.current;

    if (!section || !trigger || !textTrack) return;

    const ctx = gsap.context(() => {
      const textWidth = textTrack.scrollWidth;
      const viewportWidth = window.innerWidth;
      const scrollDistance = textWidth - viewportWidth + 100;

      // Main horizontal scroll timeline
      const tl = gsap.timeline({
        scrollTrigger: {
          trigger: trigger,
          start: "top top",
          end: () => `+=${scrollDistance * 1.1}`,
          pin: true,
          scrub: 1,
          anticipatePin: 1,
          invalidateOnRefresh: true,
        },
      });

      tl.to(textTrack, {
        x: -scrollDistance,
        ease: "none",
      });

      // Ambient orbs - subtle parallax
      const orbs = section.querySelectorAll(".ambient-orb");
      orbs.forEach((orb, i) => {
        const speed = 0.15 + i * 0.08;
        gsap.to(orb, {
          x: -scrollDistance * speed,
          scrollTrigger: {
            trigger: trigger,
            start: "top top",
            end: () => `+=${scrollDistance * 1.1}`,
            scrub: 1.5,
          },
        });
      });

      // Text reveal with smooth mask effect
      const revealTexts = section.querySelectorAll(".reveal-text");
      revealTexts.forEach((text) => {
        gsap.fromTo(
          text,
          {
            opacity: 0,
            y: 40,
            filter: "blur(10px)"
          },
          {
            opacity: 1,
            y: 0,
            filter: "blur(0px)",
            scrollTrigger: {
              trigger: text,
              containerAnimation: tl,
              start: "left 85%",
              end: "left 55%",
              scrub: true,
            },
          }
        );
      });

      // Accent text special treatment
      const accentTexts = section.querySelectorAll(".accent-text");
      accentTexts.forEach((text) => {
        gsap.fromTo(
          text,
          {
            scale: 0.9,
            opacity: 0,
          },
          {
            scale: 1,
            opacity: 1,
            scrollTrigger: {
              trigger: text,
              containerAnimation: tl,
              start: "left 80%",
              end: "left 50%",
              scrub: true,
            },
          }
        );
      });

      // Stat cards slide in
      const statCards = section.querySelectorAll(".stat-card");
      statCards.forEach((card) => {
        gsap.fromTo(
          card,
          {
            y: 60,
            opacity: 0,
            scale: 0.95
          },
          {
            y: 0,
            opacity: 1,
            scale: 1,
            scrollTrigger: {
              trigger: card,
              containerAnimation: tl,
              start: "left 75%",
              end: "left 45%",
              scrub: true,
            },
          }
        );
      });

      // Platform pills stagger
      const platforms = section.querySelectorAll(".platform-pill");
      platforms.forEach((pill) => {
        gsap.fromTo(
          pill,
          {
            x: 30,
            opacity: 0,
          },
          {
            x: 0,
            opacity: 1,
            scrollTrigger: {
              trigger: pill,
              containerAnimation: tl,
              start: "left 80%",
              end: "left 55%",
              scrub: true,
            },
          }
        );
      });

      // Number counter animations
      const counters = section.querySelectorAll("[data-count]");
      counters.forEach((counter) => {
        const target = parseInt(counter.getAttribute("data-count") || "0");
        const suffix = counter.getAttribute("data-suffix") || "";

        gsap.fromTo(
          { val: 0 },
          { val: target },
          {
            val: target,
            duration: 1.5,
            ease: "power2.out",
            scrollTrigger: {
              trigger: counter,
              containerAnimation: tl,
              start: "left 70%",
              toggleActions: "play none none none",
            },
            onUpdate: function() {
              counter.textContent = Math.round(this.targets()[0].val) + suffix;
            }
          }
        );
      });

      // Decorative line animation
      const lines = section.querySelectorAll(".animated-line");
      lines.forEach((line) => {
        gsap.fromTo(
          line,
          { scaleX: 0 },
          {
            scaleX: 1,
            scrollTrigger: {
              trigger: line,
              containerAnimation: tl,
              start: "left 70%",
              end: "left 40%",
              scrub: true,
            },
          }
        );
      });

    }, section);

    const handleResize = () => ScrollTrigger.refresh();
    window.addEventListener("resize", handleResize);

    return () => {
      ctx.revert();
      window.removeEventListener("resize", handleResize);
    };
  }, [prefersReducedMotion]);

  if (prefersReducedMotion) {
    return (
      <section className={cn("py-20 bg-[#14110F]", className)}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 text-center">
          <h2 className="text-4xl sm:text-5xl font-bold text-white mb-4">
            Expert guidance for your learning journey
          </h2>
          <p className="text-white/60 text-lg">
            Connect with mentors who help you master skills, not just complete tasks.
          </p>
        </div>
      </section>
    );
  }

  return (
    <section
      ref={sectionRef}
      className={cn("relative bg-[#14110F] overflow-hidden", className)}
    >
      {/* Noise texture overlay */}
      <div
        className="absolute inset-0 opacity-[0.03] pointer-events-none z-20"
        style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E")`,
        }}
      />

      <div ref={triggerRef} className="h-screen overflow-hidden relative">

        {/* Ambient background orbs - Coffee Bean palette */}
        <div className="ambient-orb absolute top-[20%] left-[10%] w-[500px] h-[500px] rounded-full bg-[#765341]/[0.07] blur-[120px]" />
        <div className="ambient-orb absolute top-[50%] left-[40%] w-[600px] h-[600px] rounded-full bg-[#A07A65]/[0.05] blur-[150px]" />
        <div className="ambient-orb absolute top-[30%] left-[70%] w-[400px] h-[400px] rounded-full bg-[#E4E1C7]/[0.04] blur-[100px]" />

        {/* Top fade */}
        <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-[#14110F] to-transparent z-10 pointer-events-none" />

        {/* MAIN TEXT TRACK */}
        <div
          ref={textTrackRef}
          className="absolute top-1/2 -translate-y-1/2 left-0 flex items-center whitespace-nowrap"
          style={{ willChange: "transform" }}
        >
          {/* Opening space */}
          <div className="w-[15vw] flex-shrink-0" />

          {/* Section 1: The statement */}
          <div className="flex items-center">
            <span className="reveal-text text-[15vw] sm:text-[12vw] font-black text-white/[0.08] leading-none tracking-[-0.04em]">
              YOUR
            </span>
            <span className="reveal-text text-[15vw] sm:text-[12vw] font-black text-white/[0.08] leading-none tracking-[-0.04em] ml-[2vw]">
              GROWTH
            </span>
          </div>

          <div className="w-[8vw] flex-shrink-0" />

          {/* Section 2: Learning matters */}
          <div className="flex items-center gap-[1.5vw]">
            <span className="reveal-text text-[14vw] sm:text-[11vw] font-black text-white leading-none tracking-[-0.03em]">
              LEARNING
            </span>
            <span className="reveal-text text-[14vw] sm:text-[11vw] font-black text-white/20 leading-none tracking-[-0.03em]">
              THAT
            </span>
            <span className="accent-text text-[14vw] sm:text-[11vw] font-black text-[#765341] leading-none tracking-[-0.03em]">
              MATTERS
            </span>
          </div>

          <div className="w-[6vw] flex-shrink-0" />

          {/* Section 3: Expert guidance */}
          <div className="flex items-center gap-[1.5vw]">
            <span className="reveal-text text-[14vw] sm:text-[11vw] font-black text-white/20 leading-none tracking-[-0.03em]">
              WITH
            </span>
            <span className="reveal-text text-[14vw] sm:text-[11vw] font-black text-white leading-none tracking-[-0.03em]">
              EXPERT
            </span>
            <span className="accent-text text-[14vw] sm:text-[11vw] font-black leading-none tracking-[-0.03em]" style={{
              background: "linear-gradient(135deg, #A07A65 0%, #E4E1C7 100%)",
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent"
            }}>
              GUIDANCE
            </span>
          </div>

          <div className="w-[8vw] flex-shrink-0" />

          {/* Decorative line */}
          <div className="animated-line h-[2px] w-[200px] bg-gradient-to-r from-white/30 to-transparent origin-left" />

          <div className="w-[6vw] flex-shrink-0" />

          {/* Section 4: Subject Areas */}
          <div className="flex items-center gap-4">
            {[
              { name: "Essays", bg: "bg-[#765341]/20", border: "border-[#765341]/30", text: "text-[#A07A65]" },
              { name: "Research", bg: "bg-[#34312D]/20", border: "border-[#34312D]/30", text: "text-[#C4B8A8]" },
              { name: "Coding", bg: "bg-[#A07A65]/20", border: "border-[#A07A65]/30", text: "text-[#E4E1C7]" },
              { name: "Math", bg: "bg-[#E4E1C7]/20", border: "border-[#E4E1C7]/30", text: "text-[#E4E1C7]" },
            ].map((platform) => (
              <div
                key={platform.name}
                className={cn(
                  "platform-pill px-6 py-3 rounded-full border backdrop-blur-sm",
                  platform.bg,
                  platform.border
                )}
              >
                <span className={cn("text-lg sm:text-xl font-semibold", platform.text)}>
                  {platform.name}
                </span>
              </div>
            ))}
          </div>

          <div className="w-[8vw] flex-shrink-0" />

          {/* Section 5: The problem */}
          <div className="flex flex-col items-start gap-3">
            <span className="reveal-text text-[8vw] sm:text-[6vw] font-medium text-white/40 leading-none tracking-tight italic" style={{ fontFamily: "var(--font-inter)" }}>
              skill development
            </span>
            <span className="reveal-text text-[8vw] sm:text-[6vw] font-medium text-white leading-none tracking-tight italic" style={{ fontFamily: "var(--font-inter)" }}>
              made personal
            </span>
          </div>

          <div className="w-[10vw] flex-shrink-0" />

          {/* Section 6: Stats */}
          <div className="flex items-center gap-6">
            <div className="stat-card flex flex-col items-center justify-center w-[180px] h-[180px] rounded-3xl bg-white/[0.03] border border-white/[0.08] backdrop-blur-sm">
              <span className="text-5xl sm:text-6xl font-bold text-white" data-count="500" data-suffix="+">0+</span>
              <span className="text-white/40 text-sm mt-2 uppercase tracking-wider">Expert Mentors</span>
            </div>
            <div className="stat-card flex flex-col items-center justify-center w-[180px] h-[180px] rounded-3xl bg-white/[0.03] border border-white/[0.08] backdrop-blur-sm">
              <span className="text-5xl sm:text-6xl font-bold text-[#A07A65]" data-count="98" data-suffix="%">0%</span>
              <span className="text-white/40 text-sm mt-2 uppercase tracking-wider">Grade Improvement</span>
            </div>
            <div className="stat-card flex flex-col items-center justify-center w-[180px] h-[180px] rounded-3xl bg-white/[0.03] border border-white/[0.08] backdrop-blur-sm">
              <span className="text-5xl sm:text-6xl font-bold text-[#E4E1C7]" data-count="10" data-suffix="K+">0K+</span>
              <span className="text-white/40 text-sm mt-2 uppercase tracking-wider">Students Helped</span>
            </div>
          </div>

          <div className="w-[10vw] flex-shrink-0" />

          {/* Section 7: The turn */}
          <div className="flex items-center gap-[2vw]">
            <span className="reveal-text text-[12vw] sm:text-[10vw] font-black text-white/15 leading-none tracking-[-0.03em]">
              START
            </span>
            <span className="accent-text text-[12vw] sm:text-[10vw] font-black text-[#765341] leading-none tracking-[-0.03em]">
              TODAY
            </span>
          </div>

          <div className="w-[6vw] flex-shrink-0" />

          {/* Section 8: AssignX reveal */}
          <div className="stat-card flex items-center gap-4 px-8 py-5 rounded-full bg-[#765341] shadow-lg shadow-[#765341]/20">
            <div className="w-10 h-10 rounded-full bg-white flex items-center justify-center">
              <span className="text-[#765341] font-bold text-lg">A</span>
            </div>
            <span className="text-white font-bold text-2xl tracking-tight">AssignX</span>
          </div>

          <div className="w-[4vw] flex-shrink-0" />

          {/* Section 9: Value prop */}
          <div className="flex items-center gap-8">
            <div className="flex flex-col gap-1">
              <span className="reveal-text text-[4vw] sm:text-[3vw] font-bold text-white/60 leading-none uppercase tracking-[0.2em]">Learn</span>
              <div className="animated-line h-[3px] w-full bg-white/20 origin-left" />
            </div>
            <div className="flex flex-col gap-1">
              <span className="reveal-text text-[4vw] sm:text-[3vw] font-bold text-white/80 leading-none uppercase tracking-[0.2em]">Grow</span>
              <div className="animated-line h-[3px] w-full bg-[#765341]/40 origin-left" />
            </div>
            <div className="flex flex-col gap-1">
              <span className="reveal-text text-[4vw] sm:text-[3vw] font-bold text-white leading-none uppercase tracking-[0.2em]">Succeed</span>
              <div className="animated-line h-[3px] w-full bg-[#765341] origin-left" />
            </div>
          </div>

          <div className="w-[8vw] flex-shrink-0" />

          {/* Section 10: Closing */}
          <div className="flex items-center gap-8">
            <div className="flex flex-col gap-2">
              <span className="reveal-text text-[6vw] sm:text-[5vw] font-medium text-white/30 leading-none tracking-tight italic" style={{ fontFamily: "var(--font-inter)" }}>
                Your learning journey?
              </span>
              <span className="reveal-text text-[6vw] sm:text-[5vw] font-medium text-white leading-none tracking-tight italic" style={{ fontFamily: "var(--font-inter)" }}>
                Starts here.
              </span>
            </div>

            <a
              href="/signup"
              className="stat-card group flex items-center gap-3 px-8 py-4 rounded-full bg-white text-[#14110F] font-semibold text-lg transition-all hover:scale-105 hover:shadow-xl hover:shadow-white/10"
            >
              <span>Get Started</span>
              <svg className="w-5 h-5 transition-transform group-hover:translate-x-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
              </svg>
            </a>
          </div>

          {/* End spacer */}
          <div className="w-[15vw] flex-shrink-0" />
        </div>

        {/* Progress indicator */}
        <div className="absolute bottom-10 left-1/2 -translate-x-1/2 z-20 flex items-center gap-4">
          <div className="flex items-center gap-2 text-white/30 text-sm font-medium">
            <span className="uppercase tracking-wider">Scroll</span>
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M17 8l4 4m0 0l-4 4m4-4H3" />
            </svg>
          </div>
        </div>

        {/* Edge gradients */}
        <div className="absolute inset-y-0 left-0 w-32 sm:w-48 bg-gradient-to-r from-[#14110F] to-transparent pointer-events-none z-10" />
        <div className="absolute inset-y-0 right-0 w-32 sm:w-48 bg-gradient-to-l from-[#14110F] to-transparent pointer-events-none z-10" />

        {/* Bottom fade */}
        <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-[#14110F] to-transparent z-10 pointer-events-none" />
      </div>
    </section>
  );
}
