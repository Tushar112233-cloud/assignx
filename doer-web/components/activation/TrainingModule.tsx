'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Play, FileText, Check, Clock, ChevronRight, Video } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import type { TrainingModule as TrainingModuleType } from '@/types/database'

interface TrainingModuleProps {
  /** Training modules from database */
  modules: TrainingModuleType[]
  /** Callback when all modules are completed */
  onComplete: () => void
  /** Initial completed modules */
  completedModules?: string[]
}

/**
 * Training module component
 * Shows video/PDF carousel for training content
 */
export function TrainingModule({
  modules,
  onComplete,
  completedModules: initialCompleted = [],
}: TrainingModuleProps) {
  const [completedModules, setCompletedModules] = useState<string[]>(initialCompleted)
  const [activeModule, setActiveModule] = useState<string | null>(
    modules[0]?.id || null
  )
  const [isPlaying, setIsPlaying] = useState(false)

  /** Calculate overall progress */
  const progressPercentage = modules.length > 0 ? (completedModules.length / modules.length) * 100 : 0
  const allCompleted = modules.length > 0 && completedModules.length === modules.length

  /** Mark a module as completed */
  const markAsCompleted = (moduleId: string) => {
    if (!completedModules.includes(moduleId)) {
      const newCompleted = [...completedModules, moduleId]
      setCompletedModules(newCompleted)

      // Move to next module
      const currentIndex = modules.findIndex(m => m.id === moduleId)
      if (currentIndex < modules.length - 1) {
        setActiveModule(modules[currentIndex + 1].id)
      }
    }
  }

  /** Get the active module details */
  const currentModule = modules.find(m => m.id === activeModule)

  /** Handle complete all training */
  const handleCompleteTraining = () => {
    onComplete()
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Header */}
      <div className="text-center space-y-2">
        <h1 className="text-2xl font-bold">Training Modules</h1>
        <p className="text-muted-foreground">
          Complete all training modules to proceed to the quiz
        </p>
      </div>

      {/* Progress overview */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium">Overall Progress</span>
            <span className="text-sm text-muted-foreground">
              {completedModules.length} of {modules.length} completed
            </span>
          </div>
          <Progress value={progressPercentage} className="h-2" />
        </CardContent>
      </Card>

      <div className="grid md:grid-cols-3 gap-6">
        {/* Module list */}
        <div className="md:col-span-1 space-y-2">
          <h3 className="font-medium text-sm text-muted-foreground mb-3">
            Modules
          </h3>
          {modules.map((module, index) => {
            const isCompleted = completedModules.includes(module.id)
            const isActive = activeModule === module.id

            return (
              <motion.button
                key={module.id}
                onClick={() => setActiveModule(module.id)}
                className={cn(
                  'w-full text-left p-3 rounded-lg border transition-colors',
                  isActive && 'border-primary bg-primary/5',
                  !isActive && 'border-transparent hover:bg-muted/50',
                  isCompleted && !isActive && 'opacity-70'
                )}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                aria-label={`${isCompleted ? 'Completed: ' : ''}Module ${index + 1}: ${module.title}${isActive ? ' (current)' : ''}`}
                aria-current={isActive ? 'step' : undefined}
              >
                <div className="flex items-center gap-3">
                  <div
                    className={cn(
                      'w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0',
                      isCompleted && 'bg-green-500 text-white',
                      !isCompleted && isActive && 'bg-primary text-primary-foreground',
                      !isCompleted && !isActive && 'bg-muted text-muted-foreground'
                    )}
                    aria-hidden="true"
                  >
                    {isCompleted ? (
                      <Check className="w-4 h-4" />
                    ) : (
                      <span className="text-sm font-medium">{index + 1}</span>
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className={cn(
                      'font-medium text-sm truncate',
                      isActive && 'text-primary'
                    )}>
                      {module.title}
                    </p>
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                      {module.content_type === 'video' ? (
                        <Video className="w-3 h-3" aria-hidden="true" />
                      ) : (
                        <FileText className="w-3 h-3" aria-hidden="true" />
                      )}
                      <span>{module.duration_minutes} min</span>
                    </div>
                  </div>
                </div>
              </motion.button>
            )
          })}
        </div>

        {/* Content viewer */}
        <div className="md:col-span-2">
          <AnimatePresence mode="wait">
            {currentModule && (
              <motion.div
                key={currentModule.id}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
              >
                <Card>
                  <CardHeader>
                    <div className="flex items-start justify-between">
                      <div>
                        <Badge variant="secondary" className="mb-2">
                          {currentModule.content_type === 'video' ? 'Video' : 'Document'}
                        </Badge>
                        <CardTitle>{currentModule.title}</CardTitle>
                        <CardDescription>{currentModule.description}</CardDescription>
                      </div>
                      <div className="flex items-center gap-1 text-muted-foreground">
                        <Clock className="w-4 h-4" />
                        <span className="text-sm">{currentModule.duration_minutes} min</span>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {/* Video/PDF viewer */}
                    <div className="relative aspect-video bg-muted rounded-lg overflow-hidden">
                      {currentModule.content_type === 'video' ? (
                        <>
                          {isPlaying ? (
                            <iframe
                              src={`${currentModule.content_url}?autoplay=1`}
                              className="w-full h-full"
                              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                              allowFullScreen
                              title={`Training video: ${currentModule.title}`}
                            />
                          ) : (
                            <div className="absolute inset-0 flex items-center justify-center">
                              <Button
                                size="lg"
                                className="rounded-full w-16 h-16"
                                onClick={() => setIsPlaying(true)}
                                aria-label={`Play video: ${currentModule.title}`}
                              >
                                <Play className="w-6 h-6 ml-1" aria-hidden="true" />
                              </Button>
                            </div>
                          )}
                        </>
                      ) : (
                        <div className="absolute inset-0 flex items-center justify-center">
                          <div className="text-center">
                            <FileText className="w-16 h-16 text-muted-foreground mx-auto mb-4" aria-hidden="true" />
                            <Button variant="outline" aria-label={`View PDF: ${currentModule.title}`}>
                              View PDF Document
                            </Button>
                          </div>
                        </div>
                      )}
                    </div>

                    {/* Mark as complete button */}
                    <div className="flex justify-between items-center">
                      {completedModules.includes(currentModule.id) ? (
                        <div className="flex items-center gap-2 text-green-600" role="status" aria-label={`Module ${currentModule.title} completed`}>
                          <Check className="w-5 h-5" aria-hidden="true" />
                          <span className="font-medium">Completed</span>
                        </div>
                      ) : (
                        <Button
                          onClick={() => markAsCompleted(currentModule.id)}
                          className="gap-2"
                          aria-label={`Mark module ${currentModule.title} as complete`}
                        >
                          <Check className="w-4 h-4" aria-hidden="true" />
                          Mark as Complete
                        </Button>
                      )}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* Complete training button */}
      {allCompleted && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex justify-center"
        >
          <Button size="lg" onClick={handleCompleteTraining} className="gap-2" aria-label="Continue to Quiz after completing all training modules">
            Continue to Quiz
            <ChevronRight className="w-4 h-4" aria-hidden="true" />
          </Button>
        </motion.div>
      )}
    </div>
  )
}
