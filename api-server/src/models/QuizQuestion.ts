import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IQuizQuestion extends Document {
  moduleId: Types.ObjectId;
  question: string;
  options: string[];
  correctAnswer: number;
  explanation: string;
  order: number;
  isActive: boolean;
  createdAt: Date;
}

const quizQuestionSchema = new Schema<IQuizQuestion>({
  moduleId: { type: Schema.Types.ObjectId, ref: 'TrainingModule', required: true },
  question: { type: String, required: true },
  options: [String],
  correctAnswer: { type: Number, required: true },
  explanation: { type: String },
  order: { type: Number, default: 0 },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

export const QuizQuestion = mongoose.model<IQuizQuestion>('QuizQuestion', quizQuestionSchema, 'quiz_questions');
