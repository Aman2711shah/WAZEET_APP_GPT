<div align="center">

# WAZEET — Flutter App

Smart UAE free zone discovery and company setup assistant — powered by GPT.

<!-- Add your screenshots/GIFs here -->
<!-- Example: -->
<!-- <img src="assets/images/screenshot_home.png" width="260" />
<img src="assets/images/screenshot_freezones.png" width="260" />
<img src="assets/images/screenshot_darkmode.png" width="260" /> -->

</div>

## ✨ Highlights

- Find and compare UAE free zones by emirate, industry, price, visas, and more
- AI-powered recommendations tailored to your business (OpenAI/GPT)
- Firebase-backed auth, data, storage, and optional Cloud Functions
- Polished UI with modern cards, tabs, filters, and compare mode
- Dark mode ready, responsive layouts (Web/Mobile/Desktop)

## 🤖 GPT Assistance (What it does)

### AI Business Expert Chatbot

The flagship AI feature is an interactive consultant that guides users through business setup decisions:

**How it works:**
1. User opens "AI Business Expert" from the home screen
2. AI asks targeted questions:
   - "What type of business are you planning to start?"
   - "How many shareholders will be involved?"
   - "Will you need employment visas? If so, how many?"
   - "Will you do business inside UAE or internationally?"
3. AI analyzes responses and provides 2-3 personalized freezone recommendations
4. User taps "View Freezones" to jump to the browser with pre-filled filters

**Technical details:**
- API: OpenAI Chat Completions
- Model: gpt-4o-mini (fast and cost-effective)
- Conversation state: Managed via Riverpod `StateNotifier`
- Context: Full conversation history sent to maintain coherent dialogue
- Code: `lib/services/ai_business_expert_service.dart` + `lib/ui/pages/ai_business_expert_page.dart`

### Company Setup Flow AI

Also available in the company setup wizard:
- Generates recommendations based on form inputs (industry, budget, visas, etc.)
- Code: `lib/services/openai_service.dart`
- Fallback: Provides default suggestions if no API key configured

**What you get:**
- Natural, consultant-like conversation experience
- Intelligent follow-up questions based on previous answers
- Personalized freezone recommendations with clear rationale
- Seamless transition to freezone browser with pre-populated search

## 🖼️ Screenshots / Demo

Add a few visuals to make the repo pop:
- Home / onboarding
- Free zone browser (by emirate / industry)
- Compare mode
- AI recommendation output
- Dark vs light mode

Tip: store images under `assets/images/` and reference them here.

## 📦 Features

- **AI Business Expert** 🤖: Interactive chatbot that asks smart questions about your business and recommends the best UAE free zones. Automatically pre-fills the freezone browser with your requirements.
- **Free zone Browser**: search, sort, and filter by license type, budget, visas, and remote setup
- **Compare Mode**: select multiple zones and view side-by-side
- **AI Advisor**: GPT-backed recommendations with clear rationale
- **Services & Community**: service request flow, posts, and tracking
- **Firebase**: Auth, Firestore, Storage, Functions-ready
- **Payments-ready**: Stripe scaffolding (see guide below)

## 🚀 Getting Started

### Prerequisites

- Flutter (3.9+ recommended)
- Dart (bundled with Flutter)
- Firebase project (for Auth/Firestore/Storage)
- OpenAI API key (optional but recommended)

### Setup (Quick Start)

1) Install dependencies

```bash
flutter pub get
```

2) Environment variables (.env)

Create a `.env` file at the project root:

```env
OPENAI_API_KEY=sk-...
# Optional overrides
# OPENAI_API_BASE=https://api.openai.com/v1
# OPENAI_MODEL=gpt-4
```

Notes:
- `.env` is loaded in `main()` before Firebase init.
- Key is accessed via `AppConfig.openAiApiKey`.
- Secrets are git-ignored; never commit real keys.

3) Firebase config

- Android: place `android/app/google-services.json`
- iOS: place `ios/Runner/GoogleService-Info.plist`

4) Run the app

```bash
flutter run
```

Optional: use VS Code task “Flutter: Run App”.

## 🧭 Detailed Guides

Start here for deeper setup and troubleshooting:

- AI setup: `docs/AI_RECOMMENDATIONS_SETUP.md`
- Firestore rules: `FIRESTORE_SECURITY_RULES_FIX.md`
- Payments & security: `SETUP_SECURITY_PAYMENTS.md`
- Freezone data import: `FREEZONE_PACKAGES_IMPORT_GUIDE.md`
- Freezone feature walkthrough: `FIND_YOUR_FREE_ZONE_README.md`
- File uploads: `FILE_UPLOAD_GUIDE.md`

## 🗂️ Project Structure

- `lib/` — main Flutter app code
- `lib/ui/pages/freezone_browser_page.dart` — free zone browser UI
- `lib/ui/widgets/freezone_card.dart` — enhanced zone cards
- `lib/services/openai_service.dart` — GPT recommendations
- `lib/config/app_config.dart` — dotenv-backed config
- `functions/` — optional Firebase Cloud Functions

## 🧪 Testing

```bash
flutter test
```

## 🔒 Security

- Do not commit API keys or service account files. Repo is configured to ignore them.
- If a secret is ever committed, rotate it and purge it from git history.

## 🙌 Contributing

PRs welcome! Please open an issue to discuss significant changes. Keep code modular, documented, and covered by tests when feasible.
