/**
 * Resources service
 * Handles training modules, templates, citations, and AI reports
 */

import { createClient } from '@/lib/supabase/client'
import type {
  TrainingModule,
  TrainingProgress,
  FormatTemplate,
  Citation,
  AIReport,
  ReferenceStyleType,
} from '@/types/database'

/**
 * Fetch all training modules
 */
export async function getTrainingModules(): Promise<TrainingModule[]> {
  const supabase = createClient()

  const { data, error } = await supabase
    .from('training_modules')
    .select('*')
    .eq('is_active', true)
    .order('sequence_order', { ascending: true })

  if (error) {
    console.error('Error fetching training modules:', error)
    throw error
  }

  return data || []
}

/**
 * Fetch training progress for a doer
 */
export async function getTrainingProgress(doerId: string): Promise<TrainingProgress[]> {
  const supabase = createClient()

  // Get profile_id from doer record (training_progress uses profile_id)
  const { data: doer, error: doerError } = await supabase
    .from('doers')
    .select('profile_id')
    .eq('id', doerId)
    .single()

  if (doerError || !doer) {
    console.error('Error fetching doer for training progress:', doerError)
    throw doerError || new Error('Doer not found')
  }

  const { data, error } = await supabase
    .from('training_progress')
    .select('*')
    .eq('profile_id', doer.profile_id)

  if (error) {
    console.error('Error fetching training progress:', error)
    throw error
  }

  return data || []
}

/**
 * Update training progress
 */
export async function updateTrainingProgress(
  doerId: string,
  moduleId: string,
  progressPercentage: number,
  isCompleted: boolean = false
): Promise<TrainingProgress> {
  const supabase = createClient()

  // Get profile_id from doer record (training_progress uses profile_id)
  const { data: doer, error: doerError } = await supabase
    .from('doers')
    .select('profile_id')
    .eq('id', doerId)
    .single()

  if (doerError || !doer) {
    console.error('Error fetching doer for training progress update:', doerError)
    throw doerError || new Error('Doer not found')
  }

  const updateData: Partial<TrainingProgress> = {
    progress_percentage: progressPercentage,
    is_completed: isCompleted,
    ...(isCompleted && { completed_at: new Date().toISOString() }),
  }

  // Check if progress exists
  const { data: existing } = await supabase
    .from('training_progress')
    .select('id')
    .eq('profile_id', doer.profile_id)
    .eq('module_id', moduleId)
    .single()

  if (existing) {
    const { data, error } = await supabase
      .from('training_progress')
      .update(updateData)
      .eq('id', existing.id)
      .select()
      .single()

    if (error) throw error
    return data
  } else {
    const { data, error } = await supabase
      .from('training_progress')
      .insert({
        profile_id: doer.profile_id,
        module_id: moduleId,
        started_at: new Date().toISOString(),
        ...updateData,
      })
      .select()
      .single()

    if (error) throw error
    return data
  }
}

/**
 * Fetch all format templates
 */
export async function getFormatTemplates(): Promise<FormatTemplate[]> {
  const supabase = createClient()

  const { data, error } = await supabase
    .from('format_templates')
    .select('*')
    .eq('is_active', true)
    .order('category', { ascending: true })
    .order('name', { ascending: true })

  if (error) {
    console.error('Error fetching templates:', error)
    throw error
  }

  return data || []
}

/**
 * Increment template download count
 */
export async function incrementTemplateDownload(templateId: string): Promise<void> {
  const supabase = createClient()

  const { error } = await supabase.rpc('increment_template_download', {
    template_id: templateId,
  })

  if (error) {
    console.error('Error incrementing download count:', error)
  }
}

/**
 * Generate citation from URL
 */
