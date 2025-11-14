#!/usr/bin/env node
/**
 * Imports curated freezone package JSON data into the `freezonePackages` collection.
 * Usage: node import_manual_freezone_packages.js
 */

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const __dirnameSafe = __dirname || process.cwd();
const serviceAccountPath = path.join(
  __dirnameSafe,
  'business-setup-application-firebase-adminsdk-fbsvc-adc9567880.json',
);
const dataPath = path.join(__dirnameSafe, 'manual_freezone_packages.json');

function ensureFile(pathToCheck, label) {
  if (!fs.existsSync(pathToCheck)) {
    console.error(`Missing ${label} at ${pathToCheck}`);
    process.exit(1);
  }
}

ensureFile(serviceAccountPath, 'service account JSON');
ensureFile(dataPath, 'data file');

const serviceAccount = require(serviceAccountPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const firestore = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const packages = JSON.parse(fs.readFileSync(dataPath, 'utf8'));

if (!Array.isArray(packages) || packages.length === 0) {
  console.error('The data file does not contain any packages. Nothing to import.');
  process.exit(1);
}

const collectionRef = firestore.collection('freezonePackages');
const timestampIso = new Date().toISOString();

function slugify(value) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .replace(/_+/g, '_');
}

function buildDocId(pkg) {
  const base = `${pkg.freezone || 'UNKNOWN'}_${slugify(pkg.product || 'package')}`;
  return base.toUpperCase();
}

async function run() {
  console.log(`Importing ${packages.length} package documents...`);
  let batch = firestore.batch();
  let opsInBatch = 0;
  let totalWritten = 0;

  for (const pkg of packages) {
    const docId = buildDocId(pkg);
    const docRef = collectionRef.doc(docId);
    const payload = {
      ...pkg,
      isActive: true,
      imported_at: timestampIso,
      updatedAt: FieldValue.serverTimestamp(),
    };

    batch.set(docRef, payload, { merge: true });
    opsInBatch += 1;
    totalWritten += 1;

    if (opsInBatch === 400) {
      await batch.commit();
      console.log(`Committed ${totalWritten} documents so far...`);
      batch = firestore.batch();
      opsInBatch = 0;
    }
  }

  if (opsInBatch > 0) {
    await batch.commit();
  }

  console.log(`✅ Successfully imported/updated ${totalWritten} documents.`);
  process.exit(0);
}

run().catch((err) => {
  console.error('Import failed:', err);
  process.exit(1);
});
