# Chat & Notifications Sync - Implementation Plan

**Goal:** Fix chat room isolation, ensure cross-portal chat sync, add missing notifications for chat messages and live doc updates, and make the supervisor messaging page work correctly.

**Architecture:** Per-project chat rooms with message approval workflow. Socket.IO for real-time delivery. Persistent notifications in MongoDB for all important events. No email notifications yet (deferred).

**Tech Stack:** Express/MongoDB API, Socket.IO, Next.js frontends (user-web, doer-web, superviser-web)

---

## Analysis of Current Issues

### Issue 1: Supervisor sees "No chat rooms" on Messages page
**Root cause:** Supervisor is NOT a participant in the AX-000001 project's chat room. The chat room was created by the user, and the doer joined, but the supervisor (`69a9e1c5814fdeb0f0a5f654`) was never added as a participant. The GET /chat/rooms endpoint correctly filters by `participants.id`, so the supervisor sees no rooms for that project.

**Why this happens:** When a project is assigned to a supervisor, the supervisor is NOT automatically added to the project's chat room. Chat rooms are only created/joined when someone visits the project page and calls `getOrCreateProjectChatRoom()`.

### Issue 2: GET /chat/rooms ignores `projectId` query param
**Root cause:** The API endpoint at line 68-97 of `chat.routes.ts` only filters by `participants.id` and ignores `req.query.projectId`. The supervisor-web `useChatRooms({ projectId })` hook sends the param but gets back ALL rooms.

### Issue 3: Doer message stuck as "pending" - user can't see it
**Root cause:** This is BY DESIGN - doer messages need supervisor approval. But the supervisor has NO notification that a message needs approval. The doer's message "ofc it will be done by 5" is `approvalStatus: pending` because no supervisor approved it.

### Issue 4: No notifications for new chat messages
**Root cause:** Chat messages only emit socket events (`chat:message`). No persistent `Notification` document is created. If someone is offline, they miss it entirely.

### Issue 5: Supervisor notification socket event mismatch
**Root cause:** API emits `notification:new` but supervisor-web listens for `notification:${user.id}`. These don't match, so real-time notifications never arrive on supervisor-web.

### Issue 6: No notification for live doc URL updates
**Root cause:** The PUT /projects/:id endpoint updates the live doc URL but doesn't create any notification.

### Issue 7: Supervisor resume endpoint wrong
**Root cause:** Supervisor-web calls `/api/chat/rooms/${roomId}/resume` but API only has `/unsuspend`.

---

## Implementation Tasks

### Task 1: Auto-add supervisor to chat rooms when assigned to project

**Files:**
- Modify: `api-server/src/routes/project.routes.ts` (assign-supervisor / claim-project)
- Modify: `api-server/src/routes/supervisor.routes.ts` (supervisor assignment endpoints)

**What to do:**
When a supervisor claims or is assigned to a project, auto-create/join the project chat room:

```typescript
// After supervisor assignment succeeds, add them to chat room
const chatRoom = await ChatRoom.findOneAndUpdate(
  { projectId, roomType: 'project_all' },
  {
    $setOnInsert: { projectId, roomType: 'project_all', name: 'Project Chat', participants: [] },
  },
  { upsert: true, new: true }
);
const isSupervisorInRoom = chatRoom.participants.some(
  (p: any) => p.id.toString() === supervisorId
);
if (!isSupervisorInRoom) {
  await ChatRoom.updateOne(
    { _id: chatRoom._id },
    { $push: { participants: { id: supervisorId, role: 'supervisor', joinedAt: new Date(), isActive: true } } }
  );
}
```

Similarly for doer assignment via `PUT /projects/:id/assign-doer`.

### Task 2: Add projectId filter to GET /chat/rooms

**Files:**
- Modify: `api-server/src/routes/chat.routes.ts` (lines 68-97)

**What to do:**
```typescript
router.get('/rooms', authenticate, async (req, res, next) => {
  try {
    const filter: Record<string, any> = {
      'participants.id': req.user!.id,
      'participants.isActive': true,
    };
    // Support projectId filter
    if (req.query.projectId) {
      filter.projectId = req.query.projectId;
    }
    // Support roomType filter
    if (req.query.roomType) {
      filter.roomType = req.query.roomType;
    }
    const rooms = await ChatRoom.find(filter).sort({ lastMessageAt: -1 });
    // ... rest of normalization
  }
});
```

### Task 3: Fix supervisor notification socket event name

**Files:**
- Modify: `superviser-web/hooks/use-notifications.ts` (lines 136-141)

**What to do:**
Change socket listener from `notification:${user.id}` to `notification:new` (which is what the API emits):

```typescript
// BEFORE (broken):
socket.on(`notification:${user.id}`, handleNew)
socket.on(`notification:update:${user.id}`, handleUpdate)

// AFTER (correct):
socket.on('notification:new', handleNew)
socket.on('notification:update', handleUpdate)
```

Also fix in doer-web if the same pattern exists there.

### Task 4: Create notifications for new chat messages (pending approval)

**Files:**
- Modify: `api-server/src/routes/chat.routes.ts` (POST /rooms/:id/messages, around line 278-322)

**What to do:**
When a doer sends a message (pending approval), create a notification for the project's supervisor:

