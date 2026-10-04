# GymBuddy Flutter Mobile App

A high-performance AI nutrition and calorie tracking mobile application designed and built with **Flutter**, translated from the Figma design system.

---

## Design System

The app utilizes the custom dark-mode aesthetic from Figma:
- **Background**: `#050505` (Deep midnight black)
- **Cards**: `#111113` (Subtle elevated surface)
- **Inputs & Bottom Nav**: `#0B0B0D`
- **Elevated Surfaces**: `#19191C`
- **AI Accent**: `#20182F` (Deep amethyst background) / `#AC8CFF` (Purple badge & fats accent)
- **Primary Accent**: `#D6FF7F` (High-contrast electric lime green)
- **Text**: `#F7F7F7` (Primary), `#A2A2AA` (Secondary), `#777780` (Muted/Timestamps)
- **Typography**: Inter (Weights 400, 500, 600, 700)

---

## App Screens & Navigation Architecture

| Screen | Route | Description |
|---|---|---|
| **Splash** | `/splash` | Animated orbital circles, breathing monogram halo, sequential loading dots |
| **Onboarding** | `/onboarding` | 8-step setup progress, personal metrics, fitness goals, and WhatsApp phone |
| **Home** | `/home` | Greeting, calorie balance ring (29% consumed), macro cards (P/C/F), quick actions, meal list, AI insight |
| **Meal Scanner** | `/scanner` | Live camera reticle, animated sweeping laser beam, capture modes, gallery upload |
| **Meal Analysis** | `/meal-analysis` | Decoded meal view, 440 kcal breakdown, protein/carbs/fat, ingredient weights, Add to Today |
| **Text Logging** | `/text-logging` | Natural language logging ("2 eggs, 2 chapatis..."), voice mic, quick suggestion chips |
| **Daily Nutrition** | `/daily-nutrition` | Calorie ring, water tracking (+250ml quick-add), timeline with check markers |
| **Progress** | `/progress` | Weekly/Monthly/Yearly calorie bars, protein trend line, weight chart, check-in completion |
| **Meal History** | `/history` | Day-grouped diary (Today / Yesterday), search bar, high-protein filter chips |
| **WhatsApp Summary**| `/whatsapp-summary` | Shareable daily report card, WhatsApp recipient phone, simulated delivery feedback |
| **AI Copilot Chat** | `/ai-chat` | Interactive assistant, protein highlights, follow-up advice, quick prompt bubbles |
| **Profile** | `/profile` | User avatar, height/weight/age stats, settings toggles (theme, notifications, goals) |

---

## How to Run

### Requirements
- **Flutter SDK**: `C:\flutter\bin` (pre-installed, channel stable)

### Running on Chrome / Web
```powershell
cd "c:\Users\ranjith kumar\Desktop\gymbuddy\gymbuddy_app"
flutter run -d chrome
```

### Running on Android Emulator / Physical Device
```powershell
cd "c:\Users\ranjith kumar\Desktop\gymbuddy\gymbuddy_app"
flutter run -d android
```

### Building Release APK
```powershell
flutter build apk --release
```
The resulting APK will be saved at:
`build\app\outputs\flutter-apk\app-release.apk`
