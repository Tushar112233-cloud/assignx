"use client";

import { useState, useRef, useEffect, useMemo } from "react";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";

/** Country entry with dial code and flag emoji */
interface Country {
  name: string;
  code: string;
  dialCode: string;
  flag: string;
}

/** Comprehensive list of countries sorted alphabetically */
const COUNTRIES: Country[] = [
  { name: "Afghanistan", code: "AF", dialCode: "+93", flag: "\u{1F1E6}\u{1F1EB}" },
  { name: "Argentina", code: "AR", dialCode: "+54", flag: "\u{1F1E6}\u{1F1F7}" },
  { name: "Australia", code: "AU", dialCode: "+61", flag: "\u{1F1E6}\u{1F1FA}" },
  { name: "Bangladesh", code: "BD", dialCode: "+880", flag: "\u{1F1E7}\u{1F1E9}" },
  { name: "Brazil", code: "BR", dialCode: "+55", flag: "\u{1F1E7}\u{1F1F7}" },
  { name: "Canada", code: "CA", dialCode: "+1", flag: "\u{1F1E8}\u{1F1E6}" },
  { name: "China", code: "CN", dialCode: "+86", flag: "\u{1F1E8}\u{1F1F3}" },
  { name: "Egypt", code: "EG", dialCode: "+20", flag: "\u{1F1EA}\u{1F1EC}" },
  { name: "France", code: "FR", dialCode: "+33", flag: "\u{1F1EB}\u{1F1F7}" },
  { name: "Germany", code: "DE", dialCode: "+49", flag: "\u{1F1E9}\u{1F1EA}" },
  { name: "India", code: "IN", dialCode: "+91", flag: "\u{1F1EE}\u{1F1F3}" },
  { name: "Indonesia", code: "ID", dialCode: "+62", flag: "\u{1F1EE}\u{1F1E9}" },
  { name: "Iran", code: "IR", dialCode: "+98", flag: "\u{1F1EE}\u{1F1F7}" },
  { name: "Iraq", code: "IQ", dialCode: "+964", flag: "\u{1F1EE}\u{1F1F6}" },
  { name: "Israel", code: "IL", dialCode: "+972", flag: "\u{1F1EE}\u{1F1F1}" },
  { name: "Italy", code: "IT", dialCode: "+39", flag: "\u{1F1EE}\u{1F1F9}" },
  { name: "Japan", code: "JP", dialCode: "+81", flag: "\u{1F1EF}\u{1F1F5}" },
  { name: "Kenya", code: "KE", dialCode: "+254", flag: "\u{1F1F0}\u{1F1EA}" },
  { name: "Malaysia", code: "MY", dialCode: "+60", flag: "\u{1F1F2}\u{1F1FE}" },
  { name: "Mexico", code: "MX", dialCode: "+52", flag: "\u{1F1F2}\u{1F1FD}" },
  { name: "Nepal", code: "NP", dialCode: "+977", flag: "\u{1F1F3}\u{1F1F5}" },
  { name: "Netherlands", code: "NL", dialCode: "+31", flag: "\u{1F1F3}\u{1F1F1}" },
  { name: "New Zealand", code: "NZ", dialCode: "+64", flag: "\u{1F1F3}\u{1F1FF}" },
  { name: "Nigeria", code: "NG", dialCode: "+234", flag: "\u{1F1F3}\u{1F1EC}" },
  { name: "Pakistan", code: "PK", dialCode: "+92", flag: "\u{1F1F5}\u{1F1F0}" },
  { name: "Philippines", code: "PH", dialCode: "+63", flag: "\u{1F1F5}\u{1F1ED}" },
  { name: "Russia", code: "RU", dialCode: "+7", flag: "\u{1F1F7}\u{1F1FA}" },
  { name: "Saudi Arabia", code: "SA", dialCode: "+966", flag: "\u{1F1F8}\u{1F1E6}" },
  { name: "Singapore", code: "SG", dialCode: "+65", flag: "\u{1F1F8}\u{1F1EC}" },
  { name: "South Africa", code: "ZA", dialCode: "+27", flag: "\u{1F1FF}\u{1F1E6}" },
  { name: "South Korea", code: "KR", dialCode: "+82", flag: "\u{1F1F0}\u{1F1F7}" },
  { name: "Spain", code: "ES", dialCode: "+34", flag: "\u{1F1EA}\u{1F1F8}" },
  { name: "Sri Lanka", code: "LK", dialCode: "+94", flag: "\u{1F1F1}\u{1F1F0}" },
  { name: "Sweden", code: "SE", dialCode: "+46", flag: "\u{1F1F8}\u{1F1EA}" },
  { name: "Switzerland", code: "CH", dialCode: "+41", flag: "\u{1F1E8}\u{1F1ED}" },
  { name: "Thailand", code: "TH", dialCode: "+66", flag: "\u{1F1F9}\u{1F1ED}" },
  { name: "Turkey", code: "TR", dialCode: "+90", flag: "\u{1F1F9}\u{1F1F7}" },
  { name: "UAE", code: "AE", dialCode: "+971", flag: "\u{1F1E6}\u{1F1EA}" },
  { name: "UK", code: "GB", dialCode: "+44", flag: "\u{1F1EC}\u{1F1E7}" },
  { name: "USA", code: "US", dialCode: "+1", flag: "\u{1F1FA}\u{1F1F8}" },
  { name: "Vietnam", code: "VN", dialCode: "+84", flag: "\u{1F1FB}\u{1F1F3}" },
];

/** Default country code (India) */
const DEFAULT_COUNTRY_CODE = "IN";

/**
 * Parse a phone value string into its country code and local number parts.
 * Handles formats like "+91 9876543210", "+1 555-1234", or just "9876543210".
 */
