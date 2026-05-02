import mongoose, { Schema, Document } from 'mongoose';

export interface IExpert extends Document {
  name: string;
  email: string;
  title: string;
  designation: string;
  specialization: string;
  specializations: string[];
  category: string;
  bio: string;
  avatarUrl: string;
  organization: string;
  whatsappNumber: string;
  rating: number;
  totalReviews: number;
  totalSessions: number;
  hourlyRate: number;
  responseTime: string;
  languages: string[];
  education: string;
  experience: string;
  verificationStatus: 'pending' | 'verified' | 'rejected';
  rejectionReason: string;
  isFeatured: boolean;
  isAvailable: boolean;
  isActive: boolean;
  availabilitySlots: Array<{ day: string; startTime: string; endTime: string }>;
  createdAt: Date;
  updatedAt: Date;
}

const expertSchema = new Schema<IExpert>(
  {
    name: { type: String, required: true },
    email: { type: String },
    title: { type: String },
    designation: { type: String },
    specialization: { type: String },
    specializations: { type: [String], default: [] },
    category: { type: String, default: 'academic' },
    bio: { type: String },
    avatarUrl: { type: String },
    organization: { type: String },
    whatsappNumber: { type: String },
    rating: { type: Number, default: 0 },
    totalReviews: { type: Number, default: 0 },
    totalSessions: { type: Number, default: 0 },
    hourlyRate: { type: Number, default: 0 },
    responseTime: { type: String, default: 'Under 1 hour' },
    languages: { type: [String], default: ['English'] },
    education: { type: String },
    experience: { type: String },
    verificationStatus: {
      type: String,
      enum: ['pending', 'verified', 'rejected'],
      default: 'pending',
    },
    rejectionReason: { type: String },
    isFeatured: { type: Boolean, default: false },
    isAvailable: { type: Boolean, default: true },
    isActive: { type: Boolean, default: true },
    availabilitySlots: {
      type: [{
        day: { type: String, enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'] },
        startTime: { type: String },
        endTime: { type: String },
      }],
      default: [],
    },
  },
  { timestamps: true }
);

expertSchema.index({ email: 1 }, { unique: true, sparse: true });
expertSchema.index({ category: 1 });
expertSchema.index({ verificationStatus: 1 });

export const Expert = mongoose.model<IExpert>('Expert', expertSchema, 'experts');
