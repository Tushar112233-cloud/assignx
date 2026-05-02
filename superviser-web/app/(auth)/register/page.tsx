"use client"

/**
 * @fileoverview Supervisor registration page — translucent glass aesthetic.
 * @module app/(auth)/register/page
 */

import Link from "next/link"
import { RegisterForm } from "@/components/auth/register-form"
import { APP_NAME } from "@/lib/constants"
import { ArrowLeft } from "lucide-react"

export default function RegisterPage() {
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

      {/* Back to login — glass pill */}
      <Link
        href="/login"
        className="inline-flex items-center gap-1.5 rounded-full border border-gray-200/50 bg-white/50 backdrop-blur-sm px-3 py-1.5 text-xs font-medium text-gray-400 hover:text-[#1C1C1C] hover:bg-white/80 transition-all mb-6 group"
      >
        <ArrowLeft className="h-3 w-3 group-hover:-translate-x-0.5 transition-transform" />
        Sign in instead
      </Link>

      {/* Header */}
      <div className="mb-8">
        <div className="inline-flex items-center gap-2 rounded-full border border-[#F97316]/15 bg-[#F97316]/[0.06] backdrop-blur-sm px-3 py-1 text-[11px] font-semibold text-[#F97316] uppercase tracking-wider mb-4">
          <div className="h-1.5 w-1.5 rounded-full bg-[#F97316]" />
          Apply for access
        </div>
        <h1 className="text-[28px] font-bold tracking-tight text-[#1C1C1C]">
          Apply to become a Supervisor
        </h1>
        <p className="mt-2 text-sm text-gray-400 leading-relaxed">
          Complete your profile to apply for supervisor access.
        </p>
      </div>

      {/* Form — glass card */}
      <div className="rounded-2xl border border-white/60 bg-white/70 backdrop-blur-xl p-6 shadow-[0_4px_24px_rgba(0,0,0,0.06)]">
        <RegisterForm />
      </div>

      {/* Footer links */}
      <div className="mt-8 flex items-center justify-center gap-4 text-[11px] text-gray-300">
        <a href="#" className="hover:text-gray-500 transition-colors">Terms</a>
        <span className="text-gray-200">·</span>
        <a href="#" className="hover:text-gray-500 transition-colors">Privacy</a>
        <span className="text-gray-200">·</span>
        <a href="#" className="hover:text-gray-500 transition-colors">Help</a>
      </div>
    </div>
  )
}
