import mongoose, { Schema, Document, Types } from 'mongoose';

export interface ISupervisorDoerReview extends Document {
  supervisorId: Types.ObjectId;
  doerId: Types.ObjectId;
  projectId: Types.ObjectId;
  rating: number;
  review: string;
  createdAt: Date;
}

const supervisorDoerReviewSchema = new Schema<ISupervisorDoerReview>({
  supervisorId: { type: Schema.Types.ObjectId, ref: 'Supervisor', required: true },
  doerId: { type: Schema.Types.ObjectId, ref: 'Doer', required: true },
  projectId: { type: Schema.Types.ObjectId, ref: 'Project' },
  rating: { type: Number, required: true, min: 1, max: 5 },
  review: { type: String },
  createdAt: { type: Date, default: Date.now },
});

supervisorDoerReviewSchema.index({ doerId: 1 });

export const SupervisorDoerReview = mongoose.model<ISupervisorDoerReview>('SupervisorDoerReview', supervisorDoerReviewSchema, 'supervisor_doer_reviews');
