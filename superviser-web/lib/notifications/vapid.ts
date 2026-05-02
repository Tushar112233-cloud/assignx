/**
 * @fileoverview VAPID key utilities
 * Handles VAPID key generation and management for Web Push
 *
 * VAPID (Voluntary Application Server Identification) keys are used to authenticate
 * the server sending push notifications. They are generated once and stored in .env
 */

/**
 * VAPID public key from environment variables
 * This should be added to .env.local:
 * NEXT_PUBLIC_VAPID_PUBLIC_KEY=your_public_key_here
 */
export const VAPID_PUBLIC_KEY = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY || ""

/**
 * Check if VAPID keys are configured
 */
export function areVapidKeysConfigured(): boolean {
  return VAPID_PUBLIC_KEY.length > 0
}

/**
 * Get instructions for generating VAPID keys
 *
 * To generate VAPID keys, run the following command in your terminal:
 *
 * npx web-push generate-vapid-keys
 *
 * This will output a public key and a private key.
 * Add them to your .env.local file:
 *
 * NEXT_PUBLIC_VAPID_PUBLIC_KEY=<your_public_key>
 * VAPID_PRIVATE_KEY=<your_private_key>
 *
 * The public key will be used in the client to subscribe to push notifications.
 * The private key will be used on the server to send push notifications.
 */
export function getVapidSetupInstructions(): string {
  return `
To set up Web Push notifications:

1. Install web-push globally:
   npm install -g web-push

2. Generate VAPID keys:
   npx web-push generate-vapid-keys

3. Add the keys to .env.local:
   NEXT_PUBLIC_VAPID_PUBLIC_KEY=<your_public_key>
   VAPID_PRIVATE_KEY=<your_private_key>

4. Restart the development server

For more information, visit:
https://github.com/web-push-libs/web-push
  `.trim()
}

/**
 * Validate VAPID public key format
 */
export function isValidVapidKey(key: string): boolean {
  // VAPID keys are base64url encoded and should be 87-88 characters
  return key.length >= 87 && key.length <= 88 && /^[A-Za-z0-9_-]+$/.test(key)
}
