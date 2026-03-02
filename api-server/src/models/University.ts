import mongoose, { Schema, Document } from 'mongoose';

export interface IUniversity extends Document {
  name: string;
  location: string;
  isActive: boolean;
  createdAt: Date;
}

const universitySchema = new Schema<IUniversity>({
  name: { type: String, required: true },
  location: { type: String },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

export const University = mongoose.model<IUniversity>('University', universitySchema, 'universities');
