# AI-Powered Free Zone Recommendations

This feature integrates OpenAI's ChatGPT to provide intelligent, personalized free zone recommendations based on user inputs.

## Features

✅ **AI-Powered Analysis**: Uses GPT-4 to analyze business requirements
✅ **Cost Optimization**: Provides detailed pricing breakdowns and comparisons
✅ **Personalized Recommendations**: Top 3 free zone options based on:
  - Business activities
  - Number of shareholders
  - Visa requirements
  - License tenure
  - Entity type
  - Preferred emirate

✅ **Fallback System**: Provides basic recommendations if API is unavailable

## Setup Instructions

### Option 1: Environment Variable (Recommended for Production)

1. Get your OpenAI API key from https://platform.openai.com/api-keys

2. Run the app with the API key:
```bash
flutter run -d chrome --dart-define=OPENAI_API_KEY=your-api-key-here
```

### Option 2: Temporary Development Setup

1. Open `lib/config/app_config.dart`
2. Replace the `defaultValue` with your API key:
```dart
static const String openAiApiKey = String.fromEnvironment(
  'OPENAI_API_KEY',
  defaultValue: 'sk-your-actual-api-key-here', // Add your key here temporarily
);
```
⚠️ **Warning**: Never commit your API key to version control!

### Option 3: Backend Proxy (Most Secure for Production)

For production apps, it's recommended to:
1. Store the API key on your backend server
2. Create a proxy endpoint that calls OpenAI
3. Update `OpenAIService` to call your backend instead

## Usage

The AI recommendations are automatically triggered when users reach the "Smart Recommender" step after completing:
1. Business Activities selection
2. Shareholders count
3. Visa requirements
4. License tenure
5. Entity type selection
6. Emirate selection

## How It Works

1. **User completes setup flow** → Provides all business requirements
2. **AI Analysis** → GPT-4 analyzes the inputs and free zone options
3. **Recommendations** → Returns top 3 options with:
   - Detailed pricing breakdown
   - Cost comparisons
   - Key benefits
   - Total first-year costs
   - Best value recommendation

## API Response Format

The AI provides structured recommendations including:
- Top 3 recommended free zones with reasoning
- Estimated pricing breakdown (license, visas, office, setup fees)
- Cost comparison between options
- Key benefits for specific activities
- Total estimated first-year cost for each
- Best value recommendation with justification

## Fallback Behavior

If the OpenAI API is unavailable or not configured:
- System automatically provides rule-based recommendations
- Uses business logic to suggest relevant free zones
- Shows general pricing estimates
- Displays note about AI being temporarily unavailable

## Cost Considerations

- GPT-4 API costs approximately $0.03 per 1K prompt tokens
- Average recommendation request: ~500 tokens input + 1500 tokens output
- Estimated cost per recommendation: ~$0.05-0.10
- Consider implementing request caching for cost optimization

## Security Best Practices

1. ✅ Never hardcode API keys in source code
2. ✅ Use environment variables or secure storage
3. ✅ Implement rate limiting
4. ✅ Add request validation
5. ✅ Monitor API usage and costs
6. ✅ Consider backend proxy for production

## Future Enhancements

- [ ] Cache recommendations for similar queries
- [ ] Add retry logic with exponential backoff
- [ ] Implement streaming responses for real-time updates
- [ ] Add user feedback system to improve recommendations
- [ ] Store successful recommendations in database
- [ ] Multi-language support for recommendations

## Troubleshooting

**Issue**: "AI recommendations temporarily unavailable"
- **Solution**: Check that OPENAI_API_KEY is properly set

**Issue**: "Failed to get recommendations: 401"
- **Solution**: Verify your API key is valid and has credits

**Issue**: "Failed to get recommendations: 429"
- **Solution**: You've hit rate limits, wait and retry

**Issue**: Slow response times
- **Solution**: GPT-4 can take 5-15 seconds, this is normal

## Support

For issues or questions about the AI integration, please contact the development team.
