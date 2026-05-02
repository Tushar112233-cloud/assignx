import { LoginForm } from "./login-form";

export const metadata = { title: "Admin Login - AssignX" };

export default function AdminLoginPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="w-full max-w-sm space-y-6">
        <div className="text-center space-y-2">
          <h1 className="text-2xl font-bold tracking-tight">Admin Panel</h1>
          <p className="text-muted-foreground text-sm">
            Sign in with your admin credentials
          </p>
        </div>
        <LoginForm />
      </div>
    </div>
  );
}
