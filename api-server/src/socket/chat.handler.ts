import { Server } from 'socket.io';
import { AuthenticatedSocket } from '../config/socket';

export const chatHandler = (io: Server, socket: AuthenticatedSocket) => {
  socket.on('chat:join', (roomId: string) => {
    socket.join(`chat:${roomId}`);
  });

  socket.on('chat:leave', (roomId: string) => {
    socket.leave(`chat:${roomId}`);
  });

  socket.on('chat:send', (data: { roomId: string; message: unknown }) => {
    io.to(`chat:${data.roomId}`).emit('chat:message', {
      ...data.message as object,
      senderId: socket.user?.id,
    });
  });

  socket.on('chat:read', (data: { roomId: string; messageId: string }) => {
    socket.to(`chat:${data.roomId}`).emit('chat:read', {
      userId: socket.user?.id,
      messageId: data.messageId,
    });
  });
};
