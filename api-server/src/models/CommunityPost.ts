import mongoose, { Schema, Document, Types } from 'mongoose';

export interface ICommunityPost extends Document {
  userId: Types.ObjectId;
  postType: 'campus' | 'pro_network' | 'business_hub';
  title: string;
  content: string;
  imageUrls: string[];
  category: string;
  tags: string[];
  viewCount: number;
  likeCount: number;
  commentCount: number;
  saveCount: number;
  isFlagged: boolean;
  isActive: boolean;
  comments: {
    userId: Types.ObjectId;
    content: string;
    parentId: Types.ObjectId;
    likeCount: number;
    isFlagged: boolean;
    createdAt: Date;
  }[];
  createdAt: Date;
  updatedAt: Date;
}

const communityPostSchema = new Schema<ICommunityPost>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    postType: { type: String, enum: ['campus', 'pro_network', 'business_hub'], required: true },
    title: { type: String, default: '' },
    content: { type: String, default: '' },
    imageUrls: [String],
    category: { type: String },
    tags: [String],
    viewCount: { type: Number, default: 0 },
    likeCount: { type: Number, default: 0 },
    commentCount: { type: Number, default: 0 },
    saveCount: { type: Number, default: 0 },
    isFlagged: { type: Boolean, default: false },
    isActive: { type: Boolean, default: true },
    comments: [
      {
        userId: { type: Schema.Types.ObjectId, ref: 'User' },
        content: String,
        parentId: { type: Schema.Types.ObjectId },
        likeCount: { type: Number, default: 0 },
        isFlagged: { type: Boolean, default: false },
        createdAt: { type: Date, default: Date.now },
      },
    ],
  },
  { timestamps: true }
);

communityPostSchema.index({ postType: 1, createdAt: -1 });
communityPostSchema.index({ userId: 1 });

export const CommunityPost = mongoose.model<ICommunityPost>('CommunityPost', communityPostSchema, 'community_posts');
