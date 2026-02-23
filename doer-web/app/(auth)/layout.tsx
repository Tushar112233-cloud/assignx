/**
 * @fileoverview Auth layout for login and registration pages
 * Social Proof Focus design with 55/45 split and refined visual design
 */

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen h-screen bg-[#EEF2F8] px-4 py-6 text-slate-900">
      <div className="mx-auto h-full max-w-6xl overflow-hidden rounded-[36px] bg-white shadow-[0_40px_120px_-70px_rgba(36,64,122,0.5)]">
        <div className="grid h-full grid-cols-1 lg:grid-cols-[0.95fr_1.05fr]">
          <div className="relative hidden h-full flex-col justify-between bg-[#0C0F14] p-10 text-white lg:flex">
            <div>
              <div className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-4 py-2 text-xs font-medium text-white/80">
                <span className="text-base">✨</span>
                AssignX Doer Portal
              </div>
            </div>

            <div className="space-y-4">
              <h1 className="text-4xl leading-tight font-semibold">
                Turn your skills
                <br />
                into real earnings.
              </h1>
              <p className="text-sm text-white/70 max-w-sm">
                Build your reputation, choose work you love, and grow on your own terms.
              </p>
            </div>

            <div className="relative h-52 overflow-hidden rounded-[28px] border border-white/10 bg-white/5">
              <div className="absolute inset-0">
                <div className="absolute -left-8 bottom-[-20%] h-48 w-48 rounded-full bg-gradient-to-br from-[#5C7CFF] to-[#9AA9FF] opacity-50 blur-2xl" />
                <div className="absolute right-0 top-0 h-40 w-40 rounded-full bg-gradient-to-br from-[#FFB199] to-[#7C8BFF] opacity-40 blur-2xl" />
                <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_30%,rgba(255,255,255,0.08),transparent_60%)]" />
              </div>
              <div className="relative grid h-full grid-cols-3 items-end gap-3 p-6">
                <div className="h-20 rounded-2xl bg-white/10" />
                <div className="h-28 rounded-2xl bg-white/20" />
                <div className="h-16 rounded-2xl bg-white/10" />
              </div>
            </div>
          </div>

          <div className="relative flex h-full items-center justify-center px-6 py-8">
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_20%,rgba(76,127,255,0.08),transparent_55%)]" />
            <div className="relative w-full max-w-md">
              {children}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
