import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IMarketplaceListing extends Document {
  userId: Types.ObjectId;
  categoryId: Types.ObjectId;
  title: string;
  description: string;
  price: number;
  imageUrl: string;
  images: string[];
  condition: string;
  location: string;
  status: 'active' | 'sold' | 'expired' | 'removed';
  viewCount: number;
  favoriteCount: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const marketplaceListingSchema = new Schema<IMarketplaceListing>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true },
    categoryId: { type: Schema.Types.ObjectId, ref: 'MarketplaceCategory' },
    title: { type: String, required: true },
    description: { type: String },
    price: { type: Number, default: 0 },
    imageUrl: { type: String },
    images: [String],
    condition: { type: String },
    location: { type: String },
    status: { type: String, enum: ['active', 'sold', 'expired', 'removed'], default: 'active' },
    viewCount: { type: Number, default: 0 },
    favoriteCount: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

marketplaceListingSchema.index({ status: 1, createdAt: -1 });
marketplaceListingSchema.index({ userId: 1 });

export const MarketplaceListing = mongoose.model<IMarketplaceListing>('MarketplaceListing', marketplaceListingSchema, 'marketplace_listings');
