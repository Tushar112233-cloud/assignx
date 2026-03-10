/**
 * @fileoverview Supervisor Dashboard — Command Center
 * Charcoal hero with integrated glass stats, orange accent energy,
 * clean workspace below. Own identity — not a doer dashboard copy.
 * @module app/(dashboard)/dashboard/page
 */

"use client"

import { useMemo, useState, useEffect, useRef } from "react"
import { motion, AnimatePresence } from "framer-motion"
import {
  useProjectsByStatus,
  useSupervisorStats,
  useEarningsStats,
  useChatRooms,
  useUnreadMessages,
  useDoers,
  claimProject,
} from "@/hooks"
import { useRouter } from "next/navigation"
import { toast } from "sonner"
import {
  FileText,
  Clock,
  CheckCircle2,
  Users,
  Zap,
  ArrowRight,
  TrendingUp,
  ChevronRight,
  FolderKanban,
  IndianRupee,
  AlertTriangle,
  MessageSquare,
  Eye,
  BarChart3,
  Shield,
  Wallet,
  BookOpen,
  Sparkles,
} from "lucide-react"
import { useAuth } from "@/hooks"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import { formatDistanceToNow } from "date-fns"

const ease = [0.25, 0.46, 0.45, 0.94] as [number, number, number, number]

function getGreeting(): string {
  const h = new Date().getHours()
  return h < 12 ? "Good morning" : h < 17 ? "Good afternoon" : "Good evening"
}

function AnimatedNumber({ value, delay = 0 }: { value: number; delay?: number }) {
  const [display, setDisplay] = useState(0)
  const started = useRef(false)
  useEffect(() => {
    if (started.current) return
    const t = setTimeout(() => {
      started.current = true
      const dur = 800, s = Date.now()
      const tick = () => {
        const p = Math.min((Date.now() - s) / dur, 1)
        setDisplay(Math.floor(value * (1 - Math.pow(1 - p, 3))))
        if (p < 1) requestAnimationFrame(tick)
      }
      requestAnimationFrame(tick)
    }, delay)
    return () => clearTimeout(t)
  }, [value, delay])
  return <>{display.toLocaleString("en-IN")}</>
}

// ─── Dashboard ──────────────────────────────────────────────────────────────

