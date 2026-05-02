import mongoose, { Schema, Document, Types } from 'mongoose';

export interface ISupportTicket extends Document {
  raisedById: Types.ObjectId;
  raisedByRole: 'user' | 'doer' | 'supervisor';
  userName: string;
  subject: string;
  description: string;
  category: string;
  priority: string;
  status: 'open' | 'in_progress' | 'resolved' | 'closed';
  assignedTo: Types.ObjectId;
  messages: {
    senderId: Types.ObjectId;
    senderName: string;
    senderRole: string;
    message: string;
    attachmentUrl: string;
    createdAt: Date;
  }[];
  createdAt: Date;
  updatedAt: Date;
  resolvedAt: Date;
}

const supportTicketSchema = new Schema<ISupportTicket>(
  {
    raisedById: { type: Schema.Types.ObjectId, required: true },
    raisedByRole: { type: String, enum: ['user', 'doer', 'supervisor'], required: true },
    userName: { type: String, default: '' },
    subject: { type: String, required: true },
    description: { type: String, default: '' },
    category: { type: String, default: 'general' },
    priority: { type: String, default: 'medium' },
    status: { type: String, enum: ['open', 'in_progress', 'resolved', 'closed'], default: 'open' },
    assignedTo: { type: Schema.Types.ObjectId, ref: 'Admin' },
    messages: [
      {
        senderId: { type: Schema.Types.ObjectId },
        senderName: String,
        senderRole: String,
        message: String,
        attachmentUrl: String,
        createdAt: { type: Date, default: Date.now },
      },
    ],
    resolvedAt: { type: Date },
  },
  { timestamps: true }
);

supportTicketSchema.index({ raisedById: 1, raisedByRole: 1, status: 1 });

export const SupportTicket = mongoose.model<ISupportTicket>('SupportTicket', supportTicketSchema, 'support_tickets');
