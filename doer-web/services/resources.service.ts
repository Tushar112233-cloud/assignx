/**
 * Resources service
 * Handles training modules, templates, citations, and AI reports via API
 */

import { apiClient } from '@/lib/api/client'
import type {
  TrainingModule,
  TrainingProgress,
  FormatTemplate,
  Citation,
  AIReport,
  ReferenceStyleType,
} from '@/types/database'

export async function getTrainingModules(): Promise<TrainingModule[]> {
  try {
    const data = await apiClient<{ modules: TrainingModule[] }>('/api/training/modules')
    return data.modules || []
  } catch (err) {
    console.error('Error fetching training modules:', err)
    throw err
  }
}

export async function getTrainingProgress(doerId: string): Promise<TrainingProgress[]> {
  try {
    const data = await apiClient<{ progress: TrainingProgress[] }>(`/api/training/progress?doer_id=${doerId}`)
    return data.progress || []
  } catch (err) {
    console.error('Error fetching training progress:', err)
    throw err
  }
}

export async function updateTrainingProgress(
  doerId: string,
  moduleId: string,
  progressPercentage: number,
  isCompleted: boolean = false
): Promise<TrainingProgress> {
  return apiClient<TrainingProgress>(`/api/training/progress/${moduleId}`, {
    method: 'PUT',
    body: JSON.stringify({
      doer_id: doerId,
      progress_percentage: progressPercentage,
      status: isCompleted ? 'completed' : 'in_progress',
      ...(isCompleted && { completed_at: new Date().toISOString() }),
    }),
  })
}

export async function getFormatTemplates(): Promise<FormatTemplate[]> {
  try {
    const data = await apiClient<{ templates: FormatTemplate[] }>('/api/resources/templates')
    return data.templates || []
  } catch {
    return []
  }
}

export async function incrementTemplateDownload(templateId: string): Promise<void> {
  try {
    await apiClient(`/api/resources/templates/${templateId}/download`, {
      method: 'POST',
    })
  } catch {
    // Non-critical
  }
}

export async function generateCitation(
  url: string,
  style: ReferenceStyleType
): Promise<string> {
  const currentDate = new Date()
  const accessDate = currentDate.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

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

export async function saveCitation(
  doerId: string,
  citation: Omit<Citation, 'id' | 'doer_id' | 'created_at'>
): Promise<Citation> {
  return {
    id: `temp-${Date.now()}`,
    doer_id: doerId,
    ...citation,
    created_at: new Date().toISOString(),
  } as Citation
}

export async function getCitationHistory(_doerId: string): Promise<Citation[]> {
  return []
}

export async function checkAIContent(
  text: string,
  doerId: string,
  projectId?: string
): Promise<AIReport> {
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

export async function getAIReportHistory(_doerId: string): Promise<AIReport[]> {
  return []
}
