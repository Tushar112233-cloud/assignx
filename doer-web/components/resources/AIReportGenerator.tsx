
'use client'

/**
 * AI Report Generator component
 * Checks text for AI-generated content percentage
 * @module components/resources/AIReportGenerator
 */

import { useState } from 'react'
import type React from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Bot,
  Upload,
  FileText,
  CheckCircle2,
  AlertTriangle,
  Loader2,
  ArrowLeft,
  Copy,
  Download,
  RefreshCw,
  Info,
  ShieldCheck,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { Progress } from '@/components/ui/progress'
import { Badge } from '@/components/ui/badge'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { cn } from '@/lib/utils'
import {
  getAIStatusColor,
  getAIStatusMessage,
  getAIBadgeColor,
  getAIProgressColor,
} from './constants'
import type { AIReport } from '@/types/database'

/**
 * AIReportGenerator component props
 */
interface AIReportGeneratorProps {
  /** Callback when check is performed */
  onCheck?: (text: string) => Promise<AIReport>
  /** Callback to go back */
  onBack?: () => void
  /** Additional class name */
  className?: string
}

/**
 * AI Report Generator component
 * Checks text for AI-generated content percentage
 */
export function AIReportGenerator({
  onCheck,
  onBack,
  className,
}: AIReportGeneratorProps) {
  const [inputText, setInputText] = useState('')
  const [isChecking, setIsChecking] = useState(false)
  const [report, setReport] = useState<AIReport | null>(null)
  const [inputMode, setInputMode] = useState<'text' | 'file'>('text')
  const [error, setError] = useState<string | null>(null)

  /** Handle text check */
  const handleCheck = async () => {
    if (!inputText.trim()) {
      setError('Please enter some text to analyze')
      return
    }

    if (inputText.trim().split(/\s+/).length < 50) {
      setError('Please enter at least 50 words for accurate analysis')
      return
    }

    setIsChecking(true)
    setError(null)

    try {
      if (onCheck) {
        const result = await onCheck(inputText)
        setReport(result)
      } else {
        // TODO: Integrate with external AI detection API
        setReport({
          id: 'pending-' + Date.now(),
          doer_id: 'pending',
          project_id: null,
          input_text: inputText,
          file_url: null,
          ai_percentage: 0,
          originality_percentage: 100,
          detailed_breakdown: {
            total_words: inputText.split(/\s+/).length,
            sentences_analyzed: inputText.split(/[.!?]+/).length,
            ai_patterns_detected: 0,
            confidence_score: 0,
          },
          created_at: new Date().toISOString(),
        })
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to analyze text')
    } finally {
      setIsChecking(false)
    }
  }

  /** Handle file upload */
  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (event) => {
      const content = event.target?.result as string
      setInputText(content)
    }
    reader.readAsText(file)
  }

  /** Reset form */
  const handleReset = () => {
    setInputText('')
    setReport(null)
    setError(null)
  }

  /**
   * Copy report summary to clipboard
   * Formats report data as readable text
   */
  const copyReport = () => {
    if (!report) return
    const text = `AI Detection Report
---
AI Content: ${report.ai_percentage}%
Original Content: ${report.originality_percentage}%
Words Analyzed: ${report.detailed_breakdown?.total_words || 'N/A'}
Generated: ${new Date(report.created_at).toLocaleString()}`
    navigator.clipboard.writeText(text)
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
              <p className="text-xs font-semibold uppercase tracking-wide text-[#4F6CF7]">Quality Check</p>
              <h2 className="text-2xl font-semibold text-slate-900 flex items-center gap-2">
                <Bot className="h-6 w-6 text-[#4F6CF7]" />
                AI Report Generator
              </h2>
              <p className="text-sm text-slate-500">
                Scan drafts for AI-generated content and keep originality high.
              </p>
            </div>
          </div>
          <Badge className="bg-[#E6F4FF] text-[#4B9BFF]">Fast scan</Badge>
        </div>
      </div>

      <AnimatePresence mode="wait">
        {!report ? (
          <motion.div
            key="input"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="grid gap-6 lg:grid-cols-[minmax(0,1.1fr)_minmax(0,0.9fr)]"
          >
            <Card className="border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
              <CardHeader>
                <CardTitle>Input Text</CardTitle>
                <CardDescription>Enter or upload the content you want to analyze.</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <Tabs value={inputMode} onValueChange={(v) => setInputMode(v as 'text' | 'file')}>
                  <TabsList className="grid w-full grid-cols-2 max-w-xs h-11 rounded-full bg-white/85 p-1 shadow-[0_10px_22px_rgba(30,58,138,0.08)]">
                    <TabsTrigger value="text" className="gap-2 rounded-full text-sm">
                      <FileText className="h-4 w-4" />
                      Paste Text
                    </TabsTrigger>
                    <TabsTrigger value="file" className="gap-2 rounded-full text-sm">
                      <Upload className="h-4 w-4" />
                      Upload File
                    </TabsTrigger>
                  </TabsList>

                  <TabsContent value="text" className="mt-4">
                    <Textarea
                      placeholder="Paste your text here (minimum 50 words)..."
                      value={inputText}
                      onChange={(e) => setInputText(e.target.value)}
                      className="min-h-[280px] resize-none"
                    />
                  </TabsContent>

                  <TabsContent value="file" className="mt-4">
                    <div className="border-2 border-dashed rounded-2xl p-8 text-center bg-slate-50/80">
                      <Upload className="h-10 w-10 mx-auto text-slate-400 mb-4" />
                      <p className="text-sm text-slate-500 mb-2">
                        Drop your file here or click to browse
                      </p>
                      <p className="text-xs text-slate-500 mb-4">
                        Supported: TXT, DOC, DOCX (Max 5MB)
                      </p>
                      <input
                        type="file"
                        accept=".txt,.doc,.docx"
                        onChange={handleFileUpload}
                        className="hidden"
                        id="file-upload"
                      />
                      <Button
                        variant="outline"
                        onClick={() => document.getElementById('file-upload')?.click()}
                        className="rounded-full"
                      >
                        Choose File
                      </Button>
                    </div>

                    {inputText && (
                      <div className="mt-4 p-4 bg-slate-50/80 rounded-2xl">
                        <p className="text-sm font-medium mb-2">File Content Preview</p>
                        <p className="text-sm text-slate-500 line-clamp-3">
                          {inputText.substring(0, 500)}...
                        </p>
                      </div>
                    )}
                  </TabsContent>
                </Tabs>

                <div className="flex items-center justify-between text-sm text-slate-500">
                  <span>Words: {inputText.trim().split(/\s+/).filter(Boolean).length}</span>
                  <span>Minimum: 50 words</span>
                </div>

                {error && (
                  <Alert variant="destructive">
                    <AlertTriangle className="h-4 w-4" />
                    <AlertDescription>{error}</AlertDescription>
                  </Alert>
                )}

                <div className="flex items-center justify-end gap-2">
                  <Button variant="outline" onClick={handleReset} disabled={!inputText || isChecking}>
                    Clear
                  </Button>
                  <Button
                    onClick={handleCheck}
                    disabled={isChecking || !inputText.trim()}
                    className="gap-2 rounded-full bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] px-5 text-sm font-semibold text-white shadow-[0_16px_35px_rgba(91,124,255,0.35)]"
                  >
                    {isChecking ? (
                      <>
                        <Loader2 className="h-4 w-4 animate-spin" />
                        Analyzing...
                      </>
                    ) : (
                      <>
                        <Bot className="h-4 w-4" />
                        Check AI Content
                      </>
                    )}
                  </Button>
                </div>

                {isChecking && (
                  <div className="space-y-2">
                    <Progress value={66} className="h-2" />
                    <p className="text-xs text-center text-slate-500">Analyzing text patterns...</p>
                  </div>
                )}
              </CardContent>
            </Card>

            <div className="space-y-4">
              <Card className="border-none bg-gradient-to-br from-[#EEF2FF] via-[#F3F5FF] to-[#E9FAFA] p-6 shadow-[0_20px_50px_rgba(30,58,138,0.12)]">
                <div className="space-y-2">
                  <p className="text-xs font-semibold uppercase tracking-wide text-[#4F6CF7]">How it works</p>
                  <p className="text-base font-semibold text-slate-900">Originality insights in seconds</p>
                  <p className="text-sm text-slate-500">
                    We analyze sentence patterns, structure, and phrasing to estimate AI usage.
                  </p>
                </div>
              </Card>
              <Card className="border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
                <CardContent className="p-5 space-y-3">
                  <div className="flex items-center gap-2">
                    <ShieldCheck className="h-4 w-4 text-[#4F6CF7]" />
                    <p className="text-sm font-semibold text-slate-900">Preparation tips</p>
                  </div>
                  <ul className="space-y-2 text-sm text-slate-500">
                    <li>Include your final draft for best accuracy.</li>
                    <li>Run a scan before each submission.</li>
                    <li>Keep AI content below 15% for best results.</li>
                  </ul>
                </CardContent>
              </Card>
              <Alert className="border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
                <Info className="h-4 w-4" />
                <AlertTitle>Tip</AlertTitle>
                <AlertDescription>
                  Save your report for reference when a supervisor requests clarity.
                </AlertDescription>
              </Alert>
            </div>
          </motion.div>
        ) : (
          <motion.div
            key="report"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-6"
          >
            <Card className="border-none bg-white/85 shadow-[0_20px_50px_rgba(30,58,138,0.1)]">
              <CardHeader>
                <CardTitle className="flex items-center justify-between">
                  <span>Analysis Results</span>
                  <Badge variant="outline" className={getAIBadgeColor(report.ai_percentage)}>
                    {getAIStatusMessage(report.ai_percentage)}
                  </Badge>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="text-center p-4 rounded-2xl bg-slate-50/80">
                      <p className="text-sm text-slate-500 mb-1">AI Content</p>
                      <p className={cn('text-4xl font-bold', getAIStatusColor(report.ai_percentage))}>
                        {report.ai_percentage}%
                      </p>
                    </div>
                    <div className="text-center p-4 rounded-2xl bg-slate-50/80">
                      <p className="text-sm text-slate-500 mb-1">Original Content</p>
                      <p className="text-4xl font-bold text-[#4F6CF7]">
                        {report.originality_percentage}%
                      </p>
                    </div>
                  </div>

                <div className="space-y-2">
                  <div className="flex justify-between text-sm text-slate-500">
                    <span>AI Content</span>
                    <span>Original Content</span>
                  </div>
                  <div className="h-4 rounded-full overflow-hidden bg-[#E3E9FF]">
                    <div
                      className={cn('h-full transition-all', getAIProgressColor(report.ai_percentage))}
                      style={{ width: `${report.ai_percentage}%` }}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div className="flex items-center justify-between p-3 rounded-2xl border border-white/70 bg-white/80">
                    <span className="text-slate-500">Words Analyzed</span>
                    <span className="font-medium text-slate-900">
                      {String(report.detailed_breakdown?.total_words ?? 'N/A')}
                    </span>
                  </div>
                  <div className="flex items-center justify-between p-3 rounded-2xl border border-white/70 bg-white/80">
                    <span className="text-slate-500">Sentences</span>
                    <span className="font-medium text-slate-900">
                      {String(report.detailed_breakdown?.sentences_analyzed ?? 'N/A')}
                    </span>
                  </div>
                  <div className="flex items-center justify-between p-3 rounded-2xl border border-white/70 bg-white/80">
                    <span className="text-slate-500">AI Patterns</span>
                    <span className="font-medium text-slate-900">
                      {String(report.detailed_breakdown?.ai_patterns_detected ?? 0)}
                    </span>
                  </div>
                  <div className="flex items-center justify-between p-3 rounded-2xl border border-white/70 bg-white/80">
                    <span className="text-slate-500">Confidence</span>
                    <span className="font-medium text-slate-900">
                      {Math.round((Number(report.detailed_breakdown?.confidence_score) || 0) * 100)}%
                    </span>
                  </div>
                </div>

                {report.ai_percentage > 15 && (
                  <Alert className="border-[#FFE7E1] bg-[#FFF4F0]">
                    <AlertTriangle className="h-4 w-4 text-[#FF8B6A]" />
                    <AlertTitle>Recommendation</AlertTitle>
                    <AlertDescription>
                      {report.ai_percentage > 30
                        ? 'High AI patterns detected. Consider rewriting key sections to improve originality.'
                        : 'Some AI patterns detected. Rephrase flagged sections for a cleaner result.'}
                    </AlertDescription>
                  </Alert>
                )}

                {report.ai_percentage <= 15 && (
                  <Alert className="border-[#E3E9FF] bg-[#EEF2FF]">
                    <CheckCircle2 className="h-4 w-4 text-[#4F6CF7]" />
                    <AlertTitle className="text-[#4F6CF7]">Looking Good</AlertTitle>
                    <AlertDescription>
                      Your content appears to be primarily original. You're ready to submit.
                    </AlertDescription>
                  </Alert>
                )}

                <div className="flex flex-wrap items-center justify-between gap-3 pt-4 border-t border-white/70">
                  <p className="text-xs text-slate-500">
                    Generated: {new Date(report.created_at).toLocaleString()}
                  </p>
                  <div className="flex flex-wrap items-center gap-2">
                    <Button variant="outline" size="sm" onClick={copyReport}>
                      <Copy className="h-4 w-4 mr-1" />
                      Copy
                    </Button>
                    <Button variant="outline" size="sm">
                      <Download className="h-4 w-4 mr-1" />
                      Download
                    </Button>
                    <Button size="sm" onClick={handleReset} className="bg-[#4F6CF7]">
                      <RefreshCw className="h-4 w-4 mr-1" />
                      Check Another
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
