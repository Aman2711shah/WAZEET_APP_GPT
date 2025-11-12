# HubSpot CRM Integration for WAZEET

This document explains how the HubSpot CRM integration works and how to set it up.

## Overview

The WAZEET app automatically creates leads in HubSpot CRM whenever a user completes a payment for a service. The integration captures:

- **Contact Information**: Email, name, phone number, company
- **Service Details**: Service name, category, amount paid
- **Documents**: Links to uploaded documents
- **Payment Information**: Amount, currency, payment date
- **Application Data**: Unique application ID for tracking

## Architecture

```
User Payment (Flutter App)
    ↓
Stripe Payment Processing
    ↓
Firestore: Create Payment Document
    ↓
Cloud Function Trigger: onPaymentCreated
    ↓
HubSpot API:
    1. Create/Update Contact
    2. Create Deal
    3. Add Document Notes
    ↓
Update Firestore with HubSpot IDs
```

## Setup Instructions

### 1. Get HubSpot API Key

1. Log in to your HubSpot account at https://app.hubspot.com
2. Navigate to **Settings** (gear icon) → **Integrations** → **API Key**
3. Click **"Show"** to reveal your API key or **"Create key"** if you don't have one
4. Copy the API key: `na2-0ba1-00ad-49fb-ae8d-ee4e0feff3cb`

### 2. Configure Firebase Functions

Add the HubSpot API key to your Firebase Functions environment:

```bash
# Navigate to functions directory
cd functions

# Set the HubSpot API key
firebase functions:config:set hubspot.api_key="na2-0ba1-00ad-49fb-ae8d-ee4e0feff3cb"
```

For local development, create a `.env` file in the `functions` directory:

```bash
# functions/.env
HUBSPOT_API_KEY=na2-0ba1-00ad-49fb-ae8d-ee4e0feff3cb
```

### 3. Deploy Firebase Functions

```bash
# Build and deploy
cd functions
npm install
npm run build
firebase deploy --only functions
```

This will deploy three new functions:
- `onPaymentCreated` - Automatically triggers on payment
- `syncPaymentToHubSpotManual` - Manual sync for retries
- `testHubSpotConnection` - Test your HubSpot connection

### 4. Custom Properties in HubSpot (Optional but Recommended)

To fully utilize the integration, create these custom properties in HubSpot:

#### Contact Properties:
1. Go to **Settings** → **Properties** → **Contact properties**
2. Click **Create property**
3. Add these properties:

| Property Name | Internal Name | Type | Description |
|---------------|---------------|------|-------------|
| Service Purchased | `service_purchased` | Single-line text | Name of the service purchased |
| Service Category | `service_category` | Single-line text | Category of service |
| Amount Paid | `amount_paid` | Single-line text | Amount and currency |
| Payment Date | `payment_date` | Date picker | Date payment was made |
| Application ID | `application_id` | Single-line text | Unique application identifier |
| Document Count | `document_count` | Number | Number of documents uploaded |
| Lead Source | `lead_source` | Single-line text | Source of the lead |

#### Deal Properties:
1. Go to **Settings** → **Properties** → **Deal properties**
2. Add these properties:

| Property Name | Internal Name | Type | Description |
|---------------|---------------|------|-------------|
| Service Type | `service_type` | Single-line text | Type of service |
| Payment Status | `payment_status` | Dropdown | Payment status (paid, pending, failed) |
| Application ID | `application_id` | Single-line text | Link to application |

## How It Works

### Automatic Sync (on Payment)

When a user completes a payment:

1. **Payment Document Created**: The app creates a document in Firestore's `payments` collection with:
   ```javascript
   {
     application_id: "app_123",
     user_id: "user_456",
     amount: 500,
     currency: "AED",
     status: "paid",
     created_at: timestamp
   }
   ```

2. **Cloud Function Triggered**: `onPaymentCreated` function automatically executes

3. **Data Collection**: The function gathers:
   - User profile data from `users` collection
   - Application details from `applications` collection
   - Document URLs (if any)

4. **HubSpot Sync**:
   - Creates or updates contact with user email
   - Creates a deal associated with the contact
   - Adds notes with document links
   - Marks deal as "closed won" since payment is complete

5. **Firestore Update**: Payment document updated with:
   ```javascript
   {
     hubspot_contact_id: "12345",
     hubspot_deal_id: "67890",
     hubspot_synced_at: timestamp
   }
   ```

### Manual Sync (for retries)

If automatic sync fails or for historical data:

