/**
 * @fileoverview Auth layout — dark glass panel + translucent form panel.
 * @module app/(auth)/layout
 */

import { APP_NAME } from "@/lib/constants"
import { Shield, Lock, Eye, TrendingUp, Users, Star } from "lucide-react"

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen bg-[#F5F5F5]">
      <div className="flex">
        {/* ── Left Panel ── */}
        <div className="hidden lg:flex lg:w-[48%] fixed h-screen bg-[#111111] overflow-hidden">
          {/* Ambient glows */}
          <div className="absolute -top-40 -left-40 w-[500px] h-[500px] bg-[#F97316]/10 blur-[160px] rounded-full pointer-events-none" />
          <div className="absolute bottom-[-80px] right-[-80px] w-[450px] h-[450px] bg-[#F97316]/15 blur-[140px] rounded-full pointer-events-none" />
          <div className="absolute top-1/2 left-1/3 w-64 h-64 bg-[#F97316]/5 blur-[100px] rounded-full pointer-events-none" />

          {/* Dot grid */}
          <div
            className="absolute inset-0 opacity-[0.035] pointer-events-none"
            style={{
              backgroundImage: "radial-gradient(circle, rgba(255,255,255,0.7) 1px, transparent 1px)",
              backgroundSize: "28px 28px",
            }}
          />

          {/* Decorative rings */}
          <div className="absolute -top-24 -right-24 w-80 h-80 rounded-full border border-white/[0.03] pointer-events-none" />
          <div className="absolute -top-16 -right-16 w-64 h-64 rounded-full border border-[#F97316]/[0.06] pointer-events-none" />
          <div className="absolute -bottom-16 -left-16 w-48 h-48 rounded-full border border-white/[0.03] pointer-events-none" />

          {/* Content */}
          <div className="relative z-10 flex flex-col justify-between h-full w-full p-10 xl:p-14">
            {/* Logo */}
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-[#F97316] flex items-center justify-center shadow-lg shadow-[#F97316]/25">
                <span className="text-base font-bold text-white">AX</span>
              </div>
              <div>
                <span className="text-lg font-semibold text-white tracking-tight">{APP_NAME}</span>
                <p className="text-[10px] text-[#F97316]/70 font-semibold tracking-[0.15em]">SUPERVISOR</p>
              </div>
            </div>

            {/* Center content */}
            <div className="space-y-7">
              {/* Tagline */}
              <div>
                <div className="w-8 h-1 rounded-full bg-[#F97316] mb-6" />
                <h1 className="text-4xl xl:text-[46px] font-bold leading-[1.08] tracking-tight text-white">
                  Review smarter,
                  <br />
                  <span className="text-[#F97316]">not harder.</span>
                </h1>
                <p className="mt-5 text-[15px] text-white/40 max-w-sm leading-relaxed">
                  One focused workspace to approve, escalate, and track every decision.
                </p>
              </div>

              {/* Glass stat cards */}
              <div className="grid grid-cols-3 gap-3 max-w-md">
                {[
                  { value: "98%", label: "QC on-time", icon: TrendingUp },
                  { value: "500+", label: "Supervisors", icon: Users },
                  { value: "4.9", label: "Avg. rating", icon: Star },
                ].map((stat) => (
                  <div
                    key={stat.label}
                    className="rounded-xl border border-white/[0.06] bg-white/[0.03] backdrop-blur-sm p-3.5"
                  >
                    <stat.icon className="h-3.5 w-3.5 text-[#F97316]/60 mb-2" />
                    <p className="text-xl font-bold text-white">{stat.value}</p>
                    <p className="text-[10px] text-white/30 mt-0.5">{stat.label}</p>
                  </div>
                ))}
              </div>

              {/* Glass testimonial card */}
              <div className="rounded-xl border border-white/[0.06] bg-white/[0.03] backdrop-blur-sm p-5 max-w-md">
                <p className="text-sm text-white/50 leading-relaxed italic">
                  &ldquo;Finally, a review workspace that doesn&apos;t fight me. Everything I need, nothing I don&apos;t.&rdquo;
                </p>
                <div className="mt-3.5 flex items-center gap-3">
                  <div className="h-8 w-8 rounded-full bg-[#F97316]/20 flex items-center justify-center text-xs font-bold text-[#F97316]">
                    S
                  </div>
                  <div>
                    <p className="text-xs font-medium text-white/70">Supervisor</p>
                    <p className="text-[10px] text-white/30">Quality Lead</p>
                  </div>
                  <div className="ml-auto flex gap-0.5">
                    {[...Array(5)].map((_, i) => (
                      <Star key={i} className="h-3 w-3 fill-[#F97316]/60 text-[#F97316]/60" />
                    ))}
                  </div>
                </div>
              </div>

              {/* Feature pills */}
              <div className="flex flex-wrap gap-2">
                {[
                  { icon: Shield, text: "Audit trails" },
                  { icon: Lock, text: "Role-gated" },
                  { icon: Eye, text: "Risk scoring" },
                ].map((pill) => (
                  <div
                    key={pill.text}
                    className="flex items-center gap-2 rounded-full border border-white/[0.06] bg-white/[0.02] backdrop-blur-sm px-3.5 py-2 text-xs text-white/40"
                  >
                    <pill.icon className="h-3.5 w-3.5 text-[#F97316]/50" />
                    {pill.text}
                  </div>
                ))}
              </div>
            </div>

            {/* Footer */}
            <div className="flex items-center justify-between">
              <p className="text-[11px] text-white/15">
                &copy; {new Date().getFullYear()} AssignX
              </p>
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-1.5">
                  <div className="h-1.5 w-1.5 rounded-full bg-emerald-500/80 animate-pulse" />
                  <span className="text-[10px] text-white/25">All systems online</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* ── Right Panel ── */}
        <div className="lg:ml-[48%] flex-1 min-h-screen relative overflow-hidden">
          {/* Background accents */}
          <div className="absolute top-[-100px] right-[-60px] w-[400px] h-[400px] bg-[#F97316]/[0.04] blur-[100px] rounded-full pointer-events-none" />
          <div className="absolute bottom-[-80px] left-[-40px] w-72 h-72 bg-[#F97316]/[0.03] blur-[80px] rounded-full pointer-events-none" />

          <div className="relative flex min-h-screen items-center justify-center px-6 py-12 lg:px-12">
            <div className="w-full max-w-[420px]">
              {children}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
