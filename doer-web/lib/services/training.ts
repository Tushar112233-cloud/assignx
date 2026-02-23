import { createClient } from '@/lib/supabase/client'

export async function getTrainingModules(role: string) {
  const supabase = createClient()
  const { data, error } = await supabase
    .from('training_modules')
    .select('*')
    .eq('target_role', role)
    .eq('is_active', true)
    .order('sequence_order', { ascending: true })
  if (error) throw error
  return data || []
}

export async function getTrainingProgress(profileId: string) {
  const supabase = createClient()
  const { data, error } = await supabase
    .from('training_progress')
    .select('*')
    .eq('profile_id', profileId)
  if (error) throw error
  return data || []
}

export async function markModuleComplete(profileId: string, moduleId: string) {
  const supabase = createClient()
  const { error } = await supabase
    .from('training_progress')
    .upsert({
      profile_id: profileId,
      module_id: moduleId,
      status: 'completed',
      progress_percentage: 100,
      completed_at: new Date().toISOString(),
    }, { onConflict: 'profile_id,module_id' })
  if (error) throw error
}

export async function isTrainingComplete(profileId: string, role: string) {
  const supabase = createClient()
  const { data: modules } = await supabase
    .from('training_modules')
    .select('id')
    .eq('target_role', role)
    .eq('is_mandatory', true)
    .eq('is_active', true)

  const { data: progress } = await supabase
    .from('training_progress')
    .select('module_id, status')
    .eq('profile_id', profileId)

  const completedIds = new Set(
    (progress || []).filter((p: any) => p.status === 'completed').map((p: any) => p.module_id)
  )
  return (modules || []).every((m: any) => completedIds.has(m.id))
}