export default function DashboardPage() {
  const router = useRouter()
  const { user } = useAuth()
  const firstName = user?.full_name?.split(" ")[0] || "Supervisor"

  const { needsQuote, readyToAssign: readyProjects, inProgress, needsQC, completed, refetch } = useProjectsByStatus()
  const { stats: svStats } = useSupervisorStats()
  const { stats: earnStats } = useEarningsStats()
  const { rooms } = useChatRooms()
  const { unreadCount } = useUnreadMessages()
  const { doers } = useDoers()

  const availableDoers = useMemo(() => doers?.filter((d: { is_available?: boolean; is_blacklisted?: boolean }) => d.is_available && !d.is_blacklisted)?.length || 0, [doers])

  const s = useMemo(() => ({
    active: svStats?.activeProjects || inProgress.length,
    qc: needsQC.length,
    done: svStats?.completedProjects || completed.length,
    earn: earnStats?.thisMonth || 0,
    requests: needsQuote.length,
    assign: readyProjects.length,
    doers: svStats?.totalDoers || doers?.length || 0,
    growth: earnStats?.monthlyGrowth || 0,
  }), [svStats, earnStats, inProgress.length, needsQC.length, completed.length, needsQuote.length, readyProjects.length, doers?.length])

  const total = s.requests + s.assign + s.active + s.qc + s.done
  const pct = total > 0 ? Math.round((s.done / total) * 100) : 0

  const urgent = useMemo(() => {
    const cut = Date.now() + 86400000
    return [...needsQuote, ...inProgress, ...needsQC].filter((p: { deadline?: string | null }) => p.deadline && new Date(p.deadline).getTime() < cut)
  }, [needsQuote, inProgress, needsQC])

  const handleAnalyze = async (pid: string, pnum: string) => {
    try { await claimProject(pid); toast.success(`Project ${pnum} claimed!`); await refetch(); router.push(`/projects/${pid}`) }
    catch { toast.error("Failed to claim"); await refetch() }
  }

  return (
    <div className="min-h-screen bg-[#F5F5F5]">
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.3 }} className="max-w-[1400px] mx-auto px-5 lg:px-8 pt-5 pb-10">

        {/* ══════════════════════════════════════════════════════════
            COMMAND HEADER — charcoal with integrated stats
           ══════════════════════════════════════════════════════════ */}
        <motion.div
          initial={{ opacity: 0, y: -8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4, ease }}
          className="relative overflow-hidden rounded-2xl bg-[#1C1C1C] mb-5"
        >
          {/* Ambient */}
          <div className="absolute -top-20 -right-20 w-80 h-80 bg-[#F97316]/10 blur-[100px] rounded-full pointer-events-none" />
          <div className="absolute -bottom-16 -left-16 w-60 h-60 bg-[#F97316]/5 blur-[80px] rounded-full pointer-events-none" />
          <div className="absolute inset-0 opacity-[0.03] pointer-events-none" style={{ backgroundImage: "radial-gradient(circle, rgba(255,255,255,0.6) 1px, transparent 1px)", backgroundSize: "24px 24px" }} />

          <div className="relative z-10 p-6 lg:p-8">
            {/* Top row: greeting + earnings */}
            <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-4 mb-6">
              <div>
                <div className="inline-flex items-center gap-2 rounded-full border border-[#F97316]/15 bg-[#F97316]/[0.06] px-3 py-1 mb-3">
                  <motion.span className="w-1.5 h-1.5 rounded-full bg-[#F97316]" animate={{ scale: [1, 1.4, 1] }} transition={{ duration: 2, repeat: Infinity }} />
                  <span className="text-[10px] font-semibold text-[#F97316] uppercase tracking-[0.1em]">Command Center</span>
                </div>
                <h1 className="text-2xl lg:text-[28px] font-bold tracking-tight text-white leading-tight mb-1.5">
                  {getGreeting()},{" "}
                  <span className="bg-clip-text [-webkit-background-clip:text] [-webkit-text-fill-color:transparent]" style={{ backgroundImage: "linear-gradient(135deg, #F97316 0%, #FB923C 100%)" }}>
                    {firstName}
                  </span>
                </h1>
                <p className="text-sm text-white/45 max-w-md">
                  {s.requests > 0
                    ? `${s.requests} new request${s.requests > 1 ? "s" : ""} waiting · ${s.qc > 0 ? `${s.qc} QC reviews pending` : "no QC reviews"}`
                    : "All caught up. Your projects are running smoothly."}
                </p>
              </div>

              {/* Earnings highlight — orange glass */}
              <Link href="/earnings" className="shrink-0">
                <motion.div
                  whileHover={{ y: -2, borderColor: "rgba(249,115,22,0.3)" }}
                  className="rounded-xl border border-[#F97316]/15 bg-[#F97316]/[0.06] backdrop-blur-sm px-5 py-4 cursor-pointer transition-all min-w-[180px]"
                >
                  <div className="flex items-center gap-2 mb-1">
                    <IndianRupee className="h-3.5 w-3.5 text-[#F97316]" />
                    <span className="text-[10px] font-semibold text-[#F97316]/70 uppercase tracking-wider">Earnings</span>
                  </div>
                  <p className="text-2xl font-bold text-white tabular-nums">₹{s.earn.toLocaleString("en-IN")}</p>
                  <p className="text-[10px] text-white/35 mt-0.5">
                    {s.growth > 0 ? <span className="text-emerald-400">+{Math.round(s.growth)}%</span> : "this month"}
                    {s.growth > 0 && " from last month"}
                  </p>
                </motion.div>
              </Link>
            </div>

            {/* Stat cards row — glass on dark */}
            <div className="grid grid-cols-2 lg:grid-cols-5 gap-3 mb-5">
              {[
                { value: s.requests, label: "New Requests", icon: FileText, href: "/projects?tab=requests", accent: s.requests > 0 },
                { value: s.qc, label: "QC Queue", icon: Eye, href: "/projects?tab=review", accent: s.qc > 0 },
                { value: s.active, label: "In Progress", icon: FolderKanban, href: "/projects?tab=ongoing" },
                { value: s.assign, label: "To Assign", icon: Zap, href: "/projects?tab=ready", accent: s.assign > 0 },
                { value: availableDoers, label: `${s.doers} doers`, icon: Users, href: "/doers" },
              ].map((card, i) => (
                <Link key={card.label} href={card.href}>
                  <motion.div
                    initial={{ opacity: 0, y: 8 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.15 + i * 0.04, ease }}
                    whileHover={{ y: -2, borderColor: card.accent ? "rgba(249,115,22,0.25)" : "rgba(255,255,255,0.12)" }}
                    className={cn(
                      "rounded-xl border backdrop-blur-sm px-4 py-3.5 cursor-pointer transition-all duration-200",
                      card.accent
                        ? "border-[#F97316]/15 bg-[#F97316]/[0.04]"
                        : "border-white/[0.06] bg-white/[0.03]"
                    )}
                  >
                    <div className="flex items-center justify-between mb-2">
                      <card.icon className={cn("h-4 w-4", card.accent ? "text-[#F97316]" : "text-white/25")} />
                      {card.accent && <span className="w-1.5 h-1.5 rounded-full bg-[#F97316] animate-pulse" />}
                    </div>
                    <p className="text-xl font-bold text-white tabular-nums">
                      <AnimatedNumber value={card.value} delay={200 + i * 60} />
                    </p>
                    <p className="text-[10px] text-white/35 font-medium mt-0.5">{card.label}</p>
                  </motion.div>
                </Link>
              ))}
            </div>

            {/* CTAs + context */}
            <div className="flex flex-wrap items-center gap-3">
              <Link href="/projects?tab=requests">
                <motion.button whileHover={{ y: -1, boxShadow: "0 8px 24px hsl(25 95% 53% / 0.3)" }} whileTap={{ scale: 0.98 }} className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-[#F97316] text-white text-sm font-semibold transition-all">
                  Review Requests <ArrowRight className="h-4 w-4" />
                </motion.button>
              </Link>
              <Link href="/projects">
                <Button variant="ghost" className="rounded-xl h-10 text-sm font-medium text-white/50 hover:text-white hover:bg-white/[0.06]">
                  All Projects
                </Button>
              </Link>

              {/* Quick context badges */}
              <div className="hidden lg:flex items-center gap-2 ml-auto">
                {unreadCount > 0 && (
                  <Link href="/chat" className="inline-flex items-center gap-1.5 rounded-full border border-white/[0.06] bg-white/[0.03] px-3 py-1 text-[10px] text-white/40 hover:text-white/60 transition-colors">
                    <MessageSquare className="h-3 w-3" />
                    {unreadCount} unread
                  </Link>
                )}
                {urgent.length > 0 && (
                  <Link href="/projects" className="inline-flex items-center gap-1.5 rounded-full border border-amber-500/20 bg-amber-500/[0.06] px-3 py-1 text-[10px] text-amber-400">
                    <Clock className="h-3 w-3" />
                    {urgent.length} urgent
                  </Link>
                )}
                <span className="text-[10px] text-white/25 tabular-nums">{pct}% completion</span>
              </div>
            </div>
          </div>
        </motion.div>

        {/* ══════════════════════════════════════════════════════════
            INSIGHTS ROW — Performance | Pipeline | Priority
           ══════════════════════════════════════════════════════════ */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-5">
          {/* Performance */}
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2, ease }} className="rounded-2xl bg-white border border-gray-200/80 p-5">
            <div className="flex items-center gap-2.5 mb-4">
              <div className="w-8 h-8 rounded-lg bg-[#F97316]/10 flex items-center justify-center">
                <BarChart3 className="h-4 w-4 text-[#1C1C1C]" />
              </div>
              <div>
                <p className="text-sm font-semibold text-[#1C1C1C]">Performance</p>
                <p className="text-[10px] text-gray-400">Delivery health</p>
              </div>
            </div>
            <div className="space-y-3">
              {[
                { label: "Completion rate", val: `${pct}%` },
                { label: "Active projects", val: s.active },
                { label: "Completed", val: s.done },
              ].map((r) => (
                <div key={r.label} className="flex items-center justify-between">
                  <span className="text-xs text-gray-500">{r.label}</span>
                  <span className="text-sm font-semibold text-[#1C1C1C] tabular-nums">{r.val}</span>
                </div>
              ))}
            </div>
          </motion.div>

          {/* Pipeline */}
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.25, ease }} className="rounded-2xl bg-white border border-gray-200/80 p-5">
            <div className="flex items-center gap-2.5 mb-4">
              <div className="w-8 h-8 rounded-lg bg-[#F97316]/10 flex items-center justify-center">
                <FolderKanban className="h-4 w-4 text-[#1C1C1C]" />
              </div>
              <div>
                <p className="text-sm font-semibold text-[#1C1C1C]">Pipeline</p>
                <p className="text-[10px] text-gray-400">Project flow</p>
              </div>
            </div>
            <div className="h-2 rounded-full bg-gray-100 flex overflow-hidden mb-4">
              {total > 0 ? (
                <>
                  {s.requests > 0 && <div className="bg-[#F97316]" style={{ width: `${(s.requests / total) * 100}%` }} />}
                  {s.assign > 0 && <div className="bg-amber-400" style={{ width: `${(s.assign / total) * 100}%` }} />}
                  {s.active > 0 && <div className="bg-blue-400" style={{ width: `${(s.active / total) * 100}%` }} />}
                  {s.qc > 0 && <div className="bg-violet-400" style={{ width: `${(s.qc / total) * 100}%` }} />}
                  {s.done > 0 && <div className="bg-emerald-400" style={{ width: `${(s.done / total) * 100}%` }} />}
                </>
              ) : <div className="bg-gray-200 w-full" />}
            </div>
            <div className="grid grid-cols-2 gap-x-4 gap-y-1.5">
              {[
                { c: "bg-[#F97316]", l: "New", n: s.requests },
                { c: "bg-amber-400", l: "Assign", n: s.assign },
                { c: "bg-blue-400", l: "Active", n: s.active },
                { c: "bg-emerald-400", l: "Done", n: s.done },
              ].map((x) => (
                <div key={x.l} className="flex items-center gap-2">
                  <span className={cn("w-2 h-2 rounded-full", x.c)} />
                  <span className="text-[11px] text-gray-500">{x.l}</span>
                  <span className="text-[11px] font-semibold text-[#1C1C1C] ml-auto tabular-nums">{x.n}</span>
                </div>
              ))}
            </div>
          </motion.div>

          {/* Priority */}
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3, ease }} className="rounded-2xl bg-white border border-gray-200/80 p-5">
            <div className="flex items-center gap-2.5 mb-4">
              <div className="w-8 h-8 rounded-lg bg-[#F97316]/10 flex items-center justify-center">
                <AlertTriangle className="h-4 w-4 text-[#1C1C1C]" />
              </div>
              <div>
                <p className="text-sm font-semibold text-[#1C1C1C]">Priority</p>
                <p className="text-[10px] text-gray-400">Needs attention</p>
              </div>
            </div>
            {urgent.length === 0 && s.qc === 0 && unreadCount === 0 ? (
              <div className="rounded-xl bg-emerald-50 border border-emerald-100 px-4 py-3 text-center">
                <p className="text-xs font-medium text-emerald-700">All clear — no priority items</p>
              </div>
            ) : (
              <div className="space-y-2">
                {urgent.length > 0 && (
                  <Link href="/projects" className="flex items-center gap-3 rounded-xl bg-amber-50 border border-amber-100 px-3 py-2.5 hover:border-amber-200 transition-colors">
                    <Clock className="h-4 w-4 text-amber-600 shrink-0" />
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-medium text-amber-800">{urgent.length} urgent deadline{urgent.length > 1 ? "s" : ""}</p>
                      <p className="text-[10px] text-amber-600">Due within 24h</p>
                    </div>
                    <ChevronRight className="h-3.5 w-3.5 text-amber-400" />
                  </Link>
                )}
                {s.qc > 0 && (
                  <Link href="/projects?tab=review" className="flex items-center gap-3 rounded-xl bg-violet-50 border border-violet-100 px-3 py-2.5 hover:border-violet-200 transition-colors">
                    <Shield className="h-4 w-4 text-violet-600 shrink-0" />
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-medium text-violet-800">{s.qc} awaiting QC</p>
                      <p className="text-[10px] text-violet-600">Review submissions</p>
                    </div>
                    <ChevronRight className="h-3.5 w-3.5 text-violet-400" />
                  </Link>
                )}
                {unreadCount > 0 && (
                  <Link href="/chat" className="flex items-center gap-3 rounded-xl bg-blue-50 border border-blue-100 px-3 py-2.5 hover:border-blue-200 transition-colors">
                    <MessageSquare className="h-4 w-4 text-blue-600 shrink-0" />
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-medium text-blue-800">{unreadCount} unread message{unreadCount > 1 ? "s" : ""}</p>
                      <p className="text-[10px] text-blue-600">Clients & doers</p>
                    </div>
                    <ChevronRight className="h-3.5 w-3.5 text-blue-400" />
                  </Link>
                )}
              </div>
            )}
          </motion.div>
        </div>

        {/* ══════════════════════════════════════════════════════════
            ROW 4 — Projects + Quick Actions (side by side)
           ══════════════════════════════════════════════════════════ */}
        <div className="grid grid-cols-1 lg:grid-cols-[1fr_300px] gap-5 mb-5">
          <ProjectTable requests={needsQuote} qcProjects={needsQC} readyToAssign={readyProjects} onAnalyze={handleAnalyze} />
          <QuickActions assign={s.assign} doers={s.doers} unread={unreadCount} />
        </div>

        {/* ══════════════════════════════════════════════════════════
            ROW 5 — Activity | Messages | Earnings Summary
           ══════════════════════════════════════════════════════════ */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          <ActivityFeed needsQuote={needsQuote} completed={completed} inProgress={inProgress} />
          <MessagesCard rooms={rooms} unreadCount={unreadCount} />
          <EarningsSummary earnings={s.earn} growth={s.growth} done={s.done} doers={availableDoers} />
        </div>
      </motion.div>
    </div>
  )
}

