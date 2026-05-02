/**
 * @fileoverview Grammar checker component for analyzing text grammar and style.
 * @module components/resources/grammar-checker
 */

"use client"

import { useState, useCallback } from "react"
import {
  FileText,
  Upload,
  Loader2,
  X,
  FileUp,
  RotateCcw,
  AlertCircle,
  CheckCircle2,
  AlertTriangle,
  Lightbulb,
  Sparkles,
} from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Textarea } from "@/components/ui/textarea"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ScrollArea } from "@/components/ui/scroll-area"
import { cn } from "@/lib/utils"
import { checkGrammar, type GrammarCheckResult, type GrammarIssue } from "@/lib/services/content-analysis"

interface GrammarCheckerProps {
  onCheck?: (content: string) => Promise<GrammarCheckResult>
}

function IssueItem({ issue }: { issue: GrammarIssue }) {
  const config = {
    error: { icon: AlertCircle, color: "text-red-600", bg: "bg-red-50 border-red-200" },
    warning: { icon: AlertTriangle, color: "text-amber-600", bg: "bg-amber-50 border-amber-200" },
    suggestion: { icon: Lightbulb, color: "text-[#F97316]", bg: "bg-orange-50 border-orange-200" },
  }
  const c = config[issue.severity]
  const Icon = c.icon

  return (
    <div className={cn("p-4 rounded-xl border bg-white hover:border-orange-200 transition-colors", c.bg)}>
      <div className="flex items-start gap-3">
        <Icon className={cn("h-5 w-5 shrink-0 mt-0.5", c.color)} />
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <Badge variant="outline" className="capitalize text-xs border-gray-200">
              {issue.type}
            </Badge>
            <Badge variant={issue.severity === "error" ? "destructive" : "secondary"} className="text-xs">
              {issue.severity}
            </Badge>
          </div>
          <p className="text-sm font-medium text-[#1C1C1C]">{issue.message}</p>
          <p className="text-xs text-gray-600 mt-1 font-mono bg-gray-50 p-2 rounded">
            &quot;...{issue.context}...&quot;
          </p>
        </div>
      </div>
    </div>
  )
}

