'use client'

import { useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import {
  Loader2, Mail, ArrowRight, ArrowLeft, User, Briefcase, Building2,
  CheckCircle2, X, Sparkles,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from '@/components/ui/select'
import { apiClient } from '@/lib/api/client'
import { QUALIFICATION_OPTIONS, EXPERIENCE_LEVELS } from '@/lib/constants'
import {
  doerEmailNameSchema, doerProfileSchema, doerBankingSchema,
  INDIAN_BANKS, SKILL_AREAS,
  type DoerEmailNameData, type DoerProfileData, type DoerBankingData,
} from '@/lib/validations/auth'

const STEPS = [
  { label: 'Email', icon: Mail },
  { label: 'Profile', icon: Briefcase },
  { label: 'Banking', icon: Building2 },
  { label: 'Review', icon: CheckCircle2 },
] as const

export default function RegisterPage() {
  const router = useRouter()
  const [step, setStep] = useState(1)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Step 1 data
  const [email, setEmail] = useState('')
  const [fullName, setFullName] = useState('')

  // Step 2 data
  const [qualification, setQualification] = useState('')
  const [experienceLevel, setExperienceLevel] = useState('')
  const [skills, setSkills] = useState<string[]>([])
  const [bio, setBio] = useState('')

  // Step 3 data
  const [bankName, setBankName] = useState('')
  const [accountNumber, setAccountNumber] = useState('')
  const [ifscCode, setIfscCode] = useState('')
  const [upiId, setUpiId] = useState('')

  const toggleSkill = (value: string) => {
    setSkills(prev =>
      prev.includes(value)
        ? prev.filter(s => s !== value)
        : [...prev, value]
    )
  }

  const validateStep = () => {
    setError(null)
    if (step === 1) {
      const result = doerEmailNameSchema.safeParse({ email: email.trim(), fullName: fullName.trim() })
      if (!result.success) {
        setError(result.error.issues[0].message)
        return false
      }
    } else if (step === 2) {
      const result = doerProfileSchema.safeParse({ qualification, experienceLevel, skills, bio: bio || undefined })
      if (!result.success) {
        setError(result.error.issues[0].message)
        return false
      }
    } else if (step === 3) {
      const result = doerBankingSchema.safeParse({
        bankName,
        accountNumber,
        ifscCode: ifscCode.toUpperCase(),
        upiId: upiId || '',
      })
      if (!result.success) {
        setError(result.error.issues[0].message)
        return false
      }
    }
    return true
  }

  const handleNext = async () => {
    if (!validateStep()) return

    if (step === 1) {
      // Check if already submitted
      setIsLoading(true)
      setError(null)
      try {
        const existing = await apiClient<{ id: string; status: string }>(
          `/api/access-requests/check?email=${encodeURIComponent(email.trim().toLowerCase())}&role=doer`,
          { skipAuth: true }
        )

        if (existing) {
          const s = existing.status
          if (s === 'approved') {
            setError('This email is already approved. Please sign in instead.')
            return
          }
          if (s === 'rejected') {
            setError('This email was not approved. Please contact support.')
            return
          }
          if (s === 'pending') {
            router.push(`/pending?email=${encodeURIComponent(email.trim().toLowerCase())}`)
            return
          }
        }
      } catch {
        // continue to next step even if check fails (404 means no existing request)
      } finally {
        setIsLoading(false)
      }
    }

    setStep(prev => prev + 1)
  }

  const handleBack = () => {
    setError(null)
    setStep(prev => prev - 1)
  }

  const handleSubmit = async () => {
    setIsLoading(true)
    setError(null)

    try {
      const trimmedEmail = email.trim().toLowerCase()

      const metadata = {
        qualification,
        experienceLevel,
        skills,
        bio: bio || null,
        bankName,
        accountNumber,
        ifscCode: ifscCode.toUpperCase(),
        upiId: upiId || null,
      }

      await apiClient('/api/access-requests', {
        method: 'POST',
        body: JSON.stringify({
          email: trimmedEmail,
          role: 'doer',
          full_name: fullName.trim(),
          metadata,
        }),
        skipAuth: true,
      })

      router.push(`/pending?email=${encodeURIComponent(trimmedEmail)}`)
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Something went wrong. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      {/* Mobile logo */}
      <div className="lg:hidden flex items-center gap-3">
        <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-teal-500 to-emerald-600 flex items-center justify-center shadow-lg shadow-teal-500/20">
          <span className="text-lg font-bold text-white">AX</span>
        </div>
        <div>
          <p className="text-base font-bold text-slate-900">AssignX</p>
          <p className="text-xs text-slate-500">Doer Portal</p>
        </div>
      </div>

      {/* Header */}
      <div className="space-y-2">
        <div className="inline-flex items-center gap-1.5 rounded-full bg-[#EEF2FF] border border-[#C7D2FE] px-3 py-1 text-xs font-semibold text-[#5A7CFF]">
          <Sparkles className="h-3 w-3" />
          Now accepting applications
        </div>
        <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">
          Become a Doer
        </h1>
        <p className="text-sm text-slate-500">
          Complete the form below to apply for access.
        </p>
      </div>

      {/* Stepper */}
      <div className="flex items-center justify-between">
        {STEPS.map((s, i) => {
          const stepNum = i + 1
          const isActive = stepNum === step
          const isCompleted = stepNum < step
          const isUpcoming = stepNum > step
          return (
            <div key={s.label} className="flex items-center gap-1.5 flex-1">
              <div className="flex flex-col items-center gap-1 flex-shrink-0">
                <div
                  className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold transition-all ${
                    isCompleted
                      ? 'bg-emerald-500 text-white'
                      : isActive
                      ? 'bg-[#5A7CFF] text-white'
                      : 'border-2 border-slate-200 text-slate-400'
                  }`}
                >
                  {isCompleted ? <CheckCircle2 className="h-4 w-4" /> : stepNum}
                </div>
                <span className={`text-[10px] font-medium ${
                  isActive ? 'text-[#5A7CFF]' : isCompleted ? 'text-emerald-600' : 'text-slate-400'
                }`}>
                  {s.label}
                </span>
              </div>
              {i < STEPS.length - 1 && (
                <div className={`flex-1 h-0.5 rounded-full mb-4 mx-1 ${
                  stepNum < step ? 'bg-emerald-400' : 'bg-slate-200'
                }`} />
              )}
            </div>
          )
        })}
      </div>

      {/* Form card */}
      <div className="rounded-2xl border border-slate-200/80 bg-[#F7F9FF] p-5 shadow-[0_4px_20px_rgba(148,163,184,0.08)]">
        {/* Step 1: Email & Name */}
        {step === 1 && (
          <div className="space-y-4">
            <div className="space-y-1.5">
              <Label htmlFor="email" className="text-sm font-semibold text-slate-700">Email address</Label>
              <div className="relative">
                <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 h-[17px] w-[17px] text-slate-400 pointer-events-none" />
                <Input
                  id="email"
                  type="email"
                  placeholder="you@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="pl-10 h-11 bg-white border-slate-200 rounded-xl text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10 transition-all"
                />
              </div>
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="fullName" className="text-sm font-semibold text-slate-700">Full name</Label>
              <div className="relative">
                <User className="absolute left-3.5 top-1/2 -translate-y-1/2 h-[17px] w-[17px] text-slate-400 pointer-events-none" />
                <Input
                  id="fullName"
                  type="text"
                  placeholder="Your full name"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="pl-10 h-11 bg-white border-slate-200 rounded-xl text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10 transition-all"
                />
              </div>
            </div>
          </div>
        )}

        {/* Step 2: Professional Profile */}
        {step === 2 && (
          <div className="space-y-4">
            <div className="space-y-1.5">
              <Label className="text-sm font-semibold text-slate-700">Qualification</Label>
              <Select value={qualification} onValueChange={setQualification}>
                <SelectTrigger className="w-full h-11 bg-white border-slate-200 rounded-xl">
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
              <Label className="text-sm font-semibold text-slate-700">Experience level</Label>
              <div className="grid grid-cols-3 gap-2">
                {EXPERIENCE_LEVELS.map(level => (
                  <button
                    key={level.value}
                    type="button"
                    onClick={() => setExperienceLevel(level.value)}
                    className={`rounded-xl border px-3 py-2.5 text-center transition-all ${
                      experienceLevel === level.value
                        ? 'border-[#5A7CFF] bg-[#5A7CFF]/10 text-[#5A7CFF]'
                        : 'border-slate-200 bg-white text-slate-700 hover:border-slate-300'
                    }`}
                  >
                    <p className="text-sm font-semibold">{level.label}</p>
                    <p className="text-[10px] text-slate-500">{level.description}</p>
                  </button>
                ))}
              </div>
            </div>

            <div className="space-y-1.5">
              <Label className="text-sm font-semibold text-slate-700">
                Skill areas <span className="font-normal text-slate-400">({skills.length} selected)</span>
              </Label>
              <div className="flex flex-wrap gap-2">
                {SKILL_AREAS.map(skill => (
                  <button
                    key={skill.value}
                    type="button"
                    onClick={() => toggleSkill(skill.value)}
                    className={`inline-flex items-center gap-1 rounded-full px-3 py-1.5 text-xs font-medium transition-all ${
                      skills.includes(skill.value)
                        ? 'bg-[#5A7CFF] text-white'
                        : 'bg-white border border-slate-200 text-slate-600 hover:border-slate-300'
                    }`}
                  >
                    {skill.label}
                    {skills.includes(skill.value) && <X className="h-3 w-3" />}
                  </button>
                ))}
              </div>
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="bio" className="text-sm font-semibold text-slate-700">
                Bio <span className="font-normal text-slate-400">(optional)</span>
              </Label>
              <textarea
                id="bio"
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                maxLength={500}
                rows={3}
                placeholder="Tell us about yourself..."
                className="w-full rounded-xl border border-slate-200 bg-white px-3.5 py-2.5 text-sm text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10 focus-visible:outline-none transition-all resize-none"
              />
              <p className="text-right text-[11px] text-slate-400">{bio.length}/500</p>
            </div>
          </div>
        )}

        {/* Step 3: Bank Details */}
        {step === 3 && (
          <div className="space-y-4">
            <div className="space-y-1.5">
              <Label className="text-sm font-semibold text-slate-700">Bank name</Label>
              <Select value={bankName} onValueChange={setBankName}>
                <SelectTrigger className="w-full h-11 bg-white border-slate-200 rounded-xl">
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
              <Label htmlFor="accountNumber" className="text-sm font-semibold text-slate-700">Account number</Label>
              <Input
                id="accountNumber"
                type="text"
                inputMode="numeric"
                placeholder="Enter account number"
                value={accountNumber}
                onChange={(e) => setAccountNumber(e.target.value.replace(/\D/g, ''))}
                maxLength={18}
                className="h-11 bg-white border-slate-200 rounded-xl text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10 transition-all"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="ifscCode" className="text-sm font-semibold text-slate-700">IFSC code</Label>
              <Input
                id="ifscCode"
                type="text"
                placeholder="e.g. SBIN0001234"
                value={ifscCode}
                onChange={(e) => setIfscCode(e.target.value.toUpperCase())}
                maxLength={11}
                className="h-11 bg-white border-slate-200 rounded-xl text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10 transition-all uppercase"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="upiId" className="text-sm font-semibold text-slate-700">
                UPI ID <span className="font-normal text-slate-400">(optional)</span>
              </Label>
              <Input
                id="upiId"
                type="text"
                placeholder="yourname@upi"
                value={upiId}
                onChange={(e) => setUpiId(e.target.value)}
                className="h-11 bg-white border-slate-200 rounded-xl text-slate-900 placeholder:text-slate-400 focus-visible:border-[#5A7CFF] focus-visible:ring-4 focus-visible:ring-[#5A7CFF]/10 transition-all"
              />
            </div>
          </div>
        )}

        {/* Step 4: Review */}
        {step === 4 && (
          <div className="space-y-4">
            <div className="rounded-xl border border-slate-200 bg-white p-4 space-y-3">
              <h3 className="text-sm font-semibold text-slate-700 flex items-center gap-2">
                <Mail className="h-4 w-4 text-[#5A7CFF]" />
                Personal Details
              </h3>
              <div className="grid gap-1.5 text-sm">
                <div className="flex justify-between">
                  <span className="text-slate-500">Email</span>
                  <span className="font-medium text-slate-900">{email}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Name</span>
                  <span className="font-medium text-slate-900">{fullName}</span>
                </div>
              </div>
            </div>

            <div className="rounded-xl border border-slate-200 bg-white p-4 space-y-3">
              <h3 className="text-sm font-semibold text-slate-700 flex items-center gap-2">
                <Briefcase className="h-4 w-4 text-[#5A7CFF]" />
                Professional Profile
              </h3>
              <div className="grid gap-1.5 text-sm">
                <div className="flex justify-between">
                  <span className="text-slate-500">Qualification</span>
                  <span className="font-medium text-slate-900">
                    {QUALIFICATION_OPTIONS.find(q => q.value === qualification)?.label}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Experience</span>
                  <span className="font-medium text-slate-900">
                    {EXPERIENCE_LEVELS.find(e => e.value === experienceLevel)?.label}
                  </span>
                </div>
                <div>
                  <span className="text-slate-500">Skills</span>
                  <div className="flex flex-wrap gap-1 mt-1">
                    {skills.map(s => (
                      <span key={s} className="inline-block rounded-full bg-[#EEF2FF] px-2 py-0.5 text-xs font-medium text-[#5A7CFF]">
                        {SKILL_AREAS.find(sa => sa.value === s)?.label}
                      </span>
                    ))}
                  </div>
                </div>
                {bio && (
                  <div>
                    <span className="text-slate-500">Bio</span>
                    <p className="mt-0.5 text-slate-700">{bio}</p>
                  </div>
                )}
              </div>
            </div>

            <div className="rounded-xl border border-slate-200 bg-white p-4 space-y-3">
              <h3 className="text-sm font-semibold text-slate-700 flex items-center gap-2">
                <Building2 className="h-4 w-4 text-[#5A7CFF]" />
                Bank Details
              </h3>
              <div className="grid gap-1.5 text-sm">
                <div className="flex justify-between">
                  <span className="text-slate-500">Bank</span>
                  <span className="font-medium text-slate-900">
                    {INDIAN_BANKS.find(b => b.value === bankName)?.label}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Account</span>
                  <span className="font-medium text-slate-900">
                    {'*'.repeat(Math.max(0, accountNumber.length - 4))}{accountNumber.slice(-4)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">IFSC</span>
                  <span className="font-medium text-slate-900">{ifscCode.toUpperCase()}</span>
                </div>
                {upiId && (
                  <div className="flex justify-between">
                    <span className="text-slate-500">UPI</span>
                    <span className="font-medium text-slate-900">{upiId}</span>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Error */}
        {error && (
          <div className="mt-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600 animate-fade-in">
            {error}
          </div>
        )}

        {/* Actions */}
        <div className="mt-5 flex gap-3">
          {step > 1 && (
            <Button
              type="button"
              variant="outline"
              onClick={handleBack}
              className="h-11 rounded-xl border-slate-200 text-slate-700 hover:bg-slate-50 font-semibold"
            >
              <ArrowLeft className="h-4 w-4 mr-1" />
              Back
            </Button>
          )}

          {step < 4 ? (
            <Button
              type="button"
              onClick={handleNext}
              disabled={isLoading}
              className="flex-1 h-11 text-sm font-semibold rounded-xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white border-0 shadow-[0_8px_24px_rgba(90,124,255,0.30)] hover:shadow-[0_12px_32px_rgba(90,124,255,0.40)] hover:opacity-95 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin mr-2" />
                  Checking...
                </>
              ) : (
                <>
                  Continue
                  <ArrowRight className="h-4 w-4 ml-2" />
                </>
              )}
            </Button>
          ) : (
            <Button
              type="button"
              onClick={handleSubmit}
              disabled={isLoading}
              className="flex-1 h-11 text-sm font-semibold rounded-xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white border-0 shadow-[0_8px_24px_rgba(90,124,255,0.30)] hover:shadow-[0_12px_32px_rgba(90,124,255,0.40)] hover:opacity-95 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin mr-2" />
                  Submitting...
                </>
              ) : (
                <>
                  Submit Application
                  <ArrowRight className="h-4 w-4 ml-2" />
                </>
              )}
            </Button>
          )}
        </div>
      </div>

      {/* Footer link */}
      <p className="text-center text-sm text-slate-500">
        Already have an account?{' '}
        <Link href="/login" className="font-semibold text-[#5A7CFF] hover:underline underline-offset-4">
          Sign in
        </Link>
      </p>
    </div>
  )
}
