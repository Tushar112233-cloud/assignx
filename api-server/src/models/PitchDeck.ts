import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IPitchDeck extends Document {
  userId: Types.ObjectId;
  title: string;
  description?: string;
  fileUrl: string;
  investorId?: Types.ObjectId;
  status: 'pending' | 'reviewed' | 'shortlisted' | 'rejected';
  feedback?: string;
  createdAt: Date;
  updatedAt: Date;
}

const pitchDeckSchema = new Schema<IPitchDeck>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    description: { type: String },
    fileUrl: { type: String, required: true },
    investorId: { type: Schema.Types.ObjectId, ref: 'Investor' },
    status: {
      type: String,
      enum: ['pending', 'reviewed', 'shortlisted', 'rejected'],
      default: 'pending',
    },
    feedback: { type: String },
  },
  { timestamps: true }
);

pitchDeckSchema.index({ userId: 1 });
pitchDeckSchema.index({ investorId: 1 });
pitchDeckSchema.index({ status: 1 });

export const PitchDeck = mongoose.model<IPitchDeck>('PitchDeck', pitchDeckSchema, 'pitchDecks');
