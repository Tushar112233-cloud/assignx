'use client'

import { motion } from 'framer-motion'
import { HelpCircle, FileText, LogOut, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'

/**
 * SettingsSidebar - Quick actions and helpful links
 */
export function SettingsSidebar() {
  return (
    <motion.aside
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.5, delay: 0.2 }}
      className="space-y-6"
    >
      {/* Quick Actions */}
      <div className="rounded-[24px] border border-white/70 bg-white/85 p-6 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
        <h3 className="text-base font-semibold text-slate-900 mb-4">Quick Actions</h3>
        <div className="space-y-3">
          <Button
            variant="outline"
            className="w-full justify-start gap-3 h-11 rounded-2xl border-slate-200/80 bg-white text-slate-700 hover:bg-slate-50"
          >
            <HelpCircle className="h-5 w-5 text-[#4F6CF7]" />
            <span>Get Help</span>
          </Button>

          <Button
            variant="outline"
            className="w-full justify-start gap-3 h-11 rounded-2xl border-slate-200/80 bg-white text-slate-700 hover:bg-slate-50"
          >
            <FileText className="h-5 w-5 text-[#4B9BFF]" />
            <span>Privacy Policy</span>
          </Button>

          <Button
            variant="outline"
            className="w-full justify-start gap-3 h-11 rounded-2xl border-slate-200/80 bg-white text-slate-700 hover:bg-slate-50"
          >
            <FileText className="h-5 w-5 text-[#6B5BFF]" />
            <span>Terms of Service</span>
          </Button>
        </div>
      </div>

      {/* Account Actions */}
      <div className="rounded-[24px] border border-white/70 bg-white/85 p-6 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
        <h3 className="text-base font-semibold text-slate-900 mb-4">Account</h3>
        <div className="space-y-3">
          <Button
            variant="outline"
            className="w-full justify-start gap-3 h-11 rounded-2xl border-slate-200/80 bg-white text-slate-700 hover:bg-slate-50"
          >
            <LogOut className="h-5 w-5 text-slate-600" />
            <span>Sign Out</span>
          </Button>

          <Button
            variant="outline"
            className="w-full justify-start gap-3 h-11 rounded-2xl border-red-200/80 bg-white text-red-600 hover:bg-red-50"
          >
            <Trash2 className="h-5 w-5" />
            <span>Delete Account</span>
          </Button>
        </div>
      </div>

      {/* Support Card */}
      <div className="rounded-[24px] bg-gradient-to-br from-[#EEF2FF] to-[#E6F4FF] p-6 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
        <div className="space-y-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white shadow-sm">
            <HelpCircle className="h-5 w-5 text-[#5A7CFF]" />
          </div>
          <h3 className="text-base font-semibold text-slate-900">Need Help?</h3>
          <p className="text-sm text-slate-600">
            Our support team is here to help you with any questions or issues.
          </p>
          <Button className="w-full h-11 rounded-2xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white shadow-[0_12px_28px_rgba(90,124,255,0.35)] hover:-translate-y-0.5 transition-all">
            Contact Support
          </Button>
        </div>
      </div>
    </motion.aside>
  )
}
