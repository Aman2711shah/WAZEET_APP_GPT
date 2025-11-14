// Import Freezone Packages to Firestore
// This script uploads IFZA, MEYDAN, RAKEZ, and SHAMS package data to Firestore

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadPackages() {
    const collection = db.collection('freezonePackages');

    // Combined data from all freezones
    const allPackages = [...ifzaData, ...meydanData, ...rakezData, ...shamsData];

    console.log(`Starting upload of ${allPackages.length} packages...`);

    let successCount = 0;
    let errorCount = 0;

    for (const packageData of allPackages) {
        try {
            await collection.add(packageData);
            successCount++;
            console.log(`✓ Added: ${packageData.freezone} - ${packageData.product}`);
        } catch (error) {
            errorCount++;
            console.error(`✗ Error adding ${packageData.freezone} - ${packageData.product}:`, error.message);
        }
    }

    console.log(`\n=== Upload Complete ===`);
    console.log(`Success: ${successCount}`);
    console.log(`Errors: ${errorCount}`);
    console.log(`Total: ${allPackages.length}`);
}

// Run the upload
uploadPackages()
    .then(() => {
        console.log('\nAll done! Exiting...');
        process.exit(0);
    })
    .catch(error => {
        console.error('Fatal error:', error);
        process.exit(1);
    });

// Data arrays will be loaded from separate file
const ifzaData = require('./data/ifza.json');
const meydanData = require('./data/meydan.json');
const rakezData = require('./data/rakez.json');
const shamsData = require('./data/shams.json');
