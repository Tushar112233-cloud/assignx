/**
 * @fileoverview Messages page - redirects to /chat to avoid duplicate pages (SW-024).
 * @module app/(dashboard)/messages/page
 */

import { redirect } from "next/navigation"

export default function MessagesPage() {
  redirect("/chat")
}
