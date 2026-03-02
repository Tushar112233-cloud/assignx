import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IAuditLog extends Document {
  userId: Types.ObjectId;
  action: string;
  resource: string;
  resourceId: Types.ObjectId;
  details: Record<string, unknown>;
  ipAddress: string;
  createdAt: Date;
}

const auditLogSchema = new Schema<IAuditLog>({
  userId: { type: Schema.Types.ObjectId, ref: 'Profile' },
  action: { type: String, required: true },
  resource: { type: String, required: true },
  resourceId: { type: Schema.Types.ObjectId },
  details: { type: Schema.Types.Mixed, default: {} },
  ipAddress: { type: String },
  createdAt: { type: Date, default: Date.now },
});

auditLogSchema.index({ createdAt: -1 });
auditLogSchema.index({ userId: 1 });

export const AuditLog = mongoose.model<IAuditLog>('AuditLog', auditLogSchema, 'audit_logs');
