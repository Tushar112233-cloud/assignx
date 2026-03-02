import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IPayoutRequest extends Document {
  recipientId: Types.ObjectId;
  amount: number;
  payoutMethod: 'bank_transfer' | 'upi';
  status: 'pending' | 'approved' | 'rejected' | 'processing' | 'completed';
  rejectionReason: string;
  createdAt: Date;
  reviewedAt: Date;
  reviewedBy: Types.ObjectId;
}

const payoutRequestSchema = new Schema<IPayoutRequest>({
  recipientId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true },
  amount: { type: Number, required: true },
  payoutMethod: { type: String, enum: ['bank_transfer', 'upi'], default: 'bank_transfer' },
  status: { type: String, enum: ['pending', 'approved', 'rejected', 'processing', 'completed'], default: 'pending' },
  rejectionReason: { type: String },
  createdAt: { type: Date, default: Date.now },
  reviewedAt: { type: Date },
  reviewedBy: { type: Schema.Types.ObjectId, ref: 'Profile' },
});

payoutRequestSchema.index({ recipientId: 1, status: 1 });

export const PayoutRequest = mongoose.model<IPayoutRequest>('PayoutRequest', payoutRequestSchema, 'payout_requests');
