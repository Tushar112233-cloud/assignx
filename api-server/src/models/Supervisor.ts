import mongoose, { Schema, Document } from 'mongoose';

export interface ISupervisor extends Document {
  email: string;
  fullName: string;
  phone: string;
  phoneVerified: boolean;
  avatarUrl: string;
  onboardingCompleted: boolean;
  onboardingStep: number;
  refreshTokens: Array<{ token: string; expiresAt: Date }>;
  lastLoginAt: Date;
  qualification: string;
  yearsOfExperience: number;
  bio: string;
  isActive: boolean;
  isActivated: boolean;
  isAvailable: boolean;
  isApproved: boolean;
  isAccessGranted: boolean;
  totalEarnings: number;
  totalProjectsCompleted: number;
  averageRating: number;
  totalReviews: number;
  onTimeDeliveryRate: number;
  successRate: number;
  isFlagged: boolean;
  flagReason: string;
  activatedAt: Date;
  bankDetails: {
    accountName: string;
    accountNumber: string;
    ifscCode: string;
    bankName: string;
    upiId: string;
    verified: boolean;
  };
  blacklistedDoers: Array<{ id: string; reason: string; addedAt: Date }>;
  expertise: string[];
  subjects: Array<{ subjectId: mongoose.Types.ObjectId | string; isPrimary: boolean }>;
  createdAt: Date;
  updatedAt: Date;
}

const supervisorSchema = new Schema<ISupervisor>(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    fullName: { type: String, default: '' },
    phone: { type: String, default: '' },
    phoneVerified: { type: Boolean, default: false },
    avatarUrl: { type: String, default: '' },
    onboardingCompleted: { type: Boolean, default: false },
    onboardingStep: { type: Number, default: 0 },
    refreshTokens: {
      type: [{ token: { type: String, required: true }, expiresAt: { type: Date, required: true } }],
      default: [],
    },
    lastLoginAt: { type: Date },
    qualification: { type: String },
    yearsOfExperience: { type: Number, default: 0 },
    bio: { type: String, default: '' },
    isActive: { type: Boolean, default: true },
    isActivated: { type: Boolean, default: false },
    isAvailable: { type: Boolean, default: true },
    isApproved: { type: Boolean, default: false },
    isAccessGranted: { type: Boolean, default: false },
    totalEarnings: { type: Number, default: 0 },
    totalProjectsCompleted: { type: Number, default: 0 },
    averageRating: { type: Number, default: 0 },
    totalReviews: { type: Number, default: 0 },
    onTimeDeliveryRate: { type: Number, default: 0 },
    successRate: { type: Number, default: 0 },
    isFlagged: { type: Boolean, default: false },
    flagReason: { type: String, default: '' },
    activatedAt: { type: Date },
    blacklistedDoers: { type: [{ id: String, reason: String, addedAt: Date }], default: [] },
    expertise: { type: [String], default: [] },
    subjects: {
      type: [{ subjectId: { type: Schema.Types.ObjectId, ref: 'Subject' }, isPrimary: { type: Boolean, default: false } }],
      default: [],
    },
    bankDetails: {
      accountName: { type: String, default: '' },
      accountNumber: { type: String, default: '' },
      ifscCode: { type: String, default: '' },
      bankName: { type: String, default: '' },
      upiId: { type: String, default: '' },
      verified: { type: Boolean, default: false },
    },
  },
  { timestamps: true }
);

export const Supervisor = mongoose.model<ISupervisor>('Supervisor', supervisorSchema, 'supervisors');
