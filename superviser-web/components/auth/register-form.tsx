/**
 * @fileoverview 4-step supervisor registration form with stepper UI.
 * Steps: Email & Name -> Professional Profile -> Bank Details -> Review & Submit
 * @module components/auth/register-form
 */

"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import {
  Loader2,
  Mail,
  ArrowRight,
  ArrowLeft,
  Check,
  User,
  Briefcase,
  Landmark,
  ClipboardList,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { apiFetch } from "@/lib/api/client"
import { sendSupervisorOTP, supervisorSignup } from "@/lib/api/auth"
import { professionalProfileSchema, bankingSchema } from "@/lib/validations/auth"
import { QUALIFICATIONS, INDIAN_BANKS } from "@/lib/constants"
import { useSubjects } from "@/lib/hooks/use-subjects"

// ---------- Step schemas ----------

const emailStepSchema = z.object({
  email: z.string().email("Please enter a valid email address"),
  fullName: z.string().min(2, "Full name must be at least 2 characters"),
})

type EmailStepData = z.infer<typeof emailStepSchema>
type ProfileStepData = z.infer<typeof professionalProfileSchema>
type BankingStepData = z.infer<typeof bankingSchema>

// ---------- Stepper UI ----------

const STEPS = [
  { num: 1, label: "Email", icon: Mail },
  { num: 2, label: "Profile", icon: Briefcase },
  { num: 3, label: "Banking", icon: Landmark },
  { num: 4, label: "Review", icon: ClipboardList },
] as const

function Stepper({ current }: { current: number }) {
  return (
    <div className="flex items-center justify-between mb-8">
      {STEPS.map((step, i) => {
        const isCompleted = current > step.num
        const isActive = current === step.num
        const isUpcoming = current < step.num

        return (
          <div key={step.num} className="flex items-center flex-1 last:flex-none">
            {/* Step circle + label */}
            <div className="flex flex-col items-center">
              <div
                className={`h-9 w-9 rounded-full flex items-center justify-center text-sm font-semibold transition-all ${
                  isCompleted
                    ? "bg-emerald-500 text-white"
                    : isActive
                    ? "bg-[#F97316] text-white shadow-lg shadow-[#F97316]/25"
                    : "border-2 border-gray-200 text-gray-400 bg-white"
                }`}
              >
                {isCompleted ? <Check className="h-4 w-4" /> : step.num}
              </div>
              <span
                className={`text-[10px] mt-1.5 font-medium ${
                  isCompleted
                    ? "text-emerald-600"
                    : isActive
                    ? "text-[#F97316]"
                    : "text-gray-400"
                }`}
              >
                {step.label}
              </span>
            </div>

            {/* Connecting line */}
            {i < STEPS.length - 1 && (
              <div className="flex-1 mx-2 mt-[-18px]">
                <div
                  className={`h-[2px] rounded-full transition-all ${
                    current > step.num ? "bg-emerald-500" : "bg-gray-200"
                  }`}
                />
              </div>
            )}
          </div>
        )
      })}
    </div>
  )
}

// ---------- Main Form ----------