// ══════════════════════════════════════════════════════════════════════════════
// PROJECT TABLE
// ══════════════════════════════════════════════════════════════════════════════

type ProjRow = { id: string; project_number: string; title: string; service_type: string; deadline: string | null; user?: { full_name: string | null }; created_at: string }
type QCRow = { id: string; project_number: string; title: string; service_type: string; deadline: string | null; user?: { full_name: string | null } }
type AssignRow = { id: string; project_number: string; title: string; service_type: string; deadline: string | null; user_quote: number | null; doer_payout: number | null; user?: { full_name: string | null } }

function ProjectTable({ requests, qcProjects, readyToAssign, onAnalyze }: { requests: ProjRow[]; qcProjects: QCRow[]; readyToAssign: AssignRow[]; onAnalyze: (id: string, num: string) => void }) {
  const [tab, setTab] = useState<"requests" | "qc" | "assign">("requests")
  const tabs = [
    { id: "requests" as const, label: "New Requests", count: requests.length, icon: FileText },
    { id: "qc" as const, label: "QC Queue", count: qcProjects.length, icon: Eye },
    { id: "assign" as const, label: "Ready to Assign", count: readyToAssign.length, icon: Zap },
  ]

  return (
    <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3, ease }} className="rounded-2xl bg-white border border-gray-200/80 overflow-hidden">
      <div className="px-5 pt-4 pb-0 border-b border-gray-100">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-sm font-semibold text-[#1C1C1C]">Your Projects</h2>
          <Link href="/projects" className="text-[11px] text-gray-400 hover:text-[#F97316] font-medium flex items-center gap-1 transition-colors">View all <ChevronRight className="h-3 w-3" /></Link>
        </div>
        <div className="flex items-center gap-0.5 -mb-px">
          {tabs.map((t) => (
            <button key={t.id} onClick={() => setTab(t.id)} className={cn("relative flex items-center gap-1.5 px-3.5 py-2.5 text-xs font-medium transition-colors", tab === t.id ? "text-[#F97316]" : "text-gray-400 hover:text-gray-600")}>
              <t.icon className="h-3.5 w-3.5" />
              {t.label}
              {t.count > 0 && <span className={cn("text-[10px] tabular-nums font-bold px-1.5 py-0.5 rounded-full", tab === t.id ? "bg-[#F97316]/10 text-[#F97316]" : "bg-gray-100 text-gray-500")}>{t.count}</span>}
              {tab === t.id && <motion.div layoutId="ptab" className="absolute bottom-0 left-0 right-0 h-[2px] bg-[#F97316] rounded-full" />}
            </button>
          ))}
        </div>
      </div>

      <AnimatePresence mode="wait">
        {tab === "requests" && (
          <motion.div key="req" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
            {requests.length === 0 ? <Empty msg="No new requests" sub="Requests from clients appear here automatically." /> : (
              <div className="divide-y divide-gray-50">
                {requests.slice(0, 6).map((p, i) => {
                  const urg = p.deadline && new Date(p.deadline) < new Date(Date.now() + 86400000)
                  return (
                    <motion.div key={p.id} initial={{ opacity: 0, x: -4 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: i * 0.03 }} className="flex items-center gap-4 px-5 py-3 hover:bg-orange-50/30 transition-colors group">
                      <div className="w-8 h-8 rounded-lg bg-orange-100 flex items-center justify-center shrink-0">
                        <span className="text-[10px] font-bold text-[#F97316]">{(p.user?.full_name || "U")[0]}</span>
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-0.5">
                          <span className="text-[10px] font-mono text-gray-400">#{p.project_number}</span>
                          <span className="text-[9px] px-1.5 py-0.5 rounded bg-gray-100 text-gray-500 font-semibold uppercase tracking-wider">{p.service_type.replace(/_/g, " ")}</span>
                          {urg && <span className="text-[9px] font-bold text-amber-700 bg-amber-100 px-1.5 py-0.5 rounded">Urgent</span>}
                        </div>
                        <p className="text-sm font-medium text-[#1C1C1C] truncate group-hover:text-[#F97316] transition-colors">{p.title}</p>
                      </div>
                      <Button size="sm" onClick={() => onAnalyze(p.id, p.project_number)} className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-lg px-3 h-8 text-[11px] font-semibold shadow-sm shadow-[#F97316]/15 active:scale-[0.97] transition-all shrink-0">
                        Analyze
                      </Button>
                    </motion.div>
                  )
                })}
                {requests.length > 6 && <Foot href="/projects?tab=requests" n={requests.length} l="requests" />}
              </div>
            )}
          </motion.div>
        )}
        {tab === "qc" && (
          <motion.div key="qc" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
            {qcProjects.length === 0 ? <Empty msg="QC queue is empty" sub="Submissions for quality check will appear here." /> : (
              <div className="divide-y divide-gray-50">
                {qcProjects.slice(0, 6).map((p, i) => (
                  <motion.div key={p.id} initial={{ opacity: 0, x: -4 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: i * 0.03 }}>
                    <Link href={`/projects/${p.id}`} className="flex items-center gap-4 px-5 py-3 hover:bg-amber-50/30 transition-colors group">
                      <div className="w-8 h-8 rounded-lg bg-amber-100 flex items-center justify-center shrink-0"><Eye className="h-4 w-4 text-amber-600" /></div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-0.5">
                          <span className="text-[10px] font-mono text-gray-400">#{p.project_number}</span>
                          <span className="text-[9px] px-1.5 py-0.5 rounded bg-gray-100 text-gray-500 font-semibold uppercase tracking-wider">{p.service_type.replace(/_/g, " ")}</span>
                        </div>
                        <p className="text-sm font-medium text-[#1C1C1C] truncate group-hover:text-[#F97316] transition-colors">{p.title}</p>
                      </div>
                      <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-amber-700 bg-amber-100 px-2.5 py-1 rounded-lg group-hover:bg-amber-200 transition-colors shrink-0">Review <ArrowRight className="h-3 w-3" /></span>
                    </Link>
                  </motion.div>
                ))}
                {qcProjects.length > 6 && <Foot href="/projects?tab=review" n={qcProjects.length} l="QC items" />}
              </div>
            )}
          </motion.div>
        )}
        {tab === "assign" && (
          <motion.div key="asgn" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
            {readyToAssign.length === 0 ? <Empty msg="Nothing to assign" sub="Projects appear after payment is confirmed." /> : (
              <div className="divide-y divide-gray-50">
                {readyToAssign.slice(0, 6).map((p, i) => (
                  <motion.div key={p.id} initial={{ opacity: 0, x: -4 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: i * 0.03 }}>
                    <Link href={`/projects/${p.id}`} className="flex items-center gap-4 px-5 py-3 hover:bg-emerald-50/30 transition-colors group">
                      <div className="w-8 h-8 rounded-lg bg-emerald-100 flex items-center justify-center shrink-0"><Zap className="h-4 w-4 text-emerald-600" /></div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-0.5">
                          <span className="text-[10px] font-mono text-gray-400">#{p.project_number}</span>
                          {p.user_quote && <span className="text-[10px] font-semibold text-[#1C1C1C] tabular-nums">₹{p.user_quote.toLocaleString("en-IN")}</span>}
                        </div>
                        <p className="text-sm font-medium text-[#1C1C1C] truncate group-hover:text-[#F97316] transition-colors">{p.title}</p>
                      </div>
                      <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-700 bg-emerald-100 px-2.5 py-1 rounded-lg group-hover:bg-emerald-200 transition-colors shrink-0">Assign <ArrowRight className="h-3 w-3" /></span>
                    </Link>
                  </motion.div>
                ))}
                {readyToAssign.length > 6 && <Foot href="/projects?tab=ready" n={readyToAssign.length} l="projects" />}
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  )
}

function Empty({ msg, sub }: { msg: string; sub: string }) {
  return (
    <div className="px-5 py-12 text-center">
      <div className="w-10 h-10 rounded-xl bg-gray-100 flex items-center justify-center mx-auto mb-3"><CheckCircle2 className="h-5 w-5 text-gray-400" /></div>
      <p className="text-xs font-medium text-gray-500 mb-1">{msg}</p>
      <p className="text-[10px] text-gray-400 max-w-[240px] mx-auto">{sub}</p>
    </div>
  )
}

function Foot({ href, n, l }: { href: string; n: number; l: string }) {
  return (
    <div className="px-5 py-2.5 bg-gray-50/50">
      <Link href={href} className="text-[11px] text-[#F97316] hover:text-[#EA580C] font-semibold flex items-center gap-1 transition-colors">View all {n} {l} <ArrowRight className="h-3 w-3" /></Link>
    </div>
  )
}

// ══════════════════════════════════════════════════════════════════════════════
// QUICK ACTIONS
// ══════════════════════════════════════════════════════════════════════════════

function QuickActions({ assign, doers, unread }: { assign: number; doers: number; unread: number }) {
  const actions = [
    { label: "Assign Projects", desc: assign > 0 ? `${assign} waiting` : "All assigned", icon: Zap, href: "/projects?tab=ready", iconBg: "bg-[#F97316]/10", iconColor: "text-[#1C1C1C]", gradient: "from-orange-500/10 to-orange-500/5" },
    { label: "Manage Doers", desc: doers > 0 ? `${doers} experts` : "Build team", icon: Users, href: "/doers", iconBg: "bg-[#F97316]/10", iconColor: "text-[#1C1C1C]", gradient: "from-orange-500/10 to-orange-500/5" },
    { label: "Messages", desc: unread > 0 ? `${unread} unread` : "All read", icon: MessageSquare, href: "/chat", iconBg: "bg-[#F97316]/10", iconColor: "text-[#1C1C1C]", gradient: "from-orange-500/10 to-orange-500/5" },
    { label: "Earnings", desc: "Payouts & stats", icon: Wallet, href: "/earnings", iconBg: "bg-[#F97316]/10", iconColor: "text-[#1C1C1C]", gradient: "from-orange-500/10 to-orange-500/5" },
    { label: "Resources", desc: "Guides & tools", icon: BookOpen, href: "/resources", iconBg: "bg-[#F97316]/10", iconColor: "text-[#1C1C1C]", gradient: "from-orange-500/10 to-orange-500/5" },
    { label: "Users", desc: "Client base", icon: Users, href: "/users", iconBg: "bg-[#F97316]/10", iconColor: "text-[#1C1C1C]", gradient: "from-orange-500/10 to-orange-500/5" },
  ]

  return (
    <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.35, ease }} className="rounded-2xl bg-white border border-gray-200/80 overflow-hidden">
      <div className="px-4 py-3 border-b border-gray-100 flex items-center gap-2">
        <div className="w-6 h-6 rounded-md bg-[#F97316]/10 flex items-center justify-center">
          <Sparkles className="h-3 w-3 text-[#1C1C1C]" />
        </div>
        <h3 className="text-xs font-semibold text-[#1C1C1C]">Quick Actions</h3>
      </div>
      <div className="p-2.5 grid grid-cols-2 gap-2">
        {actions.map((a, i) => (
          <motion.div key={a.label} initial={{ opacity: 0, scale: 0.96 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.38 + i * 0.04, ease }}>
            <Link href={a.href}>
              <div className="group relative overflow-hidden rounded-xl border border-gray-100 p-3.5 hover:border-[#F97316]/20 hover:shadow-md hover:-translate-y-0.5 transition-all duration-300 cursor-pointer">
                <div className={cn("absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none", a.gradient)} />
                <div className="relative z-10">
                  <div className={cn("w-9 h-9 rounded-xl flex items-center justify-center mb-2.5 transition-transform duration-300 group-hover:scale-110", a.iconBg)}>
                    <a.icon className={cn("h-4 w-4", a.iconColor)} />
                  </div>
                  <p className="text-xs font-semibold text-[#1C1C1C] group-hover:text-[#F97316] transition-colors">{a.label}</p>
                  <p className="text-[10px] text-gray-400 mt-0.5">{a.desc}</p>
                </div>
              </div>
            </Link>
          </motion.div>
        ))}
      </div>
    </motion.div>
  )
}

// ══════════════════════════════════════════════════════════════════════════════
// EARNINGS SUMMARY — charcoal card for bottom row
// ══════════════════════════════════════════════════════════════════════════════

function EarningsSummary({ earnings, growth, done, doers }: { earnings: number; growth: number; done: number; doers: number }) {
  return (
    <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.45, ease }} className="relative overflow-hidden rounded-2xl bg-[#1C1C1C] border border-white/[0.06] p-5">
      <div className="absolute -top-10 -right-10 w-28 h-28 bg-[#F97316]/15 blur-[50px] rounded-full pointer-events-none" />
      <div className="absolute inset-0 opacity-[0.025] pointer-events-none" style={{ backgroundImage: "radial-gradient(circle, rgba(255,255,255,0.5) 1px, transparent 1px)", backgroundSize: "20px 20px" }} />

      <div className="relative z-10">
        <div className="flex items-center gap-2 mb-4">
          <div className="w-8 h-8 rounded-lg bg-[#F97316]/10 flex items-center justify-center">
            <IndianRupee className="h-4 w-4 text-[#F97316]" />
          </div>
          <div>
            <p className="text-xs font-semibold text-white">Earnings Overview</p>
            <p className="text-[10px] text-white/35">This month&apos;s summary</p>
          </div>
        </div>

        <div className="space-y-3 mb-4">
          {[
            { label: "Commission earned", value: `₹${earnings.toLocaleString("en-IN")}`, highlight: true },
            { label: "Projects delivered", value: String(done) },
            { label: "Active doers", value: String(doers) },
            { label: "Monthly growth", value: growth > 0 ? `+${Math.round(growth)}%` : `${Math.round(growth)}%`, green: growth > 0 },
          ].map((r) => (
            <div key={r.label} className="flex items-center justify-between">
              <span className="text-[11px] text-white/40">{r.label}</span>
              <span className={cn("text-sm font-semibold tabular-nums", r.highlight ? "text-[#F97316]" : r.green ? "text-emerald-400" : "text-white/70")}>{r.value}</span>
            </div>
          ))}
        </div>

        <Link href="/earnings">
          <motion.div whileHover={{ x: 3 }} className="inline-flex items-center gap-2 text-[11px] font-semibold text-[#F97316] cursor-pointer">
            View full report
            <div className="w-5 h-5 rounded-full bg-[#F97316] flex items-center justify-center">
              <ArrowRight className="h-3 w-3 text-white" />
            </div>
          </motion.div>
        </Link>
      </div>
    </motion.div>
  )
}

