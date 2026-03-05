import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IPostInteraction extends Document {
  postId: Types.ObjectId;
  userId: Types.ObjectId;
  type: 'like' | 'save';
  createdAt: Date;
}

const postInteractionSchema = new Schema<IPostInteraction>({
  postId: { type: Schema.Types.ObjectId, ref: 'CommunityPost', required: true },
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, enum: ['like', 'save'], required: true },
  createdAt: { type: Date, default: Date.now },
});

postInteractionSchema.index({ postId: 1, userId: 1, type: 1 }, { unique: true });

export const PostInteraction = mongoose.model<IPostInteraction>('PostInteraction', postInteractionSchema, 'post_interactions');
