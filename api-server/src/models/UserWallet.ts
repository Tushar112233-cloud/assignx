import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IUserWallet extends Document {
  userId: Types.ObjectId;
  balance: number;
  currency: string;
  totalCredited: number;
  totalDebited: number;
  totalWithdrawn: number;
  lockedAmount: number;
  createdAt: Date;
  updatedAt: Date;
}

const userWalletSchema = new Schema<IUserWallet>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    balance: { type: Number, default: 0 },
    currency: { type: String, default: 'INR' },
    totalCredited: { type: Number, default: 0 },
    totalDebited: { type: Number, default: 0 },
    totalWithdrawn: { type: Number, default: 0 },
    lockedAmount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

export const UserWallet = mongoose.model<IUserWallet>('UserWallet', userWalletSchema, 'user_wallets');
