import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IJobApplication extends Document {
  jobId: Types.ObjectId;
  userId: Types.ObjectId;
  resumeUrl: string;
  coverLetter?: string;
  status: 'applied' | 'reviewing' | 'shortlisted' | 'rejected';
  createdAt: Date;
  updatedAt: Date;
}

const jobApplicationSchema = new Schema<IJobApplication>(
  {
    jobId: { type: Schema.Types.ObjectId, ref: 'Job', required: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    resumeUrl: { type: String, required: true },
    coverLetter: { type: String },
    status: {
      type: String,
      enum: ['applied', 'reviewing', 'shortlisted', 'rejected'],
      default: 'applied',
    },
  },
  { timestamps: true }
);

jobApplicationSchema.index({ jobId: 1, userId: 1 }, { unique: true });
jobApplicationSchema.index({ userId: 1 });
jobApplicationSchema.index({ status: 1 });

export const JobApplication = mongoose.model<IJobApplication>(
  'JobApplication',
  jobApplicationSchema,
  'jobApplications'
);
