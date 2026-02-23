import Link from "next/link";
import { ArrowLeft } from "lucide-react";

export const metadata = {
  title: "Open Source Licenses | AssignX",
};

export default function OpenSourcePage() {
  return (
    <div className="min-h-screen bg-background">
      <div className="container max-w-3xl mx-auto px-6 py-12">
        <Link
          href="/home"
          className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground mb-8"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to Home
        </Link>

        <h1 className="text-3xl font-bold tracking-tight mb-2">Open Source Licenses</h1>
        <p className="text-sm text-muted-foreground mb-8">Third-party software used in AssignX</p>

        <div className="prose prose-neutral dark:prose-invert max-w-none space-y-6">
          <section>
            <p className="text-muted-foreground leading-relaxed">
              AssignX is built using open source software. We are grateful to the developers and communities behind these projects.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-3">Core Framework</h2>
            <ul className="space-y-2 text-muted-foreground">
              <li><strong className="text-foreground">Next.js</strong> - MIT License - The React framework for the web</li>
              <li><strong className="text-foreground">React</strong> - MIT License - A JavaScript library for building user interfaces</li>
              <li><strong className="text-foreground">TypeScript</strong> - Apache 2.0 License - Typed JavaScript at any scale</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-3">UI Components</h2>
            <ul className="space-y-2 text-muted-foreground">
              <li><strong className="text-foreground">Radix UI</strong> - MIT License - Unstyled, accessible UI components</li>
              <li><strong className="text-foreground">Tailwind CSS</strong> - MIT License - Utility-first CSS framework</li>
              <li><strong className="text-foreground">Lucide Icons</strong> - ISC License - Beautiful & consistent icons</li>
              <li><strong className="text-foreground">Framer Motion</strong> - MIT License - Animation library for React</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-3">Backend & Data</h2>
            <ul className="space-y-2 text-muted-foreground">
              <li><strong className="text-foreground">Supabase</strong> - Apache 2.0 License - Open source Firebase alternative</li>
              <li><strong className="text-foreground">Zustand</strong> - MIT License - Small, fast state management</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-3">Utilities</h2>
            <ul className="space-y-2 text-muted-foreground">
              <li><strong className="text-foreground">date-fns</strong> - MIT License - Date utility library</li>
              <li><strong className="text-foreground">Zod</strong> - MIT License - TypeScript-first schema validation</li>
              <li><strong className="text-foreground">Sonner</strong> - MIT License - Toast notifications</li>
            </ul>
          </section>
        </div>
      </div>
    </div>
  );
}