export function RegisterForm() {
  const router = useRouter()
  const { subjects: apiSubjects, isLoading: subjectsLoading } = useSubjects()
  const [step, setStep] = useState(1)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Collected data across steps
  const [emailData, setEmailData] = useState<EmailStepData>({
    email: "",
    fullName: "",
  })
  const [profileData, setProfileData] = useState<ProfileStepData>({
    qualification: "",
    yearsOfExperience: 0,
    expertiseAreas: [],
    bio: "",
  })
  const [bankingData, setBankingData] = useState<BankingStepData>({
    bankName: "",
    accountNumber: "",
    ifscCode: "",
    upiId: "",
  })
  const [otpSent, setOtpSent] = useState(false)
  const [otp, setOtp] = useState("")
  const [resendCooldown, setResendCooldown] = useState(0)

  useEffect(() => {
    if (resendCooldown <= 0) return
    const timer = setTimeout(() => setResendCooldown(resendCooldown - 1), 1000)
    return () => clearTimeout(timer)
  }, [resendCooldown])

  // Step 1 form
  const emailForm = useForm<EmailStepData>({
    resolver: zodResolver(emailStepSchema),
    defaultValues: emailData,
  })

  // Step 2 form
  const profileForm = useForm<ProfileStepData>({
    resolver: zodResolver(professionalProfileSchema),
    defaultValues: profileData,
  })

  // Step 3 form
  const bankingForm = useForm<BankingStepData>({
    resolver: zodResolver(bankingSchema),
    defaultValues: bankingData,
  })

  // ---------- Step handlers ----------

  const handleEmailNext = async (data: EmailStepData) => {
    setError(null)
    setIsLoading(true)
    try {
      const trimmed = data.email.trim().toLowerCase()

      // Check if email is registered on another platform
      const crossCheck = await apiFetch<{ available: boolean; conflictingRole: string | null }>(
        "/api/auth/check-account",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email: trimmed, role: "supervisor" }),
        }
      ).catch(() => null)

      if (crossCheck && !crossCheck.available) {
        setError(`This email is already registered as a ${crossCheck.conflictingRole}. Each role requires a unique email.`)
        return
      }

      // Check if email already has a request
      const existing = await apiFetch<{ id?: string; status?: string } | null>(
        `/api/access-requests/check?email=${encodeURIComponent(trimmed)}&role=supervisor`
      ).catch(() => null)

      if (existing && existing.id) {
        const s = existing.status
        if (s === "approved") {
          router.push("/login")
          return
        }
        if (s === "rejected") {
          setError("This email was not approved. Please contact support.")
          return
        }
        // Already pending
        router.push(`/pending?email=${encodeURIComponent(trimmed)}`)
        return
      }

      setEmailData({ ...data, email: trimmed })
      setStep(2)
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Something went wrong.")
    } finally {
      setIsLoading(false)
    }
  }

  const handleProfileNext = (data: ProfileStepData) => {
    setProfileData(data)
    setStep(3)
  }

  const handleBankingNext = (data: BankingStepData) => {
    setBankingData(data)
    setStep(4)
  }

  const handleSendOtp = async () => {
    setError(null)
    setIsLoading(true)
    try {
      await sendSupervisorOTP(emailData.email.trim().toLowerCase(), 'signup')
      setOtpSent(true)
      setResendCooldown(60)
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Failed to send verification code.")
    } finally {
      setIsLoading(false)
    }
  }

  const handleSubmit = async () => {
    if (otp.length !== 6) return
    setError(null)
    setIsLoading(true)
    try {
      const trimmed = emailData.email.trim().toLowerCase()
      const metadata = {
        qualification: profileData.qualification,
        yearsOfExperience: profileData.yearsOfExperience,
        expertiseAreas: profileData.expertiseAreas,
        bio: profileData.bio || "",
        bankName: bankingData.bankName,
        accountNumber: bankingData.accountNumber,
        ifscCode: bankingData.ifscCode,
        upiId: bankingData.upiId || "",
      }
      await supervisorSignup(trimmed, otp, emailData.fullName, metadata)
      router.push(`/pending?email=${encodeURIComponent(trimmed)}`)
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Something went wrong.")
    } finally {
      setIsLoading(false)
    }
  }

  // ---------- Helper labels ----------

  const getQualificationLabel = (value: string) =>
    QUALIFICATIONS.find((q) => q.value === value)?.label || value

  const getBankLabel = (value: string) =>
    INDIAN_BANKS.find((b) => b.value === value)?.label || value

  const getExpertiseLabels = (values: string[]) =>
    values.map((v) => apiSubjects.find((s) => s._id === v)?.name || v)

  // ---------- Render ----------

  return (
    <div>
      <Stepper current={step} />

      {error && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600 mb-4">
          {error}
        </div>
      )}

      {/* ── Step 1: Email & Name ── */}
      {step === 1 && (
        <Form {...emailForm}>
          <form onSubmit={emailForm.handleSubmit(handleEmailNext)} className="space-y-4">
            <FormField
              control={emailForm.control}
              name="fullName"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-semibold text-[#1C1C1C]">Full name</FormLabel>
                  <FormControl>
                    <div className="relative">
                      <User className="absolute left-3.5 top-1/2 -translate-y-1/2 h-[17px] w-[17px] text-gray-400 pointer-events-none" />
                      <Input
                        placeholder="Your full name"
                        disabled={isLoading}
                        className="pl-10 h-11 bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] placeholder:text-gray-400 focus-visible:border-[#F97316] focus-visible:ring-4 focus-visible:ring-orange-500/10 transition-all"
                        {...field}
                      />
                    </div>
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={emailForm.control}
              name="email"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-semibold text-[#1C1C1C]">
                    Work email address
                  </FormLabel>
                  <FormControl>
                    <div className="relative">
                      <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 h-[17px] w-[17px] text-gray-400 pointer-events-none" />
                      <Input
                        type="email"
                        placeholder="you@company.com"
                        disabled={isLoading}
                        className="pl-10 h-11 bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] placeholder:text-gray-400 focus-visible:border-[#F97316] focus-visible:ring-4 focus-visible:ring-orange-500/10 transition-all"
                        {...field}
                      />
                    </div>
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <Button
              type="submit"
              size="lg"
              disabled={isLoading}
              className="w-full h-11 text-sm font-semibold rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white border-0 shadow-sm hover:shadow-md transition-all duration-200"
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
          </form>
        </Form>
      )}

      {/* ── Step 2: Professional Profile ── */}
      {step === 2 && (
        <Form {...profileForm}>
          <form onSubmit={profileForm.handleSubmit(handleProfileNext)} className="space-y-4">
            <FormField
              control={profileForm.control}
              name="qualification"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-semibold text-[#1C1C1C]">
                    Qualification
                  </FormLabel>
                  <Select onValueChange={field.onChange} defaultValue={field.value}>
                    <FormControl>
                      <SelectTrigger className="h-11 bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] focus:border-[#F97316] focus:ring-4 focus:ring-orange-500/10">
                        <SelectValue placeholder="Select qualification" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      {QUALIFICATIONS.map((q) => (
                        <SelectItem key={q.value} value={q.value}>
                          {q.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={profileForm.control}
              name="yearsOfExperience"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-semibold text-[#1C1C1C]">
                    Years of experience
                  </FormLabel>
                  <FormControl>
                    <Input
                      type="number"
                      min={0}
                      max={50}
                      placeholder="0"
                      className="h-11 bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] placeholder:text-gray-400 focus-visible:border-[#F97316] focus-visible:ring-4 focus-visible:ring-orange-500/10 transition-all"
                      {...field}
                      onChange={(e) => field.onChange(parseInt(e.target.value) || 0)}
                      value={field.value || ""}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={profileForm.control}
              name="expertiseAreas"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-semibold text-[#1C1C1C]">
                    Expertise areas
                  </FormLabel>
                  <FormControl>
                    {subjectsLoading ? (
                      <div className="flex items-center justify-center py-4">
                        <Loader2 className="h-5 w-5 animate-spin text-gray-400" />
                        <span className="ml-2 text-sm text-gray-400">Loading subjects...</span>
                      </div>
                    ) : (
                      <div className="flex flex-wrap gap-2">
                        {apiSubjects.map((subject) => {
                          const selected = field.value?.includes(subject._id)
                          return (
                            <button
                              key={subject._id}
                              type="button"
                              onClick={() => {
                                const current = field.value || []
                                if (selected) {
                                  field.onChange(current.filter((v: string) => v !== subject._id))
                                } else {
                                  field.onChange([...current, subject._id])
                                }
                              }}
                              className={`px-3 py-1.5 rounded-full text-xs font-medium border transition-all ${
                                selected
                                  ? "bg-[#F97316] text-white border-[#F97316]"
                                  : "bg-gray-50 text-gray-600 border-gray-200 hover:border-[#F97316]/50 hover:text-[#F97316]"
                              }`}
                            >
                              {subject.name}
                            </button>
                          )
                        })}
                      </div>
                    )}
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={profileForm.control}
              name="bio"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-semibold text-[#1C1C1C]">
                    Bio <span className="text-gray-400 font-normal">(optional)</span>
                  </FormLabel>
                  <FormControl>
                    <Textarea
                      placeholder="Tell us about your experience..."
                      maxLength={500}
                      rows={3}
                      className="bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] placeholder:text-gray-400 focus-visible:border-[#F97316] focus-visible:ring-4 focus-visible:ring-orange-500/10 transition-all resize-none"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="flex gap-3 pt-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setStep(1)}
                className="flex-1 h-11 rounded-xl border-gray-200 text-gray-600 hover:bg-gray-50"
              >
                <ArrowLeft className="h-4 w-4 mr-2" />
                Back
              </Button>
              <Button
                type="submit"
                className="flex-1 h-11 rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white font-semibold"
              >
                Continue
                <ArrowRight className="h-4 w-4 ml-2" />
              </Button>
            </div>
          </form>
        </Form>
      )}

      {/* ── Step 3: Bank Details ── */}
      {step === 3 && (
        <Form {...bankingForm}>
          <form onSubmit={bankingForm.handleSubmit(handleBankingNext)} className="space-y-4">
            <FormField
              control={bankingForm.control}
              name="bankName"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-semibold text-[#1C1C1C]">Bank name</FormLabel>
                  <Select onValueChange={field.onChange} defaultValue={field.value}>
                    <FormControl>
                      <SelectTrigger className="h-11 bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] focus:border-[#F97316] focus:ring-4 focus:ring-orange-500/10">
                        <SelectValue placeholder="Select bank" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      {INDIAN_BANKS.map((b) => (
                        <SelectItem key={b.value} value={b.value}>
                          {b.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={bankingForm.control}
              name="accountNumber"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-semibold text-[#1C1C1C]">
                    Account number
                  </FormLabel>
                  <FormControl>
                    <Input
                      placeholder="Enter account number"
                      inputMode="numeric"
                      className="h-11 bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] placeholder:text-gray-400 focus-visible:border-[#F97316] focus-visible:ring-4 focus-visible:ring-orange-500/10 transition-all"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={bankingForm.control}
              name="ifscCode"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-semibold text-[#1C1C1C]">IFSC code</FormLabel>
                  <FormControl>
                    <Input
                      placeholder="e.g. SBIN0001234"
                      className="h-11 bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] placeholder:text-gray-400 focus-visible:border-[#F97316] focus-visible:ring-4 focus-visible:ring-orange-500/10 transition-all uppercase"
                      {...field}
                      onChange={(e) => field.onChange(e.target.value.toUpperCase())}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={bankingForm.control}
              name="upiId"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-semibold text-[#1C1C1C]">
                    UPI ID <span className="text-gray-400 font-normal">(optional)</span>
                  </FormLabel>
                  <FormControl>
                    <Input
                      placeholder="yourname@bank"
                      className="h-11 bg-gray-50 border-gray-200 rounded-xl text-[#1C1C1C] placeholder:text-gray-400 focus-visible:border-[#F97316] focus-visible:ring-4 focus-visible:ring-orange-500/10 transition-all"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="flex gap-3 pt-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setStep(2)}
                className="flex-1 h-11 rounded-xl border-gray-200 text-gray-600 hover:bg-gray-50"
              >
                <ArrowLeft className="h-4 w-4 mr-2" />
                Back
              </Button>
              <Button
                type="submit"
                className="flex-1 h-11 rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white font-semibold"
              >
                Continue
                <ArrowRight className="h-4 w-4 ml-2" />
              </Button>
            </div>
          </form>
        </Form>
      )}

      {/* ── Step 4: Review & Submit ── */}
      {step === 4 && (
        <div className="space-y-4">
          {/* Email & Name */}
          <div className="rounded-xl border border-gray-200/60 bg-gray-50/50 p-4 space-y-2">
            <p className="text-xs font-semibold text-[#F97316] uppercase tracking-wider">
              Contact
            </p>
            <div className="grid grid-cols-2 gap-y-1.5 text-sm">
              <span className="text-gray-400">Name</span>
              <span className="text-[#1C1C1C] font-medium">{emailData.fullName}</span>
              <span className="text-gray-400">Email</span>
              <span className="text-[#1C1C1C] font-medium break-all">{emailData.email}</span>
            </div>
          </div>

          {/* Profile */}
          <div className="rounded-xl border border-gray-200/60 bg-gray-50/50 p-4 space-y-2">
            <p className="text-xs font-semibold text-[#F97316] uppercase tracking-wider">
              Professional Profile
            </p>
            <div className="grid grid-cols-2 gap-y-1.5 text-sm">
              <span className="text-gray-400">Qualification</span>
              <span className="text-[#1C1C1C] font-medium">
                {getQualificationLabel(profileData.qualification)}
              </span>
              <span className="text-gray-400">Experience</span>
              <span className="text-[#1C1C1C] font-medium">
                {profileData.yearsOfExperience} years
              </span>
              <span className="text-gray-400">Expertise</span>
              <span className="text-[#1C1C1C] font-medium">
                {getExpertiseLabels(profileData.expertiseAreas).join(", ")}
              </span>
              {profileData.bio && (
                <>
                  <span className="text-gray-400">Bio</span>
                  <span className="text-[#1C1C1C] font-medium">{profileData.bio}</span>
                </>
              )}
            </div>
          </div>

          {/* Banking */}
          <div className="rounded-xl border border-gray-200/60 bg-gray-50/50 p-4 space-y-2">
            <p className="text-xs font-semibold text-[#F97316] uppercase tracking-wider">
              Banking Details
            </p>
            <div className="grid grid-cols-2 gap-y-1.5 text-sm">
              <span className="text-gray-400">Bank</span>
              <span className="text-[#1C1C1C] font-medium">
                {getBankLabel(bankingData.bankName)}
              </span>
              <span className="text-gray-400">Account</span>
              <span className="text-[#1C1C1C] font-medium">
                {"*".repeat(Math.max(0, bankingData.accountNumber.length - 4))}
                {bankingData.accountNumber.slice(-4)}
              </span>
              <span className="text-gray-400">IFSC</span>
              <span className="text-[#1C1C1C] font-medium">{bankingData.ifscCode}</span>
              {bankingData.upiId && (
                <>
                  <span className="text-gray-400">UPI</span>
                  <span className="text-[#1C1C1C] font-medium">{bankingData.upiId}</span>
                </>
              )}
            </div>
          </div>

          {/* OTP verification */}
          {otpSent && (
            <div className="rounded-xl border border-orange-200/60 bg-orange-50/50 p-4 space-y-3">
              <p className="text-xs font-semibold text-[#F97316] uppercase tracking-wider">
                Verify Email
              </p>
              <p className="text-sm text-gray-600">
                Enter the 6-digit code sent to <span className="font-medium text-[#1C1C1C]">{emailData.email}</span>
              </p>
              <Input
                type="text"
                inputMode="numeric"
                pattern="[0-9]*"
                maxLength={6}
                placeholder="000000"
                value={otp}
                onChange={(e) => setOtp(e.target.value.replace(/\D/g, "").slice(0, 6))}
                disabled={isLoading}
                autoFocus
                className="h-12 text-center text-2xl font-mono tracking-[0.5em] bg-white border-gray-200 rounded-xl text-[#1C1C1C] placeholder:text-gray-300 focus-visible:border-[#F97316] focus-visible:ring-4 focus-visible:ring-orange-500/10 transition-all"
              />
              <div className="flex justify-center">
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  disabled={resendCooldown > 0}
                  onClick={handleSendOtp}
                  className="text-xs text-gray-500 hover:text-orange-600"
                >
                  {resendCooldown > 0 ? `Resend in ${resendCooldown}s` : "Resend code"}
                </Button>
              </div>
            </div>
          )}

          <div className="flex gap-3 pt-2">
            <Button
              type="button"
              variant="outline"
              onClick={() => { setStep(3); setOtpSent(false); setOtp("") }}
              disabled={isLoading}
              className="flex-1 h-11 rounded-xl border-gray-200 text-gray-600 hover:bg-gray-50"
            >
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back
            </Button>
            {!otpSent ? (
              <Button
                type="button"
                onClick={handleSendOtp}
                disabled={isLoading}
                className="flex-1 h-11 rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white font-semibold"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin mr-2" />
                    Sending...
                  </>
                ) : (
                  <>
                    Send Verification Code
                    <ArrowRight className="h-4 w-4 ml-2" />
                  </>
                )}
              </Button>
            ) : (
              <Button
                type="button"
                onClick={handleSubmit}
                disabled={isLoading || otp.length !== 6}
                className="flex-1 h-11 rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white font-semibold"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin mr-2" />
                    Submitting...
                  </>
                ) : (
                  <>
                    Verify & Submit
                    <ArrowRight className="h-4 w-4 ml-2" />
                  </>
                )}
              </Button>
            )}
          </div>

          <p className="text-center text-xs text-gray-400">
            By applying, you agree to our{" "}
            <a href="#" className="text-orange-600 hover:underline">
              Terms of Service
            </a>{" "}
            and{" "}
            <a href="#" className="text-orange-600 hover:underline">
              Privacy Policy
            </a>
          </p>
        </div>
      )}
    </div>
  )
}
