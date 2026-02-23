/**
 * Student email validation utility
 * Validates that an email belongs to an educational institution
 */

/**
 * Common educational email domain patterns
 * Includes .edu, .ac.in (Indian colleges), and other common patterns
 */
const STUDENT_EMAIL_PATTERNS = [
  // Standard .edu domain
  /\.edu$/i,
  // Indian academic institutions (.ac.in)
  /\.ac\.in$/i,
  // UK academic (.ac.uk)
  /\.ac\.uk$/i,
  // Australian academic (.edu.au)
  /\.edu\.au$/i,
  // Canadian academic
  /\.edu\.ca$/i,
  // European academic
  /\.edu\.[a-z]{2}$/i,
  // Generic student email patterns
  /student\./i,
  /stu\./i,
  // Common Indian university domain patterns
  /\.iit[a-z]*\.ac\.in$/i,
  /\.nit[a-z]*\.ac\.in$/i,
  /\.iiit[a-z]*\.ac\.in$/i,
  /\.bits[a-z]*\.ac\.in$/i,
  /\.vit\.ac\.in$/i,
  /\.srm\.edu\.in$/i,
  /\.amity\.edu$/i,
  /\.du\.ac\.in$/i,
  /\.jnu\.ac\.in$/i,
  /\.bhu\.ac\.in$/i,
  /\.cusat\.ac\.in$/i,
  /\.ignou\.ac\.in$/i,
  // Common .edu.in domains (Indian private universities)
  /\.edu\.in$/i,
]

/**
 * List of known educational institution domains (partial list)
 * These are checked if the pattern matching fails
 */
const KNOWN_EDU_DOMAINS = [
  // Major Indian institutions
  "iitb.ac.in",
  "iitd.ac.in",
  "iitm.ac.in",
  "iitkgp.ac.in",
  "iitk.ac.in",
  "iith.ac.in",
  "iitg.ac.in",
  "iitr.ac.in",
  "iitbbs.ac.in",
  "iiti.ac.in",
  "iitdh.ac.in",
  "iitgn.ac.in",
  "iitj.ac.in",
  "iitp.ac.in",
  "iitmandi.ac.in",
  "iitpkd.ac.in",
  "iitrpr.ac.in",
  "iitism.ac.in",
  "nitt.edu",
  "nitc.ac.in",
  "nitw.ac.in",
  "nitk.ac.in",
  "nits.ac.in",
  "bits-pilani.ac.in",
  "hyderabad.bits-pilani.ac.in",
  "goa.bits-pilani.ac.in",
  "pilani.bits-pilani.ac.in",
  "vit.ac.in",
  "vitstudent.ac.in",
  "srm.edu.in",
  "srmist.edu.in",
  "amity.edu",
  "amityonline.com",
  "manipal.edu",
  "thapar.edu",
  "lpu.in",
  "chitkara.edu.in",
  "christ.ac.in",
  "christuniversity.in",
  "dtu.ac.in",
  "nsut.ac.in",
  "iiitd.ac.in",
  "iiita.ac.in",
  "iiitb.ac.in",
  "iiitdm.ac.in",
  "du.ac.in",
  "jnu.ac.in",
  "bhu.ac.in",
  "hcu.ac.in",
  "jmi.ac.in",
  "uohyd.ac.in",
  "cusat.ac.in",
  "pondiuni.edu.in",
  "mu.ac.in",
  "annauniv.edu",
  "svce.ac.in",
  "srmist.edu.in",
]

/**
 * Check if an email domain is a valid student/educational email
 * @param email - The email address to validate
 * @returns Object with isValid flag and optional error message
 */
export function validateStudentEmail(email: string): {
  isValid: boolean
  error?: string
} {
  if (!email || typeof email !== "string") {
    return { isValid: false, error: "Email is required" }
  }

  const normalizedEmail = email.toLowerCase().trim()

  // Basic email format check
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(normalizedEmail)) {
    return { isValid: false, error: "Please enter a valid email address" }
  }

  // Extract domain
  const domain = normalizedEmail.split("@")[1]
  if (!domain) {
    return { isValid: false, error: "Invalid email format" }
  }

  // Check against pattern matching
  for (const pattern of STUDENT_EMAIL_PATTERNS) {
    if (pattern.test(domain)) {
      return { isValid: true }
    }
  }

  // Check against known educational domains
  if (KNOWN_EDU_DOMAINS.includes(domain)) {
    return { isValid: true }
  }

  // Check if domain contains "university", "college", "institute", etc.
  const eduKeywords = [
    "university",
    "college",
    "institute",
    "school",
    "academy",
    "polytechnic",
  ]
  for (const keyword of eduKeywords) {
    if (domain.includes(keyword)) {
      return { isValid: true }
    }
  }

  return {
    isValid: false,
    error:
      "Please use your college/university email address (e.g., yourname@college.edu or yourname@university.ac.in)",
  }
}

/**
 * Check if email is likely a personal/non-student email
 * @param email - The email address to check
 * @returns true if it's a common personal email provider
 */
export function isPersonalEmail(email: string): boolean {
  const personalDomains = [
    "gmail.com",
    "yahoo.com",
    "hotmail.com",
    "outlook.com",
    "live.com",
    "icloud.com",
    "aol.com",
    "protonmail.com",
    "mail.com",
    "zoho.com",
    "yandex.com",
    "gmx.com",
    "inbox.com",
    "rediffmail.com",
  ]

  const domain = email.toLowerCase().split("@")[1]
  return personalDomains.includes(domain)
}
