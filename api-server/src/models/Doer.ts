import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IDoer extends Document {
  email: string;
  fullName: string;
  phone: string;
  phoneVerified: boolean;
  avatarUrl: string;
  onboardingCompleted: boolean;
  onboardingStep: number;
  refreshTokens: { token: string; expiresAt: Date }[];
  lastLoginAt: Date;
  qualification: 'high_school' | 'undergraduate' | 'postgraduate' | 'phd';
  universityName: string;
  experienceLevel: 'beginner' | 'intermediate' | 'pro';
  yearsOfExperience: number;
  bio: string;
  isAvailable: boolean;
  maxConcurrentProjects: number;
  isActivated: boolean;
  activatedAt: Date;
  totalEarnings: number;
  totalProjectsCompleted: number;
  averageRating: number;
  totalReviews: number;
  successRate: number;
  onTimeDeliveryRate: number;
  bankDetails: {
    accountName: string;
    accountNumber: string;
    ifscCode: string;
    bankName: string;
    upiId: string;
    verified: boolean;
  };
  skills: { skillId: Types.ObjectId; proficiencyLevel: string; isVerified: boolean }[];
  subjects: { subjectId: Types.ObjectId; isPrimary: boolean }[];
  trainingCompleted: boolean;
  trainingCompletedAt: Date;
  isFlagged: boolean;
  flagReason: string;
  isAccessGranted: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const doerSchema = new Schema<IDoer>(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    fullName: { type: String, default: '' },
    phone: { type: String, default: '' },
    phoneVerified: { type: Boolean, default: false },
    avatarUrl: { type: String, default: '' },
    onboardingCompleted: { type: Boolean, default: false },
    onboardingStep: { type: Number, default: 0 },
    refreshTokens: [
      {
        token: { type: String, required: true },
        expiresAt: { type: Date, required: true },
      },
    ],
    lastLoginAt: { type: Date },
    qualification: { type: String, enum: ['high_school', 'undergraduate', 'postgraduate', 'phd'] },
    universityName: { type: String },
    experienceLevel: { type: String, enum: ['beginner', 'intermediate', 'pro'], default: 'beginner' },
    yearsOfExperience: { type: Number, default: 0 },
    bio: { type: String, default: '' },
    isAvailable: { type: Boolean, default: true },
    maxConcurrentProjects: { type: Number, default: 3 },
    isActivated: { type: Boolean, default: false },
    activatedAt: { type: Date },
    totalEarnings: { type: Number, default: 0 },
    totalProjectsCompleted: { type: Number, default: 0 },
    averageRating: { type: Number, default: 0 },
    totalReviews: { type: Number, default: 0 },
    successRate: { type: Number, default: 0 },
    onTimeDeliveryRate: { type: Number, default: 0 },
    bankDetails: {
      accountName: { type: String, default: '' },
      accountNumber: { type: String, default: '' },
      ifscCode: { type: String, default: '' },
      bankName: { type: String, default: '' },
      upiId: { type: String, default: '' },
      verified: { type: Boolean, default: false },
    },
    skills: [
      {
        skillId: { type: Schema.Types.ObjectId, ref: 'Skill' },
        proficiencyLevel: { type: String },
        isVerified: { type: Boolean, default: false },
      },
    ],
    subjects: [
      {
        subjectId: { type: Schema.Types.ObjectId, ref: 'Subject' },
        isPrimary: { type: Boolean, default: false },
      },
    ],
    trainingCompleted: { type: Boolean, default: false },
    trainingCompletedAt: { type: Date },
    isFlagged: { type: Boolean, default: false },
    flagReason: { type: String, default: '' },
    isAccessGranted: { type: Boolean, default: false },
  },
  { timestamps: true }
);

doerSchema.index({ isAvailable: 1, isActivated: 1 });

export const Doer = mongoose.model<IDoer>('Doer', doerSchema, 'doers');
