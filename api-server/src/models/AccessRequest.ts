import mongoose, { Schema, Document } from 'mongoose';

export interface IAccessRequest extends Document {
  email: string;
  role: string;
  fullName: string;
  status: 'pending' | 'approved' | 'rejected';
  metadata: Record<string, unknown>;
  reviewedAt?: Date;
  reviewedBy?: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const accessRequestSchema = new Schema<IAccessRequest>(
  {
    email: { type: String, required: true, lowercase: true, trim: true },
    role: { type: String, required: true },
    fullName: { type: String, required: true, trim: true },
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected'],
      default: 'pending',
    },
    metadata: { type: Schema.Types.Mixed, default: {} },
    reviewedAt: Date,
    reviewedBy: { type: Schema.Types.ObjectId, ref: 'Admin' },
  },
  { timestamps: true }
);

accessRequestSchema.index({ email: 1, role: 1 });

export const AccessRequest = mongoose.model<IAccessRequest>(
  'AccessRequest',
  accessRequestSchema
);