// ══════════════════════════════════════════════════════════════════════════════
// MESSAGES
// ══════════════════════════════════════════════════════════════════════════════

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function MessagesCard({ rooms, unreadCount }: { rooms: any[]; unreadCount: number }) {
  const recent = useMemo(() => (rooms || []).filter((r: { last_message?: string | null }) => r.last_message).sort((a: { updated_at?: string | null }, b: { updated_at?: string | null }) => new Date(b.updated_at || 0).getTime() - new Date(a.updated_at || 0).getTime()).slice(0, 4), [rooms])

  return (
    <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.35, ease }} className="rounded-2xl bg-white border border-gray-200/80 overflow-hidden">
      <div className="flex items-center justify-between px-4 py-3 border-b border-gray-100">
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded-md bg-[#F97316]/10 flex items-center justify-center">
            <MessageSquare className="h-3 w-3 text-[#1C1C1C]" />
          </div>
          <h3 className="text-xs font-semibold text-[#1C1C1C]">Messages</h3>
          {unreadCount > 0 && <span className="text-[9px] font-bold text-white bg-[#F97316] px-1.5 py-0.5 rounded-full tabular-nums min-w-[18px] text-center">{unreadCount}</span>}
        </div>
        <Link href="/chat" className="text-[10px] text-gray-400 hover:text-[#F97316] font-medium flex items-center gap-0.5 transition-colors">Open <ChevronRight className="h-3 w-3" /></Link>
      </div>
      {recent.length === 0 ? (
        <div className="px-4 py-8 text-center"><MessageSquare className="h-5 w-5 text-gray-300 mx-auto mb-2" /><p className="text-[11px] text-gray-400">No conversations yet</p></div>
      ) : (
        <div className="divide-y divide-gray-50">
          {recent.map((room: { id: string; projects?: { project_number?: string } | null; chat_participants?: Array<{ full_name?: string | null }>; last_message?: string | null; updated_at?: string | null }) => {
            const name = room.chat_participants?.find((cp) => cp.full_name)?.full_name || room.projects?.project_number || "Chat"
            return (
              <Link key={room.id} href="/chat" className="flex items-center gap-3 px-4 py-2.5 hover:bg-orange-50/20 transition-colors group">
                <div className="w-7 h-7 rounded-full bg-[#F97316]/10 flex items-center justify-center shrink-0"><span className="text-[10px] font-bold text-[#F97316]">{name[0]?.toUpperCase()}</span></div>
                <div className="flex-1 min-w-0">
                  <p className="text-[11px] font-medium text-[#1C1C1C] truncate group-hover:text-[#F97316] transition-colors">{name}</p>
                  <p className="text-[10px] text-gray-400 truncate">{room.last_message}</p>
                </div>
                {room.updated_at && <span className="text-[9px] text-gray-400 shrink-0 tabular-nums">{formatDistanceToNow(new Date(room.updated_at), { addSuffix: false })}</span>}
              </Link>
            )
          })}
        </div>
      )}
    </motion.div>
  )
}

