import mongoose, { Schema, Document } from 'mongoose';

export interface IAdmin extends Document {
  email: string;
  fullName: string;
  phone: string;
  avatarUrl: string;
  adminRole: 'super_admin' | 'admin' | 'moderator' | 'support' | 'viewer';
  permissions: Record<string, boolean>;
  isActive: boolean;
  lastActiveAt: Date;
  refreshTokens: Array<{ token: string; expiresAt: Date }>;
  lastLoginAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const adminSchema = new Schema<IAdmin>(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    fullName: { type: String, default: '' },
    phone: { type: String, default: '' },
    avatarUrl: { type: String, default: '' },
    adminRole: { type: String, enum: ['super_admin', 'admin', 'moderator', 'support', 'viewer'], default: 'admin' },
    permissions: { type: Schema.Types.Mixed, default: {} },
    isActive: { type: Boolean, default: true },
    lastActiveAt: { type: Date },
    refreshTokens: [
      {
        token: { type: String, required: true },
        expiresAt: { type: Date, required: true },
      },
    ],
    lastLoginAt: { type: Date },
  },
  { timestamps: true }
);

export const Admin = mongoose.model<IAdmin>('Admin', adminSchema, 'admins');
