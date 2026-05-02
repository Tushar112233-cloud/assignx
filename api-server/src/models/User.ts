import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IUser extends Document {
  email: string;
  fullName: string;
  phone: string;
  phoneVerified: boolean;
  avatarUrl: string;
  userType: 'student' | 'professional' | 'business';
  onboardingCompleted: boolean;
  onboardingStep: number;
  refreshTokens: Array<{ token: string; expiresAt: Date }>;
  lastLoginAt: Date;
  preferences: Record<string, unknown>;
  twoFactorEnabled: boolean;
  twoFactorSecret: string;
  // Student fields
  universityId?: Types.ObjectId;
  courseId?: Types.ObjectId;
  semester?: number;
  yearOfStudy?: number;
  studentIdNumber?: string;
  expectedGraduationYear?: number;
  collegeEmail?: string;
  collegeEmailVerified?: boolean;
  preferredSubjects?: Types.ObjectId[];
  // Professional fields
  professionalType?: string;
  industryId?: string;
  jobTitle?: string;
  companyName?: string;
  linkedinUrl?: string;
  // Business fields
  businessType?: string;
  gstNumber?: string;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    fullName: { type: String, default: '' },
    phone: { type: String, default: '' },
    phoneVerified: { type: Boolean, default: false },
    avatarUrl: { type: String, default: '' },
    userType: { type: String, enum: ['student', 'professional', 'business'], required: true },
    onboardingCompleted: { type: Boolean, default: false },
    onboardingStep: { type: Number, default: 0 },
    refreshTokens: [
      {
        token: { type: String, required: true },
        expiresAt: { type: Date, required: true },
      },
    ],
    lastLoginAt: { type: Date },
    preferences: { type: Schema.Types.Mixed, default: {} },
    twoFactorEnabled: { type: Boolean, default: false },
    twoFactorSecret: { type: String, default: '' },
    // Student
    universityId: { type: Schema.Types.ObjectId, ref: 'University' },
    courseId: { type: Schema.Types.ObjectId },
    semester: { type: Number },
    yearOfStudy: { type: Number },
    studentIdNumber: { type: String },
    expectedGraduationYear: { type: Number },
    collegeEmail: { type: String },
    collegeEmailVerified: { type: Boolean, default: false },
    preferredSubjects: [{ type: Schema.Types.ObjectId, ref: 'Subject' }],
    // Professional
    professionalType: { type: String },
    industryId: { type: String },
    jobTitle: { type: String },
    companyName: { type: String },
    linkedinUrl: { type: String },
    // Business
    businessType: { type: String },
    gstNumber: { type: String },
  },
  { timestamps: true }
);

userSchema.index({ userType: 1 });

export const User = mongoose.model<IUser>('User', userSchema, 'users');
