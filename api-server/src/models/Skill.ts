import mongoose, { Schema, Document } from 'mongoose';

export interface ISkill extends Document {
  name: string;
  category: string;
  isActive: boolean;
  createdAt: Date;
}

const skillSchema = new Schema<ISkill>({
  name: { type: String, required: true },
  category: { type: String },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

export const Skill = mongoose.model<ISkill>('Skill', skillSchema, 'skills');