export async function generateCitation(
  url: string,
  style: ReferenceStyleType
): Promise<string> {
  // This would typically call an external API for citation generation
  // For now, we'll return a formatted placeholder based on style

  const currentDate = new Date()
  const accessDate = currentDate.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

  // Extract domain for basic formatting
  let domain = ''
  try {
    domain = new URL(url).hostname.replace('www.', '')
  } catch {
    domain = 'Unknown Source'
  }

  switch (style) {
    case 'APA':
      return `${domain}. (n.d.). Retrieved ${accessDate}, from ${url}`
    case 'Harvard':
      return `${domain} (n.d.) Available at: ${url} (Accessed: ${accessDate}).`
    case 'MLA':
      return `"${domain}." Web. ${accessDate}. <${url}>.`
    case 'Chicago':
      return `"${domain}." Accessed ${accessDate}. ${url}.`
    case 'IEEE':
      return `[Online]. Available: ${url}. [Accessed: ${accessDate}].`
    case 'Vancouver':
      return `${domain} [Internet]. Available from: ${url} [cited ${accessDate}].`
    default:
      return `${domain}. ${url}. Accessed ${accessDate}.`
  }
}

/**
 * Save citation to history
 */
export async function saveCitation(
  doerId: string,
  citation: Omit<Citation, 'id' | 'doer_id' | 'created_at'>
): Promise<Citation> {
  // Citations table not yet created in database — return placeholder
  // TODO: Uncomment DB insert when citations table is migrated
  return {
    id: `temp-${Date.now()}`,
    doer_id: doerId,
    ...citation,
    created_at: new Date().toISOString(),
  } as Citation
}

/**
 * Fetch citation history for a doer
 * TODO: Implement citations table in database first
 * Currently returns empty array as citations table doesn't exist yet
 */
export async function getCitationHistory(doerId: string): Promise<Citation[]> {
  // Citations feature not yet implemented - table doesn't exist in database
  // Return empty array to prevent errors
  return []

  /* Uncomment when citations table is created in database:
  const supabase = createClient()

  const { data, error } = await supabase
    .from('citations')
    .select('*')
    .eq('doer_id', doerId)
    .order('created_at', { ascending: false })
    .limit(50)

  if (error) {
    console.error('Error fetching citations:', error)
    throw error
  }

  return data || []
  */
}

/**
 * Check AI content percentage
 * This would typically integrate with an external AI detection API
 */
export async function checkAIContent(
  text: string,
  doerId: string,
  projectId?: string
): Promise<AIReport> {
  const supabase = createClient()

  // TODO: Integrate with an external AI detection API (e.g., Originality.ai, GPTZero)
  // For now, return a placeholder result indicating the feature is pending integration
  const aiPercentage = 0
  const originalityPercentage = 100

  const detailedBreakdown = {
    total_words: text.split(/\s+/).length,
    sentences_analyzed: text.split(/[.!?]+/).length,
    ai_patterns_detected: 0,
    confidence_score: 0,
    sections: [
      { name: 'Introduction', ai_percentage: 0 },
      { name: 'Body', ai_percentage: 0 },
      { name: 'Conclusion', ai_percentage: 0 },
    ],
  }

  const { data, error } = await supabase
    .from('ai_reports')
    .insert({
      doer_id: doerId,
      project_id: projectId || null,
      input_text: text.substring(0, 10000), // Limit stored text
      ai_percentage: aiPercentage,
      originality_percentage: originalityPercentage,
      detailed_breakdown: detailedBreakdown,
    })
    .select()
    .single()

  if (error) {
    console.error('Error saving AI report:', error)
    // Return a temporary report even if save fails
    return {
      id: 'temp-' + Date.now(),
      doer_id: doerId,
      project_id: projectId || null,
      input_text: text.substring(0, 1000),
      file_url: null,
      ai_percentage: aiPercentage,
      originality_percentage: originalityPercentage,
      detailed_breakdown: detailedBreakdown,
      created_at: new Date().toISOString(),
    }
  }

  return data
}

/**
 * Fetch AI report history
 */
export async function getAIReportHistory(doerId: string): Promise<AIReport[]> {
  const supabase = createClient()

  const { data, error } = await supabase
    .from('ai_reports')
    .select('*')
    .eq('doer_id', doerId)
    .order('created_at', { ascending: false })
    .limit(20)

  if (error) {
    console.error('Error fetching AI reports:', error)
    throw error
  }

  return data || []
}
