'use client'

import { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronLeft, ChevronRight, Loader2, GraduationCap, Building2, Sparkles, Check } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Progress } from '@/components/ui/progress'
import { Badge } from '@/components/ui/badge'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
  FormDescription,
} from '@/components/ui/form'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { cn } from '@/lib/utils'
import { QUALIFICATION_OPTIONS, EXPERIENCE_LEVELS } from '@/lib/constants'
import { createClient } from '@/lib/supabase/client'

/** Profile setup form schema */
const profileSetupSchema = z.object({
  qualification: z.string().min(1, 'Please select your qualification'),
  universityName: z.string().optional(),
  skills: z.array(z.string()).min(1, 'Please select at least one skill'),
  subjects: z.array(z.string()).min(1, 'Please select at least one subject'),
  experienceLevel: z.string().min(1, 'Please select your experience level'),
})

type ProfileSetupFormData = z.infer<typeof profileSetupSchema>

/** Skill type from database */
interface Skill {
  id: string
  name: string
}

/** Subject type from database */
interface Subject {
  id: string
  name: string
}

interface ProfileSetupFormProps {
  /** Callback when profile setup is complete */
  onComplete: (data: ProfileSetupFormData) => Promise<void>
  /** Current user name for greeting */
  userName?: string
}

/** Step titles and descriptions */
const STEPS = [
  {
    title: 'Education',
    description: 'Tell us about your educational background',
    icon: GraduationCap,
    color: 'teal',
  },
  {
    title: 'Skills & Interests',
    description: 'Select your areas of expertise',
    icon: Building2,
    color: 'emerald',
  },
  {
    title: 'Experience',
    description: 'How experienced are you?',
    icon: Sparkles,
    color: 'amber',
  },
]

/**
 * Profile setup form component with multi-step wizard
 * Professional design with teal/emerald theme
 */
