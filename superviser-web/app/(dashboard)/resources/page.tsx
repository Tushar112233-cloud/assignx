/**
 * @fileoverview Resources page - Studio layout redesign
 * Distinct landing identity with dashboard hierarchy alignment
 */

"use client"

import { useState, useCallback, useEffect } from "react"
import { motion, AnimatePresence } from "framer-motion"
import {
  ArrowLeft,
  ArrowRight,
  ChevronRight,
  Search,
  Bot,
  SpellCheck,
  DollarSign,
  FileText,
  HelpCircle,
  GraduationCap,
  ExternalLink,
  Sparkles,
  Shield,
  CheckCircle2,
  Loader2,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { apiFetch } from "@/lib/api/client"

import {
  ResourcesIllustration,
  FeaturedTools,
  ToolCategoryGrid,
  pricingGuides,
  trainingTools,
  QuickAccessPanel,
} from "@/components/resources/v2"

import {
  PlagiarismChecker,
  AIDetector,
  PricingGuide,
  TrainingLibrary,
  GrammarChecker,
} from "@/components/resources"
import { analyzeForAI, checkPlagiarism } from "@/lib/services/content-analysis"

import { ScrollArea } from "@/components/ui/scroll-area"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"

type ResourceView =
  | "grid"
  | "plagiarism"
  | "ai-detector"
  | "grammar"
  | "pricing"
  | "guidelines"
  | "faq"
  | "training"
  | "courses"

const viewTitles: Record<ResourceView, string> = {
  grid: "Resources",
  plagiarism: "Plagiarism Checker",
  "ai-detector": "AI Content Detector",
  grammar: "Grammar Checker",
  pricing: "Pricing Guide",
  guidelines: "Service Guidelines",
  faq: "FAQ & Help",
  training: "Training Library",
  courses: "External Courses",
}

const quickLaunch = [
  { id: "plagiarism", label: "Plagiarism", icon: Search, tone: "bg-orange-50 text-orange-700" },
  { id: "ai-detector", label: "AI Detector", icon: Bot, tone: "bg-purple-50 text-purple-700" },
  { id: "grammar", label: "Grammar", icon: SpellCheck, tone: "bg-emerald-50 text-emerald-700" },
  { id: "pricing", label: "Pricing", icon: DollarSign, tone: "bg-emerald-50 text-emerald-700" },
]

const navigationGroups = [
  {
    title: "Quality Tools",
    items: [
      { id: "plagiarism", label: "Plagiarism Checker", icon: Search },
      { id: "ai-detector", label: "AI Detector", icon: Bot },
      { id: "grammar", label: "Grammar Checker", icon: SpellCheck },
    ],
  },
  {
    title: "Guides & Training",
    items: [
      { id: "pricing", label: "Pricing Guide", icon: DollarSign },
      { id: "guidelines", label: "Service Guidelines", icon: FileText },
      { id: "faq", label: "FAQ & Help", icon: HelpCircle },
      { id: "training", label: "Training Library", icon: GraduationCap },
      { id: "courses", label: "External Courses", icon: ExternalLink },
    ],
  },
]

function ServiceGuidelines() {
  const guidelines = [
    {
      category: "Essay Writing",
      standards: [
        "Maintain academic integrity and proper citation formats (APA, MLA, Chicago)",
        "Ensure original content with plagiarism score below 15%",
        "Include proper thesis statement and structured arguments",
        "Minimum word count adherence with quality over quantity focus",
      ],
    },
    {
      category: "Research Papers",
      standards: [
        "Use peer-reviewed sources and academic databases",
        "Include methodology section when applicable",
        "Proper literature review with critical analysis",
        "Data presentation with appropriate charts and tables",
      ],
    },
    {
      category: "Technical Assignments",
      standards: [
        "Code must be well-documented with comments",
        "Follow best practices and coding standards",
        "Include test cases and error handling",
        "Provide clear instructions for running/testing",
      ],
    },
    {
      category: "Quality Assurance",
      standards: [
        "All submissions must pass plagiarism check (<15%)",
        "AI content detection must be below 20%",
        "Grammar and spelling errors should be minimal",
        "Formatting must match client requirements",
      ],
    },
  ]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white rounded-2xl border border-gray-200 overflow-hidden"
    >
      <div className="p-6 border-b border-gray-100">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-xl bg-amber-50 flex items-center justify-center">
            <Shield className="h-6 w-6 text-amber-600" />
          </div>
          <div>
            <h2 className="text-lg font-semibold text-[#1C1C1C]">Service Guidelines</h2>
            <p className="text-sm text-gray-500">Standards and expectations for each service type</p>
          </div>
        </div>
      </div>
      <ScrollArea className="h-[500px]">
        <div className="p-6 space-y-6">
          {guidelines.map((section, idx) => (
            <motion.div
              key={section.category}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 * idx }}
              className="space-y-3"
            >
              <h3 className="font-semibold text-[#1C1C1C] flex items-center gap-2">
                <CheckCircle2 className="h-5 w-5 text-emerald-500" />
                {section.category}
              </h3>
              <ul className="space-y-2 ml-7">
                {section.standards.map((standard, sidx) => (
                  <li key={sidx} className="text-sm text-gray-600 flex items-start gap-2">
                    <span className="text-[#F97316] mt-1.5 text-xs">●</span>
                    {standard}
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}
        </div>
      </ScrollArea>
    </motion.div>
  )
}

function FAQSection() {
  const faqs = [
    {
      question: "How do I accept a new project?",
      answer:
        "Go to the Projects page, find available projects in the 'Available' tab, review the requirements, and click 'Accept Project' to start working on it.",
    },
    {
      question: "What should I do if a client requests revisions?",
      answer:
        "Review the revision request carefully, communicate with the client through chat if needed, make the necessary changes, and resubmit. Always maintain professionalism.",
    },
    {
      question: "How is my rating calculated?",
      answer:
        "Your rating is based on client satisfaction, on-time delivery, quality of work, and revision frequency. Consistently high-quality work improves your rating.",
    },
    {
      question: "What are the plagiarism thresholds?",
      answer:
        "All submissions should have less than 15% similarity score. AI-generated content should be below 20%. Use the quality tools to check before submitting.",
    },
    {
      question: "How do I handle deadline extensions?",
      answer:
        "Contact the client through chat to discuss extension needs. If approved, update the deadline in the project settings. Always communicate proactively about delays.",
    },
    {
      question: "What payment methods are supported?",
      answer:
        "Payments are processed weekly via bank transfer, PayPal, or other configured payment methods. Check your profile settings to set up payment preferences.",
    },
    {
      question: "How do I improve my supervisor rating?",
      answer:
        "Deliver high-quality work on time, maintain clear communication, minimize revision requests, and consistently meet or exceed client expectations.",
    },
    {
      question: "What happens if I need to cancel a project?",
      answer:
        "Contact support immediately. Cancellations affect your reliability score. Only cancel in unavoidable circumstances and provide adequate notice.",
    },
  ]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white rounded-2xl border border-gray-200 overflow-hidden"
    >
      <div className="p-6 border-b border-gray-100">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-xl bg-slate-100 flex items-center justify-center">
            <HelpCircle className="h-6 w-6 text-slate-600" />
          </div>
          <div>
            <h2 className="text-lg font-semibold text-[#1C1C1C]">FAQ & Help</h2>
            <p className="text-sm text-gray-500">Frequently asked questions and troubleshooting guides</p>
          </div>
        </div>
      </div>
      <ScrollArea className="h-[500px]">
        <div className="p-6">
          <Accordion type="single" collapsible className="space-y-3">
            {faqs.map((faq, idx) => (
              <AccordionItem
                key={idx}
                value={`faq-${idx}`}
                className="border border-gray-200 rounded-xl px-4 data-[state=open]:border-orange-200
                  data-[state=open]:bg-orange-50/30 transition-colors"
              >
                <AccordionTrigger className="text-sm font-medium text-[#1C1C1C] text-left hover:no-underline py-4">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-sm text-gray-600 pb-4">
                  {faq.answer}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </div>
      </ScrollArea>
    </motion.div>
  )
}

function ExternalCourses() {
  const courses = [
    {
      title: "Academic Writing Fundamentals",
      provider: "Coursera",
      duration: "4 weeks",
      level: "Beginner",
      url: "https://www.coursera.org/learn/academic-writing",
    },
    {
      title: "Research Methods & Data Analysis",
      provider: "edX",
      duration: "6 weeks",
      level: "Intermediate",
      url: "https://www.edx.org/learn/research",
    },
    {
      title: "Technical Writing for Professionals",
      provider: "LinkedIn Learning",
      duration: "3 hours",
      level: "All Levels",
      url: "https://www.linkedin.com/learning/technical-writing",
    },
    {
      title: "APA & Citation Mastery",
      provider: "Purdue OWL",
      duration: "Self-paced",
      level: "All Levels",
      url: "https://owl.purdue.edu/owl/research_and_citation/apa_style/",
    },
    {
      title: "Critical Thinking & Analysis",
      provider: "Udemy",
      duration: "5 hours",
      level: "Beginner",
      url: "https://www.udemy.com/topic/critical-thinking/",
    },
    {
      title: "Plagiarism Prevention Workshop",
      provider: "Turnitin",
      duration: "2 hours",
      level: "All Levels",
      url: "https://www.turnitin.com/resources",
    },
  ]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white rounded-2xl border border-gray-200 overflow-hidden"
    >
      <div className="p-6 border-b border-gray-100">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-xl bg-violet-50 flex items-center justify-center">
            <ExternalLink className="h-6 w-6 text-violet-600" />
          </div>
          <div>
            <h2 className="text-lg font-semibold text-[#1C1C1C]">External Courses</h2>
            <p className="text-sm text-gray-500">Enhance your skills with recommended courses</p>
          </div>
        </div>
      </div>
      <ScrollArea className="h-[500px]">
        <div className="p-6 space-y-4">
          {courses.map((course, idx) => (
            <motion.div
              key={idx}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.1 * idx }}
              className="group flex items-center justify-between p-4 rounded-xl border border-gray-200
                hover:border-orange-200 hover:shadow-md hover:-translate-y-0.5
                transition-all duration-200 cursor-pointer"
              onClick={() => window.open(course.url, "_blank", "noopener,noreferrer")}
            >
              <div className="space-y-1">
                <h4 className="font-medium text-[#1C1C1C] group-hover:text-[#F97316] transition-colors">
                  {course.title}
                </h4>
                <div className="flex items-center gap-2 text-xs text-gray-500">
                  <Badge variant="outline" className="text-xs font-normal">
                    {course.provider}
                  </Badge>
                  <span>•</span>
                  <span>{course.duration}</span>
                  <span>•</span>
                  <span>{course.level}</span>
                </div>
              </div>
              <ExternalLink className="h-5 w-5 text-gray-300 group-hover:text-[#F97316] transition-colors" />
            </motion.div>
          ))}
        </div>
      </ScrollArea>
    </motion.div>
  )
}

function BackButton({ onClick }: { onClick: () => void }) {
  return (
    <motion.button
      initial={{ opacity: 0, x: -10 }}
      animate={{ opacity: 1, x: 0 }}
      onClick={onClick}
      className="group flex items-center gap-2 text-gray-500 hover:text-[#1C1C1C]
        transition-colors"
    >
      <div className="w-8 h-8 rounded-lg bg-gray-100 group-hover:bg-orange-50
        flex items-center justify-center transition-colors">
        <ArrowLeft className="h-4 w-4 group-hover:text-[#F97316] transition-colors" />
      </div>
      <span className="text-sm font-medium">Back to Resources</span>
    </motion.button>
  )
}

function ToolWrapper({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      transition={{ duration: 0.3 }}
      className="max-w-4xl"
    >
      {children}
    </motion.div>
  )
}

export default function ResourcesPage() {
  const [activeView, setActiveView] = useState<ResourceView>("grid")
  const [learningResources, setLearningResources] = useState<Array<{
    id: string
    title: string
    description: string | null
    content_type: string
    content_url: string | null
    thumbnail_url: string | null
    is_featured: boolean
    category: string | null
    created_at: string
  }>>([])
  const [resourcesLoading, setResourcesLoading] = useState(true)

  useEffect(() => {
    const fetchResources = async () => {
      try {
        const data = await apiFetch<Array<{
          id: string
          title: string
          description: string | null
          content_type: string
          content_url: string | null
          thumbnail_url: string | null
          is_featured: boolean
          category: string | null
          created_at: string
        }>>("/api/resources/learning?is_active=true&sort=-created_at")
        if (data) setLearningResources(data)
      } catch {
        // Resources may not be available
      }
      setResourcesLoading(false)
    }
    fetchResources()
  }, [])

  // TODO: Fetch these from Supabase (supervisor activity stats)
  const toolsCount = 8
  const checksToday = 0
  const trainingProgress = 0

  const progressItems = [
    {
      label: "Quality checks",
      value: `${checksToday} today`,
      percent: Math.min(100, Math.round((checksToday / 60) * 100)),
      color: "bg-orange-500",
    },
    {
      label: "Training progress",
      value: `${trainingProgress}%`,
      percent: trainingProgress,
      color: "bg-emerald-500",
    },
    {
      label: "Tools available",
      value: `${toolsCount} tools`,
      percent: Math.min(100, Math.round((toolsCount / 12) * 100)),
      color: "bg-purple-500",
    },
  ]

  const handleAIDetect = useCallback(async (content: string | File) => {
    const text = typeof content === "string" ? content : await content.text()
    return analyzeForAI(text)
  }, [])

  const handlePlagiarismCheck = useCallback(async (content: string | File) => {
    const text = typeof content === "string" ? content : await content.text()
    return checkPlagiarism(text)
  }, [])

  const handleToolSelect = useCallback((toolId: string) => {
    setActiveView(toolId as ResourceView)
  }, [])

  const renderGridView = () => (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="grid lg:grid-cols-[280px_1fr] gap-8"
    >
      <aside className="space-y-6">
        <div className="bg-white rounded-2xl border border-gray-200 p-5 space-y-4">
          <div className="flex items-center gap-2">
            <Sparkles className="h-5 w-5 text-[#F97316]" />
            <div>
              <h3 className="text-sm font-semibold text-[#1C1C1C]">Resource Index</h3>
              <p className="text-xs text-gray-500">Jump to any tool or guide</p>
            </div>
          </div>

          <button
            onClick={() => setActiveView("grid")}
            className={cn(
              "w-full flex items-center justify-between rounded-xl border px-4 py-3 text-sm font-medium transition-all",
              activeView === "grid"
                ? "bg-orange-500 text-white border-orange-500"
                : "bg-white text-gray-700 border-gray-200 hover:border-orange-300"
            )}
          >
            All Resources
            <ChevronRight className="h-4 w-4" />
          </button>

          {navigationGroups.map((group) => (
            <div key={group.title} className="space-y-2">
              <p className="text-xs font-semibold uppercase tracking-[0.12em] text-gray-400">
                {group.title}
              </p>
              <div className="space-y-2">
                {group.items.map((item) => (
                  <button
                    key={item.id}
                    onClick={() => handleToolSelect(item.id)}
                    className={cn(
                      "w-full flex items-center justify-between gap-3 rounded-xl border px-4 py-3 text-sm transition-all",
                      activeView === item.id
                        ? "bg-orange-50 text-orange-700 border-orange-200"
                        : "bg-white text-gray-600 border-gray-200 hover:border-orange-300"
                    )}
                  >
                    <span className="flex items-center gap-2">
                      <item.icon className="h-4 w-4" />
                      {item.label}
                    </span>
                    <ChevronRight className="h-4 w-4 text-gray-300" />
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>

        <QuickAccessPanel onItemSelect={handleToolSelect} className="w-full" />

        <div className="rounded-3xl border border-gray-200 bg-white p-6 space-y-5">
          <div className="flex items-center gap-2">
            <FileText className="h-5 w-5 text-orange-600" />
            <h3 className="text-sm font-semibold text-[#1C1C1C]">Supervisor Playbook</h3>
          </div>
          <p className="text-sm text-gray-500 leading-relaxed">
            Key rules and quality checkpoints to stay consistent across projects.
          </p>
          <div className="space-y-3 text-sm text-gray-600 leading-relaxed">
            <div className="flex items-start gap-2">
              <span className="text-[#F97316] mt-1 text-xs">●</span>
              Verify plagiarism score and AI detection before delivery.
            </div>
            <div className="flex items-start gap-2">
              <span className="text-[#F97316] mt-1 text-xs">●</span>
              Use pricing guide to align urgency and complexity.
            </div>
            <div className="flex items-start gap-2">
              <span className="text-[#F97316] mt-1 text-xs">●</span>
              Log revisions and keep client communication clear.
            </div>
          </div>
          <Button
            variant="outline"
            className="rounded-full border-gray-200"
            onClick={() => setActiveView("guidelines")}
          >
            Open Guidelines
          </Button>
        </div>

      </aside>

      <div className="space-y-8">
        <section className="relative overflow-hidden rounded-3xl border border-gray-200 bg-white p-6 lg:p-8">
          <div className="absolute -top-16 left-1/3 h-44 w-44 rounded-full bg-orange-100/50 blur-3xl" />
          <div className="absolute -bottom-16 right-10 h-44 w-44 rounded-full bg-amber-100/50 blur-3xl" />

          <div className="relative grid lg:grid-cols-[1.1fr_0.9fr] gap-8 items-center">
            <div className="space-y-6">
              <div>
                <p className="text-xs uppercase tracking-[0.2em] text-gray-400">Resource Studio</p>
                <h1 className="text-4xl lg:text-5xl font-bold text-[#1C1C1C] tracking-tight mt-2">
                  Resources Hub
                </h1>
                <p className="text-lg text-gray-500 mt-3">
                  Quality checks, pricing playbooks, and training in one curated workspace.
                </p>
              </div>

              <div className="flex flex-wrap items-center gap-3">
                <Button
                  onClick={() => setActiveView("plagiarism")}
                  className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-full px-6 h-11 font-medium shadow-lg shadow-orange-500/20 hover:shadow-xl hover:shadow-orange-500/30 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200"
                >
                  Run Quality Check
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Button>
                <Button
                  variant="outline"
                  onClick={() => setActiveView("training")}
                  className="rounded-full h-11 px-5 border-gray-200 text-gray-700"
                >
                  Open Training
                </Button>
              </div>

              <div className="flex flex-wrap gap-2 text-xs text-gray-500">
                <span className="px-3 py-1 rounded-full bg-gray-100">{toolsCount} tools</span>
                <span className="px-3 py-1 rounded-full bg-orange-50 text-orange-700">{checksToday} checks</span>
                <span className="px-3 py-1 rounded-full bg-emerald-50 text-emerald-700">
                  {trainingProgress}% training
                </span>
              </div>

              <div className="flex flex-wrap gap-2">
                {quickLaunch.map((item) => (
                  <button
                    key={item.id}
                    onClick={() => handleToolSelect(item.id)}
                    className={cn(
                      "flex items-center gap-2 px-3 py-2 rounded-full text-xs font-medium border border-transparent hover:border-orange-200 transition-all",
                      item.tone
                    )}
                  >
                    <item.icon className="h-3.5 w-3.5" />
                    {item.label}
                  </button>
                ))}
              </div>
            </div>

            <div className="space-y-4">
              <div className="w-full h-[220px]">
                <ResourcesIllustration className="w-full h-full" />
              </div>
              <div className="rounded-2xl border border-gray-200 bg-gray-50/80 p-4">
                <div className="flex items-center justify-between">
                  <h3 className="text-sm font-semibold text-[#1C1C1C]">Resource Snapshot</h3>
                  <span className="text-xs text-gray-400">Today</span>
                </div>
                <div className="mt-4 space-y-3">
                  {progressItems.map((item) => (
                    <div key={item.label} className="space-y-1">
                      <div className="flex items-center justify-between text-xs text-gray-500">
                        <span>{item.label}</span>
                        <span>{item.value}</span>
                      </div>
                      <div className="h-2 rounded-full bg-white border border-gray-200 overflow-hidden">
                        <div className={item.color} style={{ width: `${item.percent}%`, height: "100%" }} />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>

        <FeaturedTools onToolSelect={handleToolSelect} />

        <section className="rounded-3xl border border-gray-200 bg-white p-6 lg:p-8">
          <ToolCategoryGrid
            title="Pricing & Guides"
            tools={pricingGuides}
            onToolSelect={handleToolSelect}
          />
        </section>

        <section className="rounded-3xl border border-gray-200 bg-white p-6 lg:p-8">
          <ToolCategoryGrid
            title="Training & Development"
            tools={trainingTools}
            onToolSelect={handleToolSelect}
          />
        </section>

        {/* Learning Resources from Admin */}
        {learningResources.length > 0 && (
          <section className="rounded-3xl border border-gray-200 bg-white p-6 lg:p-8">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center">
                <GraduationCap className="h-5 w-5 text-blue-600" />
              </div>
              <div>
                <h2 className="text-lg font-semibold text-[#1C1C1C]">Learning Resources</h2>
                <p className="text-sm text-gray-500">Curated materials from the admin team</p>
              </div>
            </div>
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {learningResources.map((resource) => (
                <div
                  key={resource.id}
                  className="group relative rounded-2xl border border-gray-200 bg-white p-5
                    hover:border-orange-200 hover:shadow-lg hover:-translate-y-0.5
                    transition-all duration-200 cursor-pointer"
                  onClick={() => resource.content_url && window.open(resource.content_url, '_blank', 'noopener,noreferrer')}
                >
                  {resource.is_featured && (
                    <Badge className="absolute top-3 right-3 bg-orange-100 text-orange-700 border-0 text-[10px]">
                      Featured
                    </Badge>
                  )}
                  <div className="space-y-2">
                    <div className="flex items-center gap-2">
                      <Badge variant="outline" className="text-[10px] capitalize">
                        {resource.content_type}
                      </Badge>
                      {resource.category && (
                        <Badge variant="outline" className="text-[10px] capitalize">
                          {resource.category}
                        </Badge>
                      )}
                    </div>
                    <h4 className="font-medium text-sm text-[#1C1C1C] group-hover:text-[#F97316] transition-colors line-clamp-2">
                      {resource.title}
                    </h4>
                    {resource.description && (
                      <p className="text-xs text-gray-500 line-clamp-2">{resource.description}</p>
                    )}
                    <p className="text-[10px] text-gray-400">
                      {new Date(resource.created_at).toLocaleDateString()}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </section>
        )}
      </div>
    </motion.div>
  )

  const renderToolView = () => {
    const commonWrapper = (content: React.ReactNode) => (
      <div className="space-y-6">
        <BackButton onClick={() => setActiveView("grid")} />
        <div>
          <p className="text-xs uppercase tracking-[0.2em] text-gray-400">Resources</p>
          <h1 className="text-3xl font-semibold text-[#1C1C1C] mt-2">
            {viewTitles[activeView]}
          </h1>
        </div>
        <ToolWrapper>{content}</ToolWrapper>
      </div>
    )

    switch (activeView) {
      case "plagiarism":
        return commonWrapper(<PlagiarismChecker onCheck={handlePlagiarismCheck} />)
      case "ai-detector":
        return commonWrapper(<AIDetector onDetect={handleAIDetect} />)
      case "grammar":
        return commonWrapper(<GrammarChecker />)
      case "pricing":
        return commonWrapper(<PricingGuide />)
      case "training":
        return commonWrapper(<TrainingLibrary />)
      case "guidelines":
        return commonWrapper(<ServiceGuidelines />)
      case "faq":
        return commonWrapper(<FAQSection />)
      case "courses":
        return commonWrapper(<ExternalCourses />)
      default:
        return null
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="relative">
        <div className="pointer-events-none absolute inset-0">
          <div className="absolute -top-24 right-0 h-64 w-64 rounded-full bg-orange-100/60 blur-3xl" />
          <div className="absolute top-40 left-10 h-56 w-56 rounded-full bg-amber-100/50 blur-3xl" />
        </div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.4 }}
          className="relative max-w-[1400px] mx-auto px-6 lg:px-10 py-8 lg:py-10"
        >
          <AnimatePresence mode="wait">
            {activeView === "grid" ? (
              <motion.div key="grid" exit={{ opacity: 0 }}>
                {renderGridView()}
              </motion.div>
            ) : (
              <motion.div key="tool" exit={{ opacity: 0 }}>
                {renderToolView()}
              </motion.div>
            )}
          </AnimatePresence>
        </motion.div>
      </div>
    </div>
  )
}
