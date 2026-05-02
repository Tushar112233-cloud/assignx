/**
 * Onboarding layout for welcome and profile setup pages
 * Provides a full-screen layout with subtle background effects
 */
export default function OnboardingLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen bg-background relative overflow-hidden">
      {children}
    </div>
  )
}
