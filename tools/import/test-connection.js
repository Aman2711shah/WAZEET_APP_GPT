const admin = require('firebase-admin');

admin.initializeApp({
    credential: admin.credential.cert(require('./serviceAccountKey.json')),
    databaseURL: 'https://business-setup-application.firebaseio.com'
});

const db = admin.firestore();

async function test() {
    try {
        console.log('Testing Firestore connection...');
        const testRef = db.collection('_test').doc('test');
        await testRef.set({ timestamp: new Date().toISOString(), test: true });
        console.log('✅ Connection successful!');
        const doc = await testRef.get();
        console.log('✅ Read successful:', doc.data());
        await testRef.delete();
        console.log('✅ Delete successful!');
        process.exit(0);
    } catch (e) {
        console.error('❌ Connection failed:', e.message);
        console.error('Full error:', e);
        process.exit(1);
    }
}

test();
