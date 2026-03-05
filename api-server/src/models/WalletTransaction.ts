import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IWalletTransaction extends Document {
  walletId: Types.ObjectId;
  walletType: 'user' | 'doer' | 'supervisor';
  transactionType: string;
  amount: number;
  status: 'pending' | 'completed' | 'failed' | 'reversed';
  description: string;
  referenceId: string;
  referenceType: string;
  balanceBefore: number;
  balanceAfter: number;
  createdAt: Date;
}

const walletTransactionSchema = new Schema<IWalletTransaction>({
  walletId: { type: Schema.Types.ObjectId, ref: 'Wallet', required: true },
  walletType: { type: String, enum: ['user', 'doer', 'supervisor'], required: true },
  transactionType: { type: String, required: true },
  amount: { type: Number, required: true },
  status: { type: String, enum: ['pending', 'completed', 'failed', 'reversed'], default: 'pending' },
  description: { type: String, default: '' },
  referenceId: { type: String },
  referenceType: { type: String },
  balanceBefore: { type: Number, default: 0 },
  balanceAfter: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
});

walletTransactionSchema.index({ walletId: 1, createdAt: -1 });

export const WalletTransaction = mongoose.model<IWalletTransaction>('WalletTransaction', walletTransactionSchema, 'wallet_transactions');
