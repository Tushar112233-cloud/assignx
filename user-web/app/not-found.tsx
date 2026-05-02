import Link from "next/link";
import { Button } from "@/components/ui/button";

/**
 * Custom 404 Not Found page
 * Displayed when users navigate to non-existent routes
 */
export default function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-background px-4">
      <div className="text-center">
        {/* 404 Illustration */}
        <div className="mb-8">
          <h1 className="text-9xl font-bold text-muted-foreground/20">404</h1>
        </div>

        {/* Error Message */}
        <h2 className="mb-2 text-2xl font-semibold tracking-tight">
          Page not found
        </h2>
        <p className="mb-8 max-w-md text-muted-foreground">
          Sorry, we couldn&apos;t find the page you&apos;re looking for. The page may
          have been moved, deleted, or never existed.
        </p>

        {/* Action Buttons */}
        <div className="flex flex-col gap-3 sm:flex-row sm:justify-center">
          <Button asChild>
            <Link href="/home">Go to Dashboard</Link>
          </Button>
          <Button variant="outline" asChild>
            <Link href="/">Back to Home</Link>
          </Button>
        </div>

        {/* Help Text */}
        <p className="mt-8 text-sm text-muted-foreground">
          Need help?{" "}
          <Link href="/support" className="underline hover:text-primary">
            Contact support
          </Link>
        </p>
      </div>
    </div>
  );
}
