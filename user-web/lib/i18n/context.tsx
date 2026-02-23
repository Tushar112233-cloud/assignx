"use client"

import React, { createContext, useContext, useState, useEffect, useCallback } from "react"
import { translations, type Locale, type TranslationKey, LOCALES } from "./index"

interface I18nContextType {
  locale: Locale
  setLocale: (locale: Locale) => void
  t: (key: TranslationKey) => string
  locales: typeof LOCALES
  isRTL: boolean
}

const I18nContext = createContext<I18nContextType>({
  locale: "en",
  setLocale: () => {},
  t: (key) => key,
  locales: LOCALES,
  isRTL: false,
})

/**
 * Provider component that supplies i18n context to the entire app tree.
 * Reads locale from localStorage on mount and applies RTL direction for Arabic.
 */
export function I18nProvider({ children }: { children: React.ReactNode }) {
  const [locale, setLocaleState] = useState<Locale>("en")

  useEffect(() => {
    const saved = localStorage.getItem("assignx-locale") as Locale | null
    if (saved && translations[saved]) {
      setLocaleState(saved)
    } else {
      // Auto-detect from browser
      const browserLang = navigator.language.split("-")[0] as Locale
      if (translations[browserLang]) {
        setLocaleState(browserLang)
      }
    }
  }, [])

  useEffect(() => {
    // Apply RTL direction for Arabic
    const currentLocale = LOCALES.find((l) => l.code === locale)
    if (currentLocale?.rtl) {
      document.documentElement.setAttribute("dir", "rtl")
    } else {
      document.documentElement.setAttribute("dir", "ltr")
    }
  }, [locale])

  const setLocale = useCallback((newLocale: Locale) => {
    setLocaleState(newLocale)
    localStorage.setItem("assignx-locale", newLocale)
  }, [])

  const t = useCallback(
    (key: TranslationKey): string => {
      const localeTranslations = translations[locale] as Record<string, string>
      const enTranslations = translations.en as Record<string, string>
      return localeTranslations[key] || enTranslations[key] || key
    },
    [locale]
  )

  const isRTL = LOCALES.find((l) => l.code === locale)?.rtl ?? false

  return (
    <I18nContext.Provider value={{ locale, setLocale, t, locales: LOCALES, isRTL }}>
      {children}
    </I18nContext.Provider>
  )
}

/**
 * Hook to access the i18n context. Must be used inside I18nProvider.
 */
export function useI18n() {
  return useContext(I18nContext)
}
