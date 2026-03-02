import mongoose, { Schema, Document } from 'mongoose';

export interface ITrainingModule extends Document {
  title: string;
  description: string;
  videoUrl: string;
  thumbnailUrl: string;
  duration: number;
  category: string;
  targetRole: string;
  order: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const trainingModuleSchema = new Schema<ITrainingModule>(
  {
    title: { type: String, required: true },
    description: { type: String },
    videoUrl: { type: String },
    thumbnailUrl: { type: String },
    duration: { type: Number, default: 0 },
    category: { type: String },
    targetRole: { type: String, default: 'all' },
    order: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export const TrainingModule = mongoose.model<ITrainingModule>('TrainingModule', trainingModuleSchema, 'training_modules');
