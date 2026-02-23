'use client'

import { motion } from 'framer-motion'
import {
  GraduationCap,
  Bot,
  Quote,
  FileText,
  LucideIcon,
  ArrowRight,
  Sparkles,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardTitle, CardHeader } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'

/** Resource item type */
export interface ResourceItem {
  id: string
  title: string
  description: string
  icon: LucideIcon
  category: 'training' | 'tools' | 'templates'
  eyebrow?: string
  meta?: string
  cta?: string
  badge?: string
  isNew?: boolean
  isPremium?: boolean
}

interface ResourcesGridProps {
  /** Callback when a resource is clicked */
  onResourceClick: (resourceId: string) => void
  /** Additional class name */
  className?: string
}

/** Default resources configuration */
const defaultResources: ResourceItem[] = [
  {
    id: 'training-center',
    title: 'Training Center',
    description: 'Learning tracks built for consistent delivery.',
    icon: GraduationCap,
    category: 'training',
    badge: 'Updated',
    eyebrow: 'Learning Path',
    cta: 'Resume learning',
  },
  {
    id: 'ai-report',
    title: 'AI Report Generator',
    description: 'Fast, clear originality checks.',
    icon: Bot,
    category: 'tools',
    isNew: true,
    eyebrow: 'Quality Check',
    cta: 'Analyze draft',
  },
  {
    id: 'citation-builder',
    title: 'Citation Builder',
    description: 'Citations in any format, instantly.',
    icon: Quote,
    category: 'tools',
    eyebrow: 'Reference Desk',
    cta: 'Create citation',
  },
  {
    id: 'templates',
    title: 'Format Templates',
    description: 'Polished templates for every doc.',
    icon: FileText,
    category: 'templates',
    eyebrow: 'Template Vault',
    cta: 'Browse templates',
  },
]

/** Animation variants */
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      type: 'spring' as const,
      stiffness: 100,
      damping: 15,
    },
  },
}

type ResourceStyle = {
  chip: string
  iconBg: string
  glow: string
  accent: string
}

interface ResourceCardBaseProps {
  resource: ResourceItem
  styles: ResourceStyle
  onClick: () => void
}

/**
 * Resources grid component
 * Asymmetric layout with featured cards and quick entries.
 */
export function ResourcesGrid({ onResourceClick, className }: ResourcesGridProps) {
  /** Get category styles */
  const getCategoryStyles = (category: ResourceItem['category']): ResourceStyle => {
    switch (category) {
      case 'training':
        return {
          chip: 'bg-[#E3E9FF] text-[#4F6CF7] border-white/60',
          iconBg: 'bg-[#4F6CF7]',
          glow: 'shadow-[0_16px_35px_rgba(91,124,255,0.2)]',
          accent: 'text-[#4F6CF7]',
        }
      case 'tools':
        return {
          chip: 'bg-[#E6F4FF] text-[#4B9BFF] border-white/60',
          iconBg: 'bg-[#45C7F3]',
          glow: 'shadow-[0_16px_35px_rgba(69,199,243,0.2)]',
          accent: 'text-[#45C7F3]',
        }
      case 'templates':
        return {
          chip: 'bg-[#FFE7E1] text-[#FF8B6A] border-white/60',
          iconBg: 'bg-[#FF9B7A]',
          glow: 'shadow-[0_16px_35px_rgba(255,155,122,0.25)]',
          accent: 'text-[#FF8B6A]',
        }
      default:
        return {
          chip: 'bg-muted',
          iconBg: 'bg-muted',
          glow: '',
          accent: 'text-slate-600',
        }
    }
  }

  const featured = defaultResources.slice(0, 2)
  const compact = defaultResources.slice(2)

  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className={cn('grid gap-8 lg:grid-cols-[1fr_400px] xl:grid-cols-[1fr_420px]', className)}
    >
      {/* Left column - Featured cards */}
      <div className="grid auto-rows-min gap-8">
        {featured.map((resource) => (
          <ResourceFeatureCard
            key={resource.id}
            resource={resource}
            styles={getCategoryStyles(resource.category)}
            onClick={() => onResourceClick(resource.id)}
          />
        ))}
        <ResourceShowcaseCard />
      </div>

      {/* Right column - Compact cards */}
      <div className="grid auto-rows-min gap-8 sm:grid-cols-2 lg:grid-cols-1">
        {compact.map((resource) => (
          <ResourceCompactCard
            key={resource.id}
            resource={resource}
            styles={getCategoryStyles(resource.category)}
            onClick={() => onResourceClick(resource.id)}
          />
        ))}
        <ResourceGuideCard />
      </div>
    </motion.div>
  )
}

