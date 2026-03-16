import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { ChatRoom, ChatMessage, Project, User, Supervisor, Doer, Notification } from '../models';
import { uploadBufferToCloudinary } from '../services/upload.service';
import { AppError } from '../middleware/errorHandler';
import multer from 'multer';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 25 * 1024 * 1024 } });

const JWT_ROLE_MAP: Record<string, 'user' | 'supervisor' | 'doer'> = {
  supervisor: 'supervisor',
  doer: 'doer',
};

// GET /chat/unread - Get unread message counts
router.get('/unread', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const rooms = await ChatRoom.find({
      'participants.id': req.user!.id,
      'participants.isActive': true,
    });

    const byRoom: Record<string, number> = {};
    let total = 0;

    for (const room of rooms) {
      const unread = await ChatMessage.countDocuments({
        chatRoomId: room._id,
        senderId: { $ne: req.user!.id },
        'readBy.id': { $ne: req.user!.id },
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
      'participants.id': req.user!.id,
      'participants.isActive': true,
    });

    for (const room of rooms) {
      await ChatMessage.updateMany(
        { chatRoomId: room._id, 'readBy.id': { $ne: req.user!.id } },
        { $addToSet: { readBy: { id: req.user!.id, role: req.user!.role } } }
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
    const filter: Record<string, any> = {
      'participants.id': req.user!.id,
      'participants.isActive': true,
    };
    if (req.query.projectId) filter.projectId = req.query.projectId;
    if (req.query.roomType) filter.roomType = req.query.roomType;

    const rooms = await ChatRoom.find(filter)
      .sort({ lastMessageAt: -1 });

    // Populate project titles for room display
    const projectIds = [...new Set(rooms.map(r => r.projectId?.toString()).filter(Boolean))];
    const projects = await Project.find({ _id: { $in: projectIds } }).select('title projectNumber').lean();
    const projectMap = new Map(projects.map(p => [p._id.toString(), p]));

    // Populate participant names
    const allParticipantIds = [...new Set(rooms.flatMap(r => (r.participants || []).map((p: any) => p.id?.toString()).filter(Boolean)))];
    const [users, supervisors, doers] = await Promise.all([
      User.find({ _id: { $in: allParticipantIds } }).select('fullName avatarUrl email').lean(),
      Supervisor.find({ _id: { $in: allParticipantIds } }).select('fullName avatarUrl email').lean(),
      Doer.find({ _id: { $in: allParticipantIds } }).select('fullName avatarUrl email').lean(),
    ]);
    const nameMap = new Map<string, { full_name: string | null; avatar_url: string | null; email: string | null }>();
    for (const u of [...users, ...supervisors, ...doers]) {
      nameMap.set(u._id.toString(), {
        full_name: (u as any).fullName || null,
        avatar_url: (u as any).avatarUrl || null,
        email: (u as any).email || null,
      });
    }

    const normalizedRooms = rooms.map(room => {
      const obj = room.toObject();
      const project = obj.projectId ? projectMap.get(obj.projectId.toString()) : null;
      return {
        ...obj,
        id: obj._id.toString(),
        project_id: obj.projectId?.toString(),
        project_title: (project as any)?.title || null,
        project_number: (project as any)?.projectNumber || null,
        room_type: obj.roomType,
        last_message_at: obj.lastMessageAt,
        created_at: obj.createdAt,
        participants: (obj.participants || []).map((p: any) => {
          const info = nameMap.get(p.id?.toString() || '');
          return {
            id: p.id,
            role: p.role,
            full_name: info?.full_name || null,
            avatar_url: info?.avatar_url || null,
            email: info?.email || null,
            joinedAt: p.joinedAt,
            isActive: p.isActive,
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

    const participants = (participantIds || []).map((p: { id: string; role: string }) => ({
      id: p.id,
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
    const requesterId = req.user!.id;

    // Verify caller is a participant on this project (or is admin)
    const project = await Project.findById(projectId).select('userId supervisorId doerId');
    if (project) {
      const projectParticipants = [
        project.userId?.toString(),
        project.supervisorId?.toString(),
        project.doerId?.toString(),
      ].filter(Boolean);
      const isProjectMember = projectParticipants.includes(requesterId) || req.user!.role === 'admin';
      if (!isProjectMember) throw new AppError('Forbidden: not a project participant', 403);
    }

    // Atomic upsert — prevents duplicate rooms from race conditions
    const room = await ChatRoom.findOneAndUpdate(
      { projectId, roomType: 'project_all' },
      {
        $setOnInsert: {
          projectId,
          roomType: 'project_all',
          name: 'Project Chat',
          participants: [],
        },
      },
      { upsert: true, new: true }
    );

    // Add caller as participant if not already present
    const isParticipant = room.participants.some(
      (p: any) => p.id.toString() === requesterId
    );
    if (!isParticipant) {
      await ChatRoom.updateOne(
        { _id: room._id },
        { $push: { participants: { id: requesterId, role: req.user!.role, joinedAt: new Date(), isActive: true } } }
      );
      const updated = await ChatRoom.findById(room._id);
      const obj = updated!.toObject();
      return res.json({ room: { ...obj, id: obj._id.toString() } });
    }

    const obj = room.toObject();
    res.json({ room: { ...obj, id: obj._id.toString() } });
  } catch (err) {
    next(err);
  }
});

// POST /chat/rooms/:id/join - Add participant to a chat room
router.post('/rooms/:id/join', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const room = await ChatRoom.findById(req.params.id);
    if (!room) throw new AppError('Chat room not found', 404);

    // Verify the caller is on the associated project
    if (room.projectId) {
      const project = await Project.findById(room.projectId).select('userId supervisorId doerId');
      if (!project) throw new AppError('Forbidden: associated project not found', 403);

      const projectParticipants = [
        project.userId?.toString(),
        project.supervisorId?.toString(),
        project.doerId?.toString(),
      ].filter(Boolean);
      const isProjectMember = projectParticipants.includes(req.user!.id) || req.user!.role === 'admin';
      if (!isProjectMember) throw new AppError('Forbidden: not a project participant', 403);
    }

    const isAlreadyParticipant = room.participants.some(
      (p: any) => p.id.toString() === req.user!.id
    );
    if (!isAlreadyParticipant) {
      await ChatRoom.updateOne(
        { _id: room._id },
        { $push: { participants: { id: req.user!.id, role: req.user!.role, joinedAt: new Date(), isActive: true } } }
      );
    }
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// GET /chat/rooms/:id
router.get('/rooms/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const room = await ChatRoom.findById(req.params.id);
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

    // Build filter based on caller's role:
    // supervisor → all messages
    // doer → own messages + approved messages
    // user → approved messages + own messages
    const baseFilter: Record<string, any> = { chatRoomId: req.params.id, isDeleted: false };
    const callerRole = req.user!.role;
    if (callerRole !== 'supervisor') {
      baseFilter.$or = [
        { approvalStatus: 'approved' },
        { senderId: req.user!.id },
      ];
    }

    const [messages, total] = await Promise.all([
      ChatMessage.find(baseFilter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      ChatMessage.countDocuments(baseFilter),
    ]);

    // Populate sender names from all role collections
    const senderIds = [...new Set(messages.map(m => m.senderId.toString()))];
    const [users, supervisors, doers] = await Promise.all([
      User.find({ _id: { $in: senderIds } }).select('fullName avatarUrl').lean(),
      Supervisor.find({ _id: { $in: senderIds } }).select('fullName avatarUrl').lean(),
      Doer.find({ _id: { $in: senderIds } }).select('fullName avatarUrl').lean(),
    ]);
    const senderMap = new Map<string, { fullName?: string; avatarUrl?: string }>();
    for (const s of [...users, ...supervisors, ...doers]) {
      senderMap.set(s._id.toString(), s);
    }

    const enriched = messages.reverse().map(m => {
      const obj = m.toObject();
      const sender = senderMap.get(obj.senderId.toString());
      return {
        ...obj,
        sender: sender ? { id: obj.senderId, full_name: sender.fullName, avatar_url: sender.avatarUrl } : null,
        sender_name: sender?.fullName || 'Unknown',
      };
    });

    res.json({ messages: enriched, total, page: Number(page) });
  } catch (err) {
    next(err);
  }
});

// POST /chat/rooms/:id/messages
router.post('/rooms/:id/messages', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Derive senderRole from JWT only — never trust the request body for role claims.
    const senderRole: 'user' | 'supervisor' | 'doer' = JWT_ROLE_MAP[req.user!.role] ?? 'user';

    // Doer messages start as pending (need supervisor approval before user sees them)
    const approvalStatus = senderRole === 'doer' ? 'pending' : 'approved';

    const message = await ChatMessage.create({
      chatRoomId: req.params.id,
      senderId: req.user!.id,
      senderRole,
      messageType: req.body.messageType || 'text',
      content: req.body.content || '',
      file: req.body.file,
      replyToId: req.body.replyToId,
      approvalStatus,
    });

    // Update room lastMessageAt
    await ChatRoom.findByIdAndUpdate(req.params.id, { lastMessageAt: new Date() });

    // Enrich with sender info (check all role collections)
    const senderId = req.user!.id;
    const senderUser = await User.findById(senderId).select('fullName avatarUrl').lean()
      || await Supervisor.findById(senderId).select('fullName avatarUrl').lean()
      || await Doer.findById(senderId).select('fullName avatarUrl').lean();
    const enrichedMessage = {
      ...message.toObject(),
      sender: senderUser ? { id: senderId, full_name: senderUser.fullName, avatar_url: senderUser.avatarUrl } : null,
      sender_name: senderUser?.fullName || 'Unknown',
    };

    // Emit to room via socket
    const io = req.app.get('io');
    if (io) {
      io.to(`chat:${req.params.id}`).emit('chat:message', enrichedMessage);
    }

    // Create notifications for chat participants
    const room = await ChatRoom.findById(req.params.id).select('projectId participants');
    if (room?.projectId) {
      const project = await Project.findById(room.projectId).select('title supervisorId userId doerId');
      if (project) {
        if (approvalStatus === 'pending' && project.supervisorId) {
          // Doer message pending — notify supervisor
          const notification = await Notification.create({
            recipientId: project.supervisorId,
            recipientRole: 'supervisor',
            type: 'message_pending_approval',
            title: 'Message Needs Approval',
            message: `A doer message in "${project.title}" needs your approval`,
            data: { projectId: project._id, chatRoomId: req.params.id, messageId: message._id },
          });
          if (io) io.to(`user:${project.supervisorId}`).emit('notification:new', notification);
        } else if (approvalStatus === 'approved') {
          // Auto-approved message (user/supervisor) — notify other participants
          const recipients = [project.userId, project.supervisorId, project.doerId]
            .filter(id => id && id.toString() !== req.user!.id);
          for (const recipientId of recipients) {
            const recipientRole = recipientId!.toString() === project.userId?.toString() ? 'user'
              : recipientId!.toString() === project.supervisorId?.toString() ? 'supervisor' : 'doer';
            const notification = await Notification.create({
              recipientId,
              recipientRole,
              type: 'new_message',
              title: 'New Message',
              message: `New message in "${project.title}" project chat`,
              data: { projectId: project._id, chatRoomId: req.params.id },
            });
            if (io) io.to(`user:${recipientId}`).emit('notification:new', notification);
          }
        }
      }
    }

    res.status(201).json({ message: enrichedMessage });
  } catch (err) {
    next(err);
  }
});

// PUT /chat/rooms/:id/read
router.put('/rooms/:id/read', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Mark all messages in room as read by current user
    await ChatMessage.updateMany(
      { chatRoomId: req.params.id, 'readBy.id': { $ne: req.user!.id } },
      { $addToSet: { readBy: { id: req.user!.id, role: req.user!.role } } }
    );

    // Update participant lastSeenAt
    await ChatRoom.updateOne(
      { _id: req.params.id, 'participants.id': req.user!.id },
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

    // Derive senderRole from JWT only — never trust the request body for role claims.
    const senderRole: 'user' | 'supervisor' | 'doer' = JWT_ROLE_MAP[req.user!.role] ?? 'user';

    const fileApprovalStatus = senderRole === 'doer' ? 'pending' : 'approved';

    const message = await ChatMessage.create({
      chatRoomId: req.params.id,
      senderId: req.user!.id,
      senderRole,
      messageType: 'file',
      content: req.body.content || '',
      file: {
        url: result.url,
        name: req.file.originalname,
        type: req.file.mimetype,
        sizeBytes: result.bytes,
      },
      approvalStatus: fileApprovalStatus,
    });

    await ChatRoom.findByIdAndUpdate(req.params.id, { lastMessageAt: new Date() });

    const io = req.app.get('io');
    if (io) {
      io.to(`chat:${req.params.id}`).emit('chat:message', message);
    }

    res.status(201).json({ message });
  } catch (err) {
    next(err);
  }
});

// PUT /chat/rooms/:id/suspend
router.put('/rooms/:id/suspend', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!['supervisor', 'admin'].includes(req.user!.role)) {
      throw new AppError('Only supervisors can suspend chat rooms', 403);
    }
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
    if (!['supervisor', 'admin'].includes(req.user!.role)) {
      throw new AppError('Only supervisors can unsuspend chat rooms', 403);
    }
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

// PUT /chat/messages/:id/approve - Supervisor approves a pending doer message
router.put('/messages/:id/approve', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (req.user!.role !== 'supervisor') {
      throw new AppError('Only supervisors can approve messages', 403);
    }
    const message = await ChatMessage.findByIdAndUpdate(
      req.params.id,
      { approvalStatus: 'approved', approvedBy: req.user!.id, approvedAt: new Date() },
      { new: true }
    );
    if (!message) throw new AppError('Message not found', 404);

    const io = req.app.get('io');
    if (io) {
      io.to(`chat:${message.chatRoomId}`).emit('chat:messageApproved', {
        messageId: req.params.id,
        roomId: message.chatRoomId,
      });
    }

    // Notify user that a new approved message is available
    const room = await ChatRoom.findById(message.chatRoomId).select('projectId');
    if (room?.projectId) {
      const project = await Project.findById(room.projectId).select('title userId');
      if (project?.userId) {
        const notification = await Notification.create({
          recipientId: project.userId,
          recipientRole: 'user',
          type: 'new_message',
          title: 'New Message',
          message: `New message in "${project.title}" project chat`,
          data: { projectId: project._id, chatRoomId: message.chatRoomId },
        });
        if (io) io.to(`user:${project.userId}`).emit('notification:new', notification);
      }
    }

    res.json({ success: true, message });
  } catch (err) {
    next(err);
  }
});

// PUT /chat/messages/:id/reject - Supervisor rejects a pending doer message
router.put('/messages/:id/reject', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (req.user!.role !== 'supervisor') {
      throw new AppError('Only supervisors can reject messages', 403);
    }
    const message = await ChatMessage.findByIdAndUpdate(
      req.params.id,
      { approvalStatus: 'rejected', approvedBy: req.user!.id, approvedAt: new Date() },
      { new: true }
    );
    if (!message) throw new AppError('Message not found', 404);

    const io = req.app.get('io');
    if (io) {
      io.to(`chat:${message.chatRoomId}`).emit('chat:messageRejected', {
        messageId: req.params.id,
        roomId: message.chatRoomId,
      });
    }

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// DELETE /chat/messages/:id
router.delete('/messages/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const message = await ChatMessage.findById(req.params.id);
    if (!message) throw new AppError('Message not found', 404);

    // Only the sender or a supervisor/admin can delete
    const isSender = message.senderId.toString() === req.user!.id;
    const isPrivileged = ['supervisor', 'admin'].includes(req.user!.role);
    if (!isSender && !isPrivileged) throw new AppError('Forbidden', 403);

    await ChatMessage.findByIdAndUpdate(
      req.params.id,
      { isDeleted: true, deletedBy: req.user!.id, deletedAt: new Date() }
    );

    const io = req.app.get('io');
    if (io) {
      io.to(`chat:${message.chatRoomId}`).emit('chat:messageDeleted', { messageId: req.params.id });
    }

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// PUT /chat/rooms/:id/resume - Alias for unsuspend (supervisor-web uses this name)
router.put('/rooms/:id/resume', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!['supervisor', 'admin'].includes(req.user!.role)) {
      throw new AppError('Only supervisors can unsuspend chat rooms', 403);
    }
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

export default router;
