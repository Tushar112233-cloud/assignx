/**
 * @fileoverview AI content detection component for checking AI-generated text.
 * @module components/resources/ai-detector
 */

"use client"

import { useState, useCallback } from "react"
import { Brain, Upload, FileText, User, Bot, Loader2, FileUp, X, RotateCcw, AlertCircle, HelpCircle, Clock } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"

import { Textarea } from "@/components/ui/textarea"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ScrollArea } from "@/components/ui/scroll-area"

import { cn } from "@/lib/utils"
import { AIDetectionResult, AISegment, AI_VERDICT_CONFIG } from "./types"
// AI detection currently not integrated with external service

interface AIDetectorProps {
  onDetect?: (content: string | File) => Promise<AIDetectionResult>
}

/** Get icon component for verdict type */
const getVerdictIcon = (verdict: AIDetectionResult["overall_verdict"]) => {
  const icons = { human: User, ai_generated: Bot, mixed: Brain, uncertain: HelpCircle }
  return icons[verdict] || HelpCircle
}

/** Segment classification display */
function SegmentItem({ segment }: { segment: AISegment }) {
  const config = {
    human: { bg: "bg-green-50 border-green-200", text: "text-green-700", icon: User, label: "Human Written" },
    ai_generated: { bg: "bg-orange-50 border-orange-200", text: "text-[#F97316]", icon: Bot, label: "AI Generated" },
    mixed: { bg: "bg-orange-50 border-orange-200", text: "text-[#F97316]", icon: Brain, label: "Mixed" },
  }
  const c = config[segment.classification]
  const Icon = c.icon

  return (
    <div className={cn("p-4 rounded-xl border bg-white", c.bg)}>
      <div className="flex items-center justify-between mb-2">
        <div className={cn("flex items-center gap-2 text-sm font-medium", c.text)}>
          <Icon className="h-4 w-4" /><span>{c.label}</span>
        </div>
        <Badge variant="outline" className={c.text}>{segment.probability}%</Badge>
      </div>
      <p className="text-sm text-[#1C1C1C]">{segment.text}</p>
    </div>
  )
}

/** Probability display bar */
function ProbabilityBar({ label, value, color, icon: Icon }: { label: string; value: number; color: string; icon: typeof User }) {
  return (
    <div className="space-y-1.5">
      <div className="flex items-center justify-between text-sm">
        <span className="flex items-center gap-2 text-[#1C1C1C]"><Icon className="h-4 w-4" />{label}</span>
        <span className="font-medium text-[#1C1C1C]">{value}%</span>
      </div>
      <div className="relative h-2 w-full overflow-hidden rounded-full bg-gray-200">
        <div className={cn("h-full transition-all", color)} style={{ width: `${value}%` }} />
      </div>
    </div>
  )
}

