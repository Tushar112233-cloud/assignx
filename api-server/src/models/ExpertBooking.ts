import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IExpertBooking extends Document {
  expertId: Types.ObjectId;
  userId: Types.ObjectId;
  date: Date;
  timeSlot: string;
  duration: number;
  topic: string;
  notes: string;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  amount: number;
  paymentId: string;
  rating: number;
  review: string;
  createdAt: Date;
  updatedAt: Date;
}

const expertBookingSchema = new Schema<IExpertBooking>(
  {
    expertId: { type: Schema.Types.ObjectId, ref: 'Expert', required: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    date: { type: Date, required: true },
    timeSlot: { type: String },
    duration: { type: Number, default: 60 },
    topic: { type: String },
    notes: { type: String },
    status: { type: String, enum: ['pending', 'confirmed', 'completed', 'cancelled'], default: 'pending' },
    amount: { type: Number, default: 0 },
    paymentId: { type: String },
    rating: { type: Number },
    review: { type: String },
  },
  { timestamps: true }
);

expertBookingSchema.index({ userId: 1 });
expertBookingSchema.index({ expertId: 1 });

export const ExpertBooking = mongoose.model<IExpertBooking>('ExpertBooking', expertBookingSchema, 'expert_bookings');
