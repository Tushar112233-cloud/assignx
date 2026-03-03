import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { ChatRoom, ChatMessage } from '../models';
import { uploadBufferToCloudinary } from '../services/upload.service';
import { AppError } from '../middleware/errorHandler';
import multer from 'multer';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 25 * 1024 * 1024 } });

// GET /chat/unread - Get unread message counts
router.get('/unread', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const rooms = await ChatRoom.find({
      'participants.profileId': req.user!.id,
      'participants.isActive': true,
    });

    const byRoom: Record<string, number> = {};
    let total = 0;

    for (const room of rooms) {
      const unread = await ChatMessage.countDocuments({
        chatRoomId: room._id,
        senderId: { $ne: req.user!.id },
        readBy: { $ne: req.user!.id },
        isDeleted: false,
      });
      if (unread > 0) {
        byRoom[room._id.toString()] = unread;
        total += unread;
      }
    }

    res.json({ total, byRoom });
  } catch (err) {
    next(err);
  }
});

// PUT /chat/read-all - Mark all messages as read
router.put('/read-all', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const rooms = await ChatRoom.find({
      'participants.profileId': req.user!.id,
      'participants.isActive': true,
    });

    for (const room of rooms) {
      await ChatMessage.updateMany(
        { chatRoomId: room._id, readBy: { $ne: req.user!.id } },
        { $addToSet: { readBy: req.user!.id } }
      );
    }

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// GET /chat/rooms
router.get('/rooms', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const rooms = await ChatRoom.find({
      'participants.profileId': req.user!.id,
      'participants.isActive': true,
    })
      .populate('participants.profileId', 'fullName avatarUrl')
      .sort({ lastMessageAt: -1 });

    const normalizedRooms = rooms.map(room => {
      const obj = room.toObject();
      return {
        ...obj,
        id: obj._id.toString(),
        room_type: obj.roomType,
        last_message_at: obj.lastMessageAt,
        created_at: obj.createdAt,
        participants: (obj.participants || []).map((p: any) => {
          const profile = p.profileId && typeof p.profileId === 'object' ? p.profileId : null;
          return {
            ...p,
            profiles: profile ? {
              full_name: profile.fullName || null,
              avatar_url: profile.avatarUrl || null,
            } : null,
          };
        }),
      };
    });

    res.json({ rooms: normalizedRooms });
  } catch (err) {
    next(err);
  }
});

// POST /chat/rooms
router.post('/rooms', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { projectId, roomType, name, participantIds } = req.body;

    const participants = participantIds.map((p: { profileId: string; role: string }) => ({
      profileId: p.profileId,
      role: p.role,
      joinedAt: new Date(),
      isActive: true,
    }));

    const room = await ChatRoom.create({
      projectId,
      roomType: roomType || 'project_all',
      name,
      participants,
    });

    res.status(201).json({ room });
  } catch (err) {
    next(err);
  }
});

// POST /chat/rooms/project/:projectId - Get or create a project chat room
router.post('/rooms/project/:projectId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { projectId } = req.params;
    const requesterId = req.body.userId || req.user!.id;

    let room = await ChatRoom.findOne({ projectId, roomType: 'project_all' });

    if (!room) {
      room = await ChatRoom.create({
        projectId,
        roomType: 'project_all',
        name: 'Project Chat',
        participants: [{ profileId: requesterId, role: 'member', joinedAt: new Date(), isActive: true }],
      });
    } else {
      const isParticipant = room.participants.some(
        (p: any) => p.profileId.toString() === requesterId
      );
      if (!isParticipant) {
        await ChatRoom.updateOne(
          { _id: room._id },
          { $push: { participants: { profileId: requesterId, role: 'member', joinedAt: new Date(), isActive: true } } }
        );
        room = (await ChatRoom.findById(room._id))!;
      }
    }

    res.json({ room });
  } catch (err) {
    next(err);
  }
});

// GET /chat/rooms/:id
router.get('/rooms/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const room = await ChatRoom.findById(req.params.id)
      .populate('participants.profileId', 'fullName avatarUrl email');
    if (!room) throw new AppError('Chat room not found', 404);
    res.json({ room });
  } catch (err) {
    next(err);
  }
});

