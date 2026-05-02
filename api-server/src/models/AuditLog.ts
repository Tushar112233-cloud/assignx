import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IAuditLog extends Document {
  actorId: Types.ObjectId;
  actorRole: 'user' | 'doer' | 'supervisor' | 'admin';
  action: string;
  resource: string;
  resourceId: Types.ObjectId;
  details: Record<string, unknown>;
  ipAddress: string;
  createdAt: Date;
}

const auditLogSchema = new Schema<IAuditLog>({
  actorId: { type: Schema.Types.ObjectId },
  actorRole: { type: String, enum: ['user', 'doer', 'supervisor', 'admin'] },
  action: { type: String, required: true },
  resource: { type: String, required: true },
  resourceId: { type: Schema.Types.ObjectId },
  details: { type: Schema.Types.Mixed, default: {} },
  ipAddress: { type: String },
  createdAt: { type: Date, default: Date.now },
});

auditLogSchema.index({ createdAt: -1 });
auditLogSchema.index({ actorId: 1 });

export const AuditLog = mongoose.model<IAuditLog>('AuditLog', auditLogSchema, 'audit_logs');
