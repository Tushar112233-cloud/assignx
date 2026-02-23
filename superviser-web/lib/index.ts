/**
 * @fileoverview Central export file for library utilities and configurations.
 * @module lib
 */

export { cn } from "./utils"
export { siteConfig, baseMetadata, viewport, generatePageMetadata } from "./metadata"
export {
  captureException,
  captureMessage,
  trackEvent,
  trackPageView,
  identifyUser,
  resetUser,
  measurePerformance,
  getFeatureFlag,
  startSessionRecording,
  handleBoundaryError,
} from "./analytics"