/**
 * Featured resource card for primary tools.
 */
function ResourceFeatureCard({ resource, styles, onClick }: ResourceCardBaseProps) {
  const Icon = resource.icon

  return (
    <motion.div variants={itemVariants}>
      <Card
        className={cn(
          'relative overflow-hidden cursor-pointer border-none bg-white/85 transition-all hover:-translate-y-1 hover:shadow-[0_24px_48px_rgba(30,58,138,0.15)]',
          styles.glow
        )}
        onClick={onClick}
      >
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(91,124,255,0.12),transparent_60%)]" />
        <CardContent className="relative p-6">
          <div className="space-y-5">
            {/* Eyebrow and badge */}
            <div className="flex items-center gap-3">
              <Badge variant="outline" className={cn('text-xs font-semibold', styles.chip)}>
                {resource.eyebrow}
              </Badge>
              {resource.isNew && (
                <Badge className="bg-gradient-to-r from-[#5B7CFF] to-[#49C5FF] border-0 text-white text-xs gap-1">
                  <Sparkles className="h-3 w-3" />
                  New
                </Badge>
              )}
            </div>

            {/* Icon, title and description */}
            <div className="flex items-start gap-4">
              <div className={cn('flex-shrink-0 h-14 w-14 rounded-2xl flex items-center justify-center shadow-lg', styles.iconBg)}>
                <Icon className="h-7 w-7 text-white" />
              </div>
              <div className="flex-1 space-y-2">
                <CardTitle className="text-xl font-semibold text-slate-900">{resource.title}</CardTitle>
                <CardDescription className="text-sm leading-relaxed text-slate-500">
                  {resource.description}
                </CardDescription>
              </div>
            </div>

            {/* CTA */}
            <div className={cn('flex items-center gap-2 text-sm font-semibold transition-all hover:gap-3', styles.accent)}>
              {resource.cta}
              <ArrowRight className="h-4 w-4" />
            </div>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  )
}

/**
 * Compact resource card for secondary tools.
 */
function ResourceCompactCard({ resource, styles, onClick }: ResourceCardBaseProps) {
  const Icon = resource.icon

  return (
    <motion.div variants={itemVariants}>
      <Card
        className="cursor-pointer border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] transition-all hover:-translate-y-1 hover:shadow-[0_24px_48px_rgba(30,58,138,0.15)]"
        onClick={onClick}
      >
        <CardContent className="p-6">
          <div className="space-y-5">
            {/* Icon and eyebrow */}
            <div className="flex items-center justify-between">
              <Badge variant="outline" className={cn('text-xs font-semibold', styles.chip)}>
                {resource.eyebrow}
              </Badge>
              <div className={cn('flex-shrink-0 h-12 w-12 rounded-2xl flex items-center justify-center shadow-md', styles.iconBg)}>
                <Icon className="h-6 w-6 text-white" />
              </div>
            </div>

            {/* Title and description */}
            <div className="space-y-2">
              <CardTitle className="text-lg font-semibold text-slate-900">{resource.title}</CardTitle>
              <CardDescription className="text-sm leading-relaxed text-slate-500">
                {resource.description}
              </CardDescription>
            </div>

            {/* CTA */}
            <div className="pt-2 border-t border-slate-100">
              <div className={cn('flex items-center justify-between text-sm')}>
                <span className="text-xs text-slate-400">Quick access</span>
                <span className={cn('font-semibold flex items-center gap-1 transition-all hover:gap-2', styles.accent)}>
                  {resource.cta}
                  <ArrowRight className="h-3.5 w-3.5" />
                </span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  )
}