// ══════════════════════════════════════════════════════════════════════════════
// ACTIVITY
// ══════════════════════════════════════════════════════════════════════════════

function ActivityFeed({ needsQuote, completed, inProgress }: { needsQuote: Array<{ id: string; title: string; created_at: string }>; completed: Array<{ id: string; title: string; updated_at: string | null }>; inProgress: Array<{ id: string; title: string; status: string; status_updated_at?: string | null }> }) {
  const items = useMemo(() => {
    const a: Array<{ id: string; type: "req" | "done" | "wip"; title: string; detail: string; time: Date; pid: string }> = []
    needsQuote.slice(0, 3).forEach((p) => a.push({ id: `r-${p.id}`, type: "req", title: "New request", detail: p.title, time: new Date(p.created_at), pid: p.id }))
    completed.slice(0, 2).forEach((p) => a.push({ id: `c-${p.id}`, type: "done", title: "Completed", detail: p.title, time: new Date(p.updated_at || Date.now()), pid: p.id }))
    inProgress.slice(0, 2).forEach((p) => a.push({ id: `p-${p.id}`, type: "wip", title: p.status.replace(/_/g, " "), detail: p.title, time: new Date(p.status_updated_at || Date.now()), pid: p.id }))
    return a.sort((x, y) => y.time.getTime() - x.time.getTime()).slice(0, 5)
  }, [needsQuote, completed, inProgress])

  const cfg = { req: { bg: "bg-orange-100", fg: "text-orange-600", ic: FileText }, done: { bg: "bg-emerald-100", fg: "text-emerald-600", ic: CheckCircle2 }, wip: { bg: "bg-blue-100", fg: "text-blue-600", ic: Clock } }

  return (
    <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4, ease }} className="rounded-2xl bg-white border border-gray-200/80 overflow-hidden">
      <div className="flex items-center justify-between px-4 py-3 border-b border-gray-100">
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded-md bg-[#F97316]/10 flex items-center justify-center">
            <Clock className="h-3 w-3 text-[#1C1C1C]" />
          </div>
          <h3 className="text-xs font-semibold text-[#1C1C1C]">Activity</h3>
          {items.length > 0 && <span className="relative flex h-1.5 w-1.5"><span className="animate-ping absolute h-full w-full rounded-full bg-emerald-400 opacity-75" /><span className="relative rounded-full h-1.5 w-1.5 bg-emerald-500" /></span>}
        </div>
        <Link href="/notifications" className="text-[10px] text-gray-400 hover:text-[#F97316] font-medium flex items-center gap-0.5 transition-colors">All <ChevronRight className="h-3 w-3" /></Link>
      </div>
      {items.length === 0 ? (
        <div className="px-4 py-8 text-center"><Clock className="h-5 w-5 text-gray-300 mx-auto mb-2" /><p className="text-[11px] text-gray-400">No recent activity</p></div>
      ) : (
        <div className="px-4 py-2">
          {items.map((a, i) => {
            const c = cfg[a.type]; const I = c.ic; const last = i === items.length - 1
            return (
              <Link key={a.id} href={`/projects/${a.pid}`} className="flex gap-2.5 group">
                <div className="flex flex-col items-center">
                  <div className={cn("w-7 h-7 rounded-md flex items-center justify-center shrink-0 group-hover:scale-110 transition-transform", c.bg)}><I className={cn("h-3.5 w-3.5", c.fg)} /></div>
                  {!last && <div className="w-px flex-1 bg-gray-100 my-1 min-h-[12px]" />}
                </div>
                <div className={cn("flex-1 min-w-0 pb-3", last && "pb-1")}>
                  <div className="flex items-center justify-between gap-2">
                    <p className="text-[11px] font-medium text-[#1C1C1C] group-hover:text-[#F97316] transition-colors">{a.title}</p>
                    <span className="text-[9px] text-gray-400 shrink-0 tabular-nums">{formatDistanceToNow(a.time, { addSuffix: false })}</span>
                  </div>
                  <p className="text-[10px] text-gray-400 truncate max-w-[220px]">{a.detail}</p>
                </div>
              </Link>
            )
          })}
        </div>
      )}
    </motion.div>
  )
}