export function ProfileSetupForm({ onComplete, userName }: ProfileSetupFormProps) {
  const [currentStep, setCurrentStep] = useState(0)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [skills, setSkills] = useState<Skill[]>([])
  const [subjects, setSubjects] = useState<Subject[]>([])
  const [isLoadingData, setIsLoadingData] = useState(true)

  const [fetchError, setFetchError] = useState<string | null>(null)

  /**
   * Fetch skills and subjects from the database
   */
  useEffect(() => {
    const fetchData = async () => {
      setIsLoadingData(true)
      setFetchError(null)

      try {
        const supabase = createClient()

        // Fetch skills and subjects in parallel
        const [skillsResult, subjectsResult] = await Promise.all([
          supabase
            .from('skills')
            .select('id, name')
            .eq('is_active', true)
            .order('name'),
          supabase
            .from('subjects')
            .select('id, name')
            .eq('is_active', true)
            .is('parent_id', null)
            .order('name'),
        ])

        if (skillsResult.error) {
          console.error('Skills fetch error:', skillsResult.error)
          setFetchError(`Failed to load skills: ${skillsResult.error.message}`)
        } else {
          setSkills(skillsResult.data || [])
        }

        if (subjectsResult.error) {
          console.error('Subjects fetch error:', subjectsResult.error)
          setFetchError(`Failed to load subjects: ${subjectsResult.error.message}`)
        } else {
          setSubjects(subjectsResult.data || [])
        }
      } catch (error) {
        console.error('Error fetching profile data:', error)
        setFetchError('Failed to load data. Please refresh the page.')
      } finally {
        setIsLoadingData(false)
      }
    }

    fetchData()
  }, [])

  const form = useForm<ProfileSetupFormData>({
    resolver: zodResolver(profileSetupSchema),
    defaultValues: {
      qualification: '',
      universityName: '',
      skills: [],
      subjects: [],
      experienceLevel: '',
    },
    mode: 'onChange',
  })

  const totalSteps = STEPS.length
  const progress = ((currentStep + 1) / totalSteps) * 100

  // Watch form values for reactive validation
  const qualification = form.watch('qualification')
  const selectedSkills = form.watch('skills')
  const selectedSubjects = form.watch('subjects')
  const experienceLevel = form.watch('experienceLevel')

  /** Toggle skill selection */
  const toggleSkill = (skillId: string) => {
    const currentSkills = form.getValues('skills')
    if (currentSkills.includes(skillId)) {
      form.setValue(
        'skills',
        currentSkills.filter((s) => s !== skillId),
        { shouldValidate: true }
      )
    } else {
      form.setValue('skills', [...currentSkills, skillId], { shouldValidate: true })
    }
  }

  /** Toggle subject selection */
  const toggleSubject = (subjectId: string) => {
    const currentSubjects = form.getValues('subjects')
    if (currentSubjects.includes(subjectId)) {
      form.setValue(
        'subjects',
        currentSubjects.filter((s) => s !== subjectId),
        { shouldValidate: true }
      )
    } else {
      form.setValue('subjects', [...currentSubjects, subjectId], { shouldValidate: true })
    }
  }

  /** Check if current step is valid (uses watched values for reactivity) */
  const isStepValid = (): boolean => {
    switch (currentStep) {
      case 0:
        return !!qualification
      case 1:
        return selectedSkills.length > 0 && selectedSubjects.length > 0
      case 2:
        return !!experienceLevel
      default:
        return false
    }
  }

  /** Go to next step */
  const nextStep = () => {
    if (currentStep < totalSteps - 1) {
      setCurrentStep(currentStep + 1)
    }
  }

  /** Go to previous step */
  const prevStep = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1)
    }
  }

  /** Handle form submission */
  const onSubmit = async (data: ProfileSetupFormData) => {
    setIsSubmitting(true)
    try {
      await onComplete(data)
    } catch (error) {
      console.error('Profile setup failed:', error)
      setIsSubmitting(false)
    }
    // Note: Don't setIsSubmitting(false) on success - page will navigate away
  }

  const slideVariants = {
    enter: (direction: number) => ({
      x: direction > 0 ? 100 : -100,
      opacity: 0,
    }),
    center: {
      x: 0,
      opacity: 1,
    },
    exit: (direction: number) => ({
      x: direction < 0 ? 100 : -100,
      opacity: 0,
    }),
  }

  const CurrentStepIcon = STEPS[currentStep].icon

  return (
    <div className="flex min-h-screen flex-col bg-background">
      {/* Background Pattern */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute inset-0 bg-gradient-to-br from-teal-500/5 via-transparent to-emerald-500/5" />
        <div className="absolute top-0 right-0 w-96 h-96 bg-teal-500/10 rounded-full blur-3xl" />
        <div className="absolute bottom-0 left-0 w-96 h-96 bg-emerald-500/10 rounded-full blur-3xl" />
      </div>

      {/* Header */}
      <div className="relative z-10 px-6 pt-8">
        {/* Logo */}
        <div className="mb-6 flex items-center justify-center">
          <div className="flex items-center gap-2">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-teal-400 via-teal-500 to-emerald-600 flex items-center justify-center shadow-lg shadow-teal-500/20">
              <span className="text-base font-bold text-white">AX</span>
            </div>
            <span className="font-semibold text-lg">AssignX</span>
          </div>
        </div>

        {/* Step Indicators */}
        <div className="flex items-center justify-center gap-2 mb-6">
          {STEPS.map((step, index) => {
            const StepIcon = step.icon
            const isCompleted = index < currentStep
            const isCurrent = index === currentStep

            return (
              <div key={index} className="flex items-center">
                <div className={cn(
                  "w-10 h-10 rounded-full flex items-center justify-center transition-all",
                  isCompleted && "bg-gradient-to-br from-teal-400 to-emerald-500",
                  isCurrent && "bg-gradient-to-br from-teal-400 to-emerald-500 ring-4 ring-teal-500/20",
                  !isCompleted && !isCurrent && "bg-muted"
                )}>
                  {isCompleted ? (
                    <Check className="h-5 w-5 text-white" />
                  ) : (
                    <StepIcon className={cn(
                      "h-5 w-5",
                      isCurrent ? "text-white" : "text-muted-foreground"
                    )} />
                  )}
                </div>
                {index < STEPS.length - 1 && (
                  <div className={cn(
                    "w-8 h-0.5 mx-1",
                    index < currentStep ? "bg-gradient-to-r from-teal-400 to-emerald-500" : "bg-muted"
                  )} />
                )}
              </div>
            )
          })}
        </div>

        {/* Progress Bar */}
        <div className="mb-2">
          <Progress value={progress} className="h-2" />
        </div>
        <p className="mb-4 text-center text-sm text-muted-foreground">
          Step {currentStep + 1} of {totalSteps}
        </p>

        {/* Greeting */}
        {userName && currentStep === 0 && (
          <motion.h1
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-2 text-center text-2xl font-bold text-foreground"
          >
            Welcome, {userName}!
          </motion.h1>
        )}

        {/* Step Title */}
        <div className="mb-8 text-center">
          <div className={cn(
            "w-14 h-14 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg",
            STEPS[currentStep].color === 'teal' && "bg-gradient-to-br from-teal-400 to-teal-600 shadow-teal-500/20",
            STEPS[currentStep].color === 'emerald' && "bg-gradient-to-br from-emerald-400 to-emerald-600 shadow-emerald-500/20",
            STEPS[currentStep].color === 'amber' && "bg-gradient-to-br from-amber-400 to-amber-600 shadow-amber-500/20"
          )}>
            <CurrentStepIcon className="h-7 w-7 text-white" />
          </div>
          <h2 className="text-xl font-semibold text-foreground">
            {STEPS[currentStep].title}
          </h2>
          <p className="text-muted-foreground">
            {STEPS[currentStep].description}
          </p>
        </div>
      </div>

      {/* Form Content */}
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="relative z-10 flex flex-1 flex-col">
          <div className="flex-1 overflow-y-auto px-6">
            <AnimatePresence mode="wait" custom={currentStep}>
              <motion.div
                key={currentStep}
                custom={currentStep}
                variants={slideVariants}
                initial="enter"
                animate="center"
                exit="exit"
                transition={{ duration: 0.3 }}
              >
                {/* Step 1: Education */}
                {currentStep === 0 && (
                  <div className="space-y-6 max-w-md mx-auto">
                    <FormField
                      control={form.control}
                      name="qualification"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Highest Qualification</FormLabel>
                          <Select
                            onValueChange={field.onChange}
                            defaultValue={field.value}
                          >
                            <FormControl>
                              <SelectTrigger className="h-12">
                                <SelectValue placeholder="Select your qualification" />
                              </SelectTrigger>
                            </FormControl>
                            <SelectContent>
                              {QUALIFICATION_OPTIONS.map((option) => (
                                <SelectItem key={option.value} value={option.value}>
                                  {option.label}
                                </SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                          <FormMessage />
                        </FormItem>
                      )}
                    />

                    <FormField
                      control={form.control}
                      name="universityName"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>University/Institution (Optional)</FormLabel>
                          <FormControl>
                            <Input
                              placeholder="Enter your university name"
                              className="h-12"
                              {...field}
                            />
                          </FormControl>
                          <FormDescription>
                            This helps us match you with relevant projects
                          </FormDescription>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>
                )}

                {/* Step 2: Skills & Subjects */}
                {currentStep === 1 && (
                  <div className="space-y-8 max-w-2xl mx-auto">
                    {fetchError && (
                      <div className="rounded-lg bg-destructive/10 p-4 text-sm text-destructive border border-destructive/20">
                        {fetchError}
                      </div>
                    )}
                    {isLoadingData ? (
                      <div className="flex items-center justify-center py-12">
                        <Loader2 className="h-8 w-8 animate-spin text-teal-500" />
                        <span className="ml-3 text-muted-foreground">Loading skills & subjects...</span>
                      </div>
                    ) : (
                      <>
                        {/* Skills Selection */}
                        <FormField
                          control={form.control}
                          name="skills"
                          render={() => (
                            <FormItem>
                              <div className="flex items-center justify-between">
                                <FormLabel className="text-base">Your Skills</FormLabel>
                                <Badge variant="secondary" className="text-xs">
                                  {selectedSkills.length} selected
                                </Badge>
                              </div>
                              <FormDescription>
                                Select all skills that apply to you
                              </FormDescription>
                              <div className="mt-3 flex flex-wrap gap-2">
                                {skills.map((skill) => {
                                  const isSelected = selectedSkills.includes(skill.id)
                                  return (
                                    <Badge
                                      key={skill.id}
                                      variant={isSelected ? 'default' : 'outline'}
                                      className={cn(
                                        'cursor-pointer px-4 py-2 text-sm transition-all hover:scale-105',
                                        isSelected && 'bg-gradient-to-r from-teal-500 to-emerald-500 border-0 shadow-md'
                                      )}
                                      onClick={() => toggleSkill(skill.id)}
                                    >
                                      {isSelected && <Check className="h-3 w-3 mr-1" />}
                                      {skill.name}
                                    </Badge>
                                  )
                                })}
                                {skills.length === 0 && (
                                  <p className="text-sm text-muted-foreground">No skills available</p>
                                )}
                              </div>
                              <FormMessage />
                            </FormItem>
                          )}
                        />

                        {/* Subjects Selection */}
                        <FormField
                          control={form.control}
                          name="subjects"
                          render={() => (
                            <FormItem>
                              <div className="flex items-center justify-between">
                                <FormLabel className="text-base">Areas of Interest</FormLabel>
                                <Badge variant="secondary" className="text-xs">
                                  {selectedSubjects.length} selected
                                </Badge>
                              </div>
                              <FormDescription>
                                Select subjects you are comfortable with
                              </FormDescription>
                              <div className="mt-3 flex flex-wrap gap-2">
                                {subjects.map((subject) => {
                                  const isSelected = selectedSubjects.includes(subject.id)
                                  return (
                                    <Badge
                                      key={subject.id}
                                      variant={isSelected ? 'default' : 'outline'}
                                      className={cn(
                                        'cursor-pointer px-4 py-2 text-sm transition-all hover:scale-105',
                                        isSelected && 'bg-gradient-to-r from-emerald-500 to-teal-500 border-0 shadow-md'
                                      )}
                                      onClick={() => toggleSubject(subject.id)}
                                    >
                                      {isSelected && <Check className="h-3 w-3 mr-1" />}
                                      {subject.name}
                                    </Badge>
                                  )
                                })}
                                {subjects.length === 0 && (
                                  <p className="text-sm text-muted-foreground">No subjects available</p>
                                )}
                              </div>
                              <FormMessage />
                            </FormItem>
                          )}
                        />
                      </>
                    )}
                  </div>
                )}

                {/* Step 3: Experience Level */}
                {currentStep === 2 && (
                  <FormField
                    control={form.control}
                    name="experienceLevel"
                    render={({ field }) => (
                      <FormItem className="max-w-md mx-auto">
                        <FormLabel className="text-base">Experience Level</FormLabel>
                        <FormDescription>
                          How would you rate your overall experience?
                        </FormDescription>
                        <div className="mt-4 grid gap-3">
                          {EXPERIENCE_LEVELS.map((level) => (
                            <div
                              key={level.value}
                              onClick={() => field.onChange(level.value)}
                              className={cn(
                                'flex cursor-pointer items-center justify-between rounded-xl border-2 p-4 transition-all hover:border-teal-500/50',
                                field.value === level.value
                                  ? 'border-teal-500 bg-teal-500/5'
                                  : 'border-border'
                              )}
                            >
                              <div>
                                <p className="font-medium text-foreground">
                                  {level.label}
                                </p>
                                <p className="text-sm text-muted-foreground">
                                  {level.description}
                                </p>
                              </div>
                              <div
                                className={cn(
                                  'h-6 w-6 rounded-full border-2 flex items-center justify-center transition-all',
                                  field.value === level.value
                                    ? 'border-teal-500 bg-gradient-to-br from-teal-400 to-emerald-500'
                                    : 'border-muted-foreground/30'
                                )}
                              >
                                {field.value === level.value && (
                                  <Check className="h-3.5 w-3.5 text-white" />
                                )}
                              </div>
                            </div>
                          ))}
                        </div>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                )}
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Navigation Buttons */}
          <div className="relative z-10 border-t bg-background/80 backdrop-blur-sm px-6 py-4">
            <div className="flex gap-3 max-w-md mx-auto">
              {currentStep > 0 && (
                <Button
                  type="button"
                  variant="outline"
                  onClick={prevStep}
                  className="flex-1 h-12"
                >
                  <ChevronLeft className="mr-2 h-4 w-4" />
                  Back
                </Button>
              )}

              {currentStep < totalSteps - 1 ? (
                <Button
                  type="button"
                  onClick={nextStep}
                  disabled={!isStepValid()}
                  className={cn(
                    'flex-1 h-12 gradient-primary hover:opacity-90',
                    currentStep === 0 && 'w-full'
                  )}
                >
                  Next
                  <ChevronRight className="ml-2 h-4 w-4" />
                </Button>
              ) : (
                <Button
                  type="submit"
                  disabled={!form.formState.isValid || isSubmitting}
                  className="flex-1 h-12 gradient-primary hover:opacity-90"
                >
                  {isSubmitting ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Completing Setup...
                    </>
                  ) : (
                    <>
                      Complete Setup
                      <Check className="ml-2 h-4 w-4" />
                    </>
                  )}
                </Button>
              )}
            </div>
          </div>
        </form>
      </Form>
    </div>
  )
}
