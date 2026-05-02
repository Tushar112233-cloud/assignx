import mongoose, { Schema, Document, Types } from 'mongoose';

export interface ICollege extends Document {
  name: string;
  universityId: Types.ObjectId;
  location: string;
  isActive: boolean;
  createdAt: Date;
}

const collegeSchema = new Schema<ICollege>({
  name: { type: String, required: true },
  universityId: { type: Schema.Types.ObjectId, ref: 'University' },
  location: { type: String },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

export const College = mongoose.model<ICollege>('College', collegeSchema, 'colleges');
