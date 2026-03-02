import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IProject extends Document {
  projectNumber: string;
  userId: Types.ObjectId;
  serviceType: string;
  title: string;
  subjectId: Types.ObjectId | string;
  topic: string;
  description: string;
  wordCount: number;
  pageCount: number;
  referenceStyleId: Types.ObjectId | string;
  specificInstructions: string;
  focusAreas: string[];
  deadline: Date;
  originalDeadline: Date;
  deadlineExtended: boolean;
  status: string;
  statusUpdatedAt: Date;
  supervisorId: Types.ObjectId;
  doerId: Types.ObjectId;
  pricing: {
    userQuote: number;
    finalQuote: number;
    doerPayout: number;
    supervisorCommission: number;
    platformFee: number;
    urgencyFee: number;
    complexityFee: number;
  };
  payment: {
    isPaid: boolean;
    paidAt: Date;
    paymentId: string;
  };
  delivery: {
    deliveredAt: Date;
    expectedDeliveryAt: Date;
    autoApproveAt: Date;
    completedAt: Date;
    completionNotes: string;
  };
  qualityCheck: {
    aiReportUrl: string;
    aiScore: number;
    plagiarismReportUrl: string;
    plagiarismScore: number;
    liveDocumentUrl: string;
  };
  progressPercentage: number;
  userApproval: {
    approved: boolean;
    approvedAt: Date;
    feedback: string;
    grade: string;
  };
  cancellation: {
    cancelledAt: Date;
    cancelledBy: Types.ObjectId;
    reason: string;
  };
  files: {
    fileName: string;
    fileUrl: string;
    fileType: string;
    fileSizeBytes: number;
    fileCategory: string;
    uploadedBy: Types.ObjectId;
    createdAt: Date;
  }[];
  deliverables: {
    fileName: string;
    fileUrl: string;
    fileType: string;
    fileSizeBytes: number;
    version: number;
    qcStatus: 'pending' | 'in_review' | 'approved' | 'rejected';
    qcNotes: string;
    qcAt: Date;
    qcBy: Types.ObjectId;
    uploadedBy: Types.ObjectId;
    createdAt: Date;
  }[];
  revisions: {
    requestedBy: Types.ObjectId;
    requestedByType: string;
    revisionNumber: number;
    feedback: string;
    specificChanges: string;
    responseNotes: string;
    status: 'pending' | 'in_progress' | 'completed' | 'cancelled';
    createdAt: Date;
    completedAt: Date;
  }[];
  statusHistory: {
    fromStatus: string;
    toStatus: string;
    changedBy: Types.ObjectId;
    notes: string;
    createdAt: Date;
  }[];
  liveDocumentUrl: string;
  cancelledAt: Date;
  doerAssignedAt: Date;
  source: string;
  createdAt: Date;
  updatedAt: Date;
}

const projectSchema = new Schema<IProject>(
  {
    projectNumber: { type: String },
    userId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true },
    serviceType: { type: String },
    title: { type: String, required: true },
    subjectId: { type: Schema.Types.Mixed },
    topic: { type: String },
    description: { type: String },
    wordCount: { type: Number },
    pageCount: { type: Number },
    referenceStyleId: { type: Schema.Types.Mixed },
    specificInstructions: { type: String },
    focusAreas: [String],
    deadline: { type: Date },
    originalDeadline: { type: Date },
    deadlineExtended: { type: Boolean, default: false },
    status: { type: String, default: 'draft' },
    statusUpdatedAt: { type: Date },
    supervisorId: { type: Schema.Types.ObjectId, ref: 'Profile' },
    doerId: { type: Schema.Types.ObjectId, ref: 'Profile' },
    pricing: {
      userQuote: { type: Number, default: 0 },
      finalQuote: { type: Number, default: 0 },
      doerPayout: { type: Number, default: 0 },
      supervisorCommission: { type: Number, default: 0 },
      platformFee: { type: Number, default: 0 },
      urgencyFee: { type: Number, default: 0 },
      complexityFee: { type: Number, default: 0 },
    },
    payment: {
      isPaid: { type: Boolean, default: false },
      paidAt: { type: Date },
      paymentId: { type: String },
    },
    delivery: {
      deliveredAt: { type: Date },
      expectedDeliveryAt: { type: Date },
      autoApproveAt: { type: Date },
      completedAt: { type: Date },
      completionNotes: { type: String },
    },
    qualityCheck: {
      aiReportUrl: { type: String },
      aiScore: { type: Number },
      plagiarismReportUrl: { type: String },
      plagiarismScore: { type: Number },
      liveDocumentUrl: { type: String },
    },
    progressPercentage: { type: Number, default: 0 },
    userApproval: {
      approved: { type: Boolean, default: false },
      approvedAt: { type: Date },
      feedback: { type: String },
      grade: { type: String },
    },
    cancellation: {
      cancelledAt: { type: Date },
      cancelledBy: { type: Schema.Types.ObjectId },
      reason: { type: String },
    },
    files: [
      {
        fileName: String,
        fileUrl: String,
        fileType: String,
        fileSizeBytes: Number,
        fileCategory: String,
        uploadedBy: { type: Schema.Types.ObjectId, ref: 'Profile' },
        createdAt: { type: Date, default: Date.now },
      },
    ],
    deliverables: [
      {
        fileName: String,
        fileUrl: String,
        fileType: String,
        fileSizeBytes: Number,
        version: { type: Number, default: 1 },
        qcStatus: { type: String, enum: ['pending', 'in_review', 'approved', 'rejected'], default: 'pending' },
        qcNotes: String,
        qcAt: Date,
        qcBy: { type: Schema.Types.ObjectId, ref: 'Profile' },
        uploadedBy: { type: Schema.Types.ObjectId, ref: 'Profile' },
        createdAt: { type: Date, default: Date.now },
      },
    ],
    revisions: [
      {
        requestedBy: { type: Schema.Types.ObjectId, ref: 'Profile' },
        requestedByType: String,
        revisionNumber: Number,
        feedback: String,
        specificChanges: String,
        responseNotes: String,
        status: { type: String, enum: ['pending', 'in_progress', 'completed', 'cancelled'], default: 'pending' },
        createdAt: { type: Date, default: Date.now },
        completedAt: Date,
      },
    ],
    statusHistory: [
      {
        fromStatus: String,
        toStatus: String,
        changedBy: { type: Schema.Types.ObjectId, ref: 'Profile' },
        notes: String,
        createdAt: { type: Date, default: Date.now },
      },
    ],
    liveDocumentUrl: { type: String },
    cancelledAt: { type: Date },
    doerAssignedAt: { type: Date },
    source: { type: String },
  },
  { timestamps: true }
);

projectSchema.index({ userId: 1, status: 1 });
projectSchema.index({ doerId: 1, status: 1 });
projectSchema.index({ supervisorId: 1, status: 1 });
projectSchema.index({ deadline: 1 });
projectSchema.index({ createdAt: -1 });

export const Project = mongoose.model<IProject>('Project', projectSchema, 'projects');
