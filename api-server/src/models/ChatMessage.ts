import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IChatMessage extends Document {
  chatRoomId: Types.ObjectId;
  senderId: Types.ObjectId;
  messageType: 'text' | 'file' | 'image' | 'system' | 'revision' | 'action';
  content: string;
  file: {
    url: string;
    name: string;
    type: string;
    sizeBytes: number;
  };
  replyToId: Types.ObjectId;
  isEdited: boolean;
  isDeleted: boolean;
  isFlagged: boolean;
  flaggedReason: string;
  containsContactInfo: boolean;
  readBy: Types.ObjectId[];
  createdAt: Date;
}

const chatMessageSchema = new Schema<IChatMessage>({
  chatRoomId: { type: Schema.Types.ObjectId, ref: 'ChatRoom', required: true },
  senderId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true },
  messageType: { type: String, enum: ['text', 'file', 'image', 'system', 'revision', 'action'], default: 'text' },
  content: { type: String, default: '' },
  file: {
    url: String,
    name: String,
    type: String,
    sizeBytes: Number,
  },
  replyToId: { type: Schema.Types.ObjectId, ref: 'ChatMessage' },
  isEdited: { type: Boolean, default: false },
  isDeleted: { type: Boolean, default: false },
  isFlagged: { type: Boolean, default: false },
  flaggedReason: { type: String },
  containsContactInfo: { type: Boolean, default: false },
  readBy: [{ type: Schema.Types.ObjectId, ref: 'Profile' }],
  createdAt: { type: Date, default: Date.now },
});

chatMessageSchema.index({ chatRoomId: 1, createdAt: -1 });

export const ChatMessage = mongoose.model<IChatMessage>('ChatMessage', chatMessageSchema, 'chat_messages');
