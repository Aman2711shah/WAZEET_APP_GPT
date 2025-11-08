// Script to seed the `freezones` collection with curated UAE data
// Run with: node functions/seed_freezones_data.js

const admin = require('firebase-admin');
const serviceAccount = require('../freezone-import/business-setup-application-firebase-adminsdk-fbsvc-adc9567880.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const defaultLicenseTypes = [
    'Commercial',
    'Trading',
    'Service',
    'Industrial',
    'E-commerce',
    'Professional',
];

const baseAdvantages = [
    '100% foreign ownership',
    'Full profit repatriation',
    'No personal income tax',
];

const createCosts = (basic, standard) => ({
    setup: {
        basic: { amount: basic, currency: 'AED' },
        standard: { amount: standard ?? Math.round(basic * 1.3), currency: 'AED' },
    },
});

const createZone = ({
    id,
    name,
    abbreviation,
    emirate,
    established,
    licenseTypes,
    costs,
    visaAllocation,
    keyAdvantages,
    notableLimitations,
    rating,
    specialFeatures,
}) => ({
    id,
    name,
    abbreviation,
    emirate,
    established,
    license_types: licenseTypes ?? defaultLicenseTypes,
    costs: costs ?? createCosts(12000, 15000),
    visa_allocation: visaAllocation ?? { flexi: 2, office: 4 },
    key_advantages: keyAdvantages ?? baseAdvantages,
    notable_limitations: notableLimitations ?? [
        'Requires UAE registered agent',
    ],
    rating: rating ?? 4.3,
    special_features: {
        dual_license: false,
        remote_setup: true,
        ...specialFeatures,
    },
});

