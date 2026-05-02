"use client";

import { useEffect } from "react";
import { Button } from "@/components/ui/button";

export default function AuthenticatedError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error("Admin panel error:", error);
  }, [error]);

  return (
    <div className="flex min-h-[50vh] items-center justify-center px-4">
      <div className="text-center space-y-4">
        <h2 className="text-xl font-semibold">Something went wrong</h2>
        <p className="text-muted-foreground text-sm max-w-md">
          There was a temporary issue loading this page. This usually resolves
          itself — try again.
        </p>
        <Button onClick={reset}>Try again</Button>
      </div>
    </div>
  );
}
