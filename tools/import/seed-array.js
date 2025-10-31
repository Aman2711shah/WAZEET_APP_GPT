const admin = require('firebase-admin');
const fs = require('fs');

// ==== EDIT THESE TWO LINES ONLY ====
const SOURCE_FILE = './excel-to-json-4.json';   // your JSON file
const COLLECTION = 'freezone_packages';        // Firestore collection name
// ===================================

admin.initializeApp({
    credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

const db = admin.firestore();

function slugify(str) {
    return String(str)
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)+/g, '')
        .slice(0, 200);
}

function loadRows(path) {
    const raw = fs.readFileSync(path, 'utf8');
    const json = JSON.parse(raw);
    if (!Array.isArray(json)) {
        throw new Error('JSON top-level must be an array of objects.');
    }
    return json;
}

async function importArray(collectionName, rows) {
    console.log(`Importing ${rows.length} records into "${collectionName}"...`);
    const chunkSize = 450; // batch limit under 500
    for (let i = 0; i < rows.length; i += chunkSize) {
        const chunk = rows.slice(i, i + chunkSize);
        const batch = db.batch();
        chunk.forEach((row) => {
            const idSource =
                row['Freezone'] ||
                row['Package Name'] ||
                row['Tenure (Years)'] ||
                'doc';
            const docId = slugify(`${idSource}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`);
            batch.set(db.collection(collectionName).doc(docId), row, { merge: true });
        });
        await batch.commit();
        console.log(`✔ Imported ${Math.min(i + chunk.length, rows.length)}/${rows.length}`);
    }
    console.log('🎉 All done!');
}

(async () => {
    try {
        const rows = loadRows(SOURCE_FILE);
        await importArray(COLLECTION, rows);
        process.exit(0);
    } catch (e) {
        console.error('❌ Import failed:', e);
        process.exit(1);
    }
})();