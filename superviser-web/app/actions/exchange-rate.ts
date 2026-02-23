"use server"

interface ExchangeRateResult {
  success: boolean
  rate?: number
  error?: string
}

const FALLBACK_RATES: Record<string, number> = {
  USD: 84,
  EUR: 90,
  GBP: 105,
  CAD: 62,
  AUD: 54,
  AED: 23,
  SGD: 62,
  JPY: 0.56,
}

/**
 * Fetch live exchange rate from currency to INR.
 * Uses Frankfurter API (free, no auth required).
 * Falls back to hardcoded rates if the API is unreachable.
 */
export async function getExchangeRate(fromCurrency: string): Promise<ExchangeRateResult> {
  if (fromCurrency === "INR") {
    return { success: true, rate: 1 }
  }

  try {
    const response = await fetch(
      `https://api.frankfurter.app/latest?from=${fromCurrency}&to=INR`,
      { next: { revalidate: 300 } } // cache for 5 minutes
    )

    if (!response.ok) {
      const fallback = FALLBACK_RATES[fromCurrency]
      if (fallback) return { success: true, rate: fallback }
      return { success: false, error: "Failed to fetch exchange rate" }
    }

    const data = await response.json()
    const rate = data.rates?.INR

    if (!rate) {
      return { success: false, error: "INR rate not found in response" }
    }

    return { success: true, rate }
  } catch {
    const fallback = FALLBACK_RATES[fromCurrency]
    if (fallback) return { success: true, rate: fallback }
    return { success: false, error: "Network error fetching exchange rate" }
  }
}
