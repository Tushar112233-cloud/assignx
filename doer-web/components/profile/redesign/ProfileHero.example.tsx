/**
 * ProfileHero Component - Usage Examples
 *
 * This file demonstrates how to use the ProfileHero component
 * in different scenarios with the profile page.
 */

import { ProfileHero } from './ProfileHero'

/**
 * Example 1: Basic usage with minimal data
 */
export function BasicExample() {
  return (
    <ProfileHero
      profile={{
        full_name: 'John Doe',
        email: 'john.doe@example.com',
        avatar_url: null
      }}
      doer={{
        is_activated: false,
        qualification: null,
        experience_level: null
      }}
      stats={{
        totalEarnings: 0,
        completedProjects: 0,
        averageRating: 0,
        onTimeDeliveryRate: 0,
        totalReviews: 0
      }}
      profileCompletion={25}
    />
  )
}

/**
 * Example 2: Complete profile with all features
 */
export function CompleteExample() {
  return (
    <ProfileHero
      profile={{
        full_name: 'Jasvin Singh',
        email: 'jasvin@example.com',
        avatar_url: 'https://example.com/avatar.jpg'
      }}
      doer={{
        is_activated: true,
        qualification: 'bachelors_degree',
        experience_level: 'expert'
      }}
      stats={{
        totalEarnings: 125000,
        completedProjects: 42,
        averageRating: 4.8,
        onTimeDeliveryRate: 95.5,
        totalReviews: 38
      }}
      profileCompletion={92}
      onEditProfile={() => console.log('Edit profile clicked')}
      onViewPayouts={() => console.log('View payouts clicked')}
      onViewEarnings={() => console.log('View earnings clicked')}
    />
  )
}

/**
 * Example 3: Integration with profile page state management
 */
export function IntegratedExample() {
  // In actual usage, these would come from props or hooks
  const profile = {
    full_name: 'Sarah Johnson',
    email: 'sarah.j@example.com',
    avatar_url: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah'
  }

  const doer = {
    is_activated: true,
    qualification: 'masters_degree',
    experience_level: 'intermediate'
  }

  const stats = {
    totalEarnings: 85000,
    completedProjects: 28,
    averageRating: 4.6,
    onTimeDeliveryRate: 89.2,
    totalReviews: 24
  }

  // Calculate profile completion
  const completionFields = [
    Boolean(profile.full_name),
    Boolean(profile.email),
    Boolean(profile.avatar_url),
    Boolean(doer.qualification),
    Boolean(doer.experience_level),
    Boolean(doer.is_activated),
    // Add more fields as needed
  ]
  const profileCompletion = Math.round(
    (completionFields.filter(Boolean).length / completionFields.length) * 100
  )

  const handleEditProfile = () => {
    // Navigate to edit profile tab
    console.log('Navigating to edit profile')
  }

  const handleViewPayouts = () => {
    // Navigate to payments tab
    console.log('Navigating to payments')
  }

  const handleViewEarnings = () => {
    // Navigate to earnings tab
    console.log('Navigating to earnings')
  }

  return (
    <ProfileHero
      profile={profile}
      doer={doer}
      stats={stats}
      profileCompletion={profileCompletion}
      onEditProfile={handleEditProfile}
      onViewPayouts={handleViewPayouts}
      onViewEarnings={handleViewEarnings}
    />
  )
}

/**
 * Example 4: Usage in the actual profile page
 *
 * Replace the existing hero section in profile/page.tsx (lines 335-426)
 * with this ProfileHero component:
 */
export function ProfilePageIntegration() {
  // This shows how to use it in the actual profile page
  /*
  <ProfileHero
    profile={profile}
    doer={doer}
    stats={stats}
    profileCompletion={profileCompletion}
    onEditProfile={() => setActiveTab('edit')}
    onViewPayouts={() => setActiveTab('payments')}
    onViewEarnings={() => setActiveTab('earnings')}
  />
  */
  return null // This is just documentation
}
