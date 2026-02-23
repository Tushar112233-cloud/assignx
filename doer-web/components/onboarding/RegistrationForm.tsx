'use client'

import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { motion } from 'framer-motion'
import { Eye, EyeOff, Check, X, Loader2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Checkbox } from '@/components/ui/checkbox'
import { Progress } from '@/components/ui/progress'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Logo } from '@/components/shared/Logo'
import { cn } from '@/lib/utils'
import { PASSWORD_MIN_LENGTH, PASSWORD_REQUIREMENTS } from '@/lib/constants'

/** Registration form schema */
const registrationSchema = z.object({
  fullName: z
    .string()
    .min(2, 'Name must be at least 2 characters')
    .max(100, 'Name must be less than 100 characters'),
  email: z
    .string()
    .email('Please enter a valid email address'),
  phone: z
    .string()
    .regex(/^\+?[1-9]\d{9,14}$/, 'Please enter a valid phone number'),
  password: z
    .string()
    .min(PASSWORD_MIN_LENGTH, `Password must be at least ${PASSWORD_MIN_LENGTH} characters`)
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number'),
  confirmPassword: z.string(),
  agreeToTerms: z.boolean().refine((val) => val === true, {
    message: 'You must agree to the terms and conditions',
  }),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
})

type RegistrationFormData = z.infer<typeof registrationSchema>

interface RegistrationFormProps {
  /** Callback when registration is successful */
  onSuccess: (data: RegistrationFormData) => void
  /** Callback when user wants to login instead */
  onLoginClick?: () => void
}

/**
 * Registration form component with multi-step validation
 * Includes phone OTP verification, password strength indicator, and terms agreement
 */
