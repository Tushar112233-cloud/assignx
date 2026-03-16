/**
 * Seed default Turnitin pricing into AppSetting collection.
 *
 * Usage:
 *   cd api-server && npx ts-node src/scripts/seed-turnitin-pricing.ts
 *
 * This is idempotent — it uses upsert so running it multiple times is safe.
 */
import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/AssignX';

async function main() {
  await mongoose.connect(MONGO_URI);
  console.log('Connected to MongoDB');

  const result = await mongoose.connection.db!.collection('app_settings').updateOne(
    { key: 'turnitin_pricing' },
    {
      $set: {
        key: 'turnitin_pricing',
        value: {
          ai_detection: 49,
          plagiarism_check: 99,
          complete_report: 129,
          gst_percent: 18,
        },
        category: 'pricing',
        description: 'Turnitin check pricing (in INR per document)',
      },
      $setOnInsert: { createdAt: new Date() },
    },
    { upsert: true }
  );

  if (result.upsertedCount > 0) {
    console.log('Inserted default turnitin_pricing setting');
  } else {
    console.log('turnitin_pricing setting already exists (updated)');
  }

  await mongoose.disconnect();
  console.log('Done');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
