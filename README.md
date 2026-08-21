# PashuRakhshak (पशुरक्षक) - AI Animal Welfare & Care Mobile Application

<p align="center">
  <b>Protect, Identify & Care for Animals across India</b><br>
  <i>Powered by Flutter (Material 3), Riverpod, GoRouter, Supabase, TensorFlow Lite, Gemini Vision, Razorpay & 13 Indian Languages</i>
</p>

---

## 🌟 Key Highlights & Features

1. **Dual-Level Animal Identification (AI & ML)**
   - **Level 1 (Primary / On-Device ML)**: TensorFlow Lite classifier trained on iNaturalist taxonomy for instant local inference.
   - **Level 2 (Deep Vision / Cloud Fallback)**: Google Gemini Vision API hosted securely inside Supabase Edge Functions. Returns detailed species taxonomy, toxicity/danger assessment, diet, emergency first-aid, and legal protection status.
   - **Hybrid Arbitration**: Automatically falls back or escalates based on confidence score thresholds.

2. **Emergency Animal Rescue & NGO/Vet Locator ("Find Help")**
   - PostGIS geospatial nearby search within radius (km).
   - Direct emergency calling & directions.
   - 1-tap SOS Emergency Rescue report broadcast with severity tagging (Critical / Moderate / Minor) and GPS location.

3. **Pet Health & Medical Record System**
   - Digital Health Card with vaccination timeline & deworming schedules.
   - Daily medicine reminders with local notification alarms.
   - AI Symptom Checker for quick triage.

4. **Adopt / Buy Marketplace**
   - Verified listings for rescued strays, shelter pets, and cattle/livestock.
   - Role-based capabilities for Users, Sellers, and NGOs.

5. **Community & Lost/Found Pet Network**
   - Geo-tagged lost pet alerts with push notifications.
   - Animal rescue recovery stories and Q&A feed.

6. **Pashu Mitra AI (पशु मित्र)**
   - Multi-turn conversational veterinary assistant.
   - Speech-to-Text (STT) voice queries + Text-to-Speech (TTS) audio playback.

7. **Indian Regional Languages (13 Languages Supported)**
   - English, Hindi (हिन्दी), Bhojpuri (भोजपुरी), Bengali (বাংলা), Tamil (தமிழ்), Telugu (తెలుగు), Marathi (मराठी), Gujarati (ગુજરાતી), Punjabi (ਪੰਜਾਬੀ), Kannada (ಕನ್ನಡ), Malayalam (മലയാളം), Odia (ଓଡ଼ିଆ), Assamese (অসমীয়া).

8. **Razorpay Payments & Subscriptions**
   - Monthly Plan: ₹99 / month
   - Yearly Gold Guardian Plan: ₹999 / year
   - Extensible provider abstraction ready for future Stripe integration.

---

## 📂 Project Architecture

```
my_app/
├── lib/
│   ├── core/
│   │   ├── config/          # AppConfig, environment variables & endpoints
│   │   ├── constants/       # AppColors (Emerald Palette), Typography, Spacing
│   │   ├── router/          # GoRouter configuration & route definitions
│   │   ├── services/        # Supabase, AI Classifier, Razorpay, Voice, Location, Notifications
│   │   └── theme/           # Material 3 Light & Dark themes
│   ├── features/
│   │   ├── adopt/           # Adoption & Cattle marketplace (models, providers, screens)
│   │   ├── ai_assistant/    # Pashu Mitra AI multi-turn voice chat
│   │   ├── auth/            # Supabase Auth, 4 user roles, profile & login
│   │   ├── community/       # Feeds, Lost & Found alerts, rescue stories
│   │   ├── help/            # Vets/NGOs directory, PostGIS geospatial locator & SOS
│   │   ├── home/            # Home dashboard, alerts carousel & quick actions
│   │   ├── identify/        # Dual-Level AI scanner & detailed result screens
│   │   ├── pet_health/      # Health cards, medicine reminders & AI symptom checker
│   │   ├── premium/         # Razorpay subscription checkout & VIP perks
│   │   ├── profile/         # User profile, statistics & role switcher
│   │   └── settings/        # 13-Language selector & notification preferences
│   ├── l10n/                # 13 ARB translation files & runtime language provider
│   ├── shared/widgets/      # PashuButton, PashuCard, PashuTextField, PashuAppBar, TagBadge
│   └── main.dart            # Flutter entrypoint with Riverpod & GoRouter
├── supabase/
│   ├── functions/           # Edge Functions: identify-animal, razorpay-order, razorpay-webhook
│   └── migrations/          # PostgreSQL schema with PostGIS, tables, and RLS policies
├── test/                    # Unit & widget test suites
└── pubspec.yaml             # Flutter dependencies
```

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK 3.10+
- Dart SDK 3.0+

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Supabase Backend
1. Create a Supabase project at [https://supabase.com](https://supabase.com).
2. Execute the SQL migration in `supabase/migrations/20260101_init_pashurakhshak.sql` in your Supabase SQL Editor.
3. Deploy the Edge Functions:
   ```bash
   supabase functions deploy identify-animal --no-verify-jwt
   supabase functions deploy razorpay-order --no-verify-jwt
   supabase functions deploy razorpay-webhook --no-verify-jwt
   ```
4. Set Edge Function Secrets:
   ```bash
   supabase secrets set GEMINI_API_KEY=your_gemini_api_key
   supabase secrets set RAZORPAY_KEY_ID=your_razorpay_key_id
   supabase secrets set RAZORPAY_KEY_SECRET=your_razorpay_key_secret
   ```

### 4. Run the Flutter App
```bash
# Run on connected mobile device or emulator
flutter run
```

<!-- Module Architecture: Emergency SOS, Gemini Multimodal Vision AI, Overpass Vets -->
