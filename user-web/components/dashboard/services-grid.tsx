"use client";

/**
 * @fileoverview Premium Services Grid Component
 *
 * Redesigned with glassmorphism cards, hover effects,
 * and premium styling matching the SAAS dashboard.
 */

import { memo } from "react";
import Link from "next/link";
import { motion, useReducedMotion } from "framer-motion";
import { ArrowRight, Sparkles } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { services } from "@/lib/data/services";
import type { Service } from "@/lib/data/services";

// Animation configuration
const EASE = [0.16, 1, 0.3, 1] as const;

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.1,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
      ease: EASE,
    },
  },
};

/**
 * Check if a URL is external
 */
const isExternalUrl = (url: string): boolean => {
  return url.startsWith("http://") || url.startsWith("https://");
};

/**
 * Premium Service Card Component
 */
const ServiceCard = memo(function ServiceCard({ service }: { service: Service }) {
  const prefersReducedMotion = useReducedMotion();

  // Determine the wrapper component based on state and URL type
  const isExternal = isExternalUrl(service.href);
  const cardClassName = cn(
    "dashboard-service-card block h-full",
    service.disabled && "cursor-not-allowed opacity-50"
  );

  const cardContent = (
    <>
      {/* Icon */}
      <div
        className={cn(
          "dashboard-service-card-icon",
          service.color
        )}
      >
        <service.icon className="h-6 w-6" />
      </div>

      {/* Badge */}
      {service.badge && (
        <Badge
          variant={service.disabled ? "outline" : "secondary"}
          className={cn(
            "absolute top-4 right-4 text-[10px] font-medium px-2.5 py-0.5",
            !service.disabled && "bg-primary/10 text-primary border-0"
          )}
        >
          {service.badge}
        </Badge>
      )}

      {/* Content */}
      <h3 className="dashboard-service-card-title">{service.title}</h3>
      <p className="dashboard-service-card-description line-clamp-2">
        {service.description}
      </p>

      {/* Arrow */}
      {!service.disabled && (
        <div className="dashboard-service-card-arrow">
          <ArrowRight className="h-4 w-4" />
        </div>
      )}
    </>
  );

  return (
    <motion.div
      variants={prefersReducedMotion ? {} : itemVariants}
      whileHover={prefersReducedMotion || service.disabled ? {} : { y: -4 }}
      transition={{ duration: 0.3 }}
    >
      {service.disabled ? (
        <div className={cardClassName}>{cardContent}</div>
      ) : isExternal ? (
        <a
          href={service.href}
          target="_blank"
          rel="noopener noreferrer"
          className={cardClassName}
        >
          {cardContent}
        </a>
      ) : (
        <Link href={service.href} className={cardClassName}>
          {cardContent}
        </Link>
      )}
    </motion.div>
  );
});

/**
 * Services grid component with premium design
 */
export function ServicesGrid() {
  const prefersReducedMotion = useReducedMotion();

  return (
    <section className="dashboard-section">
      {/* Section header */}
      <div className="dashboard-section-header">
        <div className="dashboard-section-icon">
          <Sparkles className="h-5 w-5 text-primary" />
        </div>
        <div>
          <h2 className="dashboard-section-title">Quick Actions</h2>
          <p className="dashboard-section-subtitle">Choose what you need help with</p>
        </div>
      </div>

      {/* Services grid */}
      <motion.div
        variants={prefersReducedMotion ? {} : containerVariants}
        initial="hidden"
        animate="visible"
        className="grid gap-4 sm:grid-cols-2"
      >
        {services.map((service) => (
          <ServiceCard key={service.id} service={service} />
        ))}
      </motion.div>
    </section>
  );
}
