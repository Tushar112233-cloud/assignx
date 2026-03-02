import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IStudent extends Document {
  profileId: Types.ObjectId;
  universityId: Types.ObjectId;
  courseId: Types.ObjectId;
  semester: number;
  yearOfStudy: number;
  studentIdNumber: string;
  expectedGraduationYear: number;
  collegeEmail: string;
  collegeEmailVerified: boolean;
  preferredSubjects: Types.ObjectId[];
}

const studentSchema = new Schema<IStudent>(
  {
    profileId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true },
    universityId: { type: Schema.Types.ObjectId, ref: 'University' },
    courseId: { type: Schema.Types.ObjectId },
    semester: { type: Number },
    yearOfStudy: { type: Number },
    studentIdNumber: { type: String },
    expectedGraduationYear: { type: Number },
    collegeEmail: { type: String },
    collegeEmailVerified: { type: Boolean, default: false },
    preferredSubjects: [{ type: Schema.Types.ObjectId, ref: 'Subject' }],
  },
  { timestamps: true }
);

studentSchema.index({ profileId: 1 });

export const Student = mongoose.model<IStudent>('Student', studentSchema, 'students');
