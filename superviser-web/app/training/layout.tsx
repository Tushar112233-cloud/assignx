/**
 * @fileoverview Training layout — minimal chrome with logo header.
 * @module app/training/layout
 */

export default function TrainingLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen bg-[#F5F5F5]">
      {/* Header */}
      <header className="border-b border-gray-200/60 bg-white/80 backdrop-blur-xl">
        <div className="max-w-4xl mx-auto px-6 py-4 flex items-center gap-3">
          <div className="h-9 w-9 rounded-xl bg-[#F97316] flex items-center justify-center shadow-sm">
            <span className="text-sm font-bold text-white">AX</span>
          </div>
          <div>
            <p className="text-sm font-semibold text-[#1C1C1C] leading-tight">AssignX</p>
            <p className="text-[10px] text-[#F97316] font-semibold tracking-[0.1em]">TRAINING</p>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="max-w-4xl mx-auto px-6 py-8">
        {children}
      </main>
    </div>
  )
}
