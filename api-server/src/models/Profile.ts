import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IProfile extends Document {
  _id: Types.ObjectId;
  email: string;
  fullName: string;
  phone: string;
  phoneVerified: boolean;
  avatarUrl: string;
  userType: 'user' | 'doer' | 'supervisor' | 'admin';
  userTypes: string[];
  primaryUserType: string;
  onboardingStep: number;
  onboardingCompleted: boolean;
  twoFactorEnabled: boolean;
  twoFactorSecret: string;
  preferences: Record<string, unknown>;
  refreshTokens: { token: string; expiresAt: Date }[];
  lastLoginAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const profileSchema = new Schema<IProfile>(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    fullName: { type: String, default: '' },
    phone: { type: String, default: '' },
    phoneVerified: { type: Boolean, default: false },
    avatarUrl: { type: String, default: '' },
    userType: { type: String, enum: ['user', 'student', 'professional', 'business', 'doer', 'supervisor', 'admin'], default: 'user' },
    userTypes: { type: [String], default: [] },
    primaryUserType: { type: String, default: '' },
    onboardingStep: { type: Number, default: 0 },
    onboardingCompleted: { type: Boolean, default: false },
    twoFactorEnabled: { type: Boolean, default: false },
    twoFactorSecret: { type: String, default: '' },
    preferences: { type: Schema.Types.Mixed, default: {} },
    refreshTokens: [
      {
        token: String,
        expiresAt: Date,
      },
    ],
    lastLoginAt: { type: Date },
  },
  { timestamps: true }
);

profileSchema.index({ userType: 1 });

export const Profile = mongoose.model<IProfile>('Profile', profileSchema, 'profiles');
