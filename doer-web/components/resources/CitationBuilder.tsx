'use client'

/**
 * Citation Builder component
 * Generates formatted citations from URLs in various academic styles
 * @module components/resources/CitationBuilder
 */

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Quote,
  Link,
  Copy,
  Check,
  Plus,
  Trash2,
  ArrowLeft,
  FileText,
  History,
  Loader2,
  Sparkles,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { ScrollArea } from '@/components/ui/scroll-area'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { referenceStyles, sourceTypes, generateCitationByStyle, type SourceTypeValue } from './constants'
import type { ReferenceStyleType, Citation } from '@/types/database'
import { cn } from '@/lib/utils'

/**
 * CitationBuilder component props
 */
interface CitationBuilderProps {
  /** Citation history */
  history?: Citation[]
  /** Callback when citation is generated */
  onGenerate?: (url: string, style: ReferenceStyleType) => Promise<string>
  /** Callback when citation is saved */
  onSave?: (citation: Omit<Citation, 'id' | 'doer_id' | 'created_at'>) => void
  /** Callback to go back */
  onBack?: () => void
  /** Additional class name */
  className?: string
}

/**
 * Citation Builder component
 * Generates formatted citations from URLs in various academic styles
 */
export function CitationBuilder({
  history = [],
  onGenerate,
  onSave,
  onBack,
  className,
}: CitationBuilderProps) {
  const [url, setUrl] = useState('')
  const [style, setStyle] = useState<ReferenceStyleType>('APA')
  const [sourceType, setSourceType] = useState<SourceTypeValue | 'other'>('website')
  const [isGenerating, setIsGenerating] = useState(false)
  const [generatedCitation, setGeneratedCitation] = useState<string | null>(null)
  const [citations, setCitations] = useState<string[]>([])
  const [copiedIndex, setCopiedIndex] = useState<number | null>(null)
  const [activeTab, setActiveTab] = useState<'generate' | 'manual' | 'history'>('generate')

  const [manualTitle, setManualTitle] = useState('')
  const [manualAuthor, setManualAuthor] = useState('')
  const [manualYear, setManualYear] = useState('')
  const [manualPublisher, setManualPublisher] = useState('')

  /**
   * Generate citation from URL
   * Uses external onGenerate callback if provided, otherwise generates locally
   */
  const handleGenerate = async () => {
    if (!url.trim()) return

    setIsGenerating(true)
    try {
      let citation: string

      if (onGenerate) {
        citation = await onGenerate(url, style)
      } else {
        await new Promise((resolve) => setTimeout(resolve, 1000))
        const domain = new URL(url).hostname.replace('www.', '')
        const date = new Date().toLocaleDateString('en-US', {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
        })
        citation = generateCitationByStyle(style, { domain, url, date })
      }

      setGeneratedCitation(citation)
    } catch (error) {
      console.error('Error generating citation:', error)
    } finally {
      setIsGenerating(false)
    }
  }

  /**
   * Generate manual citation from form fields
   * Uses shared citation generator utility
   */
  const handleGenerateManual = () => {
    if (!manualTitle.trim()) return

    const citation = generateCitationByStyle(style, {
      title: manualTitle,
      author: manualAuthor || undefined,
      year: manualYear || undefined,
      publisher: manualPublisher || undefined,
    })

    setGeneratedCitation(citation)
  }

  /**
   * Add generated citation to the list
   * Saves citation and resets form fields
   */
  const addToList = () => {
    if (generatedCitation && !citations.includes(generatedCitation)) {
      setCitations([...citations, generatedCitation])
      onSave?.({
        url: url || null,
        style,
        formatted_citation: generatedCitation,
        source_type: sourceType,
        title: manualTitle || null,
        author: manualAuthor || null,
        publication_date: manualYear || null,
        access_date: new Date().toISOString(),
      })
      setGeneratedCitation(null)
      setUrl('')
      setManualTitle('')
      setManualAuthor('')
      setManualYear('')
      setManualPublisher('')
    }
  }

  /**
   * Copy citation text to clipboard
   * @param text - Citation text to copy
   * @param index - Index of citation for UI feedback
   */
  const copyToClipboard = (text: string, index: number) => {
    navigator.clipboard.writeText(text)
    setCopiedIndex(index)
    setTimeout(() => setCopiedIndex(null), 2000)
  }

  /**
   * Remove citation from list
   * @param index - Index of citation to remove
   */
  const removeCitation = (index: number) => {
    setCitations(citations.filter((_, i) => i !== index))
  }

  /**
   * Copy all citations to clipboard
   * Joins citations with double newlines
   */
  const copyAll = () => {
    const allCitations = citations.join('\n\n')
    navigator.clipboard.writeText(allCitations)
    setCopiedIndex(-1)
    setTimeout(() => setCopiedIndex(null), 2000)
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
              <p className="text-xs font-semibold uppercase tracking-wide text-[#4F6CF7]">Reference Desk</p>
              <h2 className="text-2xl font-semibold text-slate-900 flex items-center gap-2">
                <Quote className="h-6 w-6 text-[#4F6CF7]" />
                Citation Builder
              </h2>
              <p className="text-sm text-slate-500">
                Generate properly formatted references in any style.
              </p>
            </div>
          </div>
          <Badge className="bg-[#E6F4FF] text-[#4B9BFF]">Auto format</Badge>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-[minmax(0,1.1fr)_minmax(0,0.9fr)]">
        <Card className="border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
          <CardHeader>
            <CardTitle>Generate Citation</CardTitle>
            <CardDescription>Enter a URL or fill in details manually.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>Reference Style</Label>
              <Select value={style} onValueChange={(v) => setStyle(v as ReferenceStyleType)}>
                <SelectTrigger>
                  <SelectValue placeholder="Select style" />
                </SelectTrigger>
                <SelectContent>
                  {referenceStyles.map((s) => (
                    <SelectItem key={s.value} value={s.value}>
                      <div className="flex flex-col">
                        <span>{s.label}</span>
                        <span className="text-xs text-slate-500">{s.description}</span>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <Tabs value={activeTab} onValueChange={(v) => setActiveTab(v as typeof activeTab)}>
              <TabsList className="grid w-full grid-cols-3 h-11 rounded-full bg-white/85 p-1 shadow-[0_10px_22px_rgba(30,58,138,0.08)]">
                <TabsTrigger value="generate" className="gap-1 rounded-full">
                  <Link className="h-4 w-4" />
                  URL
                </TabsTrigger>
                <TabsTrigger value="manual" className="gap-1 rounded-full">
                  <FileText className="h-4 w-4" />
                  Manual
                </TabsTrigger>
                <TabsTrigger value="history" className="gap-1 rounded-full">
                  <History className="h-4 w-4" />
                  History
                </TabsTrigger>
              </TabsList>

              <TabsContent value="generate" className="space-y-4 mt-4">
                <div className="space-y-2">
                  <Label>Source Type</Label>
                  <div className="flex gap-2 flex-wrap">
                    {sourceTypes.map((type) => {
                      const Icon = type.icon
                      return (
                        <Button
                          key={type.value}
                          variant={sourceType === type.value ? 'default' : 'outline'}
                          size="sm"
                          className="gap-1 rounded-full"
                          onClick={() => setSourceType(type.value as typeof sourceType)}
                        >
                          <Icon className="h-4 w-4" />
                          {type.label}
                        </Button>
                      )
                    })}
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="url">Source URL</Label>
                  <div className="flex gap-2">
                    <Input
                      id="url"
                      type="url"
                      placeholder="https://example.com/article"
                      value={url}
                      onChange={(e) => setUrl(e.target.value)}
                    />
                    <Button
                      onClick={handleGenerate}
                      disabled={!url.trim() || isGenerating}
                      className="rounded-full"
                    >
                      {isGenerating ? (
                        <Loader2 className="h-4 w-4 animate-spin" />
                      ) : (
                        'Generate'
                      )}
                    </Button>
                  </div>
                </div>
              </TabsContent>

              <TabsContent value="manual" className="space-y-4 mt-4">
                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="title">Title *</Label>
                    <Input
                      id="title"
                      placeholder="Title of work"
                      value={manualTitle}
                      onChange={(e) => setManualTitle(e.target.value)}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="author">Author(s)</Label>
                    <Input
                      id="author"
                      placeholder="Last, First M."
                      value={manualAuthor}
                      onChange={(e) => setManualAuthor(e.target.value)}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="year">Year</Label>
                    <Input
                      id="year"
                      placeholder="2024"
                      value={manualYear}
                      onChange={(e) => setManualYear(e.target.value)}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="publisher">Publisher/Source</Label>
                    <Input
                      id="publisher"
                      placeholder="Publisher name"
                      value={manualPublisher}
                      onChange={(e) => setManualPublisher(e.target.value)}
                    />
                  </div>
                </div>
                <Button
                  onClick={handleGenerateManual}
                  disabled={!manualTitle.trim()}
                  className="w-full rounded-full"
                >
                  Generate Citation
                </Button>
              </TabsContent>

              <TabsContent value="history" className="mt-4">
                <ScrollArea className="h-[200px]">
                  {history.length > 0 ? (
                    <div className="space-y-2">
                      {history.map((citation) => (
                        <div
                          key={citation.id}
                          className="p-3 rounded-2xl border border-white/70 bg-white/80 text-sm cursor-pointer hover:bg-white"
                          onClick={() => setGeneratedCitation(citation.formatted_citation)}
                        >
                          <div className="flex items-center justify-between mb-1">
                            <Badge variant="outline" className="text-xs">
                              {citation.style}
                            </Badge>
                            <span className="text-xs text-slate-500">
                              {new Date(citation.created_at).toLocaleDateString()}
                            </span>
                          </div>
                          <p className="line-clamp-2 text-slate-600">{citation.formatted_citation}</p>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-sm text-slate-500 text-center py-8">
                      No citation history yet
                    </p>
                  )}
                </ScrollArea>
              </TabsContent>
            </Tabs>

            <AnimatePresence>
              {generatedCitation && (
                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-2"
                >
                  <Label>Generated Citation</Label>
                  <div className="p-4 rounded-2xl border border-white/70 bg-white/80">
                    <p className="text-sm text-slate-600">{generatedCitation}</p>
                  </div>
                  <div className="flex gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => copyToClipboard(generatedCitation, -2)}
                      className="gap-1"
                    >
                      {copiedIndex === -2 ? (
                        <Check className="h-4 w-4" />
                      ) : (
                        <Copy className="h-4 w-4" />
                      )}
                      Copy
                    </Button>
                    <Button size="sm" onClick={addToList} className="gap-1">
                      <Plus className="h-4 w-4" />
                      Add to List
                    </Button>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </CardContent>
        </Card>

        <div className="space-y-4">
          <Card className="border-none bg-gradient-to-br from-[#EEF2FF] via-[#F3F5FF] to-[#E9FAFA] p-6 shadow-[0_20px_50px_rgba(30,58,138,0.12)]">
            <div className="space-y-2">
              <p className="text-xs font-semibold uppercase tracking-wide text-[#4F6CF7]">Style Preview</p>
              <p className="text-base font-semibold text-slate-900">Current style: {style}</p>
              <p className="text-sm text-slate-500">
                Use consistent formatting across all citations before final submission.
              </p>
            </div>
          </Card>

          <Card className="border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>Your Citations</CardTitle>
                  <CardDescription>
                    {citations.length} citation{citations.length !== 1 ? 's' : ''} collected
                  </CardDescription>
                </div>
                {citations.length > 0 && (
                  <Button variant="outline" size="sm" onClick={copyAll}>
                    {copiedIndex === -1 ? (
                      <Check className="h-4 w-4 mr-1" />
                    ) : (
                      <Copy className="h-4 w-4 mr-1" />
                    )}
                    Copy All
                  </Button>
                )}
              </div>
            </CardHeader>
            <CardContent>
              <ScrollArea className="h-[360px]">
                {citations.length > 0 ? (
                  <div className="space-y-3">
                    {citations.map((citation, index) => (
                      <motion.div
                        key={index}
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        className="group p-4 rounded-2xl border border-white/70 bg-white/80 hover:border-[#B8C4FF] transition-colors"
                      >
                        <div className="flex items-start justify-between gap-2">
                          <p className="text-sm flex-1 text-slate-600">{citation}</p>
                          <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-8 w-8"
                              onClick={() => copyToClipboard(citation, index)}
                            >
                              {copiedIndex === index ? (
                                <Check className="h-4 w-4 text-green-600" />
                              ) : (
                                <Copy className="h-4 w-4" />
                              )}
                            </Button>
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-8 w-8 text-destructive"
                              onClick={() => removeCitation(index)}
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                ) : (
                  <div className="flex flex-col items-center justify-center py-12 text-center">
                    <Quote className="h-12 w-12 text-slate-400 mb-4" />
                    <h3 className="font-medium text-slate-900">No citations yet</h3>
                    <p className="text-sm text-slate-500 mt-1">
                      Generate citations and add them to your list.
                    </p>
                    <div className="mt-4 inline-flex items-center gap-1 text-xs text-slate-500">
                      <Sparkles className="h-3 w-3" />
                      Your citations sync automatically
                    </div>
                  </div>
                )}
              </ScrollArea>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
