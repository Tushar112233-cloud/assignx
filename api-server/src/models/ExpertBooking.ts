import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IExpertBooking extends Document {
  expertId: Types.ObjectId;
  userId: Types.ObjectId;
  date: Date;
  timeSlot: string;
  startTime: string;
  endTime: string;
  duration: number;
  topic: string;
  notes: string;
  meetLink: string;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  amount: number;
  platformFee: number;
  paymentId: string;
  paymentStatus: 'pending' | 'completed' | 'refunded' | 'failed';
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
    startTime: { type: String },
    endTime: { type: String },
    duration: { type: Number, default: 60 },
    topic: { type: String },
    notes: { type: String },
    meetLink: { type: String },
    status: { type: String, enum: ['pending', 'confirmed', 'completed', 'cancelled'], default: 'pending' },
    amount: { type: Number, default: 0 },
    platformFee: { type: Number, default: 0 },
    paymentId: { type: String },
    paymentStatus: { type: String, enum: ['pending', 'completed', 'refunded', 'failed'], default: 'pending' },
    rating: { type: Number },
    review: { type: String },
  },
  { timestamps: true }
);

expertBookingSchema.index({ userId: 1 });
expertBookingSchema.index({ expertId: 1 });
expertBookingSchema.index({ expertId: 1, date: 1, startTime: 1 });

export const ExpertBooking = mongoose.model<IExpertBooking>('ExpertBooking', expertBookingSchema, 'expert_bookings');
