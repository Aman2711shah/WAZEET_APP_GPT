const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
admin.initializeApp({
    credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

const db = admin.firestore();
const COLLECTION = 'free_zones';

function normalizeEmirate(emirate) {
    return emirate.toLowerCase().replace(/\s+/g, '_');
}

function slugify(str) {
    return str.toLowerCase()
        .replace(/[^a-z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '');
}

function parseArray(str) {
    if (!str) return [];
    if (Array.isArray(str)) return str;
    return str.split(',').map(s => s.trim()).filter(s => s);
}

async function importFreeZones() {
    try {
        console.log('Loading free zones data...');

        // Read the JSON file from assets
        const filePath = path.join(__dirname, '../../assets/docs/freezones_guide.json');
        const rawData = fs.readFileSync(filePath, 'utf8');
        const data = JSON.parse(rawData);

        const zones = data.freeZoneData || [];
        console.log(`Found ${zones.length} free zones to import`);

        const batch = db.batch();
        let count = 0;

        // Process each zone
        for (const zone of zones) {
            const name = zone['Free Zone'] || zone.name;
            const emirate = normalizeEmirate(zone['Emirate'] || zone.emirate || '');
            const abbreviation = name.match(/\(([^)]+)\)/)?.[1] || name.split(' ')[0];
            const docId = slugify(abbreviation);

            // Parse license types
            const licenseTypes = parseArray(zone['License Types'] || zone.license_types);

            // Parse activities
            const activitiesAllowed = parseArray(zone['Activities Allowed'] || '');
            const activitiesRestricted = parseArray(zone['Activities Restricted'] || '');

            // Parse key advantages
            const keyAdvantages = parseArray(zone['Key Advantages'] || zone.key_advantages);

            // Parse notable limitations
            const notableLimitations = parseArray(zone['Notable Limitations'] || zone.notable_limitations);

            // Prepare the document data
            const docData = {
                name: name,
                abbreviation: abbreviation,
                emirate: emirate,
                established: zone.established || null,
                license_types: licenseTypes,
                costs: {
                    setup: zone['Setup Cost (2025)'] || zone.setup_cost || '',
                    annual_renewal: zone['Annual Renewal'] || zone.annual_renewal || ''
                },
                visa_allocation: {
                    description: zone['Visa Allocation'] || zone.visa_allocation || ''
                },
                activities: {
                    allowed: activitiesAllowed,
                    restricted: activitiesRestricted
                },
                office_requirements: {
                    minimum: zone['Minimum Office'] || zone.minimum_office || ''
                },
                key_advantages: keyAdvantages,
                notable_limitations: notableLimitations,
                special_features: {
                    remote_setup: zone['Remote Setup Possible (Y/N)']?.toUpperCase() === 'Y',
                    fastest_setup_days: zone['Fastest Setup (Days)'] || null,
                    best_for: zone['Best For (Sector/Use Case)'] || ''
                },
                rating: zone.rating || null,
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            };

            // Add to batch
            batch.set(db.collection(COLLECTION).doc(docId), docData, { merge: true });
            count++;

            console.log(`✓ Prepared: ${name} (${abbreviation}) - ${emirate}`);
        }

        // Commit the batch
        console.log(`\nCommitting ${count} free zones to Firestore...`);
        await batch.commit();
        console.log('🎉 Successfully imported all free zones!');

        process.exit(0);
    } catch (error) {
        console.error('❌ Import failed:', error);
        console.error(error.stack);
        process.exit(1);
    }
}

// Run the import
importFreeZones();
