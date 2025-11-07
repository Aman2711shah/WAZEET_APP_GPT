// Script to seed freezones collection with real data
// Run with: node functions/seed_freezones_data.js

const admin = require('firebase-admin');
const serviceAccount = require('../freezone-import/business-setup-application-firebase-adminsdk-fbsvc-adc9567880.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const freezonesData = [
    {
        id: 'rakez',
        name: 'RAK Economic Zone',
        abbreviation: 'RAKEZ',
        emirate: 'ras_al_khaimah',
        established: 2000,
        license_types: ['Commercial', 'Trading', 'Service', 'Industrial', 'E-commerce'],
        costs: {
            setup: {
                basic: { amount: 6500, currency: 'AED' },
                standard: { amount: 8500, currency: 'AED' }
            }
        },
        visa_allocation: {
            basic: 1,
            standard: 2
        },
        key_advantages: [
            '100% foreign ownership',
            'Cost-effective setup',
            'Fast company formation',
            'Tax benefits',
            'E-commerce friendly'
        ],
        notable_limitations: [
            'Cannot trade within UAE mainland without distributor'
        ],
        rating: 4.5,
        special_features: {
            dual_license: false,
            remote_setup: true
        }
    },
    {
        id: 'ajman_free_zone',
        name: 'Ajman Free Zone',
        abbreviation: 'AFZ',
        emirate: 'ajman',
        established: 1988,
        license_types: ['Commercial', 'Trading', 'Service', 'Industrial', 'E-commerce'],
        costs: {
            setup: {
                basic: { amount: 5500, currency: 'AED' },
                standard: { amount: 7500, currency: 'AED' }
            }
        },
        visa_allocation: {
            basic: 1,
            standard: 2
        },
        key_advantages: [
            'Lowest setup costs',
            'Quick processing (1-3 days)',
            '100% foreign ownership',
            'No personal income tax',
            'Ideal for small businesses'
        ],
        notable_limitations: [
            'Limited international recognition',
            'Smaller infrastructure'
        ],
        rating: 4.2,
        special_features: {
            dual_license: false,
            remote_setup: true
        }
    },
    {
        id: 'saif_zone',
        name: 'Sharjah Airport International Free Zone',
        abbreviation: 'SAIF',
        emirate: 'sharjah',
        established: 1995,
        license_types: ['Commercial', 'Trading', 'Service', 'Industrial', 'E-commerce', 'Logistics'],
        costs: {
            setup: {
                basic: { amount: 8500, currency: 'AED' },
                standard: { amount: 11500, currency: 'AED' }
            }
        },
        visa_allocation: {
            basic: 1,
            standard: 3
        },
        key_advantages: [
            'Adjacent to Sharjah Airport',
            'Instant licensing (same day)',
            'Excellent logistics infrastructure',
            'Cost-effective visa packages',
            'Multiple office/warehouse options'
        ],
        notable_limitations: [
            'Limited compared to Dubai zones'
        ],
        rating: 4.4,
        special_features: {
            dual_license: false,
            remote_setup: true
        }
    },
    {
        id: 'ifza',
        name: 'International Free Zone Authority',
        abbreviation: 'IFZA',
        emirate: 'dubai',
        established: 2017,
        license_types: ['Commercial', 'Trading', 'Service', 'E-commerce', 'Consultancy'],
        costs: {
            setup: {
                basic: { amount: 11500, currency: 'AED' },
                standard: { amount: 14500, currency: 'AED' }
            }
        },
        visa_allocation: {
            basic: 0,
            standard: 2
        },
        key_advantages: [
            'Modern and digital-first',
            'Excellent customer support',
            'Dubai location',
            'Flexible office solutions',
            'Great for service businesses'
        ],
        notable_limitations: [
            'Higher costs than other zones',
            'Relatively new'
        ],
        rating: 4.6,
        special_features: {
            dual_license: false,
            remote_setup: true
        }
    },
    {
        id: 'dmcc',
        name: 'Dubai Multi Commodities Centre',
        abbreviation: 'DMCC',
        emirate: 'dubai',
        established: 2002,
        license_types: ['Commercial', 'Trading', 'Service', 'Commodities'],
        costs: {
            setup: {
                basic: { amount: 18000, currency: 'AED' },
                standard: { amount: 25000, currency: 'AED' }
            }
        },
        visa_allocation: {
            basic: 2,
            standard: 4
        },
        key_advantages: [
            'Premium Dubai location',
            'World-class infrastructure',
            'Strong international reputation',
            'Ideal for trading companies',
            'Extensive networking opportunities'
        ],
        notable_limitations: [
            'Higher setup and operating costs',
            'Competitive application process'
        ],
        rating: 4.7,
        special_features: {
            dual_license: false,
            remote_setup: false
        }
    },
    {
        id: 'meydan_freezone',
        name: 'Meydan Free Zone',
        abbreviation: 'Meydan',
        emirate: 'dubai',
        established: 2009,
        license_types: ['Commercial', 'Trading', 'Service', 'E-commerce', 'Media'],
        costs: {
            setup: {
                basic: { amount: 15000, currency: 'AED' },
                standard: { amount: 20000, currency: 'AED' }
            }
        },
        visa_allocation: {
            basic: 2,
            standard: 3
        },
        key_advantages: [
            'Premium Dubai location near Burj Khalifa',
            'Modern facilities',
            'Strong business reputation',
            'Flexible office solutions',
            'E-commerce friendly'
        ],
        notable_limitations: [
            'Higher costs',
            'Limited industrial options'
        ],
        rating: 4.5,
        special_features: {
            dual_license: false,
            remote_setup: true
        }
    }
];

async function seedData() {
    console.log('🚀 Starting freezones data seeding...\n');

    try {
        const batch = db.batch();
        const freezonesRef = db.collection('freezones');

        for (const freezone of freezonesData) {
            const docRef = freezonesRef.doc(freezone.id);
            batch.set(docRef, freezone);
            console.log(`✅ Queued: ${freezone.name} (${freezone.abbreviation})`);
        }

        await batch.commit();
        console.log('\n🎉 Successfully seeded all freezones data!');
        console.log(`📊 Total freezones: ${freezonesData.length}`);

        process.exit(0);
    } catch (error) {
        console.error('❌ Error seeding data:', error);
        process.exit(1);
    }
}

seedData();
