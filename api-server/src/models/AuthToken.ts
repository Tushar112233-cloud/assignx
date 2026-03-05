import mongoose, { Schema, Document } from 'mongoose';

export interface IAuthToken extends Document {
  email: string;
  otp: string;
  type: string;
  role: string;
  sessionId: string;
  verified: boolean;
  purpose: 'login' | 'signup';
  attempts: number;
  lockedUntil: Date | null;
  expiresAt: Date;
  createdAt: Date;
}

const authTokenSchema = new Schema<IAuthToken>({
  email: { type: String, required: true },
  otp: { type: String, required: true },
  type: { type: String, default: 'otp' },
  role: { type: String, default: '' },
  sessionId: { type: String, default: '' },
  verified: { type: Boolean, default: false },
  purpose: { type: String, enum: ['login', 'signup'], default: 'login' },
  attempts: { type: Number, default: 0 },
  lockedUntil: { type: Date, default: null },
  expiresAt: { type: Date, required: true, index: { expireAfterSeconds: 0 } },
  createdAt: { type: Date, default: Date.now },
});

authTokenSchema.index({ email: 1, purpose: 1 });

export const AuthToken = mongoose.model<IAuthToken>('AuthToken', authTokenSchema, 'auth_tokens');
