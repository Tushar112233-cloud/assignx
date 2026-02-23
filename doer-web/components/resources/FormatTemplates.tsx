'use client'

/**
 * Format Templates component
 * Displays downloadable document templates organized by category
 * @module components/resources/FormatTemplates
 */

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  FileText,
  Presentation,
  Table,
  Download,
  Eye,
  ArrowLeft,
  Search,
  FileType,
  CheckCircle2,
  Loader2,
  Sparkles,
} from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { cn } from '@/lib/utils'
import { mockTemplates as defaultMockTemplates, categoryColors, formatFileSize } from './constants'
import type { FormatTemplate, TemplateCategory } from '@/types/database'

/**
 * FormatTemplates component props
 */
interface FormatTemplatesProps {
  /** Available templates */
  templates?: FormatTemplate[]
  /** Loading state */
  isLoading?: boolean
  /** Callback when template is downloaded */
  onDownload?: (templateId: string) => void
  /** Callback to go back */
  onBack?: () => void
  /** Additional class name */
  className?: string
}

/**
 * Format Templates component
 * Displays downloadable document templates organized by category
 */
export function FormatTemplates({
  templates = defaultMockTemplates,
  isLoading,
  onDownload,
  onBack,
  className,
}: FormatTemplatesProps) {
  const [searchQuery, setSearchQuery] = useState('')
  const [activeCategory, setActiveCategory] = useState<TemplateCategory | 'all'>('all')
  const [previewTemplate, setPreviewTemplate] = useState<FormatTemplate | null>(null)
  const [downloadingId, setDownloadingId] = useState<string | null>(null)
  const [downloadedIds, setDownloadedIds] = useState<string[]>([])

  /**
   * Get icon component for template category
   * @param category - Template category
   * @returns Lucide icon component
   */
  const getCategoryIcon = (category: TemplateCategory) => {
    switch (category) {
      case 'document':
        return FileText
      case 'presentation':
        return Presentation
      case 'spreadsheet':
        return Table
      default:
        return FileType
    }
  }

  /**
   * Get color classes for template category
   * Uses shared categoryColors from constants
   * @param category - Template category
   * @returns Tailwind color classes
   */
  const getCategoryColor = (category: TemplateCategory) => {
    return categoryColors[category] || 'bg-muted'
  }

  /** Filter templates based on search and category */
  const filteredTemplates = templates.filter((template) => {
    const matchesSearch = template.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (template.description?.toLowerCase().includes(searchQuery.toLowerCase()) ?? false)
    const matchesCategory = activeCategory === 'all' || template.category === activeCategory
    return matchesSearch && matchesCategory
  })

  /**
   * Handle template download
   * Triggers file download and tracks downloaded state
   * @param template - Template to download
   */
  const handleDownload = async (template: FormatTemplate) => {
    setDownloadingId(template.id)
    try {
      await new Promise((resolve) => setTimeout(resolve, 1000))
      onDownload?.(template.id)
      setDownloadedIds([...downloadedIds, template.id])

      const link = document.createElement('a')
      link.href = template.file_url
      link.download = template.name
      link.click()
    } finally {
      setDownloadingId(null)
    }
  }

  /** Category statistics for tabs */
  const categoryStats = {
    all: templates.length,
    document: templates.filter((t) => t.category === 'document').length,
    presentation: templates.filter((t) => t.category === 'presentation').length,
    spreadsheet: templates.filter((t) => t.category === 'spreadsheet').length,
  }

  return (
    <div className={cn('space-y-6', className)}>
      <div className="rounded-[28px] bg-white/85 p-6 shadow-[0_24px_60px_rgba(30,58,138,0.12)]">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            {onBack && (
              <Button variant="ghost" size="icon" onClick={onBack} className="bg-white/70">
                <ArrowLeft className="h-5 w-5" />
              </Button>
            )}
            <div>
              <p className="text-xs font-semibold uppercase tracking-wide text-[#4F6CF7]">Template Vault</p>
              <h2 className="text-2xl font-semibold text-slate-900 flex items-center gap-2">
                <FileText className="h-6 w-6 text-[#4F6CF7]" />
                Format Templates
              </h2>
              <p className="text-sm text-slate-500">
                Download professionally formatted templates for your work.
              </p>
            </div>
          </div>
          <Badge className="bg-[#E6F4FF] text-[#4B9BFF]">{templates.length} templates</Badge>
        </div>

        <div className="mt-6 flex flex-col sm:flex-row gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
            <Input
              placeholder="Search templates..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-9"
            />
          </div>
          <Button variant="outline" className="rounded-full">
            <Sparkles className="h-4 w-4 mr-2 text-[#4F6CF7]" />
            Most downloaded
          </Button>
        </div>
      </div>

      <Tabs value={activeCategory} onValueChange={(v) => setActiveCategory(v as typeof activeCategory)}>
        <TabsList className="grid w-full grid-cols-4 max-w-xl h-11 rounded-full bg-white/85 p-1 shadow-[0_10px_22px_rgba(30,58,138,0.08)]">
          <TabsTrigger value="all" className="gap-1 rounded-full">
            All
            <Badge variant="secondary" className="ml-1 text-xs">
              {categoryStats.all}
            </Badge>
          </TabsTrigger>
          <TabsTrigger value="document" className="gap-1 rounded-full">
            <FileText className="h-4 w-4" />
            <span className="hidden sm:inline">Docs</span>
          </TabsTrigger>
          <TabsTrigger value="presentation" className="gap-1 rounded-full">
            <Presentation className="h-4 w-4" />
            <span className="hidden sm:inline">Slides</span>
          </TabsTrigger>
          <TabsTrigger value="spreadsheet" className="gap-1 rounded-full">
            <Table className="h-4 w-4" />
            <span className="hidden sm:inline">Sheets</span>
          </TabsTrigger>
        </TabsList>
      </Tabs>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        <AnimatePresence>
          {filteredTemplates.map((template, index) => {
            const CategoryIcon = getCategoryIcon(template.category)
            const isDownloading = downloadingId === template.id
            const isDownloaded = downloadedIds.includes(template.id)

            return (
              <motion.div
                key={template.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95 }}
                transition={{ delay: index * 0.05 }}
              >
                <Card className="group overflow-hidden h-full flex flex-col border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] transition-all hover:-translate-y-1">
                  <div
                    className="aspect-[4/3] bg-slate-50/80 relative cursor-pointer overflow-hidden"
                    onClick={() => setPreviewTemplate(template)}
                  >
                    {template.preview_url ? (
                      <img
                        src={template.preview_url}
                        alt={template.name}
                        className="object-cover w-full h-full group-hover:scale-105 transition-transform"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <CategoryIcon className="h-16 w-16 text-slate-300" />
                      </div>
                    )}
                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/30 transition-colors flex items-center justify-center opacity-0 group-hover:opacity-100">
                      <Button variant="secondary" size="sm" className="gap-1">
                        <Eye className="h-4 w-4" />
                        Preview
                      </Button>
                    </div>
                  </div>

                  <CardContent className="flex-1 flex flex-col p-4">
                    <div className="flex items-start justify-between gap-2 mb-2">
                      <Badge
                        variant="outline"
                        className={cn('capitalize text-xs', getCategoryColor(template.category))}
                      >
                        <CategoryIcon className="h-3 w-3 mr-1" />
                        {template.category}
                      </Badge>
                      <span className="text-xs text-slate-500">
                        {formatFileSize(template.file_size)}
                      </span>
                    </div>

                    <h3 className="font-medium line-clamp-1 mb-1 text-slate-900">{template.name}</h3>
                    <p className="text-sm text-slate-500 line-clamp-2 flex-1">
                      {template.description}
                    </p>

                    <div className="flex items-center justify-between mt-4 pt-4 border-t border-white/70">
                      <span className="text-xs text-slate-500">
                        {template.download_count.toLocaleString()} downloads
                      </span>
                      <Button
                        size="sm"
                        variant={isDownloaded ? 'outline' : 'default'}
                        disabled={isDownloading}
                        onClick={() => handleDownload(template)}
                        className="gap-1 rounded-full"
                      >
                        {isDownloading ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : isDownloaded ? (
                          <>
                            <CheckCircle2 className="h-4 w-4 text-[#4F6CF7]" />
                            Downloaded
                          </>
                        ) : (
                          <>
                            <Download className="h-4 w-4" />
                            Download
                          </>
                        )}
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            )
          })}
        </AnimatePresence>
      </div>

      {filteredTemplates.length === 0 && !isLoading && (
        <Card className="p-8 text-center border-none bg-white/85">
          <FileText className="h-12 w-12 mx-auto text-slate-400 mb-4" />
          <h3 className="font-medium text-slate-900">No templates found</h3>
          <p className="text-sm text-slate-500 mt-1">
            Try adjusting your search or filter criteria.
          </p>
          <Button
            variant="outline"
            className="mt-4"
            onClick={() => {
              setSearchQuery('')
              setActiveCategory('all')
            }}
          >
            Clear Filters
          </Button>
        </Card>
      )}

      <Dialog open={!!previewTemplate} onOpenChange={() => setPreviewTemplate(null)}>
        <DialogContent className="max-w-4xl">
          <DialogHeader>
            <DialogTitle>{previewTemplate?.name}</DialogTitle>
            <DialogDescription>{previewTemplate?.description}</DialogDescription>
          </DialogHeader>
          <div className="aspect-[4/3] bg-slate-50/80 rounded-2xl overflow-hidden">
            {previewTemplate?.preview_url ? (
              <img
                src={previewTemplate.preview_url}
                alt={previewTemplate.name}
                className="object-contain w-full h-full"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <FileText className="h-24 w-24 text-slate-300" />
              </div>
            )}
          </div>
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div className="flex items-center gap-4 text-sm text-slate-500">
              <span>{formatFileSize(previewTemplate?.file_size ?? 0)}</span>
              <span>{previewTemplate?.download_count.toLocaleString()} downloads</span>
            </div>
            <Button
              onClick={() => {
                if (previewTemplate) handleDownload(previewTemplate)
                setPreviewTemplate(null)
              }}
              className="gap-2 rounded-full"
            >
              <Download className="h-4 w-4" />
              Download Template
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
