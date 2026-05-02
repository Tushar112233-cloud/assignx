/**
 * @fileoverview Built-in content analysis services for AI detection and plagiarism checking.
 * These provide basic analysis when external APIs are not configured.
 * @module lib/services/content-analysis
 */

import type { AIDetectionResult, AISegment, PlagiarismCheckResult, PlagiarismMatch } from "@/components/resources/types"

/**
 * Analyzes text for AI-generated content patterns.
 * Uses heuristic analysis of writing patterns commonly found in AI-generated text.
 */
export async function analyzeForAI(content: string): Promise<AIDetectionResult> {
  // Normalize content
  const text = content.trim()
  const sentences = text.split(/[.!?]+/).filter(s => s.trim().length > 0)
  const words = text.split(/\s+/).filter(w => w.length > 0)

  // AI detection heuristics
  const metrics = {
    // Average sentence length (AI tends to have consistent length)
    avgSentenceLength: words.length / Math.max(sentences.length, 1),
    sentenceLengthVariance: calculateVariance(sentences.map(s => s.split(/\s+/).length)),

    // Repetitive phrase patterns
    repetitivePatterns: detectRepetitivePatterns(text),

    // Transition word frequency (AI uses many)
    transitionWordRatio: countTransitionWords(text) / Math.max(words.length, 1),

    // Passive voice usage
    passiveVoiceRatio: countPassiveVoice(sentences) / Math.max(sentences.length, 1),

    // Formal language indicators
    formalityScore: calculateFormalityScore(text),

    // Unique word ratio (AI tends to have lower vocabulary diversity)
    uniqueWordRatio: new Set(words.map(w => w.toLowerCase())).size / Math.max(words.length, 1),

    // Sentence starter variety
    starterVariety: calculateStarterVariety(sentences),
  }

  // Calculate AI probability based on metrics
  let aiScore = 0

  // Low sentence length variance suggests AI
  if (metrics.sentenceLengthVariance < 15) aiScore += 15
  else if (metrics.sentenceLengthVariance < 25) aiScore += 8

  // High transition word usage suggests AI
  if (metrics.transitionWordRatio > 0.08) aiScore += 20
  else if (metrics.transitionWordRatio > 0.05) aiScore += 10

  // Repetitive patterns suggest AI
  aiScore += Math.min(metrics.repetitivePatterns * 5, 20)

  // High formality suggests AI
  if (metrics.formalityScore > 0.7) aiScore += 15
  else if (metrics.formalityScore > 0.5) aiScore += 8

  // Low unique word ratio suggests AI
  if (metrics.uniqueWordRatio < 0.4) aiScore += 15
  else if (metrics.uniqueWordRatio < 0.5) aiScore += 8

  // Low sentence starter variety suggests AI
  if (metrics.starterVariety < 0.3) aiScore += 15
  else if (metrics.starterVariety < 0.5) aiScore += 8

  // Normalize score to 0-100
  const aiProbability = Math.min(Math.max(aiScore, 0), 100)
  const humanProbability = 100 - aiProbability
  const mixedProbability = Math.min(aiProbability, humanProbability)

  // Determine verdict
  let verdict: AIDetectionResult["overall_verdict"]
  let confidenceLevel: AIDetectionResult["confidence_level"]

  if (aiProbability >= 70) {
    verdict = "ai_generated"
    confidenceLevel = aiProbability >= 85 ? "high" : "medium"
  } else if (aiProbability <= 30) {
    verdict = "human"
    confidenceLevel = aiProbability <= 15 ? "high" : "medium"
  } else {
    verdict = "mixed"
    confidenceLevel = "low"
  }

  // Generate segment analysis
  const segments = analyzeSegments(text, sentences, aiProbability)

  return {
    id: `ai-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
    file_name: "content-analysis",
    overall_verdict: verdict,
    confidence_level: confidenceLevel,
    ai_probability: Math.round(aiProbability),
    human_probability: Math.round(humanProbability),
    mixed_probability: Math.round(mixedProbability),
    segments,
    checked_at: new Date().toISOString(),
    status: "completed",
  }
}

/**
 * Checks content for plagiarism using pattern matching and common phrase detection.
 */
export async function checkPlagiarism(content: string): Promise<PlagiarismCheckResult> {
  const text = content.trim()
  const words = text.split(/\s+/).filter(w => w.length > 0)
  const sentences = text.split(/[.!?]+/).filter(s => s.trim().length > 0)

  // Common academic phrases that might indicate copied content
  const commonPhrases = [
    "according to research",
    "studies have shown",
    "it is widely known that",
    "in conclusion",
    "furthermore",
    "on the other hand",
    "in addition to this",
    "it can be argued that",
    "research indicates",
    "evidence suggests",
  ]

  // Detect potential matches
  const matches: PlagiarismMatch[] = []
  let matchedWordCount = 0

  // Check for common phrases
  sentences.forEach((sentence, index) => {
    const lowerSentence = sentence.toLowerCase()
    commonPhrases.forEach((phrase, phraseIndex) => {
      if (lowerSentence.includes(phrase)) {
        const wordCount = phrase.split(/\s+/).length
        matchedWordCount += wordCount

        if (!matches.some(m => m.matched_text === sentence.trim())) {
          matches.push({
            id: `match-${index}-${phraseIndex}`,
            source_title: "Common Academic Phrase Database",
            source_url: "#",
            similarity_percentage: Math.round(20 + Math.random() * 30),
            matched_text: sentence.trim(),
            word_count: sentence.split(/\s+/).length,
          })
        }
      }
    })
  })

  // Check for Wikipedia-style content patterns
  const wikiPatterns = [
    /is a [a-z]+ (that|which|who)/i,
    /was (born|founded|established|created) in \d{4}/i,
    /is (known|famous|notable) for/i,
    /refers to the/i,
  ]

  sentences.forEach((sentence, index) => {
    wikiPatterns.forEach((pattern, patternIndex) => {
      if (pattern.test(sentence) && !matches.some(m => m.matched_text === sentence.trim())) {
        matchedWordCount += 5
        matches.push({
          id: `wiki-${index}-${patternIndex}`,
          source_title: "Wikipedia-style Encyclopedia Content",
          source_url: "https://en.wikipedia.org",
          similarity_percentage: Math.round(15 + Math.random() * 25),
          matched_text: sentence.trim(),
          word_count: sentence.split(/\s+/).length,
        })
      }
    })
  })

  // Calculate overall score
  const matchedPercentage = Math.min((matchedWordCount / Math.max(words.length, 1)) * 100, 100)
  const overallScore = Math.round(matchedPercentage)
  const uniqueContent = Math.round(100 - overallScore)

  // Sort matches by similarity
  matches.sort((a, b) => b.similarity_percentage - a.similarity_percentage)

  return {
    id: `plag-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
    file_name: "content-check",
    overall_score: overallScore,
    unique_content: uniqueContent,
    matched_content: overallScore,
    sources_found: matches.length,
    checked_at: new Date().toISOString(),
    matches: matches.slice(0, 10), // Limit to top 10 matches
    status: "completed",
  }
}

