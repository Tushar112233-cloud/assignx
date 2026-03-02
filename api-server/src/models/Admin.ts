import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IAdmin extends Document {
  profileId: Types.ObjectId;
  email: string;
  adminRole: 'super_admin' | 'admin' | 'moderator' | 'support' | 'viewer';
  permissions: Record<string, boolean>;
  isActive: boolean;
  lastActiveAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const adminSchema = new Schema<IAdmin>(
  {
    profileId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true, unique: true },
    email: { type: String, required: true },
    adminRole: { type: String, enum: ['super_admin', 'admin', 'moderator', 'support', 'viewer'], default: 'admin' },
    permissions: { type: Schema.Types.Mixed, default: {} },
    isActive: { type: Boolean, default: true },
    lastActiveAt: { type: Date },
  },
  { timestamps: true }
);

export const Admin = mongoose.model<IAdmin>('Admin', adminSchema, 'admins');
