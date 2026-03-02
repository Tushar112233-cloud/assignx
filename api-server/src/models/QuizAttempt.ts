import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IQuizAttempt extends Document {
  userId: Types.ObjectId;
  moduleId: Types.ObjectId;
  answers: { questionId: Types.ObjectId; selectedAnswer: number; isCorrect: boolean }[];
  score: number;
  totalQuestions: number;
  passed: boolean;
  createdAt: Date;
}

const quizAttemptSchema = new Schema<IQuizAttempt>({
  userId: { type: Schema.Types.ObjectId, ref: 'Profile', required: true },
  moduleId: { type: Schema.Types.ObjectId, ref: 'TrainingModule', required: true },
  answers: [
    {
      questionId: { type: Schema.Types.ObjectId, ref: 'QuizQuestion' },
      selectedAnswer: Number,
      isCorrect: Boolean,
    },
  ],
  score: { type: Number, default: 0 },
  totalQuestions: { type: Number, default: 0 },
  passed: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

quizAttemptSchema.index({ userId: 1, moduleId: 1 });

export const QuizAttempt = mongoose.model<IQuizAttempt>('QuizAttempt', quizAttemptSchema, 'quiz_attempts');