function parsePhoneValue(value: string): { countryCode: string; localNumber: string } {
  if (!value || !value.startsWith("+")) {
    return { countryCode: DEFAULT_COUNTRY_CODE, localNumber: value || "" };
  }

  // Try to match the dial code against known countries (longest match first)
  const sortedCountries = [...COUNTRIES].sort(
    (a, b) => b.dialCode.length - a.dialCode.length
  );

  for (const country of sortedCountries) {
    if (value.startsWith(country.dialCode)) {
      const rest = value.slice(country.dialCode.length).trim();
      return { countryCode: country.code, localNumber: rest };
    }
  }

  return { countryCode: DEFAULT_COUNTRY_CODE, localNumber: value };
}

/** Props for the PhoneInput component */
interface PhoneInputProps {
  /** Full phone string including country code, e.g. "+91 9876543210" */
  value: string;
  /** Called with the full phone string whenever it changes */
  onChange: (value: string) => void;
  /** Whether to show error styling */
  error?: boolean;
  /** Whether the input is disabled */
  disabled?: boolean;
  /** Additional class names */
  className?: string;
}

/**
 * Composite phone input with a searchable country code dropdown and number field.
 * Produces full international phone numbers like "+91 9876543210".
 */
export function PhoneInput({ value, onChange, error, disabled, className }: PhoneInputProps) {
  const { countryCode, localNumber } = parsePhoneValue(value);
  const [isOpen, setIsOpen] = useState(false);
  const [search, setSearch] = useState("");
  const dropdownRef = useRef<HTMLDivElement>(null);
  const searchInputRef = useRef<HTMLInputElement>(null);

  const selectedCountry = COUNTRIES.find((c) => c.code === countryCode) ||
    COUNTRIES.find((c) => c.code === DEFAULT_COUNTRY_CODE)!;

  const filteredCountries = useMemo(() => {
    if (!search) return COUNTRIES;
    const q = search.toLowerCase();
    return COUNTRIES.filter(
      (c) =>
        c.name.toLowerCase().includes(q) ||
        c.dialCode.includes(q) ||
        c.code.toLowerCase().includes(q)
    );
  }, [search]);

  // Close dropdown on outside click
  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setIsOpen(false);
        setSearch("");
      }
    }
    if (isOpen) {
      document.addEventListener("mousedown", handleClickOutside);
      return () => document.removeEventListener("mousedown", handleClickOutside);
    }
  }, [isOpen]);

  // Focus search input when dropdown opens
  useEffect(() => {
    if (isOpen && searchInputRef.current) {
      searchInputRef.current.focus();
    }
  }, [isOpen]);

  function handleCountrySelect(country: Country) {
    const newValue = localNumber
      ? `${country.dialCode} ${localNumber}`
      : country.dialCode;
    onChange(newValue);
    setIsOpen(false);
    setSearch("");
  }

  function handleNumberChange(e: React.ChangeEvent<HTMLInputElement>) {
    const num = e.target.value.replace(/[^0-9\s\-]/g, "");
    const newValue = num
      ? `${selectedCountry.dialCode} ${num}`
      : selectedCountry.dialCode;
    onChange(newValue);
  }

  return (
    <div className={cn("flex gap-0", className)} ref={dropdownRef}>
      {/* Country code selector button */}
      <div className="relative">
        <button
          type="button"
          disabled={disabled}
          onClick={() => setIsOpen(!isOpen)}
          className={cn(
            "flex h-9 items-center gap-1 rounded-l-md border border-r-0 bg-transparent px-2 text-sm transition-colors",
            "hover:bg-accent/50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
            "disabled:pointer-events-none disabled:opacity-50",
            error
              ? "border-destructive"
              : "border-input focus-visible:border-ring"
          )}
        >
          <span className="text-base leading-none">{selectedCountry.flag}</span>
          <span className="text-muted-foreground text-xs">{selectedCountry.dialCode}</span>
          <svg
            className={cn(
              "h-3 w-3 text-muted-foreground transition-transform",
              isOpen && "rotate-180"
            )}
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            strokeWidth={2}
          >
            <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
          </svg>
        </button>

        {/* Dropdown */}
        {isOpen && (
          <div className="absolute left-0 top-full z-50 mt-1 w-64 rounded-md border border-input bg-popover shadow-md">
            {/* Search */}
            <div className="border-b border-input p-2">
              <input
                ref={searchInputRef}
                type="text"
                placeholder="Search country..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full rounded-sm border border-input bg-transparent px-2 py-1.5 text-sm outline-none placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-1 focus-visible:ring-ring"
              />
            </div>
            {/* Country list */}
            <div className="max-h-56 overflow-y-auto p-1">
              {filteredCountries.length === 0 ? (
                <div className="px-2 py-3 text-center text-sm text-muted-foreground">
                  No countries found
                </div>
              ) : (
                filteredCountries.map((country) => (
                  <button
                    key={country.code}
                    type="button"
                    onClick={() => handleCountrySelect(country)}
                    className={cn(
                      "flex w-full items-center gap-2 rounded-sm px-2 py-1.5 text-sm transition-colors",
                      "hover:bg-accent hover:text-accent-foreground",
                      country.code === selectedCountry.code && "bg-accent/50"
                    )}
                  >
                    <span className="text-base leading-none">{country.flag}</span>
                    <span className="flex-1 truncate text-left">{country.name}</span>
                    <span className="text-muted-foreground">{country.dialCode}</span>
                  </button>
                ))
              )}
            </div>
          </div>
        )}
      </div>

      {/* Phone number input */}
      <Input
        type="tel"
        placeholder="98765 43210"
        value={localNumber}
        onChange={handleNumberChange}
        disabled={disabled}
        className={cn(
          "rounded-l-none",
          error && "border-destructive"
        )}
      />
    </div>
  );
}
