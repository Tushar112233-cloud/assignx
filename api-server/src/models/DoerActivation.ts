import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IDoerActivation extends Document {
  doerId: Types.ObjectId;
  step: number;
  totalSteps: number;
  completedSteps: string[];
  isCompleted: boolean;
  completedAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const doerActivationSchema = new Schema<IDoerActivation>(
  {
    doerId: { type: Schema.Types.ObjectId, ref: 'Doer', required: true },
    step: { type: Number, default: 0 },
    totalSteps: { type: Number, default: 5 },
    completedSteps: [String],
    isCompleted: { type: Boolean, default: false },
    completedAt: { type: Date },
  },
  { timestamps: true }
);

doerActivationSchema.index({ doerId: 1 });

export const DoerActivation = mongoose.model<IDoerActivation>('DoerActivation', doerActivationSchema, 'doer_activations');
