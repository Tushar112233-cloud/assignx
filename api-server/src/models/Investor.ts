import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IInvestor extends Document {
  name: string;
  firm: string;
  avatarUrl?: string;
  bio: string;
  fundingStages: string[];
  sectors: string[];
  ticketSize?: { min: number; max: number; currency: string };
  dealCount: number;
  linkedinUrl?: string;
  websiteUrl?: string;
  contactEmail?: string;
  isActive: boolean;
  addedBy: Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const investorSchema = new Schema<IInvestor>(
  {
    name: { type: String, required: true },
    firm: { type: String, required: true },
    avatarUrl: { type: String },
    bio: { type: String, required: true },
    fundingStages: {
      type: [String],
      required: true,
      validate: {
        validator: (v: string[]) => v.length > 0,
        message: 'At least one funding stage is required',
      },
    },
    sectors: {
      type: [String],
      required: true,
      validate: {
        validator: (v: string[]) => v.length > 0,
        message: 'At least one sector is required',
      },
    },
    ticketSize: {
      type: {
        min: { type: Number, required: true },
        max: { type: Number, required: true },
        currency: { type: String, default: 'USD' },
      },
      required: false,
    },
    dealCount: { type: Number, default: 0 },
    linkedinUrl: { type: String },
    websiteUrl: { type: String },
    contactEmail: { type: String },
    isActive: { type: Boolean, default: true },
    addedBy: { type: Schema.Types.ObjectId, ref: 'Admin', required: true },
  },
  { timestamps: true }
);

investorSchema.index({ isActive: 1 });
investorSchema.index({ fundingStages: 1 });
investorSchema.index({ sectors: 1 });
investorSchema.index({ name: 'text', firm: 'text', bio: 'text' });

export const Investor = mongoose.model<IInvestor>('Investor', investorSchema, 'investors');
