import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IProfessional extends Document {
  profileId: Types.ObjectId;
  professionalType: string;
  industryId: Types.ObjectId;
  jobTitle: string;
  companyName: string;
  linkedinUrl: string;
  businessType: string;
  gstNumber: string;
}

const professionalSchema = new Schema<IProfessional>(
  {
    profileId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true },
    professionalType: { type: String },
    industryId: { type: Schema.Types.ObjectId },
    jobTitle: { type: String },
    companyName: { type: String },
    linkedinUrl: { type: String },
    businessType: { type: String },
    gstNumber: { type: String },
  },
  { timestamps: true }
);

professionalSchema.index({ profileId: 1 });

export const Professional = mongoose.model<IProfessional>('Professional', professionalSchema, 'professionals');
