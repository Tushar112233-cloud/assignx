'use client'

/**
 * Skill Verification component
 * Displays skills with verification status
 * @module components/profile/SkillVerification
 */

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  BadgeCheck,
  Clock,
  AlertCircle,
  ChevronRight,
  Send,
  Loader2,
  CheckCircle2,
  Sparkles,
  Info,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { cn } from '@/lib/utils'
import { proficiencyConfig } from './constants'
import type { SkillWithVerification } from '@/types/database'

/**
 * SkillVerification component props
 */
interface SkillVerificationProps {
  /** Skills with verification status */
  skills?: SkillWithVerification[]
  /** Callback when verification is requested */
  onRequestVerification?: (skillId: string) => Promise<void>
  /** Loading state */
  isLoading?: boolean
  /** Additional class name */
  className?: string
}

/** Animation variants */
const itemVariants = {
  hidden: { opacity: 0, y: 10 },
  visible: (i: number) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.05 },
  }),
}

/**
 * Skill Verification component
 * Displays skills with verification status
 */
export function SkillVerification({
  skills = [],
  onRequestVerification,
  isLoading,
  className,
}: SkillVerificationProps) {
  const [selectedSkill, setSelectedSkill] = useState<SkillWithVerification | null>(null)
  const [isRequesting, setIsRequesting] = useState(false)
  const [successSkillId, setSuccessSkillId] = useState<string | null>(null)

  /** Calculate verification stats */
  const stats = {
    total: skills.length,
    verified: skills.filter((s) => s.is_verified).length,
    pending: skills.filter((s) => !s.is_verified).length,
  }
  const verificationPercentage = stats.total > 0 ? (stats.verified / stats.total) * 100 : 0

  /** Handle verification request */
  const handleRequestVerification = async () => {
    if (!selectedSkill) return

    setIsRequesting(true)
    try {
      if (onRequestVerification) {
        await onRequestVerification(selectedSkill.id)
      } else {
        await new Promise((resolve) => setTimeout(resolve, 1500))
      }
      setSuccessSkillId(selectedSkill.id)
      setTimeout(() => {
        setSelectedSkill(null)
        setSuccessSkillId(null)
      }, 2000)
    } finally {
      setIsRequesting(false)
    }
  }

  /** Get verification status icon */
  const getStatusIcon = (skill: SkillWithVerification) => {
    if (skill.is_verified) return <BadgeCheck className="h-5 w-5 text-blue-600" />
    if (successSkillId === skill.id) return <Clock className="h-5 w-5 text-amber-600" />
    return <AlertCircle className="h-5 w-5 text-slate-400" />
  }

  /** Get status badge */
  const getStatusBadge = (skill: SkillWithVerification) => {
    if (skill.is_verified) {
      return (
        <Badge variant="outline" className="bg-blue-500/10 text-blue-600 border-blue-500/30 shadow-sm">
          <CheckCircle2 className="h-3 w-3 mr-1" />
          Verified
        </Badge>
      )
    }
    if (successSkillId === skill.id) {
      return (
        <Badge variant="outline" className="bg-amber-500/10 text-amber-600 border-amber-500/30 shadow-sm">
          <Clock className="h-3 w-3 mr-1" />
          Pending
        </Badge>
      )
    }
    return <Badge variant="outline" className="bg-slate-100 text-slate-600 border-slate-200">Not Verified</Badge>
  }

  return (
    <div className={cn('space-y-6', className)}>
      <div className="grid gap-6 xl:grid-cols-[1fr_0.8fr]">
        {/* Verification overview */}
        <Card className="w-full max-w-full overflow-hidden shadow-md border-slate-200">
          <CardHeader className="p-6 pb-4">
            <CardTitle className="flex items-center gap-2.5 text-xl">
              <div className="p-2 flex-shrink-0 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 shadow-md">
                <Sparkles className="h-5 w-5 text-white" />
              </div>
              <span className="truncate">Skill Verification</span>
            </CardTitle>
            <CardDescription className="text-slate-600 line-clamp-2">
              Verified skills get priority in project matching
            </CardDescription>
          </CardHeader>
          <CardContent className="p-6 space-y-5">
            <div className="space-y-3 p-4 rounded-xl bg-gradient-to-br from-blue-50 to-slate-50 border border-blue-100">
              <div className="flex items-center justify-between text-sm">
                <span className="font-medium text-slate-700">Verification Progress</span>
                <span className="font-semibold text-blue-600">{stats.verified} of {stats.total} verified</span>
              </div>
              <Progress value={verificationPercentage} className="h-2.5 bg-blue-100" />
            </div>

            <div className="grid grid-cols-3 gap-3 pt-1">
              <div className="text-center p-4 rounded-xl border-2 border-slate-200 bg-white shadow-sm hover:shadow-md transition-shadow">
                <p className="text-2xl font-bold bg-gradient-to-br from-slate-700 to-slate-900 bg-clip-text text-transparent">{stats.total}</p>
                <p className="text-xs font-medium text-slate-500 mt-1">Total Skills</p>
              </div>
              <div className="text-center p-4 rounded-xl border-2 border-blue-200 bg-gradient-to-br from-blue-50 to-white shadow-sm hover:shadow-md transition-shadow">
                <p className="text-2xl font-bold text-blue-600">{stats.verified}</p>
                <p className="text-xs font-medium text-blue-600/70 mt-1">Verified</p>
              </div>
              <div className="text-center p-4 rounded-xl border-2 border-amber-200 bg-gradient-to-br from-amber-50 to-white shadow-sm hover:shadow-md transition-shadow">
                <p className="text-2xl font-bold text-amber-600">{stats.pending}</p>
                <p className="text-xs font-medium text-amber-600/70 mt-1">Pending</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Info alert */}
        <Alert className="border-blue-200 bg-gradient-to-br from-blue-50 to-white shadow-sm">
          <div className="p-1.5 rounded-lg bg-blue-500/10">
            <Info className="h-4 w-4 text-blue-600" />
          </div>
          <AlertTitle className="text-blue-900 font-semibold">Why verify skills?</AlertTitle>
          <AlertDescription className="text-slate-600">
            Verified skills help you get more projects. Verification involves a short assessment
            to confirm your proficiency level.
          </AlertDescription>
        </Alert>
      </div>

      {/* Skills list */}
      <Card className="w-full max-w-full overflow-hidden shadow-md border-slate-200">
        <CardHeader className="p-6 pb-4">
          <CardTitle className="text-xl truncate">Your Skills</CardTitle>
          <CardDescription className="text-slate-600 line-clamp-2">
            Click on unverified skills to request verification
          </CardDescription>
        </CardHeader>
        <CardContent className="p-6">
          {skills.length === 0 ? (
            <div className="text-center py-12">
              <div className="w-16 h-16 mx-auto rounded-2xl bg-blue-50 flex items-center justify-center mb-4">
                <Sparkles className="h-8 w-8 text-blue-300" />
              </div>
              <p className="text-muted-foreground font-medium">No skills added yet</p>
              <p className="text-sm text-muted-foreground/70 mt-1">Add skills to your profile to get matched with projects</p>
            </div>
          ) : (
          <div className="w-full space-y-2.5">
            <AnimatePresence>
              {skills.map((skill, index) => {
                const proficiency = proficiencyConfig[skill.proficiency_level]

                return (
                  <motion.div
                    key={skill.id}
                    custom={index}
                    initial="hidden"
                    animate="visible"
                    variants={itemVariants}
                  >
                    <button
                      type="button"
                      onClick={() => !skill.is_verified && setSelectedSkill(skill)}
                      disabled={skill.is_verified || isLoading}
                      className={cn(
                        'w-full flex items-center justify-between p-4 rounded-xl border-2 transition-all duration-200 group',
                        skill.is_verified
                          ? 'bg-gradient-to-br from-blue-50 to-white border-blue-200 cursor-default shadow-sm'
                          : 'bg-white border-slate-200 hover:border-blue-300 hover:shadow-md cursor-pointer hover:scale-[1.01]'
                      )}
                    >
                      <div className="flex items-center gap-3.5">
                        <div className={cn(
                          'p-2 rounded-lg transition-colors',
                          skill.is_verified
                            ? 'bg-blue-500/10'
                            : 'bg-slate-100 group-hover:bg-blue-500/10'
                        )}>
                          {getStatusIcon(skill)}
                        </div>
                        <div className="text-left">
                          <p className="font-semibold text-slate-900">{skill.name}</p>
                          <div className="flex items-center gap-2 mt-1.5">
                            <Badge variant="outline" className={cn('text-xs shadow-sm', proficiency.bgColor, proficiency.color)}>
                              {proficiency.label}
                            </Badge>
                            {skill.category && (
                              <span className="text-xs font-medium text-slate-500">{skill.category}</span>
                            )}
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center gap-2.5">
                        {getStatusBadge(skill)}
                        {!skill.is_verified && successSkillId !== skill.id && (
                          <ChevronRight className="h-4 w-4 text-slate-400 group-hover:text-blue-600 transition-colors" />
                        )}
                      </div>
                    </button>
                  </motion.div>
                )
              })}
            </AnimatePresence>
          </div>
          )}
        </CardContent>
      </Card>

      {/* Verification request dialog */}
      <Dialog open={!!selectedSkill} onOpenChange={() => setSelectedSkill(null)}>
        <DialogContent className="sm:max-w-md shadow-xl">
          <AnimatePresence mode="wait">
            {successSkillId === selectedSkill?.id ? (
              <motion.div
                key="success"
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="text-center py-6"
              >
                <div className="w-20 h-20 rounded-full bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center mx-auto mb-5 shadow-lg">
                  <CheckCircle2 className="h-10 w-10 text-white" />
                </div>
                <DialogTitle className="text-2xl mb-2 text-slate-900">Request Submitted!</DialogTitle>
                <DialogDescription className="text-slate-600 text-base">
                  We'll review your skill and get back to you within 24 hours.
                </DialogDescription>
              </motion.div>
            ) : (
              <motion.div key="form" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                <DialogHeader>
                  <DialogTitle className="text-xl text-slate-900">Request Skill Verification</DialogTitle>
                  <DialogDescription className="text-slate-600">
                    Request verification for {selectedSkill?.name}
                  </DialogDescription>
                </DialogHeader>

                <div className="py-6 space-y-5">
                  <div className="p-5 rounded-xl bg-gradient-to-br from-blue-50 to-slate-50 border border-blue-100 shadow-sm">
                    <div className="flex items-center gap-4 mb-4">
                      <div className="h-14 w-14 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-md">
                        <BadgeCheck className="h-7 w-7 text-white" />
                      </div>
                      <div>
                        <p className="font-semibold text-slate-900">{selectedSkill?.name}</p>
                        <p className="text-sm text-blue-600 font-medium mt-0.5">
                          {proficiencyConfig[selectedSkill?.proficiency_level || 'beginner'].label} level
                        </p>
                      </div>
                    </div>
                    <p className="text-sm text-slate-600 leading-relaxed">
                      After submitting, you'll receive a short assessment to verify your
                      proficiency. Successfully completing it will add a verification badge
                      to your skill.
                    </p>
                  </div>

                  <div className="space-y-3 p-4 rounded-xl bg-white border border-slate-200">
                    <h4 className="font-semibold text-sm text-slate-900">What happens next?</h4>
                    <ol className="list-decimal list-inside text-sm text-slate-600 space-y-2 pl-1">
                      <li>We'll send you a verification assessment</li>
                      <li>Complete the assessment within 24 hours</li>
                      <li>Get your skill verified upon successful completion</li>
                    </ol>
                  </div>
                </div>

                <DialogFooter className="gap-2">
                  <Button
                    variant="outline"
                    onClick={() => setSelectedSkill(null)}
                    className="border-slate-300 hover:bg-slate-50"
                  >
                    Cancel
                  </Button>
                  <Button
                    onClick={handleRequestVerification}
                    disabled={isRequesting}
                    className="gap-2 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 shadow-md"
                  >
                    {isRequesting ? (
                      <>
                        <Loader2 className="h-4 w-4 animate-spin" />
                        Submitting...
                      </>
                    ) : (
                      <>
                        <Send className="h-4 w-4" />
                        Request Verification
                      </>
                    )}
                  </Button>
                </DialogFooter>
              </motion.div>
            )}
          </AnimatePresence>
        </DialogContent>
      </Dialog>
    </div>
  )
}