function ScoreDisplay({ score }: { score: number }) {
  const getScoreConfig = (s: number) => {
    if (s >= 90) return { color: "text-green-600", bg: "bg-green-100", label: "Excellent" }
    if (s >= 70) return { color: "text-[#F97316]", bg: "bg-orange-100", label: "Good" }
    if (s >= 50) return { color: "text-amber-600", bg: "bg-amber-100", label: "Needs Work" }
    return { color: "text-red-600", bg: "bg-red-100", label: "Poor" }
  }
  const config = getScoreConfig(score)

  return (
    <Card className="bg-white border-gray-200 rounded-xl">
      <CardContent className="pt-6 p-6">
        <div className="flex items-center gap-4">
          <div className={cn("h-20 w-20 rounded-full flex items-center justify-center", config.bg)}>
            <span className={cn("text-3xl font-bold", config.color)}>{score}</span>
          </div>
          <div>
            <p className="text-sm text-gray-600">Grammar Score</p>
            <p className={cn("text-xl font-semibold", config.color)}>{config.label}</p>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

/**
 * Grammar checker component for analyzing text grammar and style issues.
 */
export function GrammarChecker({ onCheck }: GrammarCheckerProps) {
  const [inputMode, setInputMode] = useState<"text" | "file">("text")
  const [textContent, setTextContent] = useState("")
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [isChecking, setIsChecking] = useState(false)
  const [result, setResult] = useState<GrammarCheckResult | null>(null)

  const handleCheck = useCallback(async () => {
    const content = inputMode === "text" ? textContent : ""
    if (!content.trim()) return

    setIsChecking(true)
    try {
      const checkResult = onCheck ? await onCheck(content) : await checkGrammar(content)
      setResult(checkResult)
    } catch (error) {
      console.error("Grammar check failed:", error)
    } finally {
      setIsChecking(false)
    }
  }, [inputMode, textContent, onCheck])

  const handleReset = () => {
    setTextContent("")
    setSelectedFile(null)
    setResult(null)
  }

  const handleFileRead = useCallback(async (file: File) => {
    const text = await file.text()
    setTextContent(text)
    setSelectedFile(file)
  }, [])

  const errorCount = result?.issues.filter(i => i.severity === "error").length || 0
  const warningCount = result?.issues.filter(i => i.severity === "warning").length || 0
  const suggestionCount = result?.issues.filter(i => i.severity === "suggestion").length || 0

  return (
    <div className="space-y-6">
      {/* Input Section */}
      {!result ? (
        <Card className="bg-white border-gray-200 rounded-xl">
          <CardHeader className="p-6">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-lg bg-orange-100 flex items-center justify-center">
                <Sparkles className="h-5 w-5 text-[#F97316]" />
              </div>
              <div>
                <CardTitle className="text-base text-[#1C1C1C] font-bold">Grammar Checker</CardTitle>
                <CardDescription className="text-gray-600">Check for grammar, spelling, and style issues</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent className="space-y-4 p-6">
            <Tabs value={inputMode} onValueChange={(v) => setInputMode(v as "text" | "file")}>
              <TabsList className="grid w-full grid-cols-2 bg-gray-100 p-1 rounded-lg">
                <TabsTrigger
                  value="text"
                  className="data-[state=active]:bg-[#F97316] data-[state=active]:text-white rounded-lg transition-colors"
                >
                  <FileText className="h-4 w-4 mr-2" />Paste Text
                </TabsTrigger>
                <TabsTrigger
                  value="file"
                  className="data-[state=active]:bg-[#F97316] data-[state=active]:text-white rounded-lg transition-colors"
                >
                  <Upload className="h-4 w-4 mr-2" />Upload File
                </TabsTrigger>
              </TabsList>
              <TabsContent value="text" className="mt-4">
                <Textarea
                  placeholder="Paste the text you want to check for grammar issues..."
                  value={textContent}
                  onChange={(e) => setTextContent(e.target.value)}
                  className="min-h-[200px] resize-none border-gray-200 rounded-xl focus:border-orange-300 focus:ring-orange-200"
                />
                <p className="text-xs text-gray-600 mt-2">
                  {textContent.split(/\s+/).filter(Boolean).length} words
                </p>
              </TabsContent>
              <TabsContent value="file" className="mt-4">
                {selectedFile ? (
                  <div className="flex items-center justify-between p-4 rounded-xl border border-gray-200 bg-gray-50">
                    <div className="flex items-center gap-3">
                      <FileText className="h-8 w-8 text-[#F97316]" />
                      <div>
                        <p className="font-medium text-[#1C1C1C]">{selectedFile.name}</p>
                        <p className="text-xs text-gray-600">
                          {(selectedFile.size / 1024).toFixed(1)} KB
                        </p>
                      </div>
                    </div>
                    <Button variant="ghost" size="icon" onClick={() => { setSelectedFile(null); setTextContent("") }} className="hover:bg-orange-50">
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                ) : (
                  <label className="flex flex-col items-center justify-center p-8 border-2 border-dashed border-gray-200 rounded-xl cursor-pointer hover:border-orange-300 hover:bg-orange-50/30 transition-colors">
                    <FileUp className="h-10 w-10 text-[#F97316] mb-3" />
                    <p className="text-sm font-medium text-[#1C1C1C]">Drop your file here or click to upload</p>
                    <p className="text-xs text-gray-600 mt-1">Supports TXT files (max 10MB)</p>
                    <input
                      type="file"
                      className="hidden"
                      accept=".txt"
                      onChange={(e) => e.target.files?.[0] && handleFileRead(e.target.files[0])}
                    />
                  </label>
                )}
              </TabsContent>
            </Tabs>
            <div className="flex gap-3">
              <Button
                className="flex-1 bg-[#F97316] hover:bg-[#EA580C] text-white rounded-xl"
                onClick={handleCheck}
                disabled={isChecking || !textContent.trim()}
              >
                {isChecking ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />Checking...
                  </>
                ) : (
                  <>
                    <Sparkles className="h-4 w-4 mr-2" />Check Grammar
                  </>
                )}
              </Button>
              {textContent && (
                <Button variant="outline" onClick={handleReset} className="rounded-xl border-gray-200 hover:bg-orange-50 hover:border-orange-200">
                  <RotateCcw className="h-4 w-4 mr-2" />Reset
                </Button>
              )}
            </div>
          </CardContent>
        </Card>
      ) : (
        <>
          {/* Results Header */}
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-bold text-[#1C1C1C]">Grammar Report</h3>
            <Button variant="outline" size="sm" onClick={handleReset} className="rounded-xl border-gray-200 hover:bg-orange-50 hover:border-orange-200">
              <RotateCcw className="h-4 w-4 mr-2" />New Check
            </Button>
          </div>

          {/* Score and Stats */}
          <div className="grid gap-4 md:grid-cols-4">
            <ScoreDisplay score={result.score} />
            <Card className="bg-white border-gray-200 rounded-xl">
              <CardContent className="pt-6 p-6">
                <div className="flex items-center gap-3">
                  <div className="h-12 w-12 rounded-full bg-red-100 flex items-center justify-center">
                    <AlertCircle className="h-6 w-6 text-red-600" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-[#1C1C1C]">{errorCount}</p>
                    <p className="text-xs text-gray-600">Errors</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card className="bg-white border-gray-200 rounded-xl">
              <CardContent className="pt-6 p-6">
                <div className="flex items-center gap-3">
                  <div className="h-12 w-12 rounded-full bg-amber-100 flex items-center justify-center">
                    <AlertTriangle className="h-6 w-6 text-amber-600" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-[#1C1C1C]">{warningCount}</p>
                    <p className="text-xs text-gray-600">Warnings</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card className="bg-white border-gray-200 rounded-xl">
              <CardContent className="pt-6 p-6">
                <div className="flex items-center gap-3">
                  <div className="h-12 w-12 rounded-full bg-orange-100 flex items-center justify-center">
                    <Lightbulb className="h-6 w-6 text-[#F97316]" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-[#1C1C1C]">{suggestionCount}</p>
                    <p className="text-xs text-gray-600">Suggestions</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Issues List */}
          {result.issues.length > 0 ? (
            <Card className="bg-white border-gray-200 rounded-xl">
              <CardHeader className="p-6">
                <CardTitle className="text-base text-[#1C1C1C] font-bold">Issues Found ({result.issues.length})</CardTitle>
                <CardDescription className="text-gray-600">Review and fix the issues below</CardDescription>
              </CardHeader>
              <CardContent className="p-6">
                <ScrollArea className="h-[400px]">
                  <div className="space-y-3 pr-4">
                    {result.issues.map((issue) => (
                      <IssueItem key={issue.id} issue={issue} />
                    ))}
                  </div>
                </ScrollArea>
              </CardContent>
            </Card>
          ) : (
            <Card className="bg-white border-gray-200 rounded-xl">
              <CardContent className="pt-6 p-6">
                <div className="flex flex-col items-center justify-center py-8 text-center">
                  <div className="h-16 w-16 rounded-full bg-green-100 flex items-center justify-center mb-4">
                    <CheckCircle2 className="h-8 w-8 text-green-600" />
                  </div>
                  <h3 className="text-lg font-bold text-[#1C1C1C] mb-2">No Issues Found!</h3>
                  <p className="text-sm text-gray-600 max-w-md">
                    Your text appears to be well-written with no obvious grammar or spelling issues.
                  </p>
                </div>
              </CardContent>
            </Card>
          )}
        </>
      )}
    </div>
  )
}
