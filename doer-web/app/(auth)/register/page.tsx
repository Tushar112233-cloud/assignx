'use client'

import { useState, useRef, useEffect } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import {
  Loader2, Mail, ArrowRight, ArrowLeft, User, Briefcase, Building2,
  CheckCircle2, X, Sparkles, KeyRound, Clock,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from '@/components/ui/select'
import { apiClient } from '@/lib/api/client'
import { sendOTP, doerSignup } from '@/lib/api/auth'
import { QUALIFICATION_OPTIONS, EXPERIENCE_LEVELS } from '@/lib/constants'
import {
  doerEmailNameSchema, doerProfileSchema, doerBankingSchema,
  INDIAN_BANKS,
} from '@/lib/validations/auth'
import { useSubjects } from '@/lib/hooks/use-subjects'

const STEPS = [
  { label: 'Email', icon: Mail },
  { label: 'Profile', icon: Briefcase },
  { label: 'Banking', icon: Building2 },
  { label: 'Review', icon: CheckCircle2 },
  { label: 'Verify', icon: KeyRound },
] as const

export default function RegisterPage() {
  const router = useRouter()
  const { subjects: apiSubjects, isLoading: subjectsLoading } = useSubjects()
  const [step, setStep] = useState(1)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const [email, setEmail] = useState('')
  const [fullName, setFullName] = useState('')
  const [qualification, setQualification] = useState('')
  const [experienceLevel, setExperienceLevel] = useState('')
  const [skills, setSkills] = useState<string[]>([])
  const [bio, setBio] = useState('')
  const [bankName, setBankName] = useState('')
  const [accountNumber, setAccountNumber] = useState('')
  const [ifscCode, setIfscCode] = useState('')
  const [upiId, setUpiId] = useState('')
  const [otp, setOtp] = useState(['', '', '', '', '', ''])
  const [resendCooldown, setResendCooldown] = useState(0)
  const inputRefs = useRef<(HTMLInputElement | null)[]>([])

  useEffect(() => {
    if (resendCooldown <= 0) return
    const timer = setTimeout(() => setResendCooldown(resendCooldown - 1), 1000)
    return () => clearTimeout(timer)
  }, [resendCooldown])

  useEffect(() => {
    const code = otp.join('')
    if (code.length === 6 && step === 5) {
      handleOtpSubmit(code)
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [otp])

  const toggleSkill = (value: string) => {
    setSkills(prev => prev.includes(value) ? prev.filter(s => s !== value) : [...prev, value])
  }

  const handleOtpChange = (index: number, value: string) => {
    if (!/^\d*$/.test(value)) return
    const newOtp = [...otp]
    newOtp[index] = value.slice(-1)
    setOtp(newOtp)
    setError(null)
    if (value && index < 5) inputRefs.current[index + 1]?.focus()
  }

  const handleOtpKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) inputRefs.current[index - 1]?.focus()
  }

  const handleOtpPaste = (e: React.ClipboardEvent) => {
    e.preventDefault()
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
    if (pasted.length === 0) return
    const newOtp = [...otp]
    for (let i = 0; i < 6; i++) newOtp[i] = pasted[i] || ''
    setOtp(newOtp)
    inputRefs.current[Math.min(pasted.length, 5)]?.focus()
  }

  const validateStep = () => {
    setError(null)
    if (step === 1) {
      const result = doerEmailNameSchema.safeParse({ email: email.trim(), fullName: fullName.trim() })
      if (!result.success) { setError(result.error.issues[0].message); return false }
    } else if (step === 2) {
      const result = doerProfileSchema.safeParse({ qualification, experienceLevel, skills, bio: bio || undefined })
      if (!result.success) { setError(result.error.issues[0].message); return false }
    } else if (step === 3) {
      const result = doerBankingSchema.safeParse({ bankName, accountNumber, ifscCode: ifscCode.toUpperCase(), upiId: upiId || '' })
      if (!result.success) { setError(result.error.issues[0].message); return false }
    }
    return true
  }

  const handleNext = async () => {
    if (!validateStep()) return
    if (step === 1) {
      setIsLoading(true)
      setError(null)
      try {
        const trimmedEmail = email.trim().toLowerCase()

        // Check if email is registered on another platform
        try {
          const crossCheck = await apiClient<{ exists: boolean; role?: string }>(
            '/api/auth/check-account',
            {
              skipAuth: true,
              method: 'POST',
              body: JSON.stringify({ email: trimmedEmail, role: 'doer' }),
            }
          )
          if (crossCheck.exists && crossCheck.role && crossCheck.role !== 'doer') {
            setError(`This email is already registered as a ${crossCheck.role}. Each role requires a unique email.`)
            return
          }
        } catch {
          // If check-account fails (e.g. 404), continue with registration
        }

        // Check if already has an access request
        const existing = await apiClient<{ id: string; status: string }>(
          `/api/access-requests/check?email=${encodeURIComponent(trimmedEmail)}&role=doer`,
          { skipAuth: true }
        )
        if (existing) {
          const s = existing.status
          if (s === 'approved') { setError('This email is already approved. Please sign in instead.'); return }
          if (s === 'rejected') { setError('This email was not approved. Please contact support.'); return }
          if (s === 'pending') { router.push(`/pending?email=${encodeURIComponent(trimmedEmail)}`); return }
        }
      } catch { /* 404 = no existing request, continue */ } finally { setIsLoading(false) }
    }
    setStep(prev => prev + 1)
  }

  const handleBack = () => {
    setError(null)
    if (step === 5) setOtp(['', '', '', '', '', ''])
    setStep(prev => prev - 1)
  }

  const handleSendOtp = async () => {
    setIsLoading(true)
    setError(null)
    try {
      await sendOTP(email.trim().toLowerCase(), 'signup', 'doer')
      setStep(5)
      setResendCooldown(30)
      setTimeout(() => inputRefs.current[0]?.focus(), 100)
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to send verification code.')
    } finally { setIsLoading(false) }
  }

  const handleResendOtp = async () => {
    if (resendCooldown > 0) return
    try { setError(null); await sendOTP(email.trim().toLowerCase(), 'signup', 'doer'); setOtp(['', '', '', '', '', '']); setResendCooldown(30) }
    catch { setError('Failed to resend. Please try again.') }
  }

  const handleOtpSubmit = async (code?: string) => {
    const otpCode = code || otp.join('')
    if (otpCode.length !== 6) { setError('Please enter the 6-digit code.'); return }
    setIsLoading(true)
    setError(null)
    try {
      const trimmedEmail = email.trim().toLowerCase()
      const metadata = { qualification, experienceLevel, skills, bio: bio || null, bankName, accountNumber, ifscCode: ifscCode.toUpperCase(), upiId: upiId || null }
      const result = await doerSignup(trimmedEmail, otpCode, fullName.trim(), metadata)
      if (!result.success) { setError(result.message || 'Signup failed. Please try again.'); setOtp(['', '', '', '', '', '']); inputRefs.current[0]?.focus(); return }
      router.push(`/pending?email=${encodeURIComponent(trimmedEmail)}`)
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Something went wrong. Please try again.')
      setOtp(['', '', '', '', '', '']); inputRefs.current[0]?.focus()
    } finally { setIsLoading(false) }
  }

  return (
    <div className="space-y-6">
      {/* Mobile logo */}
      <div className="lg:hidden flex items-center gap-2.5 mb-2">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-[#5A7CFF]">
          <span className="text-xs font-bold text-white">D</span>
        </div>
        <span className="text-base font-bold tracking-tight text-slate-900">Dolancer</span>
      </div>

      {/* Header */}
      <div className="space-y-1">
        <div className="inline-flex items-center gap-1.5 rounded-full border border-[#5A7CFF]/20 bg-[#EEF2FF] px-3 py-1 text-xs font-semibold text-[#5A7CFF]">
          <Sparkles className="h-3 w-3" />
          Now accepting applications
        </div>
        <h1 className="text-xl font-bold tracking-tight text-slate-900">Become a Dolancer</h1>
        <p className="text-sm text-slate-500">Complete the form below to apply for access.</p>
      </div>

      {/* Stepper */}
      <div className="flex items-center justify-between">
        {STEPS.map((s, i) => {
          const stepNum = i + 1
          const isActive = stepNum === step
          const isCompleted = stepNum < step
          return (
            <div key={s.label} className="flex items-center flex-1 last:flex-none">
              <div className="flex flex-col items-center gap-1.5">
                <div className={`flex h-8 w-8 items-center justify-center rounded-full text-xs font-bold transition-all ${
                  isCompleted
                    ? 'bg-[#5A7CFF] text-white'
                    : isActive
                    ? 'bg-[#5A7CFF] text-white ring-4 ring-[#5A7CFF]/15'
                    : 'border-2 border-slate-200 text-slate-400'
                }`}>
                  {isCompleted ? <CheckCircle2 className="h-4 w-4" /> : stepNum}
                </div>
                <span className={`text-[10px] font-medium ${
                  isActive || isCompleted ? 'text-[#5A7CFF]' : 'text-slate-400'
                }`}>{s.label}</span>
              </div>
              {i < STEPS.length - 1 && (
                <div className={`mx-1.5 mb-5 h-0.5 flex-1 rounded-full ${
                  stepNum < step ? 'bg-[#5A7CFF]' : 'bg-slate-200'
                }`} />
              )}
            </div>
          )
        })}
      </div>

      {/* Form content */}
      <div>
        {step === 1 && (
          <div className="space-y-4">
            <div className="space-y-1.5">
              <Label htmlFor="email" className="text-sm font-medium text-slate-700">Email address</Label>
              <div className="relative">
                <Mail className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                <Input id="email" type="email" placeholder="you@example.com" value={email} onChange={(e) => setEmail(e.target.value)}
                  className="h-11 rounded-xl border-slate-200 bg-white pl-10 text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10" />
              </div>
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="fullName" className="text-sm font-medium text-slate-700">Full name</Label>
              <div className="relative">
                <User className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                <Input id="fullName" type="text" placeholder="Your full name" value={fullName} onChange={(e) => setFullName(e.target.value)}
                  className="h-11 rounded-xl border-slate-200 bg-white pl-10 text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10" />
              </div>
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-4">
            <div className="space-y-1.5">
              <Label className="text-sm font-medium text-slate-700">Qualification</Label>
              <Select value={qualification} onValueChange={setQualification}>
                <SelectTrigger className="w-full h-11 rounded-xl border-slate-200 bg-white">
                  <SelectValue placeholder="Select your qualification" />
                </SelectTrigger>
                <SelectContent>
                  {QUALIFICATION_OPTIONS.map(opt => (
                    <SelectItem key={opt.value} value={opt.value}>{opt.label}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-1.5">
              <Label className="text-sm font-medium text-slate-700">Experience level</Label>
              <div className="grid grid-cols-3 gap-2">
                {EXPERIENCE_LEVELS.map(level => (
                  <button key={level.value} type="button" onClick={() => setExperienceLevel(level.value)}
                    className={`rounded-xl border px-3 py-2.5 text-center transition-all ${
                      experienceLevel === level.value
                        ? 'border-[#5A7CFF] bg-[#EEF2FF] text-[#5A7CFF]'
                        : 'border-slate-200 bg-white text-slate-700 hover:border-slate-300'
                    }`}>
                    <p className="text-sm font-semibold">{level.label}</p>
                    <p className="text-[10px] text-slate-500">{level.description}</p>
                  </button>
                ))}
              </div>
            </div>

            <div className="space-y-1.5">
              <Label className="text-sm font-medium text-slate-700">
                Skill areas <span className="font-normal text-slate-400">({skills.length} selected)</span>
              </Label>
              {subjectsLoading ? (
                <div className="flex items-center justify-center py-4">
                  <Loader2 className="h-5 w-5 animate-spin text-slate-400" />
                  <span className="ml-2 text-sm text-slate-400">Loading subjects...</span>
                </div>
              ) : (
                <div className="flex flex-wrap gap-2">
                  {apiSubjects.map(subject => (
                    <button key={subject._id} type="button" onClick={() => toggleSkill(subject._id)}
                      className={`inline-flex items-center gap-1 rounded-full px-3 py-1.5 text-xs font-medium transition-all ${
                        skills.includes(subject._id)
                          ? 'bg-[#5A7CFF] text-white'
                          : 'border border-slate-200 bg-white text-slate-600 hover:border-slate-300'
                      }`}>
                      {subject.name}
                      {skills.includes(subject._id) && <X className="h-3 w-3" />}
                    </button>
                  ))}
                </div>
              )}
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="bio" className="text-sm font-medium text-slate-700">
                Bio <span className="font-normal text-slate-400">(optional)</span>
              </Label>
              <textarea id="bio" value={bio} onChange={(e) => setBio(e.target.value)} maxLength={500} rows={3}
                placeholder="Tell us about yourself..."
                className="w-full rounded-xl border border-slate-200 bg-white px-3.5 py-2.5 text-sm text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10 focus-visible:outline-none resize-none" />
              <p className="text-right text-[11px] text-slate-400">{bio.length}/500</p>
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-4">
            <div className="space-y-1.5">
              <Label className="text-sm font-medium text-slate-700">Bank name</Label>
              <Select value={bankName} onValueChange={setBankName}>
                <SelectTrigger className="w-full h-11 rounded-xl border-slate-200 bg-white">
                  <SelectValue placeholder="Select your bank" />
                </SelectTrigger>
                <SelectContent>
                  {INDIAN_BANKS.map(bank => (
                    <SelectItem key={bank.value} value={bank.value}>{bank.label}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="accountNumber" className="text-sm font-medium text-slate-700">Account number</Label>
              <Input id="accountNumber" type="text" inputMode="numeric" placeholder="Enter account number" value={accountNumber}
                onChange={(e) => setAccountNumber(e.target.value.replace(/\D/g, ''))} maxLength={18}
                className="h-11 rounded-xl border-slate-200 bg-white text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10" />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="ifscCode" className="text-sm font-medium text-slate-700">IFSC code</Label>
              <Input id="ifscCode" type="text" placeholder="e.g. SBIN0001234" value={ifscCode}
                onChange={(e) => setIfscCode(e.target.value.toUpperCase())} maxLength={11}
                className="h-11 rounded-xl border-slate-200 bg-white text-slate-900 uppercase placeholder:text-slate-400 placeholder:normal-case focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10" />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="upiId" className="text-sm font-medium text-slate-700">
                UPI ID <span className="font-normal text-slate-400">(optional)</span>
              </Label>
              <Input id="upiId" type="text" placeholder="yourname@upi" value={upiId} onChange={(e) => setUpiId(e.target.value)}
                className="h-11 rounded-xl border-slate-200 bg-white text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10" />
            </div>
          </div>
        )}

        {step === 4 && (
          <div className="space-y-3">
            <div className="rounded-xl border border-slate-200 bg-slate-50 p-4 space-y-3">
              <h3 className="text-sm font-semibold text-slate-700 flex items-center gap-2">
                <Mail className="h-4 w-4 text-[#5A7CFF]" /> Personal Details
              </h3>
              <div className="grid gap-1.5 text-sm">
                <div className="flex justify-between"><span className="text-slate-500">Email</span><span className="font-medium text-slate-900">{email}</span></div>
                <div className="flex justify-between"><span className="text-slate-500">Name</span><span className="font-medium text-slate-900">{fullName}</span></div>
              </div>
            </div>
            <div className="rounded-xl border border-slate-200 bg-slate-50 p-4 space-y-3">
              <h3 className="text-sm font-semibold text-slate-700 flex items-center gap-2">
                <Briefcase className="h-4 w-4 text-[#5A7CFF]" /> Professional Profile
              </h3>
              <div className="grid gap-1.5 text-sm">
                <div className="flex justify-between"><span className="text-slate-500">Qualification</span><span className="font-medium text-slate-900">{QUALIFICATION_OPTIONS.find(q => q.value === qualification)?.label}</span></div>
                <div className="flex justify-between"><span className="text-slate-500">Experience</span><span className="font-medium text-slate-900">{EXPERIENCE_LEVELS.find(e => e.value === experienceLevel)?.label}</span></div>
                <div>
                  <span className="text-slate-500">Skills</span>
                  <div className="flex flex-wrap gap-1 mt-1">
                    {skills.map(s => (
                      <span key={s} className="inline-block rounded-full bg-[#EEF2FF] px-2 py-0.5 text-xs font-medium text-[#5A7CFF]">
                        {apiSubjects.find(sub => sub._id === s)?.name ?? s}
                      </span>
                    ))}
                  </div>
                </div>
                {bio && <div><span className="text-slate-500">Bio</span><p className="mt-0.5 text-slate-700">{bio}</p></div>}
              </div>
            </div>
            <div className="rounded-xl border border-slate-200 bg-slate-50 p-4 space-y-3">
              <h3 className="text-sm font-semibold text-slate-700 flex items-center gap-2">
                <Building2 className="h-4 w-4 text-[#5A7CFF]" /> Bank Details
              </h3>
              <div className="grid gap-1.5 text-sm">
                <div className="flex justify-between"><span className="text-slate-500">Bank</span><span className="font-medium text-slate-900">{INDIAN_BANKS.find(b => b.value === bankName)?.label}</span></div>
                <div className="flex justify-between"><span className="text-slate-500">Account</span><span className="font-medium text-slate-900">{'*'.repeat(Math.max(0, accountNumber.length - 4))}{accountNumber.slice(-4)}</span></div>
                <div className="flex justify-between"><span className="text-slate-500">IFSC</span><span className="font-medium text-slate-900">{ifscCode.toUpperCase()}</span></div>
                {upiId && <div className="flex justify-between"><span className="text-slate-500">UPI</span><span className="font-medium text-slate-900">{upiId}</span></div>}
              </div>
            </div>
          </div>
        )}

        {step === 5 && (
          <div className="space-y-5">
            <div className="text-center space-y-2">
              <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-[#EEF2FF]">
                <KeyRound className="h-6 w-6 text-[#5A7CFF]" />
              </div>
              <h3 className="text-lg font-bold text-slate-900">Verify your email</h3>
              <p className="text-sm text-slate-500">
                Enter the 6-digit code sent to <span className="font-semibold text-slate-700">{email}</span>
              </p>
            </div>

            <div className="flex justify-center gap-2.5" onPaste={handleOtpPaste}>
              {otp.map((digit, i) => (
                <input key={i} ref={(el) => { inputRefs.current[i] = el }} type="text" inputMode="numeric" maxLength={1}
                  value={digit} onChange={(e) => handleOtpChange(i, e.target.value)} onKeyDown={(e) => handleOtpKeyDown(i, e)}
                  disabled={isLoading}
                  className="h-13 w-12 rounded-xl border-2 border-slate-200 bg-white text-center text-xl font-bold text-slate-900 transition-all focus:border-[#5A7CFF] focus:outline-none focus:ring-4 focus:ring-[#5A7CFF]/10 disabled:opacity-40" />
              ))}
            </div>

            <div className="flex justify-center items-center gap-2">
              {resendCooldown > 0 && (
                <span className="flex items-center gap-1 text-xs text-slate-400">
                  <Clock className="h-3.5 w-3.5" />{resendCooldown}s
                </span>
              )}
              <button type="button" disabled={resendCooldown > 0} onClick={handleResendOtp}
                className="text-sm font-medium text-[#5A7CFF] hover:underline underline-offset-4 disabled:text-slate-300 disabled:no-underline">
                Resend code
              </button>
            </div>
          </div>
        )}

        {error && (
          <div className="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
            {error}
          </div>
        )}

        <div className="mt-5 flex gap-3">
          {step > 1 && (
            <Button type="button" variant="outline" onClick={handleBack}
              className="h-11 rounded-xl border-slate-200 text-slate-700 hover:bg-slate-50 font-semibold">
              <ArrowLeft className="mr-1 h-4 w-4" /> Back
            </Button>
          )}

          {step < 4 ? (
            <Button type="button" onClick={handleNext} disabled={isLoading}
              className="h-11 flex-1 rounded-xl bg-[#5A7CFF] text-sm font-semibold text-white shadow-md shadow-[#5A7CFF]/20 hover:bg-[#4A6AEF] disabled:cursor-not-allowed disabled:opacity-40">
              {isLoading ? <><Loader2 className="mr-2 h-4 w-4 animate-spin" />Checking...</> : <>Continue<ArrowRight className="ml-2 h-4 w-4" /></>}
            </Button>
          ) : step === 4 ? (
            <Button type="button" onClick={handleSendOtp} disabled={isLoading}
              className="h-11 flex-1 rounded-xl bg-[#5A7CFF] text-sm font-semibold text-white shadow-md shadow-[#5A7CFF]/20 hover:bg-[#4A6AEF] disabled:cursor-not-allowed disabled:opacity-40">
              {isLoading ? <><Loader2 className="mr-2 h-4 w-4 animate-spin" />Sending code...</> : <>Submit & Verify<ArrowRight className="ml-2 h-4 w-4" /></>}
            </Button>
          ) : (
            <Button type="button" onClick={() => handleOtpSubmit()} disabled={isLoading || otp.join('').length !== 6}
              className="h-11 flex-1 rounded-xl bg-[#5A7CFF] text-sm font-semibold text-white shadow-md shadow-[#5A7CFF]/20 hover:bg-[#4A6AEF] disabled:cursor-not-allowed disabled:opacity-40">
              {isLoading ? <><Loader2 className="mr-2 h-4 w-4 animate-spin" />Submitting...</> : <>Verify & Submit<ArrowRight className="ml-2 h-4 w-4" /></>}
            </Button>
          )}
        </div>
      </div>

      <p className="text-center text-sm text-slate-500">
        Already have an account?{' '}
        <Link href="/login" className="font-semibold text-[#5A7CFF] hover:underline underline-offset-4">Sign in</Link>
      </p>
    </div>
  )
}
