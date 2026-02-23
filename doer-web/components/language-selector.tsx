"use client"

import { useI18n } from "@/lib/i18n/context"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Button } from "@/components/ui/button"
import { Globe } from "lucide-react"

/**
 * Language selector dropdown component.
 * Displays the current locale flag and native name, with a dropdown to switch languages.
 * Supports RTL indicator for Arabic.
 */
export function LanguageSelector() {
  const { locale, setLocale, locales } = useI18n()
  const current = locales.find((l) => l.code === locale)

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm" className="gap-2">
          <Globe className="h-4 w-4" />
          <span className="hidden sm:inline">
            {current?.flag} {current?.nativeName}
          </span>
          <span className="sm:hidden">{current?.flag}</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-48">
        {locales.map((l) => (
          <DropdownMenuItem
            key={l.code}
            onClick={() => setLocale(l.code)}
            className={locale === l.code ? "bg-accent font-medium" : ""}
          >
            <span className="mr-2">{l.flag}</span>
            <span>{l.nativeName}</span>
            {l.rtl && (
              <span className="ml-auto text-xs text-muted-foreground">RTL</span>
            )}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
