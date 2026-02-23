"use client";

import * as React from "react";
import { useActionState } from "react";
import { IconLoader2 } from "@tabler/icons-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { loginAdmin } from "./actions";

export function LoginForm() {
  const [state, formAction, isPending] = useActionState(loginAdmin, {
    error: "",
  });
  const [email, setEmail] = React.useState("");
  const isTestAccount = email.toLowerCase() === "admin@gmail.com";

  return (
    <form action={formAction} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          name="email"
          type="email"
          placeholder="admin@assignx.com"
          required
          autoComplete="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
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
          defaultValue={isTestAccount ? "Admin@123" : ""}
          key={isTestAccount ? "test" : "normal"}
        />
        {isTestAccount && (
          <p className="text-xs text-muted-foreground">
            Test account — password pre-filled: <span className="font-mono font-medium">Admin@123</span>
          </p>
        )}
      </div>
      {state.error && (
        <p className="text-sm text-destructive">{state.error}</p>
      )}
      <Button type="submit" className="w-full" disabled={isPending}>
        {isPending && <IconLoader2 className="animate-spin" />}
        Sign In
      </Button>
    </form>
  );
}
