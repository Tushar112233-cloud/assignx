import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IChatRoom extends Document {
  projectId: Types.ObjectId;
  roomType: 'project_user_supervisor' | 'project_supervisor_doer' | 'project_all' | 'support' | 'direct';
  name: string;
  participants: {
    id: Types.ObjectId;
    role: 'user' | 'doer' | 'supervisor' | 'admin';
    joinedAt: Date;
    lastSeenAt: Date;
    lastReadMessageId: Types.ObjectId;
    isMuted: boolean;
    isActive: boolean;
  }[];
  lastMessageAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const chatRoomSchema = new Schema<IChatRoom>(
  {
    projectId: { type: Schema.Types.ObjectId, ref: 'Project' },
    roomType: {
      type: String,
      enum: ['project_user_supervisor', 'project_supervisor_doer', 'project_all', 'support', 'direct'],
    },
    name: { type: String },
    participants: [
      {
        id: { type: Schema.Types.ObjectId, required: true },
        role: { type: String, enum: ['user', 'doer', 'supervisor', 'admin'], required: true },
        joinedAt: { type: Date, default: Date.now },
        lastSeenAt: { type: Date },
        lastReadMessageId: { type: Schema.Types.ObjectId },
        isMuted: { type: Boolean, default: false },
        isActive: { type: Boolean, default: true },
      },
    ],
    lastMessageAt: { type: Date },
  },
  { timestamps: true }
);

chatRoomSchema.index({ projectId: 1 });
chatRoomSchema.index({ 'participants.id': 1 });
chatRoomSchema.index({ projectId: 1, roomType: 1 }, { unique: true, sparse: true });

export const ChatRoom = mongoose.model<IChatRoom>('ChatRoom', chatRoomSchema, 'chat_rooms');
