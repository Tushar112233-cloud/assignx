/**
 * @fileoverview Socket.IO client for real-time events from Express API.
 * Connects with JWT auth token. Exposes a singleton socket instance.
 * @module lib/socket/client
 */

import { io, type Socket } from "socket.io-client"
import { getAccessToken } from "@/lib/api/client"

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"

let socket: Socket | null = null

/**
 * Get or create the Socket.IO connection.
 * Connects lazily on first call and reconnects if disconnected.
 */
export function getSocket(): Socket {
  if (socket?.connected) return socket

  const token = getAccessToken()

  socket = io(API_BASE, {
    auth: { token },
    transports: ["websocket", "polling"],
    reconnection: true,
    reconnectionAttempts: 10,
    reconnectionDelay: 1000,
    reconnectionDelayMax: 10000,
    autoConnect: true,
  })

  socket.on("connect_error", (err) => {
    console.warn("[Socket] Connection error:", err.message)
  })

  return socket
}

/**
 * Disconnect the socket (call on logout).
 */
export function disconnectSocket(): void {
  if (socket) {
    socket.disconnect()
    socket = null
  }
}

/**
 * Update the socket auth token (call after token refresh).
 */
export function updateSocketAuth(): void {
  if (!socket) return
  const token = getAccessToken()
  socket.auth = { token }
  if (!socket.connected) {
    socket.connect()
  }
}
