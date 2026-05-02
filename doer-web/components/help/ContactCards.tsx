"use client";

import React from "react";
import { MessageSquare, Mail, Ticket, BookOpen, ArrowRight } from "lucide-react";

interface ContactCard {
  icon: React.ElementType;
  iconBgColor: string;
  iconColor: string;
  title: string;
  description: string;
  badge?: string;
  badgeBgColor?: string;
  badgeTextColor?: string;
  ctaText: string;
  ctaAction: () => void;
  themeColor: string;
}

export const ContactCards: React.FC = () => {
  const cards: ContactCard[] = [
    {
      icon: MessageSquare,
      iconBgColor: "bg-[#4F6CF7]",
      iconColor: "text-white",
      title: "Live Chat",
      description: "Chat with our support team",
      badge: "Online now",
      badgeBgColor: "bg-emerald-100",
      badgeTextColor: "text-emerald-700",
      ctaText: "Start chat",
      ctaAction: () => {
        // TODO: Implement live chat functionality
      },
      themeColor: "hover:border-[#4F6CF7]/30",
    },
    {
      icon: Mail,
      iconBgColor: "bg-[#0D9488]",
      iconColor: "text-white",
      title: "Email Us",
      description: "Get response within 24 hours",
      ctaText: "Send email",
      ctaAction: () => {
        window.location.href = "mailto:support@assignx.com";
      },
      themeColor: "hover:border-[#0D9488]/30",
    },
    {
      icon: Ticket,
      iconBgColor: "bg-[#FF8B6A]",
      iconColor: "text-white",
      title: "Submit a Ticket",
      description: "Detailed issue tracking",
      ctaText: "Create ticket",
      ctaAction: () => {
        // TODO: Implement ticket submission functionality
      },
      themeColor: "hover:border-[#FF8B6A]/30",
    },
    {
      icon: BookOpen,
      iconBgColor: "bg-[#6B5BFF]",
      iconColor: "text-white",
      title: "Documentation",
      description: "Comprehensive guides",
      ctaText: "Browse docs",
      ctaAction: () => {
        // TODO: Navigate to documentation page
      },
      themeColor: "hover:border-[#6B5BFF]/30",
    },
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
      {cards.map((card, index) => {
        const IconComponent = card.icon;

        return (
          <div
            key={index}
            className={`
              relative group
              bg-white/85 backdrop-blur-sm
              rounded-3xl
              shadow-[0_16px_35px_rgba(30,58,138,0.08)]
              hover:shadow-[0_24px_60px_rgba(30,58,138,0.12)]
              border border-gray-100
              ${card.themeColor}
              transition-all duration-300
              hover:-translate-y-1
              p-8
              cursor-pointer
            `}
            onClick={card.ctaAction}
          >
            {/* Badge (if exists) */}
            {card.badge && (
              <div className="absolute top-6 right-6">
                <span
                  className={`
                    inline-flex items-center
                    px-3 py-1
                    rounded-full
                    text-xs font-medium
                    ${card.badgeBgColor}
                    ${card.badgeTextColor}
                  `}
                >
                  <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full mr-2 animate-pulse" />
                  {card.badge}
                </span>
              </div>
            )}

            {/* Icon */}
            <div
              className={`
                inline-flex items-center justify-center
                w-14 h-14
                rounded-2xl
                ${card.iconBgColor}
                mb-6
                transition-transform duration-300
                group-hover:scale-110
              `}
            >
              <IconComponent className={`h-7 w-7 ${card.iconColor}`} />
            </div>

            {/* Title */}
            <h3 className="text-xl font-semibold text-gray-900 mb-3">
              {card.title}
            </h3>

            {/* Description */}
            <p className="text-gray-600 text-sm mb-6 leading-relaxed">
              {card.description}
            </p>

            {/* CTA Button */}
            <button
              className={`
                inline-flex items-center
                text-sm font-medium
                text-gray-900
                group-hover:text-[#4F6CF7]
                transition-colors duration-300
              `}
            >
              {card.ctaText}
              <ArrowRight
                className={`
                  ml-2 h-4 w-4
                  transition-transform duration-300
                  group-hover:translate-x-1
                `}
              />
            </button>
          </div>
        );
      })}
    </div>
  );
};

export default ContactCards;