/** Coming Soon card */
function ComingSoonCard({ onReset }: { onReset: () => void }) {
  return (
    <Card className="bg-white border-gray-200 rounded-xl">
      <CardContent className="pt-6">
        <div className="flex flex-col items-center justify-center py-8 text-center">
          <div className="h-16 w-16 rounded-full bg-orange-100 flex items-center justify-center mb-4">
            <Clock className="h-8 w-8 text-[#F97316]" />
          </div>
          <h3 className="text-lg font-bold text-[#1C1C1C] mb-2">Coming Soon</h3>
          <p className="text-sm text-gray-600 max-w-md mb-4">
            AI content detection is not yet integrated with an external service.
            This feature will be available once the API integration is complete.
          </p>
          <Button variant="outline" onClick={onReset} className="border-gray-200 hover:border-orange-200 rounded-xl">
            <RotateCcw className="h-4 w-4 mr-2" />Try Again Later
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}

/**
 * AI content detector component for analyzing text for AI-generated content.
 */
export function AIDetector({ onDetect }: AIDetectorProps) {
  const [inputMode, setInputMode] = useState<"text" | "file">("text")
  const [textContent, setTextContent] = useState("")
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [isChecking, setIsChecking] = useState(false)
  const [result, setResult] = useState<AIDetectionResult | null>(null)
  const [showComingSoon, setShowComingSoon] = useState(false)

  const handleCheck = useCallback(async () => {
    const content = inputMode === "text" ? textContent : selectedFile
    if (!content || (inputMode === "text" && !textContent.trim())) return

    setIsChecking(true)
    setShowComingSoon(false)
    try {
      if (onDetect) {
        const res = await onDetect(content)
        setResult(res)
      } else {
        await new Promise((r) => setTimeout(r, 1000))
        // Coming soon - external API integration required
        setShowComingSoon(true)
        setResult(null)
      }
    } catch (error) {
      console.error("AI detection failed:", error)
    } finally {
      setIsChecking(false)
    }
  }, [inputMode, textContent, selectedFile, onDetect])

  const handleReset = () => {
    setTextContent("")
    setSelectedFile(null)
    setResult(null)
    setShowComingSoon(false)
  }

  const handleFileDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    const file = e.dataTransfer.files[0]
    if (file && (file.type.includes("text") || file.name.endsWith(".docx") || file.name.endsWith(".pdf"))) {
      setSelectedFile(file)
    }
  }, [])

  const VerdictIcon = result ? getVerdictIcon(result.overall_verdict) : null
  const verdictConfig = result ? AI_VERDICT_CONFIG[result.overall_verdict] : null

  return (
    <div className="space-y-6">
      {/* Input Section */}
      <Card className="bg-white border-gray-200 rounded-xl">
        <CardHeader className="p-6">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-lg bg-orange-100 flex items-center justify-center">
              <Brain className="h-5 w-5 text-[#F97316]" />
            </div>
            <div>
              <CardTitle className="text-base font-bold text-[#1C1C1C]">AI Content Detector</CardTitle>
              <CardDescription className="text-gray-600">Check if content is AI-generated or human-written</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-4 p-6">
          <Tabs value={inputMode} onValueChange={(v) => setInputMode(v as "text" | "file")}>
            <TabsList className="grid w-full grid-cols-2 bg-gray-100 rounded-lg p-1">
              <TabsTrigger value="text" className="data-[state=active]:bg-[#F97316] data-[state=active]:text-white rounded-lg"><FileText className="h-4 w-4 mr-2" />Paste Text</TabsTrigger>
              <TabsTrigger value="file" className="data-[state=active]:bg-[#F97316] data-[state=active]:text-white rounded-lg"><Upload className="h-4 w-4 mr-2" />Upload File</TabsTrigger>
            </TabsList>
            <TabsContent value="text" className="mt-4">
              <Textarea placeholder="Paste the text you want to check for AI content..." value={textContent} onChange={(e) => setTextContent(e.target.value)} className="min-h-[200px] resize-none border-gray-200 rounded-xl focus:border-orange-200" />
              <p className="text-xs text-gray-600 mt-2">{textContent.split(/\s+/).filter(Boolean).length} words</p>
            </TabsContent>
            <TabsContent value="file" className="mt-4">
              {selectedFile ? (
                <div className="flex items-center justify-between p-4 rounded-xl border border-gray-200 bg-white">
                  <div className="flex items-center gap-3">
                    <FileText className="h-8 w-8 text-[#F97316]" />
                    <div><p className="font-medium text-[#1C1C1C]">{selectedFile.name}</p><p className="text-xs text-gray-600">{(selectedFile.size / 1024).toFixed(1)} KB</p></div>
                  </div>
                  <Button variant="ghost" size="icon" onClick={() => setSelectedFile(null)} className="hover:bg-orange-50"><X className="h-4 w-4" /></Button>
                </div>
              ) : (
                <div className="border-2 border-dashed border-gray-200 rounded-xl p-8 text-center hover:border-orange-200 transition-colors" onDrop={handleFileDrop} onDragOver={(e) => e.preventDefault()}>
                  <FileUp className="h-10 w-10 text-gray-400 mx-auto mb-3" />
                  <p className="text-sm text-[#1C1C1C] mb-2">Drag & drop or click to upload</p>
                  <p className="text-xs text-gray-600">Supports .txt, .docx, .pdf (max 10MB)</p>
                  <input type="file" className="absolute inset-0 opacity-0 cursor-pointer" accept=".txt,.docx,.pdf" onChange={(e) => e.target.files?.[0] && setSelectedFile(e.target.files[0])} />
                </div>
              )}
            </TabsContent>
          </Tabs>
          <div className="flex gap-3">
            <Button className="flex-1 bg-[#F97316] hover:bg-[#EA580C] text-white rounded-xl" onClick={handleCheck} disabled={isChecking || (inputMode === "text" ? !textContent.trim() : !selectedFile)}>
              {isChecking ? <><Loader2 className="h-4 w-4 mr-2 animate-spin" />Analyzing...</> : <><Brain className="h-4 w-4 mr-2" />Check for AI Content</>}
            </Button>
            {(textContent || selectedFile || result || showComingSoon) && <Button variant="outline" onClick={handleReset} className="border-gray-200 hover:border-orange-200 rounded-xl"><RotateCcw className="h-4 w-4 mr-2" />Reset</Button>}
          </div>
        </CardContent>
      </Card>

      {/* Coming Soon Section */}
      {showComingSoon && <ComingSoonCard onReset={handleReset} />}

      {/* Results Section */}
      {result && (
        <Card className="bg-white border-gray-200 rounded-xl">
          <CardHeader className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                {VerdictIcon && <div className={cn("h-12 w-12 rounded-full flex items-center justify-center bg-orange-100")}><VerdictIcon className="h-6 w-6 text-[#F97316]" /></div>}
                <div>
                  <CardTitle className="text-lg font-bold text-[#1C1C1C]">{verdictConfig?.label}</CardTitle>
                  <CardDescription className="text-gray-600">Confidence: {result.confidence_level}</CardDescription>
                </div>
              </div>
              <Badge className="bg-[#F97316] text-white">{result.ai_probability}% AI</Badge>
            </div>
          </CardHeader>
          <CardContent className="space-y-6 p-6">
            {/* Probability Bars */}
            <div className="space-y-4">
              <ProbabilityBar label="Human Written" value={result.human_probability} color="bg-green-500" icon={User} />
              <ProbabilityBar label="AI Generated" value={result.ai_probability} color="bg-[#F97316]" icon={Bot} />
              <ProbabilityBar label="Mixed Content" value={result.mixed_probability} color="bg-[#F97316]" icon={Brain} />
            </div>
            {/* Segment Analysis */}
            {result.segments.length > 0 && (
              <div className="space-y-3">
                <h4 className="font-bold text-[#1C1C1C] flex items-center gap-2"><AlertCircle className="h-4 w-4 text-[#F97316]" />Segment Analysis</h4>
                <ScrollArea className="h-[300px]">
                  <div className="space-y-3 pr-4">
                    {result.segments.map((segment) => <SegmentItem key={segment.id} segment={segment} />)}
                  </div>
                </ScrollArea>
              </div>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  )
}
