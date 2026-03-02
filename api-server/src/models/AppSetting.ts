import mongoose, { Schema, Document } from 'mongoose';

export interface IAppSetting extends Document {
  key: string;
  value: unknown;
  description: string;
  category: string;
  createdAt: Date;
  updatedAt: Date;
}

const appSettingSchema = new Schema<IAppSetting>(
  {
    key: { type: String, required: true, unique: true },
    value: { type: Schema.Types.Mixed },
    description: { type: String },
    category: { type: String, default: 'general' },
  },
  { timestamps: true }
);

export const AppSetting = mongoose.model<IAppSetting>('AppSetting', appSettingSchema, 'app_settings');
