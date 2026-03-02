import { Server } from 'socket.io';
import { AuthenticatedSocket } from '../config/socket';

export const typingHandler = (_io: Server, socket: AuthenticatedSocket) => {
  socket.on('typing:start', (roomId: string) => {
    socket.to(`chat:${roomId}`).emit('typing:start', {
      userId: socket.user?.id,
    });
  });

  socket.on('typing:stop', (roomId: string) => {
    socket.to(`chat:${roomId}`).emit('typing:stop', {
      userId: socket.user?.id,
    });
  });
};
