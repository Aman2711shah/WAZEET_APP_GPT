const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./functions/serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const sampleEvents = [
    {
        eventName: "Dubai Startup Networking Mixer",
        date: "2025-11-05",
        time: "18:00",
        location: {
            venue: "DIFC Innovation Hub",
            address: "Gate Village, Dubai International Financial Centre"
        },
        category: "Networking",
        sourceURL: "https://www.eventbrite.ae/sample-event-1",
        description: "Join fellow entrepreneurs and startup founders for an evening of networking, insights, and collaboration in the heart of Dubai's financial district.",
        attendees: 45,
        discoveredAt: admin.firestore.FieldValue.serverTimestamp(),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    },
    {
        eventName: "Digital Marketing Workshop for SMEs",
        date: "2025-11-08",
        time: "14:00",
        location: {
            venue: "Dubai Internet City",
            address: "Building 10, Dubai Internet City"
        },
        category: "Workshop",
        sourceURL: "https://www.meetup.com/sample-event-2",
        description: "Learn the latest digital marketing strategies tailored for small and medium enterprises in the UAE market.",
        attendees: 32,
        discoveredAt: admin.firestore.FieldValue.serverTimestamp(),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    },
    {
        eventName: "UAE Business Conference 2025",
        date: "2025-11-12",
        time: "09:00",
        location: {
            venue: "Dubai World Trade Centre",
            address: "Sheikh Zayed Road, Dubai"
        },
        category: "Conference",
        sourceURL: "https://www.lovin.co/sample-event-3",
        description: "The premier business conference bringing together industry leaders, investors, and innovators from across the UAE and GCC region.",
        attendees: 250,
        discoveredAt: admin.firestore.FieldValue.serverTimestamp(),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    },
    {
        eventName: "AI & Innovation Pitch Competition",
        date: "2025-11-15",
        time: "10:00",
        location: {
            venue: "Area 2071",
            address: "Emirates Towers, Sheikh Zayed Road"
        },
        category: "Competition",
        sourceURL: "https://www.eventbrite.ae/sample-event-4",
        description: "Pitch your AI-powered startup to a panel of leading investors and win funding, mentorship, and exposure.",
        attendees: 120,
        discoveredAt: admin.firestore.FieldValue.serverTimestamp(),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    },
    {
        eventName: "Free Zone Setup Masterclass",
        date: "2025-11-10",
        time: "16:00",
        location: {
            venue: "Virtual Event",
            address: null
        },
        category: "Workshop",
        sourceURL: "https://www.meetup.com/sample-event-5",
        description: "Everything you need to know about setting up your business in a UAE free zone. Expert advice on licenses, visas, and costs.",
        attendees: 89,
        discoveredAt: admin.firestore.FieldValue.serverTimestamp(),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    }
];

async function addSampleEvents() {
    try {
        console.log('Adding sample events to Firestore...');

        const batch = db.batch();

        sampleEvents.forEach((event, index) => {
            const docRef = db.collection('discoveredEvents').doc(`sample-event-${index + 1}`);
            batch.set(docRef, event);
        });

        await batch.commit();

        console.log('✅ Successfully added', sampleEvents.length, 'sample events!');
        console.log('Events should now appear in your app.');
        process.exit(0);
    } catch (error) {
        console.error('❌ Error adding events:', error);
        process.exit(1);
    }
}

addSampleEvents();
