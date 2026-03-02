import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IExpert extends Document {
  profileId: Types.ObjectId;
  name: string;
  title: string;
  specialization: string;
  bio: string;
  avatarUrl: string;
  rating: number;
  totalReviews: number;
  hourlyRate: number;
  isAvailable: boolean;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const expertSchema = new Schema<IExpert>(
  {
    profileId: { type: Schema.Types.ObjectId, ref: 'Profile' },
    name: { type: String, required: true },
    title: { type: String },
    specialization: { type: String },
    bio: { type: String },
    avatarUrl: { type: String },
    rating: { type: Number, default: 0 },
    totalReviews: { type: Number, default: 0 },
    hourlyRate: { type: Number, default: 0 },
    isAvailable: { type: Boolean, default: true },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export const Expert = mongoose.model<IExpert>('Expert', expertSchema, 'experts');
