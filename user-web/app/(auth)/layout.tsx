/**
 * Auth layout - shared layout for authentication pages
 */
export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-background">
      {/* Main content */}
      <main>{children}</main>
    </div>
  );
}
