import { Server as HttpServer } from 'http';
import { Server, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import { chatHandler } from '../socket/chat.handler';
import { notificationHandler } from '../socket/notification.handler';
import { typingHandler } from '../socket/typing.handler';
import { presenceHandler } from '../socket/presence.handler';

export interface AuthenticatedSocket extends Socket {
  user?: {
    id: string;
    email: string;
    role: string;
  };
}

export const initializeSocket = (server: HttpServer): Server => {
  const io = new Server(server, {
    cors: {
      origin: '*',
    },
  });

  // JWT auth middleware for socket connections
  io.use((socket: AuthenticatedSocket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) {
      return next(new Error('Authentication token required'));
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
        sub: string;
        email: string;
        role: string;
      };
      socket.user = {
        id: decoded.sub,
        email: decoded.email,
        role: decoded.role,
      };
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket: AuthenticatedSocket) => {
    const userId = socket.user?.id;
    if (userId) {
      // Join user-specific room for notifications/wallet updates
      socket.join(`user:${userId}`);
    }

    chatHandler(io, socket);
    notificationHandler(io, socket);
    typingHandler(io, socket);
    presenceHandler(io, socket);

    socket.on('disconnect', () => {
      // Handled by presenceHandler
    });
  });

  return io;
};
