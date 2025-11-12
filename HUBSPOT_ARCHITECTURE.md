# HubSpot Integration Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         WAZEET Flutter App                               │
│                                                                          │
│  ┌────────────────┐      ┌─────────────────┐     ┌──────────────────┐  │
│  │  User Selects  │ ───> │  Stripe Payment │ ──> │  Payment Success │  │
│  │    Service     │      │    Processing   │     │                  │  │
│  └────────────────┘      └─────────────────┘     └──────────────────┘  │
│                                                            │             │
│                                                            │             │
└────────────────────────────────────────────────────────────┼─────────────┘
                                                             │
                                                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          Firebase Firestore                              │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  payments/{paymentId}                                            │   │
│  │  {                                                               │   │
│  │    application_id: "app_123",                                    │   │
│  │    user_id: "user_456",                                          │   │
│  │    amount: 500,                                                  │   │
│  │    currency: "AED",                                              │   │
│  │    status: "paid",              ← TRIGGER                        │   │
│  │    created_at: timestamp                                         │   │
│  │  }                                                               │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                   │                                      │
└───────────────────────────────────┼──────────────────────────────────────┘
                                    │
                                    │ Firestore onCreate Trigger
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     Firebase Cloud Function                              │
│                     onPaymentCreated()                                   │
│                                                                          │
│  Step 1: Fetch Data                                                     │
│  ┌────────────────────┐  ┌──────────────────────┐  ┌──────────────┐    │
│  │  Get User Profile  │  │  Get Application     │  │  Get Documents│   │
│  │  from users/{uid}  │  │  from applications/  │  │  URLs        │    │
│  └────────────────────┘  └──────────────────────┘  └──────────────┘    │
│           │                        │                       │            │
│           └────────────────────────┴───────────────────────┘            │
│                                    │                                    │
│                                    ▼                                    │
│  Step 2: Prepare HubSpot Data                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  WazeetUserData {                                                 │  │
│  │    userId, email, displayName, phoneNumber,                       │  │
│  │    companyName, serviceName, serviceCategory,                     │  │
│  │    amount, currency, applicationId, documentUrls                  │  │
│  │  }                                                                 │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                    │                                    │
└────────────────────────────────────┼────────────────────────────────────┘
                                     │
                                     │ syncPaymentToHubSpot()
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         HubSpot CRM API                                  │
│                  (hubspotService.ts functions)                           │
│                                                                          │
│  Step 1: Create/Update Contact                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  POST /crm/v3/objects/contacts                                    │  │
│  │  Authorization: Bearer na2-0ba1-00ad-49fb-ae8d-ee4e0feff3cb       │  │
│  │                                                                    │  │
│  │  Body: {                                                           │  │
│  │    properties: {                                                   │  │
│  │      email: "user@example.com",                                    │  │
│  │      firstname: "John",                                            │  │
│  │      lastname: "Doe",                                              │  │
│  │      phone: "+971501234567",                                       │  │
│  │      company: "ABC Trading",                                       │  │
│  │      service_purchased: "Corporate Tax Registration",              │  │
│  │      service_category: "Tax Services",                             │  │
│  │      amount_paid: "500 AED",                                       │  │
│  │      payment_date: "2025-11-11",                                   │  │
│  │      application_id: "app_123",                                    │  │
│  │      document_count: "2",                                          │  │
│  │      lead_source: "WAZEET Mobile App"                              │  │
│  │    }                                                               │  │
│  │  }                                                                 │  │
│  │                                                                    │  │
│  │  Response: { id: "12345" }  ← Contact ID                          │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                    │                                    │
│                                    ▼                                    │
│  Step 2: Create Deal                                                    │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  POST /crm/v3/objects/deals                                        │  │
│  │                                                                    │  │
│  │  Body: {                                                           │  │
│  │    properties: {                                                   │  │
│  │      dealname: "Corporate Tax Registration - ABC Trading",         │  │
│  │      amount: "500",                                                │  │
│  │      dealstage: "closedwon",                                       │  │
│  │      pipeline: "default",                                          │  │
│  │      closedate: "2025-11-11",                                      │  │
│  │      service_type: "Corporate Tax Registration",                   │  │
│  │      payment_status: "paid",                                       │  │
│  │      application_id: "app_123"                                     │  │
│  │    }                                                               │  │
│  │  }                                                                 │  │
│  │                                                                    │  │
│  │  Response: { id: "67890" }  ← Deal ID                             │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                    │                                    │
│                                    ▼                                    │
│  Step 3: Associate Deal with Contact                                    │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  PUT /crm/v3/objects/deals/67890/associations/contacts/12345/3    │  │
│  │                                                                    │  │
│  │  (Links deal to contact)                                           │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                    │                                    │
│                                    ▼                                    │
│  Step 4: Add Document Note (if documents exist)                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  POST /crm/v3/objects/notes                                        │  │
│  │                                                                    │  │
│  │  Body: {                                                           │  │
│  │    properties: {                                                   │  │
│  │      hs_note_body: "Documents uploaded:\n1. doc1.pdf\n2. doc2.pdf"│  │
│  │    },                                                              │  │
│  │    associations: [{ to: { id: "12345" }, ... }]                   │  │
│  │  }                                                                 │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└──────────────────────────────────────┬───────────────────────────────────┘
                                       │
                                       │ Success Response
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    Update Firestore Payment Document                     │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  payments/{paymentId}                                            │   │
│  │  {                                                               │   │
│  │    application_id: "app_123",                                    │   │
│  │    user_id: "user_456",                                          │   │
│  │    amount: 500,                                                  │   │
│  │    currency: "AED",                                              │   │
│  │    status: "paid",                                               │   │
│  │    created_at: timestamp,                                        │   │
│  │    hubspot_contact_id: "12345",     ← NEW                        │   │
│  │    hubspot_deal_id: "67890",        ← NEW                        │   │
│  │    hubspot_synced_at: timestamp     ← NEW                        │   │
│  │  }                                                               │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                            ✅ INTEGRATION COMPLETE


