/**
 * One-time migration script to:
 * 1. Add slugs to existing subjects that don't have them
 * 2. Migrate projects with string subjectId to ObjectId references
 *
 * Run: npx ts-node-dev src/scripts/migrate-subjects.ts
 */
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

import { Subject } from '../models/Subject';
import { Project } from '../models/Project';

const MONGODB_URI = process.env.MONGODB_URI || '';

// Mapping: old string IDs / names → canonical slugs
const SLUG_MAP: Record<string, string> = {
  // user-web string IDs
  'engineering': 'engineering',
  'business': 'business',
  'medicine': 'medicine',
  'law': 'law',
  'science': 'biology',
  'mathematics': 'mathematics',
  'humanities': 'literature',
  'social-sciences': 'sociology',
  'arts': 'arts',
  'other': 'other',
  // user_app enum names (normalized lowercase no spaces)
  'computerscience': 'computer-science',
  'datascience': 'data-science',
  'nursing': 'nursing',
  'history': 'history',
  'sociology': 'sociology',
  'chemistry': 'chemistry',
  'physics': 'physics',
  'psychology': 'psychology',
  'literature': 'literature',
  'economics': 'economics',
  'finance': 'finance',
  'marketing': 'marketing',
  'biology': 'biology',
  // Old seed names (normalized)
  'mechanicalengineering': 'engineering',
  'businessmanagement': 'business',
  'englishliterature': 'literature',
  'computersience': 'computer-science',
};

async function migrate() {
  console.log('Connecting to MongoDB...');
  await mongoose.connect(MONGODB_URI);
  console.log('Connected.\n');

  // Step 1: Add slugs to existing subjects that don't have them
  console.log('--- Step 1: Ensuring all subjects have slugs ---');
  const existingSubjects = await Subject.find({});
  for (const sub of existingSubjects) {
    if (!(sub as any).slug) {
      const normalized = sub.name.toLowerCase().replace(/\s+/g, '');
      const slug = SLUG_MAP[normalized] || sub.name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
      await Subject.updateOne({ _id: sub._id }, { $set: { slug } });
      console.log(`  Added slug "${slug}" to subject "${sub.name}"`);
    }
  }

  // Step 2: Build slug → ObjectId map
  const allSubjects = await Subject.find({});
  const slugToId: Record<string, mongoose.Types.ObjectId> = {};
  for (const s of allSubjects) {
    slugToId[(s as any).slug] = s._id as mongoose.Types.ObjectId;
  }
  console.log(`\nLoaded ${Object.keys(slugToId).length} subjects.\n`);

  // Step 3: Migrate projects with string subjectId
  console.log('--- Step 2: Migrating project subjectId strings to ObjectIds ---');
  const projects = await Project.find({});
  let migratedCount = 0;
  let skippedCount = 0;
  let alreadyOk = 0;

  for (const p of projects) {
    const sid = p.subjectId;

    // Already an ObjectId or null — skip
    if (!sid) { skippedCount++; continue; }
    if (typeof sid !== 'string') { alreadyOk++; continue; }
    if (/^[0-9a-fA-F]{24}$/.test(sid)) { alreadyOk++; continue; }

    // Normalize and look up
    const normalized = sid.toLowerCase().replace(/[\s_-]+/g, '');
    const slug = SLUG_MAP[normalized] || SLUG_MAP[sid] || sid;
    const objectId = slugToId[slug];

    if (objectId) {
      await Project.updateOne({ _id: p._id }, { $set: { subjectId: objectId } });
      migratedCount++;
      console.log(`  Migrated project ${p._id}: "${sid}" → ObjectId(${objectId})`);
    } else {
      console.warn(`  ⚠ No match for project ${p._id} subjectId: "${sid}"`);
    }
  }

  console.log(`\nDone. Migrated: ${migratedCount}, Already OK: ${alreadyOk}, Skipped (null): ${skippedCount}`);
  await mongoose.disconnect();
}

migrate().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