```typescript
// After message creation, if it's pending approval, notify supervisor
if (approvalStatus === 'pending') {
  const room = await ChatRoom.findById(req.params.id).select('projectId');
  if (room?.projectId) {
    const project = await Project.findById(room.projectId).select('supervisorId projectNumber title');
    if (project?.supervisorId) {
      const notification = await Notification.create({
        recipientId: project.supervisorId,
        recipientRole: 'supervisor',
        type: 'message_pending_approval',
        title: 'Message Needs Approval',
        message: `A doer message in "${project.title}" needs your approval`,
        data: { projectId: project._id, chatRoomId: req.params.id, messageId: message._id },
      });
      const io = req.app.get('io');
      if (io) {
        io.to(`user:${project.supervisorId}`).emit('notification:new', notification);
      }
    }
  }
}
```

When a message is approved, notify the user that a new message is available:

```typescript
// In PUT /messages/:id/approve, after approval:
const room = await ChatRoom.findById(message.chatRoomId).select('projectId');
if (room?.projectId) {
  const project = await Project.findById(room.projectId).select('userId title');
  if (project?.userId) {
    const notification = await Notification.create({
      recipientId: project.userId,
      recipientRole: 'user',
      type: 'new_message',
      title: 'New Message',
      message: `New message in "${project.title}" project chat`,
      data: { projectId: project._id, chatRoomId: message.chatRoomId },
    });
    const io = req.app.get('io');
    if (io) {
      io.to(`user:${project.userId}`).emit('notification:new', notification);
    }
  }
}
```

For user/supervisor messages (auto-approved), notify all other participants.

### Task 5: Create notification for live doc URL updates

**Files:**
- Modify: `api-server/src/routes/project.routes.ts` (PUT /:id, around line 262-297)

**What to do:**
After a successful `liveDocumentUrl` update, notify the supervisor and user:

```typescript
if (updates.liveDocumentUrl !== undefined) {
  const project = await Project.findById(req.params.id);
  const recipients = [project.userId, project.supervisorId, project.doerId]
    .filter(id => id && id.toString() !== uid); // exclude updater

  for (const recipientId of recipients) {
    const recipientRole = recipientId.toString() === project.userId?.toString() ? 'user'
      : recipientId.toString() === project.supervisorId?.toString() ? 'supervisor' : 'doer';

    const notification = await Notification.create({
      recipientId,
      recipientRole,
      type: 'live_doc_updated',
      title: 'Live Document Updated',
      message: updates.liveDocumentUrl
        ? `A live document link has been added to "${project.title}"`
        : `Live document link removed from "${project.title}"`,
      data: { projectId: project._id },
    });
    io.to(`user:${recipientId}`).emit('notification:new', notification);
  }
}
```

### Task 6: Add Notification model import and new notification types

**Files:**
- Modify: `api-server/src/routes/chat.routes.ts` (add Notification import)
- Verify: `api-server/src/models/Notification.ts` supports the new types

**What to do:**
Add `Notification` to the imports in chat.routes.ts. The Notification model uses a free-form `type` string field, so no schema changes needed.

### Task 7: Fix doer-web notification listener

**Files:**
- Check: `doer-web/hooks/` or `doer-web/components/` for notification socket listeners
- May need to create/fix notification bell component for doer-web

**What to do:**
Ensure doer-web listens for `notification:new` socket event (same fix as Task 3).

### Task 8: Fix supervisor resume/unsuspend endpoint mismatch

**Files:**
- Check: `superviser-web/` for calls to `/resume`
- Either add `/resume` alias in API or fix the frontend to call `/unsuspend`

**What to do:**
Add an alias route in `chat.routes.ts`:
```typescript
// Alias for resume
router.put('/rooms/:id/resume', authenticate, async (req, res, next) => {
  // Delegate to unsuspend handler
  req.url = req.url.replace('/resume', '/unsuspend');
  // ... same logic as unsuspend
});
```

Or simpler: just change the frontend to call `/unsuspend`.

### Task 9: Auto-add doer to chat room on assignment

**Files:**
- Modify: `api-server/src/routes/project.routes.ts` (PUT /:id/assign-doer, around line 560-661)

**What to do:**
Same pattern as Task 1 - when a doer is assigned to a project, auto-add them to the chat room.

### Task 10: Ensure unread message tracking works across portals

**Files:**
- Verify: `api-server/src/routes/chat.routes.ts` (GET /chat/unread)
- Verify: Supervisor-web `useUnreadMessages` hook
- Verify: User-web and doer-web unread tracking

**What to do:**
The unread tracking is already implemented via `readBy` array on messages and `lastSeenAt` on participants. Verify it works correctly:
1. When supervisor opens a room, it calls `PUT /chat/rooms/:id/read`
2. When user/doer opens a room, same call
3. Unread count badge shows on navigation

---

## Priority Order

1. **Task 1 + Task 9** (Critical) - Auto-add supervisor/doer to chat rooms on assignment
2. **Task 2** (Critical) - Add projectId filter to GET /chat/rooms
3. **Task 3 + Task 7** (Critical) - Fix notification socket event names
4. **Task 4** (High) - Notifications for pending messages and approved messages
5. **Task 5** (High) - Notifications for live doc URL updates
6. **Task 6** (Required for Task 4) - Add Notification import to chat routes
7. **Task 8** (Medium) - Fix resume/unsuspend mismatch
8. **Task 10** (Medium) - Verify unread tracking works

---

## Testing Plan

1. **Supervisor chat**: Visit `/chat` on supervisor-web - should see rooms for assigned projects
2. **Doer sends message**: From doer-web, send a message - supervisor should get a notification
3. **Supervisor approves**: Approve the doer's message - user should get a notification
4. **Live doc update**: Doer adds a Google Docs link - supervisor and user get notified
5. **Project assignment**: Assign a new doer - doer should auto-appear in chat room
6. **Cross-portal sync**: All three portals should see the same messages in the same room
