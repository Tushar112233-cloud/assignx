"use client";

/**
 * TestimonialsSection - Customer testimonials with parallax cards
 * Features GSAP parallax effects and staggered reveals
 */

import { useEffect, useRef } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { Star, Quote } from "lucide-react";

import { cn } from "@/lib/utils";
import { easings } from "@/lib/gsap/animations";

// Register plugin
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

const testimonials = [
  {
    id: 1,
    content:
      "AssignX transformed my academic experience. The quality of work and attention to detail exceeded my expectations. Highly recommend!",
    author: "Sarah M.",
    role: "Graduate Student",
    university: "Stanford University",
    rating: 5,
    avatar: "SM",
  },
  {
    id: 2,
    content:
      "Fast, reliable, and professional. Got my dissertation review back within 48 hours with incredibly detailed feedback. Game changer!",
    author: "James K.",
    role: "PhD Candidate",
    university: "MIT",
    rating: 5,
    avatar: "JK",
  },
  {
    id: 3,
    content:
      "The tutoring sessions helped me understand complex topics I'd been struggling with for months. Worth every penny.",
    author: "Emily R.",
    role: "Undergraduate",
    university: "UCLA",
    rating: 5,
    avatar: "ER",
  },
  {
    id: 4,
    content:
      "Professional proofreading service that caught errors I completely missed. My paper went from good to publication-ready.",
    author: "Michael T.",
    role: "Researcher",
    university: "Harvard",
    rating: 5,
    avatar: "MT",
  },
  {
    id: 5,
    content:
      "24/7 support is incredible. Had a deadline crisis at 2 AM and they came through. This service is a lifesaver.",
    author: "Lisa P.",
    role: "MBA Student",
    university: "Wharton",
    rating: 5,
    avatar: "LP",
  },
  {
    id: 6,
    content:
      "Best investment in my academic career. The consultation helped me completely restructure my thesis approach.",
    author: "David W.",
    role: "Masters Student",
    university: "Columbia",
    rating: 5,
    avatar: "DW",
  },
];

export function TestimonialsSection() {
  const containerRef = useRef<HTMLElement>(null);
  const headingRef = useRef<HTMLDivElement>(null);
  const cardsRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      // Heading animation
      gsap.fromTo(
        headingRef.current,
        { opacity: 0, y: 50 },
        {
          opacity: 1,
          y: 0,
          duration: 1,
          ease: easings.smooth,
          scrollTrigger: {
            trigger: headingRef.current,
            start: "top 80%",
            toggleActions: "play none none reverse",
          },
        }
      );

      // Cards with parallax effect
      const cards = cardsRef.current?.querySelectorAll(".testimonial-card");
      if (cards) {
        cards.forEach((card, index) => {
          // Initial reveal
          gsap.fromTo(
            card,
            { opacity: 0, y: 80 },
            {
              opacity: 1,
              y: 0,
              duration: 1,
              ease: easings.smooth,
              scrollTrigger: {
                trigger: card,
                start: "top 85%",
                toggleActions: "play none none reverse",
              },
            }
          );

          // Parallax movement
          const speed = index % 2 === 0 ? 30 : -30;
          gsap.to(card, {
            y: speed,
            ease: "none",
            scrollTrigger: {
              trigger: cardsRef.current,
              start: "top bottom",
              end: "bottom top",
              scrub: 1,
            },
          });
        });
      }
    }, containerRef);

    return () => ctx.revert();
  }, []);

  return (
    <section
      ref={containerRef}
      id="testimonials"
      className="py-24 md:py-32 lg:py-40 overflow-hidden bg-white dark:bg-slate-900"
    >
      <div className="container px-6 md:px-8 lg:px-12">
        {/* Heading */}
        <div ref={headingRef} className="text-center max-w-3xl mx-auto mb-16 md:mb-20">
          <span className="inline-block text-sm font-semibold text-indigo-600 dark:text-indigo-400 uppercase tracking-wider mb-4">
            Testimonials
          </span>
          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight mb-6 text-slate-900 dark:text-white">
            Loved by{" "}
            <span className="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
              Thousands
            </span>
          </h2>
          <p className="text-lg md:text-xl text-slate-600 dark:text-slate-300 leading-relaxed">
            Join over 10,000 students and professionals who have transformed
            their academic journey with AssignX.
          </p>
        </div>

        {/* Testimonials grid */}
        <div
          ref={cardsRef}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 md:gap-8"
        >
          {testimonials.map((testimonial) => (
            <div
              key={testimonial.id}
              className={cn(
                "testimonial-card group relative p-6 md:p-8 rounded-2xl md:rounded-3xl",
                "bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700/50",
                "hover:border-indigo-300 dark:hover:border-indigo-500/50",
                "hover:shadow-xl hover:shadow-indigo-500/10",
                "transition-all duration-300"
              )}
            >
              {/* Quote icon */}
              <Quote className="absolute top-6 right-6 md:top-8 md:right-8 size-8 md:size-10 text-indigo-500/10" />

              {/* Rating */}
              <div className="flex gap-1 mb-4">
                {Array.from({ length: testimonial.rating }).map((_, i) => (
                  <Star
                    key={i}
                    className="size-5 fill-yellow-500 text-yellow-500"
                  />
                ))}
              </div>

              {/* Content */}
              <p className="text-slate-600 dark:text-slate-400 mb-6 relative z-10 leading-relaxed">
                "{testimonial.content}"
              </p>

              {/* Author */}
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 md:w-14 md:h-14 rounded-full bg-gradient-to-br from-indigo-500 to-purple-500 flex items-center justify-center text-white font-bold text-lg">
                  {testimonial.avatar}
                </div>
                <div>
                  <p className="font-bold text-slate-900 dark:text-white">{testimonial.author}</p>
                  <p className="text-sm text-slate-500 dark:text-slate-400">
                    {testimonial.role} • {testimonial.university}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