// GET /chat/rooms/:id/messages
router.get('/rooms/:id/messages', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '50' } = req.query;
    const skip = (Number(page) - 1) * Number(limit);

    const [messages, total] = await Promise.all([
      ChatMessage.find({ chatRoomId: req.params.id, isDeleted: false })
        .populate('senderId', 'fullName avatarUrl')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      ChatMessage.countDocuments({ chatRoomId: req.params.id, isDeleted: false }),
    ]);

    res.json({ messages: messages.reverse(), total, page: Number(page) });
  } catch (err) {
    next(err);
  }
});

// POST /chat/rooms/:id/messages
router.post('/rooms/:id/messages', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const message = await ChatMessage.create({
      chatRoomId: req.params.id,
      senderId: req.user!.id,
      messageType: req.body.messageType || 'text',
      content: req.body.content || '',
      file: req.body.file,
      replyToId: req.body.replyToId,
    });

    // Update room lastMessageAt
    await ChatRoom.findByIdAndUpdate(req.params.id, { lastMessageAt: new Date() });

    const populated = await message.populate('senderId', 'fullName avatarUrl');

    // Emit to room via socket
    const io = req.app.get('io');
    if (io) {
      io.to(`chat:${req.params.id}`).emit('chat:message', populated);
    }

    res.status(201).json({ message: populated });
  } catch (err) {
    next(err);
  }
});

// PUT /chat/rooms/:id/read
router.put('/rooms/:id/read', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Mark all messages in room as read by current user
    await ChatMessage.updateMany(
      { chatRoomId: req.params.id, readBy: { $ne: req.user!.id } },
      { $addToSet: { readBy: req.user!.id } }
    );

    // Update participant lastSeenAt
    await ChatRoom.updateOne(
      { _id: req.params.id, 'participants.profileId': req.user!.id },
      { $set: { 'participants.$.lastSeenAt': new Date() } }
    );

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// POST /chat/rooms/:id/files
router.post('/rooms/:id/files', authenticate, upload.single('file'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.file) throw new AppError('No file provided', 400);
    const result = await uploadBufferToCloudinary(req.file.buffer, 'assignx/chat');

    const message = await ChatMessage.create({
      chatRoomId: req.params.id,
      senderId: req.user!.id,
      messageType: 'file',
      content: req.body.content || '',
      file: {
        url: result.url,
        name: req.file.originalname,
        type: req.file.mimetype,
        sizeBytes: result.bytes,
      },
    });

    await ChatRoom.findByIdAndUpdate(req.params.id, { lastMessageAt: new Date() });

    const populated = await message.populate('senderId', 'fullName avatarUrl');

    const io = req.app.get('io');
    if (io) {
      io.to(`chat:${req.params.id}`).emit('chat:message', populated);
    }

    res.status(201).json({ message: populated });
  } catch (err) {
    next(err);
  }
});

// PUT /chat/rooms/:id/suspend
router.put('/rooms/:id/suspend', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const room = await ChatRoom.findByIdAndUpdate(
      req.params.id,
      { isSuspended: true, suspendedBy: req.user!.id, suspendedAt: new Date(), suspensionReason: req.body.reason || '' },
      { new: true }
    );
    if (!room) throw new AppError('Chat room not found', 404);

    const io = req.app.get('io');
    if (io) {
      io.to(`chat:${req.params.id}`).emit('chat:suspended', { roomId: req.params.id });
    }

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// PUT /chat/rooms/:id/unsuspend
router.put('/rooms/:id/unsuspend', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const room = await ChatRoom.findByIdAndUpdate(
      req.params.id,
      { isSuspended: false, suspendedBy: null, suspendedAt: null, suspensionReason: '' },
      { new: true }
    );
    if (!room) throw new AppError('Chat room not found', 404);

    const io = req.app.get('io');
    if (io) {
      io.to(`chat:${req.params.id}`).emit('chat:unsuspended', { roomId: req.params.id });
    }

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// DELETE /chat/messages/:id
router.delete('/messages/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const message = await ChatMessage.findByIdAndUpdate(
      req.params.id,
      { isDeleted: true, deletedBy: req.user!.id, deletedAt: new Date() },
      { new: true }
    );
    if (!message) throw new AppError('Message not found', 404);

    const io = req.app.get('io');
    if (io) {
      io.to(`chat:${message.chatRoomId}`).emit('chat:messageDeleted', { messageId: req.params.id });
    }

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

export default router;