const freezonesData = [
    // Ras Al Khaimah
    createZone({
        id: 'rakez',
        name: 'Ras Al Khaimah Economic Zone (RAKEZ)',
        abbreviation: 'RAKEZ',
        emirate: 'ras_al_khaimah',
        established: 2000,
        costs: createCosts(6500, 9500),
        visaAllocation: { flexi: 2, warehouse: 10 },
        keyAdvantages: [
            'Cost-effective setup packages',
            'Industrial and logistics ecosystems',
            'Dedicated SME support team',
        ],
        notableLimitations: ['Limited direct trade on mainland'],
        rating: 4.5,
    }),
    createZone({
        id: 'rak_maritime_city',
        name: 'RAK Maritime City Free Zone',
        abbreviation: 'RAKMC',
        emirate: 'ras_al_khaimah',
        established: 2011,
        costs: createCosts(9000, 14000),
        visaAllocation: { flexi: 1, port_office: 5 },
        keyAdvantages: [
            'Deep-water port access',
            'Ideal for ship repair and logistics',
            '24/7 customs and marine services',
        ],
        notableLimitations: ['Requires maritime-focused business activity'],
        rating: 4.2,
    }),

    // Ajman
    createZone({
        id: 'ajman_free_zone',
        name: 'Ajman Free Zone (AFZ)',
        abbreviation: 'AFZ',
        emirate: 'ajman',
        established: 1988,
        costs: createCosts(5500, 8200),
        visaAllocation: { flexi: 1, office: 3 },
        keyAdvantages: [
            'Lowest setup costs',
            'Quick processing (1–3 days)',
            'Remote setup friendly',
        ],
        notableLimitations: ['Smaller infrastructure footprint'],
        rating: 4.2,
    }),
    createZone({
        id: 'ajman_media_city',
        name: 'Ajman Media City Free Zone',
        abbreviation: 'AMCFZ',
        emirate: 'ajman',
        established: 2018,
        costs: createCosts(6500, 9800),
        licenseTypes: ['Media', 'Creative', 'E-commerce', 'Service'],
        visaAllocation: { flexi: 1, office: 2 },
        keyAdvantages: [
            'One-day media licensing',
            'Digital onboarding',
            'Ideal for freelancers/creatives',
        ],
        notableLimitations: ['Limited industrial activities'],
        rating: 4.1,
    }),

    // Sharjah
    createZone({
        id: 'saif_zone',
        name: 'Sharjah Airport International Free Zone (SAIF)',
        abbreviation: 'SAIF',
        emirate: 'sharjah',
        established: 1995,
        costs: createCosts(8500, 12500),
        visaAllocation: { flexi: 1, warehouse: 8 },
        keyAdvantages: [
            'Adjacent to Sharjah Airport',
            'Same-day business licensing',
            'Strong logistics infrastructure',
        ],
        rating: 4.4,
    }),
    createZone({
        id: 'hamriyah_free_zone',
        name: 'Hamriyah Free Zone Authority (HFZA)',
        abbreviation: 'HFZA',
        emirate: 'sharjah',
        established: 1995,
        costs: createCosts(9000, 13500),
        visaAllocation: { flexi: 1, warehouse: 10 },
        keyAdvantages: [
            'Large industrial plots',
            'Deep-water port access',
            'Energy-efficient warehouses',
        ],
        rating: 4.3,
    }),
    createZone({
        id: 'shams',
        name: 'Sharjah Media City (SHAMS)',
        abbreviation: 'SHAMS',
        emirate: 'sharjah',
        established: 2017,
        costs: createCosts(5750, 9500),
        licenseTypes: ['Media', 'Creative', 'E-commerce', 'Service'],
        keyAdvantages: [
            'Fully digital onboarding',
            'Popular with content creators',
            'Flexible shared-desk options',
        ],
        rating: 4.2,
    }),
    createZone({
        id: 'spc',
        name: 'Sharjah Publishing City Free Zone (SPC)',
        abbreviation: 'SPC',
        emirate: 'sharjah',
        established: 2017,
        costs: createCosts(14000, 18500),
        licenseTypes: ['Publishing', 'Media', 'E-commerce', 'Consultancy'],
        keyAdvantages: [
            'Dual license with Sharjah mainland',
            'Ideal for publishing & e-commerce',
            '2-visa packages with flexi-desk',
        ],
        specialFeatures: { dual_license: true },
        rating: 4.4,
    }),
    createZone({
        id: 'srtip',
        name: 'Sharjah Research, Technology & Innovation Park (SRTIP)',
        abbreviation: 'SRTIP',
        emirate: 'sharjah',
        established: 2016,
        costs: createCosts(9000, 14500),
        licenseTypes: ['R&D', 'Technology', 'CleanTech', 'Education'],
        visaAllocation: { flexi: 2, lab: 6 },
        keyAdvantages: [
            'University-linked innovation hub',
            'Lab/testing facilities',
            'Great for R&D partnerships',
        ],
        specialFeatures: { innovation_cluster: true },
        rating: 4.3,
    }),

    // Dubai (major free zones)
    createZone({
        id: 'ifza',
        name: 'IFZA Dubai (International Free Zone Authority)',
        abbreviation: 'IFZA',
        emirate: 'dubai',
        established: 2017,
        costs: createCosts(11500, 15500),
        visaAllocation: { flexi: 0, office: 2 },
        keyAdvantages: [
            'Modern, digital-first platform',
            'Great for consultants and SMEs',
            'Strong partner ecosystem',
        ],
        rating: 4.6,
    }),
    createZone({
        id: 'dmcc',
        name: 'Dubai Multi Commodities Centre (DMCC)',
        abbreviation: 'DMCC',
        emirate: 'dubai',
        established: 2002,
        costs: createCosts(18000, 26000),
        visaAllocation: { flexi: 2, office: 4 },
        keyAdvantages: [
            'Premier Dubai address (JLT)',
            'Ideal for global traders',
            'World-class infrastructure',
        ],
        notableLimitations: ['Higher setup/operational costs'],
        rating: 4.7,
    }),
    createZone({
        id: 'jafza',
        name: 'Jebel Ali Free Zone (JAFZA)',
        abbreviation: 'JAFZA',
        emirate: 'dubai',
        established: 1985,
        costs: createCosts(18500, 26000),
        visaAllocation: { flexi: 2, warehouse: 12 },
        keyAdvantages: [
            'Largest logistics hub in MENA',
            'Direct access to Jebel Ali Port',
            'Preferred for manufacturing & logistics',
        ],
        notableLimitations: ['Requires physical office or warehouse'],
        specialFeatures: { dual_license: true },
        rating: 4.7,
    }),
    createZone({
        id: 'dafza',
        name: 'Dubai Airport Free Zone (DAFZ / DIEZ)',
        abbreviation: 'DAFZ',
        emirate: 'dubai',
        established: 1996,
        costs: createCosts(20000, 28000),
        visaAllocation: { flexi: 2, office: 5 },
        keyAdvantages: [
            'Next to DXB airport',
            'Ideal for high-value trading',
            'Integrated with DIEZ “One Free Zone Passport”',
        ],
        specialFeatures: { one_freezone_passport: true },
        rating: 4.6,
    }),
    createZone({
        id: 'dubai_silicon_oasis',
        name: 'Dubai Silicon Oasis (DSO / DIEZ)',
        abbreviation: 'DSO',
        emirate: 'dubai',
        established: 2004,
        costs: createCosts(14000, 19500),
        licenseTypes: ['Technology', 'IT Services', 'R&D', 'Consultancy'],
        keyAdvantages: [
            'Integrated tech community',
            'Access to labs & co-working',
            'Part of DIEZ ecosystem',
        ],
        specialFeatures: { innovation_cluster: true, one_freezone_passport: true },
        rating: 4.5,
    }),
    createZone({
        id: 'dubai_commercity',
        name: 'Dubai CommerCity (DIEZ)',
        abbreviation: 'DCC',
        emirate: 'dubai',
        established: 2020,
        costs: createCosts(16000, 21000),
        licenseTypes: ['E-commerce', 'Logistics', 'Service'],
        keyAdvantages: [
            'Purpose-built for e-commerce',
            'Fulfilment + logistics bundles',
            'Integrated digital platform',
        ],
        specialFeatures: { e_commerce_hub: true, one_freezone_passport: true },
        rating: 4.4,
    }),
    createZone({
        id: 'difc',
        name: 'Dubai International Financial Centre (DIFC)',
        abbreviation: 'DIFC',
        emirate: 'dubai',
        established: 2004,
        costs: createCosts(25000, 42000),
        licenseTypes: ['Financial', 'Non-Financial', 'Retail', 'Innovation'],
        keyAdvantages: [
            'Common-law jurisdiction',
            'FSRA-regulated financial hub',
            'Top choice for fintech/finance',
        ],
        notableLimitations: ['Higher capitalization requirements'],
        specialFeatures: { dual_license: true },
        rating: 4.8,
    }),
    createZone({
        id: 'dubai_south',
        name: 'Dubai South (DWC & Logistics District)',
        abbreviation: 'DWC',
        emirate: 'dubai',
        established: 2006,
        costs: createCosts(12000, 18500),
        keyAdvantages: [
            'Home to Al Maktoum International Airport',
            'Logistics and aviation ecosystem',
            'Expo City access',
        ],
        rating: 4.4,
    }),
    createZone({
        id: 'meydan_freezone',
        name: 'Meydan Free Zone',
        abbreviation: 'MEYDAN',
        emirate: 'dubai',
        established: 2009,
        costs: createCosts(15000, 21000),
        keyAdvantages: [
            'Prestige Downtown Dubai address',
            'Fast digital onboarding',
            'Great for consultants & marketers',
        ],
        rating: 4.5,
    }),
    createZone({
        id: 'dubai_healthcare_city',
        name: 'Dubai Healthcare City (DHCC)',
        abbreviation: 'DHCC',
        emirate: 'dubai',
        established: 2002,
        licenseTypes: ['Healthcare', 'Wellness', 'Education', 'Service'],
        costs: createCosts(16000, 23000),
        visaAllocation: { clinic: 4, hospital: 25 },
        keyAdvantages: [
            'Dedicated healthcare regulator',
            'Access to hospitals & labs',
            'Popular for medical tourism',
        ],
        specialFeatures: { healthcare_cluster: true },
        rating: 4.5,
    }),
    createZone({
        id: 'dubai_maritime_city',
        name: 'Dubai Maritime City',
        abbreviation: 'DMC-MAR',
        emirate: 'dubai',
        established: 2007,
        costs: createCosts(15000, 20000),
        licenseTypes: ['Maritime', 'Logistics', 'Industrial', 'Service'],
        keyAdvantages: [
            'Dedicated ship repair + marine hub',
            'Direct waterfront access',
            'Strategic between Port Rashid & Drydocks World',
        ],
        specialFeatures: { maritime_cluster: true },
        rating: 4.3,
    }),
    createZone({
        id: 'dubai_internet_city',
        name: 'Dubai Internet City (TECOM)',
        abbreviation: 'DIC',
        emirate: 'dubai',
        established: 1999,
        licenseTypes: ['Technology', 'Software', 'R&D'],
        costs: createCosts(19000, 26000),
        keyAdvantages: [
            'Flagship tech & SaaS hub',
            'Global tech tenants (Meta, Google)',
            'Part of TECOM clusters',
        ],
        specialFeatures: { tech_cluster: true, one_freezone_passport: true },
        rating: 4.6,
    }),
    createZone({
        id: 'dubai_media_city',
        name: 'Dubai Media City (TECOM)',
        abbreviation: 'DMC',
        emirate: 'dubai',
        established: 2000,
        licenseTypes: ['Media', 'Broadcast', 'Production', 'Marketing'],
        costs: createCosts(17500, 24000),
        keyAdvantages: [
            'MENA media headquarters cluster',
            'Studios + sound stages',
            'Part of TECOM family',
        ],
        specialFeatures: { media_cluster: true, one_freezone_passport: true },
        rating: 4.5,
    }),
    createZone({
        id: 'dubai_production_city',
        name: 'Dubai Production City (TECOM)',
        abbreviation: 'DPC',
        emirate: 'dubai',
        established: 2003,
        licenseTypes: ['Printing', 'Packaging', 'Publishing'],
        costs: createCosts(15000, 21000),
        keyAdvantages: [
            'Purpose-built for production houses',
            'Warehouses + light industrial units',
            'Part of TECOM ecosystem',
        ],
        rating: 4.2,
    }),
    createZone({
        id: 'dubai_studio_city',
        name: 'Dubai Studio City (TECOM)',
        abbreviation: 'DSC',
        emirate: 'dubai',
        established: 2006,
        licenseTypes: ['Film', 'Broadcast', 'Gaming', 'Audio'],
        costs: createCosts(16500, 21500),
        keyAdvantages: [
            'Sound stages + backlots',
            'Ideal for production companies',
            'Part of TECOM clusters',
        ],
        specialFeatures: { media_cluster: true },
        rating: 4.4,
    }),
    createZone({
        id: 'dubai_design_district',
        name: 'Dubai Design District (d3)',
        abbreviation: 'D3',
        emirate: 'dubai',
        established: 2013,
        licenseTypes: ['Design', 'Fashion', 'Luxury', 'Art'],
        costs: createCosts(18000, 25000),
        keyAdvantages: [
            'Curated design + fashion hub',
            'Creative workspaces and showrooms',
            'Part of TECOM clusters',
        ],
        rating: 4.4,
    }),
    createZone({
        id: 'dubai_knowledge_park',
        name: 'Dubai Knowledge Park',
        abbreviation: 'DKP',
        emirate: 'dubai',
        established: 2003,
        licenseTypes: ['Education', 'Training', 'HR', 'Consultancy'],
        costs: createCosts(16000, 22000),
        keyAdvantages: [
            'Focused on education & training',
            'Easy to host learning centers',
            'Part of TECOM ecosystem',
        ],
        rating: 4.3,
    }),
    createZone({
        id: 'dubai_outsource_city',
        name: 'Dubai Outsource City',
        abbreviation: 'DOC',
        emirate: 'dubai',
        established: 2007,
        licenseTypes: ['BPO', 'Shared Services', 'IT', 'Contact Centers'],
        costs: createCosts(15500, 21000),
        keyAdvantages: [
            'Optimized for BPO/shared-services',
            'Bulk visa options',
            'Part of TECOM clusters',
        ],
        rating: 4.2,
    }),
    createZone({
        id: 'international_humanitarian_city',
        name: 'International Humanitarian City (IHC)',
        abbreviation: 'IHC',
        emirate: 'dubai',
        established: 2003,
        licenseTypes: ['NGO', 'Relief', 'Logistics', 'UN Agencies'],
        costs: createCosts(8000, 12000),
        visaAllocation: { flexi: 2, warehouse: 8 },
        keyAdvantages: [
            'World’s largest humanitarian hub',
            'Tax/duty exemptions for aid cargo',
            'Ideal for NGOs and relief agencies',
        ],
        specialFeatures: { humanitarian_cluster: true },
        rating: 4.3,
    }),

    // Abu Dhabi
    createZone({
        id: 'adgm',
        name: 'Abu Dhabi Global Market (ADGM)',
        abbreviation: 'ADGM',
        emirate: 'abu_dhabi',
        established: 2015,
        costs: createCosts(20000, 35000),
        licenseTypes: ['Financial', 'Non-Financial', 'Tech Startup', 'SPV'],
        keyAdvantages: [
            'English common-law jurisdiction',
            'Tech startup & fintech programs',
            'FSRA regulated financial centre',
        ],
        notableLimitations: ['Higher compliance requirements'],
        rating: 4.8,
    }),
    createZone({
        id: 'kezad',
        name: 'Khalifa Economic Zones Abu Dhabi (KEZAD)',
        abbreviation: 'KEZAD',
        emirate: 'abu_dhabi',
        established: 2012,
        costs: createCosts(10000, 16000),
        visaAllocation: { flexi: 1, warehouse: 12 },
        keyAdvantages: [
            'Mega industrial + logistics ecosystem',
            'Direct link to Khalifa Port',
            'ZonesCorp consolidation benefits',
        ],
        rating: 4.5,
    }),
    createZone({
        id: 'masdar_city',
        name: 'Masdar City Free Zone',
        abbreviation: 'MASDAR',
        emirate: 'abu_dhabi',
        established: 2006,
        licenseTypes: ['CleanTech', 'Renewables', 'R&D', 'Consultancy'],
        costs: createCosts(14000, 19000),
        keyAdvantages: [
            'Sustainability-focused ecosystem',
            'Labs + pilot testing facilities',
            'Ideal for climate tech startups',
        ],
        specialFeatures: { innovation_cluster: true },
        rating: 4.4,
    }),
    createZone({
        id: 'adafz',
        name: 'Abu Dhabi Airports Free Zone (ADAFZ)',
        abbreviation: 'ADAFZ',
        emirate: 'abu_dhabi',
        established: 2010,
        costs: createCosts(12000, 17500),
        keyAdvantages: [
            'Inside Abu Dhabi International Airport',
            'Great for logistics and duty-free',
            'Cargo village connectivity',
        ],
        rating: 4.2,
    }),
    createZone({
        id: 'twofour54',
        name: 'twofour54 Abu Dhabi',
        abbreviation: 'TWOFOUR54',
        emirate: 'abu_dhabi',
        established: 2008,
        licenseTypes: ['Media', 'Gaming', 'Production', 'Digital'],
        costs: createCosts(14500, 19500),
        keyAdvantages: [
            'Media & gaming production hub',
            'Incentives for film/TV projects',
            'Home to gaming/animation studios',
        ],
        specialFeatures: { media_cluster: true },
        rating: 4.4,
    }),

    // Fujairah
    createZone({
        id: 'fujairah_free_zone',
        name: 'Fujairah Free Zone Authority (FFZA)',
        abbreviation: 'FFZA',
        emirate: 'fujairah',
        established: 1987,
        costs: createCosts(7500, 11500),
        keyAdvantages: [
            'Access to Fujairah Port',
            'Lower leasing costs',
            'Ideal for logistics + trading',
        ],
        rating: 4.1,
    }),
    createZone({
        id: 'creative_city_fujairah',
        name: 'Creative City Fujairah',
        abbreviation: 'CCFZ',
        emirate: 'fujairah',
        established: 2007,
        licenseTypes: ['Media', 'Creative', 'Consultancy', 'E-commerce'],
        costs: createCosts(6500, 9800),
        keyAdvantages: [
            'Popular with freelancers',
            'Remote setup in 2–3 days',
            'Media + e-learning friendly',
        ],
        rating: 4.1,
    }),

    // Umm Al Quwain
    createZone({
        id: 'uaq_free_trade_zone',
        name: 'Umm Al Quwain Free Trade Zone (UAQ FTZ)',
        abbreviation: 'UAQ',
        emirate: 'umm_al_quwain',
        established: 2014,
        costs: createCosts(8000, 11800),
        keyAdvantages: [
            'Affordable flexi-desk packages',
            'Fast incorporation timelines',
            'Ideal for trading & holding companies',
        ],
        rating: 4.0,
    }),
];

async function seedData() {
    console.log('🚀 Starting freezones data seeding...\n');

    try {
        const batch = db.batch();
        const freezonesRef = db.collection('freezones');

        for (const freezone of freezonesData) {
            const docRef = freezonesRef.doc(freezone.id);
            batch.set(docRef, freezone, { merge: true });
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
