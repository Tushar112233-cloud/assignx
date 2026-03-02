import { Server } from 'socket.io';
import { AuthenticatedSocket } from '../config/socket';

const onlineUsers = new Map<string, Set<string>>();

export const presenceHandler = (io: Server, socket: AuthenticatedSocket) => {
  const userId = socket.user?.id;
  if (!userId) return;

  // Track user online
  if (!onlineUsers.has(userId)) {
    onlineUsers.set(userId, new Set());
  }
  onlineUsers.get(userId)!.add(socket.id);

  // Broadcast online status
  io.emit('presence:online', { userId });

  socket.on('presence:check', (targetUserId: string) => {
    const isOnline = onlineUsers.has(targetUserId) && onlineUsers.get(targetUserId)!.size > 0;
    socket.emit('presence:status', { userId: targetUserId, isOnline });
  });

  socket.on('disconnect', () => {
    const sockets = onlineUsers.get(userId);
    if (sockets) {
      sockets.delete(socket.id);
      if (sockets.size === 0) {
        onlineUsers.delete(userId);
        io.emit('presence:offline', { userId });
      }
    }
  });
};

export const isUserOnline = (userId: string): boolean => {
  return onlineUsers.has(userId) && onlineUsers.get(userId)!.size > 0;
};