/**
 * Pulse card for learning highlights.
 */
function ResourceShowcaseCard() {
  return (
    <Card className="relative overflow-hidden border-none bg-gradient-to-br from-[#EEF2FF] via-[#F3F5FF] to-[#E9FAFA] shadow-[0_24px_60px_rgba(30,58,138,0.12)]">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,rgba(107,91,255,0.12),transparent_60%)]" />
      <CardContent className="relative p-6">
        <div className="flex items-center justify-between gap-6">
          <div className="flex-1 space-y-3">
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-[#4F6CF7]">Resource Studio</p>
            <p className="text-lg font-semibold text-slate-900">A calmer workflow for busy days.</p>
            <p className="text-sm leading-relaxed text-slate-500">Keep everything in one place with a softer focus.</p>
          </div>
          <div className="hidden xl:flex flex-shrink-0 items-center justify-center">
            <div className="relative h-28 w-28">
              {/* Subtle floating shapes */}
              <div className="absolute top-2 left-2 h-10 w-10 rounded-full bg-[#E3E9FF] opacity-70 blur-sm" />
              <div className="absolute bottom-3 left-4 h-8 w-8 rounded-2xl bg-[#E6F4FF] opacity-60 blur-sm" />
              <div className="absolute top-4 right-2 h-12 w-12 rounded-full bg-[#FFE7E1] opacity-50 blur-sm" />
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

/**
 * Quick guide card for finishing touches.
 */
function ResourceGuideCard() {
  return (
    <Card className="border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
      <CardContent className="p-6">
        <div className="space-y-4">
          <div className="space-y-2">
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-slate-400">Quick Guide</p>
            <p className="text-lg font-semibold text-slate-900">Finish line checklist</p>
          </div>
          <ul className="space-y-3 text-sm text-slate-600">
            <li className="flex items-start gap-2">
              <span className="flex-shrink-0 mt-0.5 h-1.5 w-1.5 rounded-full bg-[#4F6CF7]" />
              <span>Run AI report before submitting</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="flex-shrink-0 mt-0.5 h-1.5 w-1.5 rounded-full bg-[#45C7F3]" />
              <span>Verify citations for every source</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="flex-shrink-0 mt-0.5 h-1.5 w-1.5 rounded-full bg-[#FF8B6A]" />
              <span>Use templates to match format rules</span>
            </li>
          </ul>
        </div>
      </CardContent>
    </Card>
  )
}

/**
 * Single resource card component
 * Can be used independently
 */
interface ResourceCardProps {
  resource: ResourceItem
  onClick: () => void
  className?: string
}

export function ResourceCard({ resource, onClick, className }: ResourceCardProps) {
  const Icon = resource.icon

  const getCategoryStyles = (category: ResourceItem['category']) => {
    switch (category) {
      case 'training':
        return {
          iconBg: 'bg-[#4F6CF7]',
        }
      case 'tools':
        return {
          iconBg: 'bg-[#45C7F3]',
        }
      case 'templates':
        return {
          iconBg: 'bg-[#FF9B7A]',
        }
      default:
        return {
          iconBg: 'bg-muted',
        }
    }
  }

  const styles = getCategoryStyles(resource.category)

  return (
    <Card
      className={cn(
        'cursor-pointer transition-all duration-300 hover:shadow-[0_16px_35px_rgba(30,58,138,0.12)] hover:-translate-y-0.5 group border-none bg-white/85',
        className
      )}
      onClick={onClick}
    >
      <CardHeader className="pb-3">
        <div
          className={cn(
            'w-12 h-12 rounded-xl flex items-center justify-center mb-3 shadow-md',
            styles.iconBg
          )}
        >
          <Icon className="h-6 w-6 text-white" />
        </div>
        <CardTitle className="text-base group-hover:text-[#4F6CF7] transition-colors">
          {resource.title}
        </CardTitle>
      </CardHeader>
      <CardContent className="pt-0">
        <CardDescription className="text-sm line-clamp-2 text-slate-500">
          {resource.description}
        </CardDescription>
      </CardContent>
    </Card>
  )
}
