import mongoose, { Schema, Document } from 'mongoose';

export interface IReferenceStyle extends Document {
  name: string;
  description: string;
  isActive: boolean;
  createdAt: Date;
}

const referenceStyleSchema = new Schema<IReferenceStyle>({
  name: { type: String, required: true },
  description: { type: String },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

export const ReferenceStyle = mongoose.model<IReferenceStyle>('ReferenceStyle', referenceStyleSchema, 'reference_styles');
