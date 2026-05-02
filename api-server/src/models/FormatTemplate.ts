import mongoose, { Schema, Document } from 'mongoose';

export interface IFormatTemplate extends Document {
  name: string;
  description: string;
  templateUrl: string;
  category: string;
  isActive: boolean;
  createdAt: Date;
}

const formatTemplateSchema = new Schema<IFormatTemplate>({
  name: { type: String, required: true },
  description: { type: String },
  templateUrl: { type: String },
  category: { type: String },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

export const FormatTemplate = mongoose.model<IFormatTemplate>('FormatTemplate', formatTemplateSchema, 'format_templates');
