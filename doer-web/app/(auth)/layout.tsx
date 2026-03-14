/**
 * @fileoverview Auth layout — 40/60 split
 * Left: bold blue branded panel | Right: clean white form area
 */

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen h-screen flex">
      {/* Left panel — 40% — Blue branded side */}
      <div className="relative hidden lg:flex w-[40%] flex-col justify-between overflow-hidden bg-[#0B0F1A] p-10 text-white">
        {/* Background gradient accents */}
        <div className="pointer-events-none absolute inset-0">
          <div className="absolute -top-20 -left-20 h-[400px] w-[400px] rounded-full bg-[#5A7CFF]/20 blur-[100px]" />
          <div className="absolute bottom-0 right-0 h-[350px] w-[350px] rounded-full bg-[#818CF8]/15 blur-[100px]" />
        </div>

        {/* Grid pattern */}
        <div
          className="pointer-events-none absolute inset-0 opacity-[0.04]"
          style={{
            backgroundImage:
              'linear-gradient(rgba(255,255,255,0.15) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.15) 1px, transparent 1px)',
            backgroundSize: '48px 48px',
          }}
        />

        {/* Logo */}
        <div className="relative z-10">
          <div className="flex items-center gap-2.5">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-[#5A7CFF]">
              <span className="text-sm font-bold text-white">D</span>
            </div>
            <span className="text-lg font-bold tracking-tight">Dolancer</span>
          </div>
        </div>

        {/* Headline */}
        <div className="relative z-10 space-y-4">
          <h1 className="text-[2.5rem] leading-[1.1] font-bold tracking-tight">
            Turn your skills
            <br />
            into real{' '}
            <span className="bg-gradient-to-r from-[#5A7CFF] to-[#A5B4FC] bg-clip-text text-transparent">
              earnings
            </span>
          </h1>
          <p className="text-sm leading-relaxed text-white/50 max-w-xs">
            Choose projects that match your expertise. Work on your schedule. Get paid fast.
          </p>
        </div>

        {/* Stats */}
        <div className="relative z-10 flex gap-8">
          {[
            { value: '2,400+', label: 'Active Dolancers' },
            { value: '48h', label: 'Avg. Payout' },
            { value: '4.9', label: 'Avg. Rating' },
          ].map((stat) => (
            <div key={stat.label}>
              <p className="text-lg font-bold text-white">{stat.value}</p>
              <p className="text-[11px] text-white/40">{stat.label}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Right panel — 60% — Form area */}
      <div className="relative flex w-full lg:w-[60%] items-center justify-center bg-white px-6 py-10">
        {/* Subtle radial gradient */}
        <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_30%_20%,rgba(90,124,255,0.04),transparent_60%)]" />

        <div className="relative w-full max-w-md">
          {children}
        </div>
      </div>
    </div>
  )
}
