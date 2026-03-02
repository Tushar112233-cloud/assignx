"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { IconLoader2 } from "@tabler/icons-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { loginWithPassword } from "@/lib/api/auth";

const DEV_BYPASS_EMAILS = ["admin@gmail.com"];

export function LoginForm() {
  const router = useRouter();
  const [error, setError] = useState("");
  const [isPending, setIsPending] = useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError("");
    setIsPending(true);

    const formData = new FormData(e.currentTarget);
    const email = (formData.get("email") as string || "").toLowerCase().trim();
    const password = formData.get("password") as string;

    if (!email) {
      setError("Email is required.");
      setIsPending(false);
      return;
    }

    // Dev bypass: no password needed for admin@gmail.com
    const isDevBypass = DEV_BYPASS_EMAILS.includes(email);
    if (!isDevBypass && !password) {
      setError("Password is required.");
      setIsPending(false);
      return;
    }

    const result = await loginWithPassword(email, password || "bypass");

    if (!result.success) {
      setError(result.error || "Login failed.");
      setIsPending(false);
      return;
    }

    // Set httpOnly cookie for server-side auth
    await fetch("/api/auth/set-token", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        accessToken: localStorage.getItem("accessToken"),
        refreshToken: localStorage.getItem("refreshToken"),
      }),
    });

    router.push("/");
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          name="email"
          type="email"
          placeholder="admin@assignx.com"
          required
          autoComplete="email"
        />
      </div>
      <div className="space-y-2">
        <Label htmlFor="password">Password</Label>
        <Input
          id="password"
          name="password"
          type="password"
          required
          autoComplete="current-password"
        />
      </div>
      {error && (
        <p className="text-sm text-destructive">{error}</p>
      )}
      <Button type="submit" className="w-full" disabled={isPending}>
        {isPending && <IconLoader2 className="animate-spin" />}
        Sign In
      </Button>
    </form>
  );
}
