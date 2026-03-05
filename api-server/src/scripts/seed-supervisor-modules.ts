import mongoose from 'mongoose';
import { TrainingModule } from '../models';
import dotenv from 'dotenv';
dotenv.config();

const SUPERVISOR_MODULES = [
  {
    title: 'Platform Overview',
    description:
      'Learn how the AssignX platform works, your role as a supervisor, and how projects flow from submission to completion.',
    category: 'orientation',
    targetRole: 'supervisor',
    order: 1,
    duration: 10,
    isActive: true,
  },
  {
    title: 'Quality Review Guidelines',
    description:
      'Understand the quality standards expected for every project. Learn how to evaluate deliverables, provide constructive feedback, and ensure consistency.',
    category: 'training',
    targetRole: 'supervisor',
    order: 2,
    duration: 15,
    isActive: true,
  },
  {
    title: 'Communication & Ethics',
    description:
      'Best practices for communicating with doers and clients. Ethical guidelines, confidentiality requirements, and conflict resolution.',
    category: 'training',
    targetRole: 'supervisor',
    order: 3,
    duration: 10,
    isActive: true,
  },
];

async function seed() {
  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/AssignX';
  await mongoose.connect(uri);
  console.log('Connected to MongoDB');

  for (const mod of SUPERVISOR_MODULES) {
    const existing = await TrainingModule.findOne({
      title: mod.title,
      targetRole: 'supervisor',
    });
    if (!existing) {
      await TrainingModule.create(mod);
      console.log(`Created: ${mod.title}`);
    } else {
      console.log(`Exists: ${mod.title}`);
    }
  }

  await mongoose.disconnect();
  console.log('Done');
}

seed().catch(console.error);
