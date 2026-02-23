import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /**
   * Performance optimizations
   */
  experimental: {
    // Optimize package imports to reduce bundle size
    optimizePackageImports: [
      "lucide-react",
      "@radix-ui/react-icons",
      "date-fns",
      "framer-motion",
    ],
  },

  /**
   * Image optimization configuration
   * Configure remote patterns for Supabase storage
   */
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "*.supabase.co",
        pathname: "/storage/v1/object/public/**",
      },
      {
        protocol: "https",
        hostname: "lh3.googleusercontent.com",
        pathname: "/**",
      },
    ],
  },

  /**
   * Security headers
   * Implements recommended security best practices
   */
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          {
            key: "X-Frame-Options",
            value: "DENY",
          },
          {
            key: "X-Content-Type-Options",
            value: "nosniff",
          },
          {
            key: "X-XSS-Protection",
            value: "1; mode=block",
          },
          {
            key: "Referrer-Policy",
            value: "strict-origin-when-cross-origin",
          },
          {
            key: "Permissions-Policy",
            value: "camera=(), microphone=(), geolocation=(), interest-cohort=()",
          },
          {
            key: "Content-Security-Policy",
            value: [
              "default-src 'self'",
              // Scripts: self + Razorpay + Google (for analytics if needed)
              // unsafe-inline needed for Next.js inline scripts in production
              "script-src 'self' 'unsafe-inline' https://checkout.razorpay.com https://api.razorpay.com https://www.googletagmanager.com",
              // Styles: self + unsafe-inline (required for CSS-in-JS and Tailwind)
              "style-src 'self' 'unsafe-inline'",
              // Images: self + data URIs + blob + trusted domains
              "img-src 'self' data: blob: https://*.supabase.co https://lh3.googleusercontent.com https://*.razorpay.com https://i.pravatar.cc https://api.qrserver.com",
              // Fonts: self + data URIs + Google Fonts
              "font-src 'self' data: https://fonts.gstatic.com",
              // API connections: self + Supabase + Razorpay
              "connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.razorpay.com https://lumberjack.razorpay.com",
              // Frames: only Razorpay checkout iframe
              "frame-src 'self' https://api.razorpay.com https://checkout.razorpay.com",
              // Prevent clickjacking
              "frame-ancestors 'none'",
              // Restrict base URI to prevent base tag injection
              "base-uri 'self'",
              // Restrict form submissions
              "form-action 'self'",
              // Upgrade insecure requests in production
              "upgrade-insecure-requests",
            ].join("; "),
          },
          {
            key: "Strict-Transport-Security",
            value: "max-age=31536000; includeSubDomains",
          },
        ],
      },
    ];
  },
};

export default nextConfig;