export function RegistrationForm({ onSuccess, onLoginClick }: RegistrationFormProps) {
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [otpSent, setOtpSent] = useState(false)
  const [otpVerified, setOtpVerified] = useState(false)
  const [otp, setOtp] = useState('')

  const form = useForm<RegistrationFormData>({
    resolver: zodResolver(registrationSchema),
    defaultValues: {
      fullName: '',
      email: '',
      phone: '',
      password: '',
      confirmPassword: '',
      agreeToTerms: false,
    },
    mode: 'onChange',
  })

  const password = form.watch('password')

  /** Calculate password strength */
  const getPasswordStrength = (pwd: string): number => {
    let strength = 0
    if (pwd.length >= PASSWORD_MIN_LENGTH) strength += 25
    if (/[A-Z]/.test(pwd)) strength += 25
    if (/[a-z]/.test(pwd)) strength += 25
    if (/[0-9]/.test(pwd)) strength += 25
    return strength
  }

  const passwordStrength = getPasswordStrength(password)

  /** Get password strength color */
  const getStrengthColor = (strength: number): string => {
    if (strength < 50) return 'bg-destructive'
    if (strength < 75) return 'bg-yellow-500'
    return 'bg-green-500'
  }

  /** Check individual password requirements */
  const checkRequirement = (pwd: string, index: number): boolean => {
    switch (index) {
      case 0: return pwd.length >= PASSWORD_MIN_LENGTH
      case 1: return /[A-Z]/.test(pwd)
      case 2: return /[a-z]/.test(pwd)
      case 3: return /[0-9]/.test(pwd)
      default: return false
    }
  }

  /** Handle sending OTP */
  const handleSendOtp = async () => {
    const phone = form.getValues('phone')
    if (!phone) {
      form.setError('phone', { message: 'Please enter a phone number' })
      return
    }

    // TODO: Implement actual OTP sending via Supabase
    setOtpSent(true)
  }

  /** Handle OTP verification */
  const handleVerifyOtp = async () => {
    if (otp.length !== 6) return

    // TODO: Implement actual OTP verification
    setOtpVerified(true)
  }

  /** Handle form submission */
  const onSubmit = async (data: RegistrationFormData) => {
    if (!otpVerified) {
      form.setError('phone', { message: 'Please verify your phone number' })
      return
    }

    setIsSubmitting(true)
    try {
      // TODO: Implement actual registration
      await new Promise((resolve) => setTimeout(resolve, 1000))
      onSuccess(data)
    } catch (error) {
      console.error('Registration failed:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="flex min-h-screen flex-col bg-background px-6 py-8">
      {/* Header */}
      <div className="mb-8 flex flex-col items-center">
        <Logo size="lg" className="mb-4" />
        <h1 className="text-2xl font-bold text-foreground">Create Account</h1>
        <p className="text-muted-foreground">Join our community of skilled professionals</p>
      </div>

      {/* Form */}
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="flex-1 space-y-5">
          {/* Full Name */}
          <FormField
            control={form.control}
            name="fullName"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Full Name</FormLabel>
                <FormControl>
                  <Input
                    placeholder="Enter your full name"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {/* Email */}
          <FormField
            control={form.control}
            name="email"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Email Address</FormLabel>
                <FormControl>
                  <Input
                    type="email"
                    placeholder="Enter your email"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {/* Phone with OTP */}
          <FormField
            control={form.control}
            name="phone"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Phone Number</FormLabel>
                <div className="flex gap-2">
                  <FormControl>
                    <Input
                      type="tel"
                      placeholder="+91 9999999999"
                      disabled={otpVerified}
                      {...field}
                    />
                  </FormControl>
                  {!otpVerified && (
                    <Button
                      type="button"
                      variant="outline"
                      onClick={handleSendOtp}
                      disabled={otpSent}
                      className="shrink-0"
                    >
                      {otpSent ? 'Resend' : 'Send OTP'}
                    </Button>
                  )}
                  {otpVerified && (
                    <div className="flex h-10 w-10 items-center justify-center rounded-md bg-green-500/10">
                      <Check className="h-5 w-5 text-green-500" />
                    </div>
                  )}
                </div>
                <FormMessage />
              </FormItem>
            )}
          />

          {/* OTP Input */}
          {otpSent && !otpVerified && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              className="space-y-2"
            >
              <Label>Enter OTP</Label>
              <div className="flex gap-2">
                <Input
                  type="text"
                  placeholder="Enter 6-digit OTP"
                  maxLength={6}
                  value={otp}
                  onChange={(e) => setOtp(e.target.value.replace(/\D/g, ''))}
                />
                <Button
                  type="button"
                  onClick={handleVerifyOtp}
                  disabled={otp.length !== 6}
                >
                  Verify
                </Button>
              </div>
            </motion.div>
          )}

          {/* Password */}
          <FormField
            control={form.control}
            name="password"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Password</FormLabel>
                <FormControl>
                  <div className="relative">
                    <Input
                      type={showPassword ? 'text' : 'password'}
                      placeholder="Create a strong password"
                      {...field}
                    />
                    <Button
                      type="button"
                      variant="ghost"
                      size="icon"
                      className="absolute right-0 top-0 h-10 w-10"
                      onClick={() => setShowPassword(!showPassword)}
                    >
                      {showPassword ? (
                        <EyeOff className="h-4 w-4" />
                      ) : (
                        <Eye className="h-4 w-4" />
                      )}
                    </Button>
                  </div>
                </FormControl>

                {/* Password Strength Indicator */}
                {password && (
                  <div className="mt-2 space-y-2">
                    <div className="flex items-center gap-2">
                      <Progress
                        value={passwordStrength}
                        className="h-2"
                        indicatorClassName={getStrengthColor(passwordStrength)}
                      />
                      <span className="text-xs text-muted-foreground">
                        {passwordStrength < 50 ? 'Weak' : passwordStrength < 75 ? 'Medium' : 'Strong'}
                      </span>
                    </div>
                    <ul className="space-y-1 text-xs">
                      {PASSWORD_REQUIREMENTS.map((req, index) => (
                        <li
                          key={index}
                          className={cn(
                            'flex items-center gap-1',
                            checkRequirement(password, index)
                              ? 'text-green-600'
                              : 'text-muted-foreground'
                          )}
                        >
                          {checkRequirement(password, index) ? (
                            <Check className="h-3 w-3" />
                          ) : (
                            <X className="h-3 w-3" />
                          )}
                          {req}
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
                <FormMessage />
              </FormItem>
            )}
          />

          {/* Confirm Password */}
          <FormField
            control={form.control}
            name="confirmPassword"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Confirm Password</FormLabel>
                <FormControl>
                  <div className="relative">
                    <Input
                      type={showConfirmPassword ? 'text' : 'password'}
                      placeholder="Confirm your password"
                      {...field}
                    />
                    <Button
                      type="button"
                      variant="ghost"
                      size="icon"
                      className="absolute right-0 top-0 h-10 w-10"
                      onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    >
                      {showConfirmPassword ? (
                        <EyeOff className="h-4 w-4" />
                      ) : (
                        <Eye className="h-4 w-4" />
                      )}
                    </Button>
                  </div>
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {/* Terms Agreement */}
          <FormField
            control={form.control}
            name="agreeToTerms"
            render={({ field }) => (
              <FormItem className="flex flex-row items-start space-x-3 space-y-0">
                <FormControl>
                  <Checkbox
                    checked={field.value}
                    onCheckedChange={field.onChange}
                  />
                </FormControl>
                <div className="space-y-1 leading-none">
                  <FormLabel className="text-sm font-normal">
                    By signing up, I agree to the{' '}
                    <a href="/terms" className="text-primary underline">
                      Terms of Service
                    </a>{' '}
                    &{' '}
                    <a href="/privacy" className="text-primary underline">
                      Privacy Policy
                    </a>
                  </FormLabel>
                  <FormMessage />
                </div>
              </FormItem>
            )}
          />

          {/* Submit Button */}
          <Button
            type="submit"
            size="lg"
            className="w-full"
            disabled={isSubmitting || !form.formState.isValid}
          >
            {isSubmitting ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Creating Account...
              </>
            ) : (
              'Create Account'
            )}
          </Button>
        </form>
      </Form>

      {/* Login Link */}
      <div className="mt-6 text-center">
        <p className="text-sm text-muted-foreground">
          Already have an account?{' '}
          <button
            type="button"
            onClick={onLoginClick}
            className="font-medium text-primary hover:underline"
          >
            Log in
          </button>
        </p>
      </div>
    </div>
  )
}
