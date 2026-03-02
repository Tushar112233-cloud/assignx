import mongoose, { Schema, Document } from 'mongoose';

export interface IAuthToken extends Document {
  email: string;
  otp: string;
  type: string;
  expiresAt: Date;
  createdAt: Date;
}

const authTokenSchema = new Schema<IAuthToken>({
  email: { type: String, required: true },
  otp: { type: String, required: true },
  type: { type: String, default: 'magic_link' },
  expiresAt: { type: Date, required: true, index: { expireAfterSeconds: 0 } },
  createdAt: { type: Date, default: Date.now },
});

export const AuthToken = mongoose.model<IAuthToken>('AuthToken', authTokenSchema, 'auth_tokens');
