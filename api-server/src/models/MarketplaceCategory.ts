import mongoose, { Schema, Document } from 'mongoose';

export interface IMarketplaceCategory extends Document {
  name: string;
  icon: string;
  order: number;
  isActive: boolean;
  createdAt: Date;
}

const marketplaceCategorySchema = new Schema<IMarketplaceCategory>({
  name: { type: String, required: true },
  icon: { type: String },
  order: { type: Number, default: 0 },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

export const MarketplaceCategory = mongoose.model<IMarketplaceCategory>('MarketplaceCategory', marketplaceCategorySchema, 'marketplace_categories');
