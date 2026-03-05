/**
 * @fileoverview Supervisor login page — translucent glass aesthetic.
 * @module app/(auth)/login/page
 */

import { Suspense } from "react"
import Link from "next/link"
import { LoginForm } from "@/components/auth/login-form"
import { APP_NAME } from "@/lib/constants"
import { ShieldCheck, Zap, Clock, ArrowRight, Fingerprint } from "lucide-react"

export default function LoginPage() {
  return (
    <div className="animate-fade-in-up">
      {/* Mobile Logo */}
      <div className="lg:hidden flex items-center gap-3 mb-10">
        <div className="h-10 w-10 rounded-xl bg-[#F97316] flex items-center justify-center shadow-lg shadow-[#F97316]/20">
          <span className="text-base font-bold text-white">AX</span>
        </div>
        <div>
          <span className="text-lg font-semibold text-[#1C1C1C] tracking-tight">{APP_NAME}</span>
          <p className="text-[10px] text-[#F97316] font-semibold tracking-[0.15em]">SUPERVISOR</p>
        </div>
      </div>

      {/* Header */}
      <div className="mb-8">
        <div className="inline-flex items-center gap-2 rounded-full border border-[#F97316]/15 bg-[#F97316]/[0.06] backdrop-blur-sm px-3 py-1 text-[11px] font-semibold text-[#F97316] uppercase tracking-wider mb-4">
          <div className="h-1.5 w-1.5 rounded-full bg-[#F97316]" />
          Supervisor portal
        </div>
        <h1 className="text-[28px] font-bold tracking-tight text-[#1C1C1C]">
          Welcome back
        </h1>
        <p className="mt-2 text-sm text-gray-400 leading-relaxed">
          Sign in with your email — we'll send a verification code.
        </p>
      </div>

      {/* Form — glass card */}
      <div className="rounded-2xl border border-white/60 bg-white/70 backdrop-blur-xl p-6 shadow-[0_4px_24px_rgba(0,0,0,0.06)]">
        <Suspense fallback={<div className="h-32 flex items-center justify-center"><div className="h-5 w-5 animate-spin rounded-full border-2 border-[#F97316] border-t-transparent" /></div>}>
          <LoginForm />
        </Suspense>
      </div>

      {/* Trust cards row */}
      <div className="mt-5 grid grid-cols-3 gap-2.5">
        {[
          { icon: ShieldCheck, label: "Encrypted", sub: "End-to-end" },
          { icon: Fingerprint, label: "OTP Verified", sub: "6-digit code" },
          { icon: Zap, label: "Instant", sub: "No wait time" },
        ].map((item) => (
          <div
            key={item.label}
            className="rounded-xl border border-gray-200/50 bg-white/50 backdrop-blur-sm p-3 text-center"
          >
            <item.icon className="h-4 w-4 text-[#F97316]/50 mx-auto mb-1.5" />
            <p className="text-[11px] font-semibold text-[#1C1C1C]">{item.label}</p>
            <p className="text-[10px] text-gray-400">{item.sub}</p>
          </div>
        ))}
      </div>

      {/* Activity card — translucent */}
      <div className="mt-4 rounded-xl border border-gray-200/40 bg-white/40 backdrop-blur-sm p-4 flex items-center gap-3">
        <div className="relative shrink-0">
          <div className="h-9 w-9 rounded-lg bg-emerald-500/10 flex items-center justify-center">
            <Clock className="h-4 w-4 text-emerald-600/60" />
          </div>
          <div className="absolute -top-0.5 -right-0.5 h-2.5 w-2.5 rounded-full bg-emerald-500 border-2 border-[#F5F5F5]" />
        </div>
        <div className="min-w-0">
          <p className="text-xs font-medium text-[#1C1C1C]/80">12 supervisors active now</p>
          <p className="text-[10px] text-gray-400">Last login 2 min ago</p>
        </div>
        <div className="ml-auto flex -space-x-1.5">
          {["#F97316", "#EA580C", "#1C1C1C"].map((bg, i) => (
            <div
              key={i}
              className="h-6 w-6 rounded-full border-2 border-[#F5F5F5] flex items-center justify-center text-[9px] font-bold text-white"
              style={{ backgroundColor: bg, opacity: 1 - i * 0.2 }}
            >
              {["A", "K", "+"][i]}
            </div>
          ))}
        </div>
      </div>

      {/* Register CTA — dark glass */}
      <div className="mt-6 rounded-xl bg-[#1C1C1C] border border-white/[0.06] p-4 flex items-center justify-between group hover:bg-[#222222] transition-all">
        <div>
          <p className="text-sm font-medium text-white">New to AssignX?</p>
          <p className="text-[11px] text-white/35 mt-0.5">Apply for supervisor access</p>
        </div>
        <Link
          href="/register"
          className="h-9 w-9 rounded-lg bg-[#F97316] flex items-center justify-center shrink-0 shadow-lg shadow-[#F97316]/20 group-hover:shadow-[#F97316]/30 group-hover:scale-105 transition-all"
        >
          <ArrowRight className="h-4 w-4 text-white" />
        </Link>
      </div>

      {/* Footer links */}
      <div className="mt-6 flex items-center justify-center gap-4 text-[11px] text-gray-300">
        <a href="#" className="hover:text-gray-500 transition-colors">Terms</a>
        <span className="text-gray-200">·</span>
        <a href="#" className="hover:text-gray-500 transition-colors">Privacy</a>
        <span className="text-gray-200">·</span>
        <a href="#" className="hover:text-gray-500 transition-colors">Help</a>
      </div>
    </div>
  )
}
