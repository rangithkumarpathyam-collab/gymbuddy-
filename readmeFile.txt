==================================================
  GYMBUDDY 💪 — Your AI Nutrition & Calorie Tracker
==================================================

A Streamlit-powered AI chatbot that lets you snap a photo of your meal
or describe what you're eating, instantly get calorie and macro estimates,
and send a WhatsApp summary straight to your phone.

--------------------------------------------------
FEATURES
--------------------------------------------------
- 📸 Meal photo analysis — upload a photo and get instant calorie/macro breakdown
- 💬 Text-based meal logging — describe your food in plain language
- 🤖 Powered by Google Gemini 2.0 Flash AI
- 📲 WhatsApp summary via Twilio — sends your full daily nutrition report to your phone
- 🔐 Secure secrets management via Streamlit secrets

--------------------------------------------------
TECH STACK
--------------------------------------------------
- Frontend/UI  : Streamlit
- AI Model     : Google Gemini (google-genai SDK)
- Messaging    : Twilio WhatsApp API
- Language     : Python 3

--------------------------------------------------
PROJECT STRUCTURE
--------------------------------------------------
gymbuddy/
├── app.py              # Main Streamlit application
├── prompts.py          # AI system prompt and message templates
├── requirements.txt    # Python dependencies
├── .gitignore          # Files excluded from Git
└── .streamlit/
    └── secrets.toml    # API keys (NOT committed to Git)

--------------------------------------------------
SETUP & INSTALLATION
--------------------------------------------------

1. Clone the repository:
   git clone https://github.com/rangithkumarpathyam-collab/gymbuddy-.git
   cd gymbuddy-

2. Create and activate a virtual environment:
   python -m venv venv
   venv\Scripts\activate        (Windows)
   source venv/bin/activate     (Mac/Linux)

3. Install dependencies:
   pip install -r requirements.txt

4. Create your secrets file at .streamlit/secrets.toml:
   GEMINI_API_KEY       = "your-google-gemini-api-key"
   TWILIO_ACCOUNT_SID   = "your-twilio-account-sid"
   TWILIO_AUTH_TOKEN    = "your-twilio-auth-token"
   TWILIO_WHATSAPP_FROM = "whatsapp:+14155238886"
   TWILIO_CONTENT_SID   = "your-twilio-content-sid"

5. Run the app locally:
   streamlit run app.py

--------------------------------------------------
DEPLOYMENT (STREAMLIT CLOUD)
--------------------------------------------------
1. Push code to GitHub (secrets.toml is gitignored — never commit it).
2. Go to https://share.streamlit.io and connect your GitHub repo.
3. Add your secret keys in the Streamlit Cloud dashboard under
   "Advanced settings -> Secrets".
4. Deploy — Streamlit Cloud will auto-install from requirements.txt.

--------------------------------------------------
HOW IT WORKS
--------------------------------------------------
1. User fills in onboarding form (name, weight, gender, age, WhatsApp number).
2. A Gemini AI chat session is initialized with a nutrition-focused system prompt.
3. User snaps/uploads a meal photo or types a description.
4. Gemini analyzes the input and returns estimated calories and macros.
5. When ready, user clicks "Send to WhatsApp" to receive a full daily summary
   via Twilio's WhatsApp API.

--------------------------------------------------
ENVIRONMENT VARIABLES / SECRETS
--------------------------------------------------
Key                   | Description
--------------------- | -------------------------------------------
GEMINI_API_KEY        | Google AI Studio API key
TWILIO_ACCOUNT_SID    | Twilio account SID
TWILIO_AUTH_TOKEN     | Twilio auth token
TWILIO_WHATSAPP_FROM  | Twilio WhatsApp sender number
TWILIO_CONTENT_SID    | Twilio content template SID for WhatsApp

--------------------------------------------------
AUTHOR
--------------------------------------------------
Ranjith Kumar
GitHub: https://github.com/rangithkumarpathyam-collab

--------------------------------------------------
LICENSE
--------------------------------------------------
MIT License — feel free to use and modify.
==================================================
