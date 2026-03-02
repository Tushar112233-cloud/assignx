import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IWallet extends Document {
  profileId: Types.ObjectId;
  balance: number;
  currency: string;
  totalCredited: number;
  totalDebited: number;
  totalWithdrawn: number;
  lockedAmount: number;
  createdAt: Date;
  updatedAt: Date;
}

const walletSchema = new Schema<IWallet>(
  {
    profileId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true, unique: true },
    balance: { type: Number, default: 0 },
    currency: { type: String, default: 'INR' },
    totalCredited: { type: Number, default: 0 },
    totalDebited: { type: Number, default: 0 },
    totalWithdrawn: { type: Number, default: 0 },
    lockedAmount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

export const Wallet = mongoose.model<IWallet>('Wallet', walletSchema, 'wallets');
