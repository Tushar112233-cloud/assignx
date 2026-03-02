import mongoose, { Schema, Document, Types } from 'mongoose';

export interface ITrainingProgress extends Document {
  userId: Types.ObjectId;
  moduleId: Types.ObjectId;
  progress: number;
  completed: boolean;
  completedAt: Date;
  lastAccessedAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const trainingProgressSchema = new Schema<ITrainingProgress>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true },
    moduleId: { type: Schema.Types.ObjectId, ref: 'TrainingModule', required: true },
    progress: { type: Number, default: 0 },
    completed: { type: Boolean, default: false },
    completedAt: { type: Date },
    lastAccessedAt: { type: Date },
  },
  { timestamps: true }
);

trainingProgressSchema.index({ userId: 1, moduleId: 1 }, { unique: true });

export const TrainingProgress = mongoose.model<ITrainingProgress>('TrainingProgress', trainingProgressSchema, 'training_progress');
