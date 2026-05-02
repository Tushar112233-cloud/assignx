import mongoose, { Schema, Document, Types } from 'mongoose';

export interface ISupervisorWallet extends Document {
  supervisorId: Types.ObjectId;
  balance: number;
  currency: string;
  totalCredited: number;
  totalDebited: number;
  totalWithdrawn: number;
  lockedAmount: number;
  createdAt: Date;
  updatedAt: Date;
}

const supervisorWalletSchema = new Schema<ISupervisorWallet>(
  {
    supervisorId: { type: Schema.Types.ObjectId, ref: 'Supervisor', required: true, unique: true },
    balance: { type: Number, default: 0 },
    currency: { type: String, default: 'INR' },
    totalCredited: { type: Number, default: 0 },
    totalDebited: { type: Number, default: 0 },
    totalWithdrawn: { type: Number, default: 0 },
    lockedAmount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

export const SupervisorWallet = mongoose.model<ISupervisorWallet>('SupervisorWallet', supervisorWalletSchema, 'supervisor_wallets');