```dart
// In your Flutter app
final callable = FirebaseFunctions.instance
    .httpsCallable('syncPaymentToHubSpotManual');

final result = await callable.call({
  'paymentId': 'payment_123',
});

print(result.data['contactId']); // HubSpot contact ID
print(result.data['dealId']); // HubSpot deal ID
```

## Testing

### Test HubSpot Connection

```dart
// In your Flutter app
final callable = FirebaseFunctions.instance
    .httpsCallable('testHubSpotConnection');

final result = await callable.call({});

if (result.data['success']) {
  print('HubSpot connected successfully!');
  print('Test contact ID: ${result.data['contactId']}');
} else {
  print('Connection failed: ${result.data['error']}');
}
```

### View Logs

```bash
# View Firebase Functions logs
firebase functions:log

# Filter for HubSpot-related logs
firebase functions:log --only onPaymentCreated
```

## Data Flow Example

### Input (from Flutter app):
```dart
// User completes payment for "Corporate Tax Registration" service
// Amount: 500 AED
// Documents: [doc1.pdf, doc2.pdf]
```

### HubSpot Contact Created:
```
Email: user@example.com
First Name: John
Last Name: Doe
Phone: +971501234567
Company: ABC Trading LLC
Service Purchased: Corporate Tax Registration
Service Category: Tax Services
Amount Paid: 500 AED
Payment Date: 2025-11-11
Application ID: app_123456
Document Count: 2
Lead Source: WAZEET Mobile App
```

### HubSpot Deal Created:
```
Deal Name: Corporate Tax Registration - ABC Trading LLC
Amount: 500
Stage: Closed Won
Service Type: Corporate Tax Registration
Payment Status: paid
Application ID: app_123456
Close Date: 2025-11-11
```

### HubSpot Note Added:
```
Documents uploaded by user:
1. https://storage.googleapis.com/.../doc1.pdf
2. https://storage.googleapis.com/.../doc2.pdf

Total documents: 2
Upload date: 2025-11-11T10:30:00Z
```

## Error Handling

The integration includes comprehensive error handling:

1. **Automatic Retries**: If contact creation fails with 409 (duplicate), it automatically updates the existing contact

2. **Non-Blocking**: HubSpot sync failures won't prevent payment completion

3. **Logging**: All errors are logged to Firebase Functions logs for troubleshooting

4. **Manual Recovery**: Use `syncPaymentToHubSpotManual` to retry failed syncs

## Common Issues & Solutions

### Issue: "HubSpot API key not configured"
**Solution**: Ensure you've set the environment variable:
```bash
firebase functions:config:set hubspot.api_key="YOUR_KEY_HERE"
```

### Issue: Contact not created
**Solution**: 
- Verify the API key has proper permissions
- Check that user email is not empty
- Review Firebase Functions logs

### Issue: Duplicate contacts
**Solution**: The integration automatically detects duplicates and updates existing contacts instead of creating new ones

### Issue: Documents not showing
**Solution**: Ensure `documentUrls` array is properly populated in the application document before payment

## Security Considerations

1. **API Key Storage**: Never commit API keys to version control
2. **Environment Variables**: Use Firebase Functions config or environment files
3. **Authentication**: All manual sync functions require user authentication
4. **Data Privacy**: Ensure compliance with GDPR/data privacy laws
5. **Access Control**: Restrict HubSpot API key to necessary scopes only

## Monitoring

### Key Metrics to Track

1. **Sync Success Rate**: Monitor function executions vs. successful HubSpot creates
2. **Error Rate**: Track failed syncs and common error types
3. **Sync Latency**: Time from payment to HubSpot sync completion
4. **Data Completeness**: Percentage of contacts with all required fields

### Firebase Console Monitoring

```bash
# View function execution stats
firebase functions:log --only onPaymentCreated

# Check for errors
firebase functions:log --only onPaymentCreated --limit 100 | grep ERROR
```

## Future Enhancements

Potential improvements to the integration:

1. **Webhook Integration**: Two-way sync from HubSpot to Firebase
2. **Custom Pipelines**: Dynamic pipeline selection based on service type
3. **Deal Stages**: Track deal progress through stages
4. **Email Automation**: Trigger HubSpot email workflows
5. **Reporting**: Custom dashboards for sales analytics
6. **File Upload**: Direct document upload to HubSpot file manager

## Support

For issues or questions:
- Email: support@wazeet.com
- Phone: +971559986386
- HubSpot Documentation: https://developers.hubspot.com/docs/api/overview

## License

This integration is proprietary to WAZEET and covered under the main application license.
