import mongoose, { Schema, Document } from 'mongoose';

export interface ISubject extends Document {
  name: string;
  slug: string;
  category: string;
  isActive: boolean;
  createdAt: Date;
}

const subjectSchema = new Schema<ISubject>({
  name: { type: String, required: true },
  slug: { type: String, required: true, unique: true, index: true },
  category: { type: String },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

export const Subject = mongoose.model<ISubject>('Subject', subjectSchema, 'subjects');