════════════════════════════════════════════════════════════════════════════

                         Manual Sync Flow (Optional)

User/Admin triggers manual sync via:
  - syncPaymentToHubSpotManual({ paymentId: "payment_123" })

                                    │
                                    ▼
                     Same process as automatic sync
                     (Steps 1-4 in Cloud Function)
                                    │
                                    ▼
                          Returns success/failure

════════════════════════════════════════════════════════════════════════════

                         Test Connection Flow

User/Admin tests HubSpot API key via:
  - testHubSpotConnection()

                                    │
                                    ▼
               Creates test contact in HubSpot
                  email: test@wazeet.com
                                    │
                                    ▼
            Returns success/failure + contact ID

════════════════════════════════════════════════════════════════════════════
```

## Key Components

### 1. **Flutter App** (`lib/utils/payment_utils.dart`)
- Handles Stripe payment
- Creates payment document in Firestore with `user_id`

### 2. **Firestore Trigger** (`functions/src/hubspot/index.ts`)
- `onPaymentCreated` - Triggered when payment document is created
- Fetches user, application, and document data
- Calls HubSpot sync service

### 3. **HubSpot Service** (`functions/src/hubspot/hubspotService.ts`)
- `createOrUpdateHubSpotContact()` - Creates/updates contact
- `createHubSpotDeal()` - Creates deal and associates it
- `addDocumentNoteToContact()` - Adds document notes
- `syncPaymentToHubSpot()` - Main orchestration function

### 4. **Manual Functions** (`functions/src/hubspot/index.ts`)
- `syncPaymentToHubSpotManual` - Retry failed syncs
- `testHubSpotConnection` - Test API connection

## Error Handling

```
┌─────────────────┐
│  Contact Exists │
│  (409 Error)    │
└────────┬────────┘
         │
         ▼
┌─────────────────────┐
│ Search by Email     │
│ GET /contacts/search│
└─────────┬───────────┘
          │
          ▼
┌──────────────────────┐
│ Update Contact       │
│ PATCH /contacts/{id} │
└──────────────────────┘
```

## Security

- ✅ API key stored server-side (Firebase Functions config)
- ✅ Never exposed to client app
- ✅ All API calls authenticated with Bearer token
- ✅ Environment variables in .gitignore

## Monitoring

```bash
# View all syncs
firebase functions:log --only onPaymentCreated

# View errors only
firebase functions:log --only onPaymentCreated | grep ERROR

# Real-time monitoring
firebase functions:log --only onPaymentCreated --follow
```
