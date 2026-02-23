"use client";

import Link from "next/link";
import {
  BookOpen,
  CreditCard,
  FileText,
  Award,
  Shield,
  Smartphone,
  Video,
  Lightbulb,
  Users,
  FileCheck,
  ArrowRight,
} from "lucide-react";

interface LinkCardProps {
  title: string;
  href: string;
  icon: React.ReactNode;
  iconBgColor: string;
}

const LinkCard = ({ title, href, icon, iconBgColor }: LinkCardProps) => {
  return (
    <Link
      href={href}
      className="group relative flex items-center gap-4 rounded-3xl border border-slate-200/60 bg-white/85 p-4 backdrop-blur-sm transition-all duration-300 hover:border-slate-300 hover:bg-white hover:shadow-[0_16px_35px_rgba(30,58,138,0.08)] hover:-translate-y-0.5"
    >
      {/* Icon */}
      <div
        className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${iconBgColor} transition-transform duration-300 group-hover:scale-110`}
      >
        {icon}
      </div>

      {/* Content */}
      <div className="flex flex-1 items-center justify-between">
        <span className="text-sm font-medium text-slate-700 transition-colors duration-300 group-hover:text-slate-900">
          {title}
        </span>
        <ArrowRight className="h-4 w-4 text-slate-400 transition-all duration-300 group-hover:translate-x-1 group-hover:text-slate-600" />
      </div>

      {/* Hover Glow Effect */}
      <div className="pointer-events-none absolute inset-0 rounded-3xl opacity-0 transition-opacity duration-300 group-hover:opacity-100 bg-gradient-to-r from-blue-500/5 via-teal-500/5 to-orange-500/5" />
    </Link>
  );
};

export function QuickLinks() {
  const popularTopics = [
    {
      title: "Getting Started Guide",
      href: "/help/getting-started",
      icon: <BookOpen className="h-5 w-5 text-[#4F6CF7]" />,
      iconBgColor: "bg-[#E3E9FF]",
    },
    {
      title: "Payment Methods",
      href: "/help/payment-methods",
      icon: <CreditCard className="h-5 w-5 text-[#0D9488]" />,
      iconBgColor: "bg-[#E9FAFA]",
    },
    {
      title: "Project Guidelines",
      href: "/help/project-guidelines",
      icon: <FileText className="h-5 w-5 text-[#FF8B6A]" />,
      iconBgColor: "bg-[#FFF1EC]",
    },
    {
      title: "Quality Standards",
      href: "/help/quality-standards",
      icon: <Award className="h-5 w-5 text-[#4F6CF7]" />,
      iconBgColor: "bg-[#E3E9FF]",
    },
    {
      title: "Account Security",
      href: "/help/account-security",
      icon: <Shield className="h-5 w-5 text-[#0D9488]" />,
      iconBgColor: "bg-[#E9FAFA]",
    },
    {
      title: "Mobile App",
      href: "/help/mobile-app",
      icon: <Smartphone className="h-5 w-5 text-[#FF8B6A]" />,
      iconBgColor: "bg-[#FFF1EC]",
    },
  ];

  const resources = [
    {
      title: "Video Tutorials",
      href: "/help/video-tutorials",
      icon: <Video className="h-5 w-5 text-[#4F6CF7]" />,
      iconBgColor: "bg-[#E3E9FF]",
    },
    {
      title: "Best Practices",
      href: "/help/best-practices",
      icon: <Lightbulb className="h-5 w-5 text-[#0D9488]" />,
      iconBgColor: "bg-[#E9FAFA]",
    },
    {
      title: "Community Forum",
      href: "/help/community-forum",
      icon: <Users className="h-5 w-5 text-[#FF8B6A]" />,
      iconBgColor: "bg-[#FFF1EC]",
    },
    {
      title: "Terms & Policies",
      href: "/help/terms-policies",
      icon: <FileCheck className="h-5 w-5 text-[#4F6CF7]" />,
      iconBgColor: "bg-[#E3E9FF]",
    },
  ];

  return (
    <div className="space-y-8">
      {/* Popular Topics Section */}
      <div className="space-y-4">
        <div className="space-y-1">
          <h3 className="text-xs uppercase tracking-[0.2em] text-slate-400 font-medium">
            Popular Topics
          </h3>
          <h2 className="text-xl font-semibold text-slate-900">
            Frequently Accessed Articles
          </h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {popularTopics.map((topic) => (
            <LinkCard
              key={topic.title}
              title={topic.title}
              href={topic.href}
              icon={topic.icon}
              iconBgColor={topic.iconBgColor}
            />
          ))}
        </div>
      </div>

      {/* Resources Section */}
      <div className="space-y-4">
        <div className="space-y-1">
          <h3 className="text-xs uppercase tracking-[0.2em] text-slate-400 font-medium">
            Resources
          </h3>
          <h2 className="text-xl font-semibold text-slate-900">
            Learning & Community
          </h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {resources.map((resource) => (
            <LinkCard
              key={resource.title}
              title={resource.title}
              href={resource.href}
              icon={resource.icon}
              iconBgColor={resource.iconBgColor}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

export default QuickLinks;
