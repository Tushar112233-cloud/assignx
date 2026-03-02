import mongoose, { Schema, Document } from 'mongoose';

export interface ILearningResource extends Document {
  title: string;
  description: string;
  url: string;
  type: string;
  category: string;
  targetRole: string;
  order: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const learningResourceSchema = new Schema<ILearningResource>(
  {
    title: { type: String, required: true },
    description: { type: String },
    url: { type: String },
    type: { type: String },
    category: { type: String },
    targetRole: { type: String, default: 'all' },
    order: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export const LearningResource = mongoose.model<ILearningResource>('LearningResource', learningResourceSchema, 'learning_resources');
