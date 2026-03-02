import { Server } from 'socket.io';
import { AuthenticatedSocket } from '../config/socket';

export const notificationHandler = (_io: Server, socket: AuthenticatedSocket) => {
  // User automatically joins their notification room on connection (handled in socket config)
  // Notifications are emitted from routes via io.to(`user:${userId}`).emit(...)

  socket.on('notification:read', (notificationId: string) => {
    // Handled via REST API, but emit confirmation
    socket.emit('notification:read:ack', { notificationId });
  });
};

// Utility to send notification via socket from services
export const emitNotification = (io: Server, userId: string, notification: unknown) => {
  io.to(`user:${userId}`).emit('notification:new', notification);
};

export const emitWalletUpdate = (io: Server, userId: string, wallet: unknown) => {
  io.to(`user:${userId}`).emit('wallet:updated', wallet);
};
