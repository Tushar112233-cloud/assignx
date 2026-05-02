import { io, Socket } from "socket.io-client";

let socket: Socket | null = null;

/**
 * Get or create a Socket.IO connection to the API server.
 * Authenticates using the stored access token.
 */
export function getSocket(): Socket {
  if (!socket) {
    const token =
      typeof window !== "undefined" ? localStorage.getItem("accessToken") : null;

    socket = io(process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000", {
      auth: { token },
      transports: ["websocket"],
    });
  }
  return socket;
}

/**
 * Disconnect and clear the socket instance
 */
export function disconnectSocket(): void {
  if (socket) {
    socket.disconnect();
    socket = null;
  }
}
