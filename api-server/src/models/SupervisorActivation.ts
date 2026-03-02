import mongoose, { Schema, Document, Types } from 'mongoose';

export interface ISupervisorActivation extends Document {
  supervisorId: Types.ObjectId;
  step: number;
  totalSteps: number;
  completedSteps: string[];
  isCompleted: boolean;
  isActivated: boolean;
  trainingCompleted: boolean;
  quizPassed: boolean;
  quizScore: number;
  activatedAt: Date;
  completedAt: Date;
  progress: Record<string, boolean>;
  createdAt: Date;
  updatedAt: Date;
}

const supervisorActivationSchema = new Schema<ISupervisorActivation>(
  {
    supervisorId: { type: Schema.Types.ObjectId, ref: 'Supervisor', required: true },
    step: { type: Number, default: 0 },
    totalSteps: { type: Number, default: 5 },
    completedSteps: [String],
    isCompleted: { type: Boolean, default: false },
    isActivated: { type: Boolean, default: false },
    trainingCompleted: { type: Boolean, default: false },
    quizPassed: { type: Boolean, default: false },
    quizScore: { type: Number, default: 0 },
    activatedAt: { type: Date },
    completedAt: { type: Date },
    progress: { type: Schema.Types.Mixed, default: {} },
  },
  { timestamps: true }
);

supervisorActivationSchema.index({ supervisorId: 1 });

export const SupervisorActivation = mongoose.model<ISupervisorActivation>('SupervisorActivation', supervisorActivationSchema, 'supervisor_activations');
