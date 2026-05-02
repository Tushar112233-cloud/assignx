"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useRouter } from "next/navigation";
import { Lightbulb, Layers, Shield, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

const slides = [
  {
    id: 1,
    icon: Lightbulb,
    title: "Expert Project Support",
    description:
      "Get professional help with your academic projects, career documents, and business needs. Our experts deliver quality work on time.",
  },
  {
    id: 2,
    icon: Layers,
    title: "Versatile Services",
    description:
      "From dissertations to resumes, plagiarism checks to expert consultations. We offer a comprehensive range of services tailored to your needs.",
  },
  {
    id: 3,
    icon: Shield,
    title: "Quality Guaranteed",
    description:
      "Every project undergoes rigorous quality checks. Your work is secure, confidential, and delivered with AI & plagiarism reports.",
  },
];

// Slide animation variants with direction awareness
const slideVariants = {
  enter: (direction: number) => ({
    x: direction > 0 ? 300 : -300,
    opacity: 0,
  }),
  center: {
    x: 0,
    opacity: 1,
  },
  exit: (direction: number) => ({
    x: direction < 0 ? 300 : -300,
    opacity: 0,
  }),
};

/**
 * Onboarding carousel with 3 slides
 * Smooth swipe-like animations between slides
 */
export function OnboardingCarousel() {
  const [[currentSlide, direction], setSlide] = useState([0, 0]);
  const router = useRouter();

  const isLastSlide = currentSlide === slides.length - 1;
  const slide = slides[currentSlide];

  const paginate = (newDirection: number) => {
    const nextSlide = currentSlide + newDirection;
    if (nextSlide >= 0 && nextSlide < slides.length) {
      setSlide([nextSlide, newDirection]);
    }
  };

  const goToSlide = (index: number) => {
    const newDirection = index > currentSlide ? 1 : -1;
    setSlide([index, newDirection]);
  };

  const handleNext = () => {
    if (isLastSlide) {
      router.push("/onboarding?step=role");
    } else {
      paginate(1);
    }
  };

  const handleSkip = () => {
    router.push("/onboarding?step=role");
  };

  return (
    <div className="flex min-h-[calc(100vh-4rem)] flex-col px-4">
      {/* Skip button */}
      <div className="flex justify-end py-4">
        <Button variant="ghost" onClick={handleSkip} className="text-muted-foreground">
          Skip
        </Button>
      </div>

      {/* Slides container */}
      <div className="flex flex-1 items-center justify-center overflow-hidden">
        <div className="relative w-full max-w-lg">
          <AnimatePresence initial={false} custom={direction} mode="wait">
            <motion.div
              key={currentSlide}
              custom={direction}
              variants={slideVariants}
              initial="enter"
              animate="center"
              exit="exit"
              transition={{
                x: { type: "spring", stiffness: 300, damping: 30 },
                opacity: { duration: 0.2 },
              }}
              className="flex flex-col items-center text-center"
            >
              {/* Icon container */}
              <motion.div
                className="mb-8 flex h-32 w-32 items-center justify-center rounded-full bg-primary/10"
                initial={{ scale: 0.8 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.1, type: "spring", stiffness: 200 }}
              >
                <slide.icon className="h-16 w-16 text-primary" />
              </motion.div>

              {/* Title */}
              <motion.h2
                className="mb-4 text-2xl font-bold tracking-tight sm:text-3xl"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.15 }}
              >
                {slide.title}
              </motion.h2>

              {/* Description */}
              <motion.p
                className="max-w-md text-muted-foreground"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
              >
                {slide.description}
              </motion.p>
            </motion.div>
          </AnimatePresence>
        </div>
      </div>

      {/* Navigation */}
      <div className="flex flex-col items-center gap-6 py-8">
        {/* Dot indicators */}
        <div className="flex gap-2">
          {slides.map((_, index) => (
            <button
              key={index}
              onClick={() => goToSlide(index)}
              className={cn(
                "h-2 rounded-full transition-all duration-300",
                index === currentSlide
                  ? "w-8 bg-primary"
                  : "w-2 bg-muted-foreground/30 hover:bg-muted-foreground/50"
              )}
            />
          ))}
        </div>

        {/* Action button */}
        <Button size="lg" onClick={handleNext} className="w-full max-w-xs">
          {isLastSlide ? (
            "Get Started"
          ) : (
            <>
              Next <ChevronRight className="ml-2 h-4 w-4" />
            </>
          )}
        </Button>
      </div>
    </div>
  );
}