/**
 * Checks grammar and style issues in text.
 */
export interface GrammarIssue {
  id: string
  type: "grammar" | "spelling" | "style" | "punctuation"
  severity: "error" | "warning" | "suggestion"
  message: string
  context: string
  suggestion?: string
  position: { start: number; end: number }
}

export interface GrammarCheckResult {
  issues: GrammarIssue[]
  score: number
  word_count: number
  sentence_count: number
  analysis_timestamp: string
}

export async function checkGrammar(content: string): Promise<GrammarCheckResult> {
  const text = content.trim()
  const words = text.split(/\s+/).filter(w => w.length > 0)
  const sentences = text.split(/[.!?]+/).filter(s => s.trim().length > 0)
  const issues: GrammarIssue[] = []

  // Common grammar patterns to check
  const grammarPatterns = [
    { pattern: /\bi\b(?!\s+(am|was|will|would|have|had|could|should|might))/gi, message: "Capitalize 'I' when used as pronoun", type: "grammar" as const },
    { pattern: /\s{2,}/g, message: "Multiple spaces detected", type: "punctuation" as const },
    { pattern: /[,]\s*[,]/g, message: "Double comma detected", type: "punctuation" as const },
    { pattern: /\b(their|there|they're)\b/gi, message: "Check usage of their/there/they're", type: "grammar" as const },
    { pattern: /\b(your|you're)\b/gi, message: "Check usage of your/you're", type: "grammar" as const },
    { pattern: /\b(its|it's)\b/gi, message: "Check usage of its/it's", type: "grammar" as const },
    { pattern: /\b(affect|effect)\b/gi, message: "Check usage of affect/effect", type: "grammar" as const },
    { pattern: /\balot\b/gi, message: "'A lot' should be two words", type: "spelling" as const },
    { pattern: /\bdefinate\b/gi, message: "Spelling: 'definite'", type: "spelling" as const },
    { pattern: /\brecieve\b/gi, message: "Spelling: 'receive'", type: "spelling" as const },
    { pattern: /\boccured\b/gi, message: "Spelling: 'occurred'", type: "spelling" as const },
    { pattern: /\bseperate\b/gi, message: "Spelling: 'separate'", type: "spelling" as const },
  ]

  // Style checks
  const stylePatterns = [
    { pattern: /\b(very|really|extremely|absolutely)\s+(very|really|extremely|absolutely)/gi, message: "Avoid redundant intensifiers", type: "style" as const },
    { pattern: /\b(in order to)\b/gi, message: "Consider using 'to' instead of 'in order to'", type: "style" as const },
    { pattern: /\b(due to the fact that)\b/gi, message: "Consider using 'because'", type: "style" as const },
    { pattern: /\b(at this point in time)\b/gi, message: "Consider using 'now' or 'currently'", type: "style" as const },
  ]

  const position = 0
  const allPatterns = [...grammarPatterns, ...stylePatterns]

  allPatterns.forEach((check, index) => {
    let match
    const regex = new RegExp(check.pattern.source, check.pattern.flags)
    while ((match = regex.exec(text)) !== null) {
      issues.push({
        id: `issue-${index}-${match.index}`,
        type: check.type,
        severity: check.type === "spelling" ? "error" : check.type === "grammar" ? "warning" : "suggestion",
        message: check.message,
        context: text.substring(Math.max(0, match.index - 20), Math.min(text.length, match.index + match[0].length + 20)),
        position: { start: match.index, end: match.index + match[0].length },
      })
    }
  })

  // Calculate score (100 minus penalties for issues)
  const errorPenalty = issues.filter(i => i.severity === "error").length * 5
  const warningPenalty = issues.filter(i => i.severity === "warning").length * 2
  const suggestionPenalty = issues.filter(i => i.severity === "suggestion").length * 1
  const score = Math.max(0, Math.min(100, 100 - errorPenalty - warningPenalty - suggestionPenalty))

  return {
    issues: issues.slice(0, 20), // Limit to 20 issues
    score,
    word_count: words.length,
    sentence_count: sentences.length,
    analysis_timestamp: new Date().toISOString(),
  }
}

// Helper functions
function calculateVariance(numbers: number[]): number {
  if (numbers.length === 0) return 0
  const mean = numbers.reduce((a, b) => a + b, 0) / numbers.length
  return numbers.reduce((sum, n) => sum + Math.pow(n - mean, 2), 0) / numbers.length
}

function detectRepetitivePatterns(text: string): number {
  const phrases = text.toLowerCase().match(/\b(\w+\s+\w+\s+\w+)\b/g) || []
  const phraseCounts = new Map<string, number>()
  phrases.forEach(p => phraseCounts.set(p, (phraseCounts.get(p) || 0) + 1))
  return Array.from(phraseCounts.values()).filter(c => c > 2).length
}

function countTransitionWords(text: string): number {
  const transitionWords = [
    "however", "therefore", "furthermore", "moreover", "additionally",
    "consequently", "nevertheless", "meanwhile", "subsequently", "accordingly",
    "similarly", "conversely", "specifically", "particularly", "notably",
    "indeed", "certainly", "undoubtedly", "evidently", "apparently"
  ]
  const lowerText = text.toLowerCase()
  return transitionWords.reduce((count, word) => {
    const regex = new RegExp(`\\b${word}\\b`, "gi")
    return count + (lowerText.match(regex) || []).length
  }, 0)
}

function countPassiveVoice(sentences: string[]): number {
  const passivePattern = /\b(is|are|was|were|been|being)\s+\w+ed\b/gi
  return sentences.filter(s => passivePattern.test(s)).length
}

function calculateFormalityScore(text: string): number {
  const formalWords = ["therefore", "furthermore", "consequently", "nevertheless", "accordingly", "subsequently"]
  const informalWords = ["gonna", "wanna", "kinda", "sorta", "yeah", "nope", "okay", "ok"]

  const lowerText = text.toLowerCase()
  const formalCount = formalWords.reduce((c, w) => c + (lowerText.match(new RegExp(`\\b${w}\\b`, "g")) || []).length, 0)
  const informalCount = informalWords.reduce((c, w) => c + (lowerText.match(new RegExp(`\\b${w}\\b`, "g")) || []).length, 0)

  const total = formalCount + informalCount
  return total === 0 ? 0.5 : formalCount / total
}

function calculateStarterVariety(sentences: string[]): number {
  if (sentences.length === 0) return 1
  const starters = sentences.map(s => s.trim().split(/\s+/)[0]?.toLowerCase()).filter(Boolean)
  const uniqueStarters = new Set(starters)
  return uniqueStarters.size / starters.length
}

function analyzeSegments(originalText: string, sentences: string[], baseAiScore: number): AISegment[] {
  let currentIndex = 0

  return sentences.slice(0, 5).map((sentence, index) => {
    // Vary the score per segment based on sentence characteristics
    const words = sentence.split(/\s+/)
    const hasTransitions = /\b(however|therefore|furthermore|moreover)\b/i.test(sentence)
    const isShort = words.length < 10

    let segmentScore = baseAiScore
    if (hasTransitions) segmentScore += 10
    if (isShort) segmentScore -= 5
    segmentScore = Math.max(0, Math.min(100, segmentScore + (Math.random() - 0.5) * 20))

    let classification: AISegment["classification"]
    if (segmentScore >= 60) classification = "ai_generated"
    else if (segmentScore <= 40) classification = "human"
    else classification = "mixed"

    // Find the sentence position in the original text
    const trimmedSentence = sentence.trim()
    const startIndex = originalText.indexOf(trimmedSentence, currentIndex)
    const endIndex = startIndex >= 0 ? startIndex + trimmedSentence.length : currentIndex
    currentIndex = endIndex

    return {
      id: `seg-${index}`,
      text: trimmedSentence,
      start_index: Math.max(0, startIndex),
      end_index: endIndex,
      classification,
      probability: Math.round(segmentScore),
    }
  })
}
