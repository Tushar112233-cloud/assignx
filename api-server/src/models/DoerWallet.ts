import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IDoerWallet extends Document {
  doerId: Types.ObjectId;
  balance: number;
  currency: string;
  totalCredited: number;
  totalDebited: number;
  totalWithdrawn: number;
  lockedAmount: number;
  createdAt: Date;
  updatedAt: Date;
}

const doerWalletSchema = new Schema<IDoerWallet>(
  {
    doerId: { type: Schema.Types.ObjectId, ref: 'Doer', required: true, unique: true },
    balance: { type: Number, default: 0 },
    currency: { type: String, default: 'INR' },
    totalCredited: { type: Number, default: 0 },
    totalDebited: { type: Number, default: 0 },
    totalWithdrawn: { type: Number, default: 0 },
    lockedAmount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

export const DoerWallet = mongoose.model<IDoerWallet>('DoerWallet', doerWalletSchema, 'doer_wallets');
