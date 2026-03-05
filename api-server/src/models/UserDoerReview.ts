import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IUserDoerReview extends Document {
  userId: Types.ObjectId;
  doerId: Types.ObjectId;
  projectId: Types.ObjectId;
  rating: number;
  review: string;
  createdAt: Date;
}

const userDoerReviewSchema = new Schema<IUserDoerReview>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  doerId: { type: Schema.Types.ObjectId, ref: 'Doer', required: true },
  projectId: { type: Schema.Types.ObjectId, ref: 'Project' },
  rating: { type: Number, required: true, min: 1, max: 5 },
  review: { type: String },
  createdAt: { type: Date, default: Date.now },
});

userDoerReviewSchema.index({ doerId: 1 });

export const UserDoerReview = mongoose.model<IUserDoerReview>('UserDoerReview', userDoerReviewSchema, 'user_doer_reviews');
