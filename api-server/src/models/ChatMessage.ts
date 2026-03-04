import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IChatMessage extends Document {
  chatRoomId: Types.ObjectId;
  senderId: Types.ObjectId;
  senderRole: 'user' | 'supervisor' | 'doer' | 'system';
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
  approvalStatus: 'pending' | 'approved' | 'rejected';
  approvedBy?: Types.ObjectId;
  approvedAt?: Date;
  createdAt: Date;
}

const chatMessageSchema = new Schema<IChatMessage>({
  chatRoomId: { type: Schema.Types.ObjectId, ref: 'ChatRoom', required: true },
  senderId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true },
  senderRole: { type: String, enum: ['user', 'supervisor', 'doer', 'system'], default: 'user' },
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
  approvalStatus: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'approved' },
  approvedBy: { type: Schema.Types.ObjectId, ref: 'Profile' },
  approvedAt: { type: Date },
  createdAt: { type: Date, default: Date.now },
});

chatMessageSchema.index({ chatRoomId: 1, createdAt: -1 });

export const ChatMessage = mongoose.model<IChatMessage>('ChatMessage', chatMessageSchema, 'chat_messages');
