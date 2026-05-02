import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IJob extends Document {
  title: string;
  company: string;
  companyLogo?: string;
  location: string;
  type: 'full-time' | 'part-time' | 'contract' | 'internship' | 'freelance';
  category: string;
  isRemote: boolean;
  salary?: { min: number; max: number; currency: string };
  description: string;
  requirements: string[];
  skills: string[];
  applyUrl?: string;
  postedBy: Types.ObjectId;
  isActive: boolean;
  applicationCount: number;
  createdAt: Date;
  updatedAt: Date;
}

const jobSchema = new Schema<IJob>(
  {
    title: { type: String, required: true },
    company: { type: String, required: true },
    companyLogo: { type: String },
    location: { type: String, required: true },
    type: {
      type: String,
      enum: ['full-time', 'part-time', 'contract', 'internship', 'freelance'],
      required: true,
    },
    category: { type: String, required: true },
    isRemote: { type: Boolean, default: false },
    salary: {
      type: {
        min: { type: Number },
        max: { type: Number },
        currency: { type: String, default: 'INR' },
      },
      default: undefined,
    },
    description: { type: String, required: true },
    requirements: { type: [String], default: [] },
    skills: { type: [String], default: [] },
    applyUrl: { type: String },
    postedBy: { type: Schema.Types.ObjectId, ref: 'Admin', required: true },
    isActive: { type: Boolean, default: true },
    applicationCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

jobSchema.index({ category: 1 });
jobSchema.index({ type: 1 });
jobSchema.index({ isActive: 1 });
jobSchema.index({ isRemote: 1 });
jobSchema.index({ title: 'text', company: 'text', description: 'text' });

export const Job = mongoose.model<IJob>('Job', jobSchema, 'jobs');
