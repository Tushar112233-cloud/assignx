import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IDoerReview extends Document {
  doerId: Types.ObjectId;
  reviewerId: Types.ObjectId;
  projectId: Types.ObjectId;
  rating: number;
  review: string;
  createdAt: Date;
}

const doerReviewSchema = new Schema<IDoerReview>({
  doerId: { type: Schema.Types.ObjectId, ref: 'Doer', required: true },
  reviewerId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true },
  projectId: { type: Schema.Types.ObjectId, ref: 'Project' },
  rating: { type: Number, required: true, min: 1, max: 5 },
  review: { type: String },
  createdAt: { type: Date, default: Date.now },
});

doerReviewSchema.index({ doerId: 1 });

export const DoerReview = mongoose.model<IDoerReview>('DoerReview', doerReviewSchema, 'doer_reviews');
