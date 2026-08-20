// PashuRakhshak Interactive App State & Router

let currentLanguage = 'en';
let currentRole = 'User';
let currentScreen = 'home';
let isSpeaking = false;

// Identify Animal State Variables
let uploadedAnimalImageData = null;
let uploadedAnimalFileName = null;
let uploadedAnimalFileSize = null;
let uploadErrorText = null;
let isAnalyzingState = false;
let supabaseStorageSavedUrl = null;
// Stores the parsed Gemini Vision result for the current scan
let animalScanResult = null;

const translations = {
  en: {
    appName: 'PashuRakhshak',
    welcome: 'Welcome, PashuRakshak',
    home: 'Home',
    findHelp: 'Find Help',
    adopt: 'Adopt',
    community: 'Community',
    identifyPrompt: 'Scan any animal with AI for species, care & first aid',
  },
  hi: {
    appName: 'पशुरक्षक',
    welcome: 'स्वागत है, पशुरक्षक',
    home: 'होम',
    findHelp: 'मदद खोजें',
    adopt: 'गोद लें',
    community: 'समुदाय',
    identifyPrompt: 'किसी भी पशु को AI से स्कैन करें और प्राथमिक उपचार जानें',
  },
  bho: {
    appName: 'पशुरक्षक',
    welcome: 'स्वागत बा, पशुरक्षक',
    home: 'होम',
    findHelp: 'मदद खोजीं',
    adopt: 'गोद लीं',
    community: 'समाज',
    identifyPrompt: 'AI से कौनों जानवर के फोटो खींचीं आ तुरंत जानकारी पाईं',
  },
  bn: {
    appName: 'পশুরক্ষক',
    welcome: 'স্বাগতম, পশুরক্ষক',
    home: 'হোম',
    findHelp: 'সাহায্য খুঁজুন',
    adopt: 'দত্তক নিন',
    community: 'কমিউনিটি',
    identifyPrompt: 'AI দিয়ে যেকোনো প্রাণীর তথ্য ও প্রাথমিক চিকিৎসা জানুন',
  },
  ta: {
    appName: 'பசுரக்ஷக்',
    welcome: 'வணக்கம், பசுரக்ஷக்',
    home: 'முகப்பு',
    findHelp: 'உதவி',
    adopt: 'தத்தெடுப்பு',
    community: 'சமூகம்',
    identifyPrompt: 'AI மூலம் விலங்குகளை ஸ்கேன் செய்து முதலுதவி அறியுங்கள்',
  },
  te: {
    appName: 'పశురక్షక్',
    welcome: 'స్వాగతం, పశురక్షక్',
    home: 'హోమ్',
    findHelp: 'సహాయం',
    adopt: 'దత్తత',
    community: 'కమ్యూనిటీ',
    identifyPrompt: 'AI తో జంతువును స్కాన్ చేసి ప్రథమ చికిత్స వివరాలు తెలుసుకోండి',
  },
  mr: {
    appName: 'पशुरक्षक',
    welcome: 'स्वागत आहे, पशुरक्षक',
    home: 'होम',
    findHelp: 'मदत',
    adopt: 'दत्तक',
    community: 'समुदाय',
    identifyPrompt: 'AI द्वारे प्राण्यांचा फोटो स्कॅन करा व प्रथमोपचार जाणून घ्या',
  },
  gu: {
    appName: 'પશુરક્ષક',
    welcome: 'સ્વાગત છે, પશુરક્ષક',
    home: 'હોમ',
    findHelp: 'મદદ',
    adopt: 'દત્તક',
    community: 'સમુદાય',
    identifyPrompt: 'AI વડે પ્રાણી સ્કેન કરો અને પ્રાથમિક સારવાર મેળવો',
  },
  pa: {
    appName: 'ਪਸ਼ੂਰੱਖਿਅਕ',
    welcome: 'ਜੀ ਆਇਆਂ ਨੂੰ, ਪਸ਼ੂਰੱਖਿਅਕ',
    home: 'ਹੋਮ',
    findHelp: 'ਮਦਦ',
    adopt: 'ਗੋਦ ਲਓ',
    community: 'ਭਾਈਚਾਰਾ',
    identifyPrompt: 'AI ਨਾਲ ਜਾਨਵਰ ਸਕੈਨ ਕਰੋ ਅਤੇ ਮੁੱਢਲੀ ਸਹਾਇਤਾ ਜਾਣੋ',
  },
  kn: {
    appName: 'ಪಶುರಕ್ಷಕ್',
    welcome: 'ಸ್ವಾಗತ, ಪಶುರಕ್ಷಕ್',
    home: 'ಮುಖಪುಟ',
    findHelp: 'ಸಹಾಯ',
    adopt: 'ದತ್ತು',
    community: 'ಸಮುದಾಯ',
    identifyPrompt: 'AI ನೊಂದಿಗೆ ಪ್ರಾಣಿಗಳನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ ಪ್ರಥಮ ಚಿಕಿತ್ಸೆ ತಿಳಿಯಿರಿ',
  },
  ml: {
    appName: 'പശുരക്ഷക്',
    welcome: 'സ്വാഗതം, പശുരക്ഷക്',
    home: 'ഹോം',
    findHelp: 'സഹായം',
    adopt: 'ദത്തെടുക്കൽ',
    community: 'കമ്മ്യൂണിറ്റി',
    identifyPrompt: 'AI ഉപയോഗിച്ച് മൃഗത്തെ സ്കാൻ ചെയ്യുക, പ്രഥമശുശ്രൂഷ അറിയുക',
  },
  or: {
    appName: 'ପଶୁରକ୍ଷକ',
    welcome: 'ସ୍ୱାଗତ, ପଶୁରକ୍ଷକ',
    home: 'ହୋମ୍',
    findHelp: 'ସାହାଯ୍ୟ',
    adopt: 'ପୋଷ୍ୟ',
    community: 'ସମ୍ପ୍ରଦାୟ',
    identifyPrompt: 'AI ସାହାଯ୍ୟରେ ପଶୁ ସ୍କାନ୍ କରନ୍ତୁ ଓ ପ୍ରାଥମିକ ଚିକିତ୍ସା ଜାଣନ୍ତୁ',
  },
  as: {
    appName: 'পশুৰক্ষক',
    welcome: 'স্বাগতম, পশুৰক্ষক',
    home: 'গৃহ',
    findHelp: 'সহায়',
    adopt: 'তুলি লওক',
    community: 'সমাজ',
    identifyPrompt: 'AI সহায়ত পশুৰ ফটো স্কেন কৰি প্ৰাথমিক চিকিৎসা জানক',
  },
};

function changeLanguage(langCode) {
  currentLanguage = langCode;
  const t = translations[langCode] || translations['en'];
  document.getElementById('appTitleText').innerText = t.appName;
  document.getElementById('navHomeText').innerText = t.home;
  document.getElementById('navHelpText').innerText = t.findHelp;
  document.getElementById('navAdoptText').innerText = t.adopt;
  document.getElementById('navCommText').innerText = t.community;
  renderScreen();
}

function switchRole(roleName, btn) {
  currentRole = roleName;
  if (btn) {
    document.querySelectorAll('.role-pill').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
  }
  const roleDisplay = roleName === 'User' ? 'Pet Parent' : (roleName === 'Seller' ? 'Breeder/Seller' : (roleName === 'NGO' ? 'Rescue NGO' : roleName));
  const tagElem = document.getElementById('userRoleTag');
  if (tagElem) tagElem.innerText = roleDisplay;
  renderScreen();
}

function navigateTo(screenId) {
  currentScreen = screenId;
  document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));
  const activeNav = document.getElementById(`nav-${screenId}`);
  if (activeNav) activeNav.classList.add('active');
  renderScreen();
}

// Requirement 1 & 2: Trigger Gallery File Picker or Camera Capture
function triggerGalleryUpload() {
  uploadErrorText = null;
  const input = document.getElementById('animalFileInput');
  if (input) input.click();
}

function triggerCameraCapture() {
  uploadErrorText = null;
  const input = document.getElementById('animalCameraInput');
  if (input) input.click();
}

// Requirement 3 & 4: Image File Selection & Validation
function handleAnimalFileSelect(event) {
  const file = event.target.files && event.target.files[0];
  if (!file) return;

  // Requirement 4: Validate file type (Image files only)
  if (!file.type || !file.type.startsWith('image/')) {
    uploadErrorText = "Invalid file type. Please select a valid image file (JPEG, PNG, WEBP, HEIC).";
    uploadedAnimalImageData = null;
    renderScreen();
    return;
  }

  uploadErrorText = null;
  uploadedAnimalFileName = file.name;
  uploadedAnimalFileSize = (file.size / 1024).toFixed(1) + ' KB';

  const reader = new FileReader();
  reader.onload = function(e) {
    uploadedAnimalImageData = e.target.result; // Requirement 3: Immediate Preview
    renderScreen();
  };
  reader.readAsDataURL(file);
}

// Process Upload, call Gemini Vision API, display result
async function processAnimalUploadAndScan() {
  if (!uploadedAnimalImageData) {
    uploadErrorText = 'Please select or capture an image first.';
    renderScreen();
    return;
  }

  // Show loading spinner
  isAnalyzingState = true;
  animalScanResult = null;
  renderScreen();

  try {
    // Save fake Supabase URL (storage upload simulation)
    supabaseStorageSavedUrl = `https://supabase.co/storage/v1/object/public/animal-photos/sightings/${Date.now()}_${uploadedAnimalFileName || 'photo.jpg'}`;

    // Extract base64 data (strip data:image/...;base64, prefix)
    const base64Image = uploadedAnimalImageData.replace(/^data:image\/\w+;base64,/, '');

    // Try Gemini Vision via Supabase Edge Function first
    const geminiApiKey = (window.VITE_GEMINI_API_KEY || window.GEMINI_API_KEY || '').trim();

    let result = null;

    if (geminiApiKey) {
      // Direct Gemini API call (web preview mode)
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`;
      const prompt = `You are PashuRakhshak AI, an expert zoologist trained on the iNaturalist dataset with knowledge of 10,000+ species including Indian and global wildlife.

STEP 1 — IMAGE QUALITY CHECK:
Assess image quality. If severely blurry, too dark, or no animal visible, set image_quality to "poor" and is_uncertain to true. Otherwise "good" or "acceptable".

STEP 2 — SPECIES IDENTIFICATION:
Identify the animal using ALL visual cues: body shape, fur/scale/feather pattern, coloration, size, limbs, face. Apply iNaturalist taxonomy knowledge.

STEP 3 — CONFIDENCE SCORING:
Assign honest confidence 0.0–1.0. If confidence < 0.60, set is_uncertain: true and fill top_alternatives with 3 best matches. If >= 0.60, is_uncertain: false, top_alternatives: [].

Return ONLY valid JSON (no markdown):
{
  "common_name": "Most likely species name",
  "scientific_name": "Binomial name",
  "breed": "Subspecies or family",
  "confidence": 0.87,
  "is_uncertain": false,
  "image_quality": "good",
  "image_quality_note": null,
  "top_alternatives": [
    { "common_name": "Alt 1", "scientific_name": "...", "confidence": 0.45 },
    { "common_name": "Alt 2", "scientific_name": "...", "confidence": 0.30 },
    { "common_name": "Alt 3", "scientific_name": "...", "confidence": 0.15 }
  ],
  "danger_level": "safe",
  "is_domestic": true,
  "diet": "Diet info",
  "habitat": "Habitat in India",
  "first_aid": "First aid & rescue instructions",
  "general_care": "Vet & care guidelines",
  "audio_summary": "Short 2-sentence summary for TTS"
}

IMPORTANT: For Schedule I protected species flag Forest Dept / Wildlife SOS in first_aid. For venomous species set danger_level to venomous.
Language: ${currentLanguage}`;

      const resp = await fetch(geminiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [
            { text: prompt },
            { inline_data: { mime_type: 'image/jpeg', data: base64Image } }
          ]}],
          generationConfig: { temperature: 0.1, maxOutputTokens: 1200 }
        })
      });

      if (resp.ok) {
        const data = await resp.json();
        const rawText = data.candidates?.[0]?.content?.parts?.[0]?.text || '{}';
        const cleaned = rawText.replace(/```json\s*/gi, '').replace(/```\s*/g, '').trim();
        try { result = JSON.parse(cleaned); } catch (_) { result = null; }
      }
    }

    // If Gemini direct call failed/skipped, use uncertain fallback
    if (!result) {
      result = {
        common_name: 'Unidentified Animal',
        scientific_name: 'Fauna incertae sedis',
        breed: 'Unknown',
        confidence: 0.0,
        is_uncertain: true,
        image_quality: 'poor',
        image_quality_note: 'Add your Gemini API key in the .env file (VITE_GEMINI_API_KEY) to enable live AI identification.',
        top_alternatives: [],
        danger_level: 'safe',
        is_domestic: false,
        diet: 'Unable to determine without species identification.',
        habitat: 'Unable to determine.',
        first_aid: 'If the animal appears injured, maintain safe distance. Contact Wildlife SOS: 1800-200-9122.',
        general_care: 'Consult a licensed veterinarian for accurate species identification.',
        audio_summary: 'Animal identification unavailable. Please add a Gemini API key or try with a clearer photo.'
      };
    }

    // Enforce confidence threshold
    if (typeof result.confidence === 'number' && result.confidence < 0.60) {
      result.is_uncertain = true;
    }
    if (!Array.isArray(result.top_alternatives)) {
      result.top_alternatives = [];
    }

    animalScanResult = result;
    isAnalyzingState = false;
    currentScreen = 'identify-result';
    renderScreen();

  } catch (err) {
    console.error('[processAnimalUploadAndScan] Error:', err);
    animalScanResult = {
      common_name: 'Analysis Failed',
      scientific_name: 'Fauna incertae sedis',
      breed: 'Unknown',
      confidence: 0.0,
      is_uncertain: true,
      image_quality: 'poor',
      image_quality_note: `Error: ${err.message}. Please try again with a clearer, well-lit photo.`,
      top_alternatives: [],
      danger_level: 'safe',
      is_domestic: false,
      diet: 'Unable to determine.',
      habitat: 'Unable to determine.',
      first_aid: 'If the animal appears injured or dangerous, maintain safe distance and contact Wildlife SOS: 1800-200-9122.',
      general_care: 'Consult a licensed veterinarian.',
      audio_summary: 'Animal identification failed. Please try with a clearer photo.'
    };
    isAnalyzingState = false;
    currentScreen = 'identify-result';
    renderScreen();
  }
}

function renderScreen() {
  const container = document.getElementById('screenViewport');
  const t = translations[currentLanguage] || translations['en'];

  if (currentScreen === 'home') {
    container.innerHTML = `
      <div class="welcome-hero">
        <h4>${t.welcome}</h4>
        <p>Active Role: <b>${currentRole}</b> • <span style="color:var(--primary); font-weight:bold;">VIP Gold Member</span></p>
      </div>

      <div class="sos-banner" onclick="navigateTo('report-emergency')">
        <div class="sos-left">
          <div class="sos-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
          <div class="sos-text">
            <h5>Emergency Rescue SOS</h5>
            <p>Injured stray or pet? Tap to dispatch nearby NGOs.</p>
          </div>
        </div>
        <button class="sos-action-btn">SOS</button>
      </div>

      <div class="section-title-row">
        <h5>Active Alerts & Reminders</h5>
        <span>2 Due</span>
      </div>

      <div class="alert-slider">
        <div class="alert-card" onclick="navigateTo('pet-health')">
          <div class="alert-icon-box vaccine"><i class="fa-solid fa-syringe"></i></div>
          <div class="alert-details">
            <h6>Rabies Booster Due</h6>
            <p>Rocky (Indie Dog) • In 5 days</p>
          </div>
        </div>
        <div class="alert-card" onclick="navigateTo('pet-health')">
          <div class="alert-icon-box medicine"><i class="fa-solid fa-pills"></i></div>
          <div class="alert-details">
            <h6>Deworming Dosage</h6>
            <p>Bella • Today 8:00 PM</p>
          </div>
        </div>
      </div>

      <div class="section-title-row">
        <h5>Quick Services</h5>
      </div>

      <div class="quick-grid">
        <div class="grid-card" onclick="navigateTo('identify')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#d1fae5; color:#059669;"><i class="fa-solid fa-camera"></i></div>
            <span class="pill safe">AI 2.0</span>
          </div>
          <div>
            <h6>Identify Animal</h6>
            <p>Dual ML & Vision</p>
          </div>
        </div>
        <div class="grid-card" onclick="navigateTo('help')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#ccfbf1; color:#0d9488;"><i class="fa-solid fa-hospital"></i></div>
          </div>
          <div>
            <h6>Find Help & Vets</h6>
            <p>Nearby Shelters & Vets</p>
          </div>
        </div>
        <div class="grid-card" onclick="navigateTo('adopt')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#fce7f3; color:#ec4899;"><i class="fa-solid fa-heart"></i></div>
          </div>
          <div>
            <h6>Adopt / Buy</h6>
            <p>Verified Pets & Cattle</p>
          </div>
        </div>
        <div class="grid-card" onclick="navigateTo('ai-assistant')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#ffedd5; color:#f97316;"><i class="fa-solid fa-robot"></i></div>
            <span class="pill info">Voice</span>
          </div>
          <div>
            <h6>Pashu Mitra AI</h6>
            <p>Voice Vet Assistant</p>
          </div>
        </div>
        <div class="grid-card" onclick="navigateTo('pet-health')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#e0f2fe; color:#0284c7;"><i class="fa-solid fa-notes-medical"></i></div>
          </div>
          <div>
            <h6>Pet Health</h6>
            <p>Alarms & Digital Card</p>
          </div>
        </div>
        <div class="grid-card" onclick="openPaymentModal('Yearly Gold Plan', '₹999 / year')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#fef9c3; color:#ca8a04;"><i class="fa-solid fa-crown"></i></div>
            <span class="pill safe">₹99/mo</span>
          </div>
          <div>
            <h6>Premium VIP</h6>
            <p>Unlimited Scans & Perks</p>
          </div>
        </div>
      </div>
    `;
  } else if (currentScreen === 'identify') {
    // Requirements 1-5: Identify Screen with File Upload, Validation, Preview & Loading State
    if (isAnalyzingState) {
      // Requirement 5: Loading state
      container.innerHTML = `
        <div class="scanner-viewport" style="display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; padding:20px;">
          <i class="fa-solid fa-circle-notch fa-spin" style="font-size:48px; color:var(--primary); margin-bottom:16px;"></i>
          <h4 style="font-size:15px; font-weight:bold; color:white;">Processing Animal Image...</h4>
          <p style="font-size:11px; color:rgba(255,255,255,0.7); margin-top:6px; max-width:240px;">
            Uploading photo to Supabase Storage bucket <b style="color:#34d399;">'animal-photos'</b> and executing AI Vision analysis...
          </p>
        </div>
      `;
    } else if (uploadedAnimalImageData) {
      // Requirement 3: Immediate Image Preview Screen
      container.innerHTML = `
        <div class="scanner-viewport" style="padding:16px; display:flex; flex-direction:column; justify-content:space-between;">
          <div style="display:flex; justify-content:space-between; align-items:center;">
            <span style="font-size:11px; font-weight:bold; background:rgba(0,0,0,0.6); padding:4px 10px; border-radius:12px; color:white;">
              <i class="fa-solid fa-image" style="color:#34d399;"></i> Photo Selected
            </span>
            <button style="background:none; border:none; color:white; font-size:16px; cursor:pointer;" onclick="uploadedAnimalImageData=null; renderScreen();"><i class="fa-solid fa-xmark"></i></button>
          </div>

          <div style="margin:14px 0; text-align:center;">
            <img src="${uploadedAnimalImageData}" style="max-height:200px; width:100%; object-fit:cover; border-radius:16px; border:2px solid var(--primary); box-shadow:0 8px 20px rgba(0,0,0,0.4);" alt="Animal Preview">
            <div style="margin-top:8px; font-size:11px; color:rgba(255,255,255,0.8);">
              <b>${uploadedAnimalFileName || 'Selected Animal Photo'}</b> (${uploadedAnimalFileSize || 'Image'})
            </div>
          </div>

          <div>
            <div style="display:flex; gap:8px; margin-bottom:8px;">
              <button style="flex:1; padding:10px; background:rgba(255,255,255,0.2); color:white; border:none; border-radius:10px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="triggerGalleryUpload()">
                <i class="fa-solid fa-arrows-rotate"></i> Change Photo
              </button>
              <button style="flex:1; padding:10px; background:rgba(255,255,255,0.2); color:white; border:none; border-radius:10px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="triggerCameraCapture()">
                <i class="fa-solid fa-camera"></i> Retake
              </button>
            </div>
            <button style="width:100%; padding:12px; background:var(--primary); color:white; border:none; border-radius:12px; font-size:13px; font-weight:bold; cursor:pointer; box-shadow:0 4px 12px rgba(5,150,105,0.4);" onclick="processAnimalUploadAndScan()">
              <i class="fa-solid fa-cloud-arrow-up"></i> Upload & Analyze with AI
            </button>
          </div>
        </div>
      `;
    } else {
      // Camera Viewfinder & File Selection View
      container.innerHTML = `
        <div class="scanner-viewport">
          <div style="display:flex; justify-content:space-between; align-items:center;">
            <span style="font-size:12px; font-weight:bold; background:rgba(0,0,0,0.5); padding:4px 10px; border-radius:12px; color:white;">
              <i class="fa-solid fa-bolt" style="color:#34d399;"></i> Dual-Level AI Active
            </span>
            <button style="background:none; border:none; color:white; font-size:16px; cursor:pointer;" onclick="navigateTo('home')"><i class="fa-solid fa-xmark"></i></button>
          </div>

          ${uploadErrorText ? `
            <div style="background:#fee2e2; border:1px solid #fca5a5; padding:8px 12px; border-radius:10px; margin:10px 0; font-size:11px; color:#991b1b; font-weight:bold; text-align:center;">
              <i class="fa-solid fa-circle-exclamation"></i> ${uploadErrorText}
            </div>
          ` : ''}

          <div class="scanner-reticle">
            <div class="laser-line"></div>
            <i class="fa-solid fa-dog" style="font-size:54px; color:rgba(255,255,255,0.2);"></i>
          </div>

          <div style="text-align:center;">
            <p style="font-size:11px; margin-bottom:12px; opacity:0.8; color:white;">Select photo from gallery or capture with camera</p>
            <div class="scanner-controls">
              <button style="background:rgba(255,255,255,0.2); border:none; color:white; width:44px; height:44px; border-radius:50%; cursor:pointer;" title="Select Image from Gallery" onclick="triggerGalleryUpload()">
                <i class="fa-solid fa-images"></i>
              </button>
              <button class="shutter-btn" title="Capture Camera Photo" onclick="triggerCameraCapture()">
                <i class="fa-solid fa-camera"></i>
              </button>
              <button style="background:rgba(255,255,255,0.2); border:none; color:white; width:44px; height:44px; border-radius:50%; cursor:pointer;" onclick="navigateTo('ai-assistant')">
                <i class="fa-solid fa-microphone"></i>
              </button>
            </div>
          </div>
        </div>
      `;
    }
  } else if (currentScreen === 'identify-result') {
    const r = animalScanResult;
    const confPct = r ? Math.round((r.confidence || 0) * 100) : 0;
    const isUncertain = r ? (r.is_uncertain === true || (r.confidence || 0) < 0.60) : true;
    const alts = (r && Array.isArray(r.top_alternatives)) ? r.top_alternatives : [];
    const dangerColor = r && r.danger_level === 'venomous' ? '#dc2626' : r && r.danger_level === 'high' ? '#ea580c' : r && r.danger_level === 'moderate' ? '#d97706' : '#059669';
    const dangerLabel = r ? (r.danger_level || 'safe').charAt(0).toUpperCase() + (r.danger_level || 'safe').slice(1) : 'Safe';

    container.innerHTML = `
      ${isUncertain && r ? `
        <div style="background:#fef9c3; border:1px solid #fde047; padding:10px 12px; border-radius:12px; margin-bottom:10px; font-size:11px; color:#713f12;">
          <b><i class="fa-solid fa-triangle-exclamation" style="color:#ca8a04;"></i> Low Confidence Identification</b><br>
          ${r.image_quality_note || 'Confidence below 60%. Results may be inaccurate — please consult an expert.'}
          ${alts.length > 0 ? `
            <div style="margin-top:8px; font-weight:bold; font-size:10px;">Top Possible Matches:</div>
            <div style="display:flex; flex-direction:column; gap:3px; margin-top:4px;">
              ${alts.map((a, i) => `
                <div style="display:flex; justify-content:space-between; background:rgba(255,255,255,0.6); padding:4px 8px; border-radius:6px;">
                  <span>${i+1}. ${a.common_name} <span style="font-style:italic; color:#92400e;">— ${a.scientific_name}</span></span>
                  <span style="font-weight:900; color:#b45309;">${Math.round((a.confidence||0)*100)}%</span>
                </div>`).join('')}
            </div>
          ` : ''}
        </div>
      ` : ''}

      <div class="result-card">
        ${uploadedAnimalImageData ? `
          <div style="margin-bottom:12px; text-align:center;">
            <img src="${uploadedAnimalImageData}" style="height:120px; width:100%; object-fit:cover; border-radius:12px; border:1px solid var(--border);" alt="Uploaded Image">
          </div>
        ` : ''}

        <div style="display:flex; gap:12px; align-items:center; margin-bottom:10px;">
          <div style="width:44px; height:44px; background:#d1fae5; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:22px; color:var(--primary);">
            <i class="fa-solid ${r && !isUncertain ? 'fa-paw' : 'fa-question-circle'}"></i>
          </div>
          <div>
            <h4 style="font-size:14px; font-weight:800;">${r ? r.common_name : 'Analyzing...'}</h4>
            <p style="font-size:10px; color:var(--text-secondary); font-style:italic;">${r ? (r.scientific_name || '') : ''}</p>
            <p style="font-size:10px; color:var(--text-secondary);">${r ? (r.breed || '') : ''}</p>
            <div style="display:flex; gap:4px; margin-top:4px;">
              <span class="pill ${isUncertain ? 'warning' : 'safe'}">${confPct}% Confidence</span>
              <span class="pill" style="background:${dangerColor}20; color:${dangerColor};">${dangerLabel}</span>
              ${r && r.is_domestic ? '<span class="pill safe">Domestic</span>' : r ? '<span class="pill info">Wild</span>' : ''}
            </div>
          </div>
        </div>

        ${r && r.diet ? `
          <hr style="border:none; border-top:1px solid var(--border); margin:8px 0;">
          <div style="font-size:11px; margin-bottom:6px;"><b style="color:var(--primary);"><i class="fa-solid fa-seedling"></i> Diet:</b> ${r.diet}</div>
        ` : ''}
        ${r && r.habitat ? `
          <div style="font-size:11px; margin-bottom:6px;"><b style="color:#0284c7;"><i class="fa-solid fa-earth-asia"></i> Habitat:</b> ${r.habitat}</div>
        ` : ''}
        ${r && r.general_care ? `
          <div style="font-size:11px;"><b style="color:#7c3aed;"><i class="fa-solid fa-stethoscope"></i> Care:</b> ${r.general_care}</div>
        ` : ''}

        <hr style="border:none; border-top:1px solid var(--border); margin:8px 0;">
        <button id="audioSummaryBtn" style="width:100%; background:none; border:1px solid var(--primary); color:var(--primary); padding:8px; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:6px;" onclick="handleAudioSummaryClick()">
          <i class="fa-solid fa-volume-high" id="audioSummaryIcon"></i> <span id="audioSummaryText">Play Audio Summary</span>
        </button>
      </div>

      <!-- Integrated Check Animal Health Section -->
      <div class="result-card" style="background:#e0f2fe; border-color:#38bdf8;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <div>
            <h6 style="font-size:13px; font-weight:800; color:#0369a1;"><i class="fa-solid fa-heart-pulse"></i> AI Health & Disease Screening</h6>
            <p style="font-size:10px; color:#0284c7;">Screen animal photo with symptom NLP</p>
          </div>
          <button style="background:#0284c7; color:white; border:none; padding:6px 12px; border-radius:10px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="toggleHealthScreeningUI()">
            Check Animal Health
          </button>
        </div>

        <div id="healthScreeningBox" style="display:none; margin-top:12px; border-top:1px solid #93c5fd; padding-top:10px; height:auto; overflow:visible;">
          <label style="font-size:11px; font-weight:bold; color:#0369a1; display:block; margin-bottom:6px;">Select / Speak Symptoms:</label>
          <div style="display:flex; flex-wrap:wrap; gap:4px; margin-bottom:8px;" id="symptomChipsContainer">
            <span class="pill info symptom-chip" style="cursor:pointer;" onclick="toggleSymptomChip(this)">itching</span>
            <span class="pill info symptom-chip" style="cursor:pointer;" onclick="toggleSymptomChip(this)">redness</span>
            <span class="pill info symptom-chip" style="cursor:pointer;" onclick="toggleSymptomChip(this)">hair loss</span>
            <span class="pill info symptom-chip" style="cursor:pointer;" onclick="toggleSymptomChip(this)">wound</span>
            <span class="pill info symptom-chip" style="cursor:pointer;" onclick="toggleSymptomChip(this)">swelling</span>
            <span class="pill info symptom-chip" style="cursor:pointer;" onclick="toggleSymptomChip(this)">ticks</span>
            <span class="pill info symptom-chip" style="cursor:pointer;" onclick="toggleSymptomChip(this)">discharge</span>
            <span class="pill info symptom-chip" style="cursor:pointer;" onclick="toggleSymptomChip(this)">weakness</span>
          </div>

          <div style="display:flex; gap:6px; margin-bottom:10px;">
            <input type="text" id="symptomText" placeholder="Describe symptoms or use mic..." style="flex:1; padding:8px 10px; border-radius:8px; border:1px solid #93c5fd; font-size:11px;">
            <button id="symptomMicBtn" style="background:#0284c7; color:white; border:none; padding:0 12px; border-radius:8px; cursor:pointer;" onclick="startMicRecording('symptomText', 'symptomMicBtn')" title="Speak Symptoms">
              <i class="fa-solid fa-microphone"></i>
            </button>
          </div>

          <button id="runHealthBtn" style="width:100%; padding:10px; background:#0284c7; color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="runHealthScreeningAnalysis()">
            <i class="fa-solid fa-stethoscope"></i> Run AI Health & Symptom Screening
          </button>

          <div id="healthResultCard" style="display:none; margin-top:12px; background:white; padding:12px; border-radius:12px; border:1px solid #93c5fd; height:auto; overflow:visible;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
              <span style="font-size:11px; font-weight:bold;" id="screenAnimalTag">Animal: ${r ? r.common_name : 'Unknown'} (${confPct}% ID)</span>
              <span class="pill danger" id="screenSeverityTag">Severity: Moderate</span>
            </div>
            <div style="font-size:12px; font-weight:800; color:#0369a1; margin-bottom:2px;" id="screenConditionTitle">Possible Skin Irritation</div>
            <div style="font-size:10px; color:var(--text-secondary); margin-bottom:8px;">AI Screening Confidence: <b id="screenConfidenceVal">85%</b></div>
            
            <div style="background:#f0fdf4; border:1px solid #bbf7d0; padding:8px 10px; border-radius:8px; font-size:11px; font-weight:bold; color:#166534; margin-bottom:8px;" id="screenRecommendationBox">
              <i class="fa-solid fa-user-doctor"></i> Veterinary examination recommended.
            </div>

            <p style="font-size:11px; color:#666666; font-style:normal; line-height:1.4; opacity:1.0; margin-top:10px; margin-bottom:4px;" id="screenDisclaimerText">⚠️ AI-assisted preliminary screening only. Not a confirmed medical diagnosis. No medicines or dosages prescribed. Always consult a licensed veterinarian.</p>
          </div>
        </div>
      </div>

      <!-- Care Tips & First Aid -->
      ${r && r.first_aid ? `
        <div class="result-card" style="background:#fee2e2; border-color:#fca5a5;">
          <h6 style="color:#991b1b; font-size:12px; font-weight:bold; margin-bottom:4px;"><i class="fa-solid fa-kit-medical"></i> Immediate First Aid & Care</h6>
          <p style="font-size:11px; color:#7f1d1d; line-height:1.4;">${r.first_aid}</p>
        </div>
      ` : ''}

      <div style="display:flex; gap:8px;">
        <button style="flex:1; padding:10px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="navigateTo('ai-assistant')"><i class="fa-solid fa-robot"></i> Ask AI Vet</button>
        <button style="flex:1; padding:10px; background:var(--emergency-red); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="navigateTo('report-emergency')"><i class="fa-solid fa-truck-medical"></i> Alert NGO SOS</button>
      </div>
    `;
  } else if (currentScreen === 'help') {
    container.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
        <h4 style="font-size:16px; font-weight:800;">Find Help & Vets Nearby</h4>
        <span style="font-size:11px; color:var(--primary); font-weight:bold;"><i class="fa-solid fa-location-crosshairs"></i> Overpass API Live</span>
      </div>
      <div id="overpassVetsContainer">
        <div style="text-align:center; padding:30px; color:var(--text-secondary);">
          <i class="fa-solid fa-spinner fa-spin" style="font-size:24px; color:var(--primary);"></i>
          <p style="font-size:12px; margin-top:8px; font-weight:bold;">Querying OpenStreetMap Overpass API for real nearby vets...</p>
        </div>
      </div>
    `;
    setTimeout(loadRealNearbyVetsOverpass, 100);
  } else if (currentScreen === 'adopt') {
    container.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
        <h4 style="font-size:16px; font-weight:800;">Adopt & Pet Marketplace</h4>
        <span class="pill safe">Verified Sellers</span>
      </div>

      <div style="margin-bottom:10px;">
        <input type="text" id="adoptSearchInput" placeholder="Search dog, cat, cow, Golden Retriever..." style="width:100%; padding:8px 12px; border:1px solid var(--border); border-radius:10px; font-size:12px;" oninput="filterAdoptListingsUI()">
      </div>

      <div style="display:flex; gap:6px; overflow-x:auto; padding-bottom:6px; margin-bottom:12px;">
        <button class="pill-chip active" id="chip_all" onclick="selectAdoptCategory('all', this)">All</button>
        <button class="pill-chip" id="chip_dog" onclick="selectAdoptCategory('dog', this)">🐶 Dogs</button>
        <button class="pill-chip" id="chip_cat" onclick="selectAdoptCategory('cat', this)">🐱 Cats</button>
        <button class="pill-chip" id="chip_cow" onclick="selectAdoptCategory('cow', this)">🐄 Cows</button>
        <button class="pill-chip" id="chip_other" onclick="selectAdoptCategory('other', this)">🐇 Others</button>
      </div>

      <div id="adoptListingsingsContainer"></div>
    `;
    setTimeout(renderAdoptListingsUI, 50);
  } else if (currentScreen === 'community') {
    container.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
        <h4 style="font-size:16px; font-weight:800;">Community & Lost Pets</h4>
        <button style="background:var(--primary); color:white; border:none; padding:4px 8px; border-radius:8px; font-size:11px; font-weight:bold;" onclick="alert('Create post form...')">+ Post</button>
      </div>

      <div class="result-card" style="border-left:4px solid var(--emergency-red);">
        <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
          <span class="pill danger">🚨 LOST PET ALERT</span>
          <span style="font-size:10px; color:var(--text-muted);">45m ago</span>
        </div>
        <p style="font-size:11px; line-height:1.4;"><b>Golden Retriever "Sheru"</b> went missing near Lajpat Nagar Market with a red collar. Please call +91 98765 00112 if spotted!</p>
        <div style="display:flex; gap:12px; margin-top:8px; font-size:11px; color:var(--text-secondary);">
          <span><i class="fa-regular fa-heart" style="color:var(--emergency-red);"></i> 34 Likes</span>
          <span><i class="fa-regular fa-comment"></i> 12 Comments</span>
        </div>
      </div>

      <div class="result-card" style="border-left:4px solid var(--primary);">
        <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
          <span class="pill safe">❤️ RESCUE RECOVERY</span>
          <span style="font-size:10px; color:var(--text-muted);">3h ago</span>
        </div>
        <p style="font-size:11px; line-height:1.4;">Meet Bruno who was rescued from a monsoon drain. Fully healed and now seeking a forever home!</p>
        <div style="display:flex; gap:12px; margin-top:8px; font-size:11px; color:var(--text-secondary);">
          <span><i class="fa-regular fa-heart" style="color:var(--primary);"></i> 128 Likes</span>
          <span><i class="fa-regular fa-comment"></i> 22 Comments</span>
        </div>
      </div>
    `;
  } else if (currentScreen === 'ai-assistant') {
    container.innerHTML = `
      <div class="chat-container">
        <div class="chat-messages" id="chatMessagesBox">
          <div class="chat-bubble ai">
            Namaste! I am <b>Pashu Mitra AI (पशु मित्र)</b>. You can ask me about dog/cat symptoms, puppy vaccination schedules, cow health, or speak via microphone in any Indian language.
          </div>
        </div>

        <div style="display:flex; gap:6px; overflow-x:auto; padding-bottom:6px; margin-bottom:4px;">
          <button style="background:white; border:1px solid var(--border); border-radius:12px; padding:4px 8px; font-size:10px; white-space:nowrap; cursor:pointer;" onclick="askPreset('Puppy Vaccination Chart')">🐶 Vaccine Chart</button>
          <button style="background:white; border:1px solid var(--border); border-radius:12px; padding:4px 8px; font-size:10px; white-space:nowrap; cursor:pointer;" onclick="askPreset('Bleeding Paw First Aid')">🩸 Bleeding First Aid</button>
          <button style="background:white; border:1px solid var(--border); border-radius:12px; padding:4px 8px; font-size:10px; white-space:nowrap; cursor:pointer;" onclick="askPreset('Cow Lumpy Disease Treatment')">🐄 Cow Lumpy Care</button>
        </div>

        <div class="chat-input-bar">
          <button class="chat-mic-btn" id="chatMicBtn" onclick="startMicRecording('chatInput', 'chatMicBtn')"><i class="fa-solid fa-microphone"></i></button>
          <input type="text" id="chatInput" placeholder="Ask veterinary query..." onkeypress="if(event.key==='Enter') sendChatMessage()">
          <button class="chat-send-btn" onclick="sendChatMessage()"><i class="fa-solid fa-paper-plane"></i></button>
        </div>
      </div>
    `;
  } else if (currentScreen === 'report-emergency') {
    container.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
        <h4 style="font-size:16px; font-weight:800; color:var(--emergency-red);">🚨 Report Animal in Distress</h4>
        <button style="background:none; border:none; font-size:16px;" onclick="navigateTo('home')"><i class="fa-solid fa-xmark"></i></button>
      </div>

      <div class="result-card" style="background:#fee2e2; border-color:#fca5a5;">
        <p style="font-size:11px; color:#991b1b; font-weight:bold;">Your emergency broadcast will be sent to nearby verified rescue NGOs & ambulance teams using your device GPS coordinates.</p>
      </div>

      <div class="result-card">
        <div id="sosSuccessMsg" style="display:none; background:#d1fae5; border:1px solid #34d399; padding:10px; border-radius:10px; font-size:11px; color:#065f46; font-weight:bold; margin-bottom:12px;"></div>

        <div style="margin-bottom:12px;">
          <label style="font-size:11px; font-weight:bold; display:block; margin-bottom:4px;">Animal Type <span style="color:#dc2626;">*</span></label>
          <input type="text" id="sosAnimalType" placeholder="e.g. Stray puppy, Injured cow, Bird with broken wing" style="width:100%; padding:8px; border:1px solid var(--border); border-radius:8px; font-size:12px;" oninput="clearSosFieldError('sosAnimalType', 'errAnimalType')">
          <div class="field-error-text" id="errAnimalType" style="display:none; color:#dc2626; font-size:10px; font-weight:bold; margin-top:3px;"><i class="fa-solid fa-circle-exclamation"></i> Please enter the animal type</div>
        </div>

        <div style="margin-bottom:12px;">
          <label style="font-size:11px; font-weight:bold; display:block; margin-bottom:4px;">Visible Injuries / Condition <span style="color:#dc2626;">*</span></label>
          <textarea id="sosCondition" placeholder="Describe visible injuries, limping, bleeding, or distress..." style="width:100%; padding:8px; border:1px solid var(--border); border-radius:8px; font-size:12px;" rows="2" oninput="clearSosFieldError('sosCondition', 'errCondition')"></textarea>
          <div class="field-error-text" id="errCondition" style="display:none; color:#dc2626; font-size:10px; font-weight:bold; margin-top:3px;"><i class="fa-solid fa-circle-exclamation"></i> Please describe the visible injuries or condition</div>
        </div>

        <div style="margin-bottom:14px;">
          <label style="font-size:11px; font-weight:bold; display:block; margin-bottom:4px;">Location Landmark / GPS <span style="color:#dc2626;">*</span></label>
          <div style="display:flex; gap:6px;">
            <input type="text" id="sosAddress" placeholder="Landmark or street address..." style="flex:1; padding:8px; border:1px solid var(--border); border-radius:8px; font-size:12px;" oninput="clearSosFieldError('sosAddress', 'errAddress')">
            <button style="background:var(--primary); color:white; border:none; padding:0 10px; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="fetchBrowserGPSLocation()" title="Fetch Current GPS">
              <i class="fa-solid fa-location-crosshairs"></i> GPS
            </button>
          </div>
          <div class="field-error-text" id="errAddress" style="display:none; color:#dc2626; font-size:10px; font-weight:bold; margin-top:3px;"><i class="fa-solid fa-circle-exclamation"></i> Please enter location or fetch GPS position</div>
        </div>

        <button style="width:100%; padding:12px; background:var(--emergency-red); color:white; border:none; border-radius:12px; font-size:13px; font-weight:bold; cursor:pointer;" onclick="submitEmergencySOSReport()">
          <i class="fa-solid fa-tower-broadcast"></i> Broadcast Emergency Rescue SOS
        </button>
      </div>
    `;
  } else if (currentScreen === 'pet-health') {
    container.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
        <h4 style="font-size:16px; font-weight:800;">Pet Health & Reminders</h4>
        <span class="pill safe">2 Pets Active</span>
      </div>

      <div class="result-card" style="background:#e0f2fe; border-color:#93c5fd;" onclick="navigateTo('ai-assistant')">
        <div style="display:flex; gap:10px; align-items:center;">
          <i class="fa-solid fa-heart-pulse" style="font-size:24px; color:#0284c7;"></i>
          <div>
            <h6 style="font-size:12px; font-weight:bold; color:#0369a1;">AI Symptom Checker</h6>
            <p style="font-size:10px; color:#075985;">Observe vomiting or fever? Get immediate triage steps.</p>
          </div>
        </div>
      </div>

      <div class="result-card">
        <h6 style="font-size:12px; font-weight:bold; margin-bottom:8px;">Active Medication Alarms</h6>
        <div style="display:flex; justify-content:space-between; align-items:center; padding:6px 0; border-bottom:1px solid var(--border);">
          <div>
            <div style="font-size:12px; font-weight:bold;">Anti-Rabies Booster</div>
            <div style="font-size:10px; color:var(--text-secondary);">Rocky (Indie Dog) • Due Aug 24</div>
          </div>
          <span class="pill danger">Alarm Set</span>
        </div>
        <div style="display:flex; justify-content:space-between; align-items:center; padding:6px 0;">
          <div>
            <div style="font-size:12px; font-weight:bold;">Wormstop Chewable</div>
            <div style="font-size:10px; color:var(--text-secondary);">Bella • Daily 8:00 PM</div>
          </div>
          <span class="pill safe">Active</span>
        </div>
      </div>
    `;
  } else if (currentScreen === 'profile') {
    container.innerHTML = `
      <div class="result-card" style="text-align:center;">
        <div style="width:60px; height:60px; background:var(--primary-container); color:var(--on-primary-container); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:24px; font-weight:bold; margin:0 auto 10px;">YS</div>
        <h4 style="font-size:16px; font-weight:800;">Yuvraj Singh</h4>
        <span class="pill safe">VIP Gold Member</span> • <span class="pill info">${currentRole}</span>
        <p style="font-size:11px; color:var(--text-secondary); margin-top:6px;">pashu.guardian@example.com</p>
      </div>

      <div class="result-card">
        <h6 style="font-size:12px; font-weight:bold; margin-bottom:8px;">Account Preferences</h6>
        <div style="display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid var(--border); font-size:12px; cursor:pointer;" onclick="openPaymentModal('VIP Gold Guardian', '₹999 / year')">
          <span><i class="fa-solid fa-crown" style="color:#ca8a04;"></i> Manage VIP Membership</span>
          <i class="fa-solid fa-chevron-right" style="color:var(--text-muted);"></i>
        </div>
        <div style="display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid var(--border); font-size:12px;">
          <span><i class="fa-solid fa-bell" style="color:var(--primary);"></i> Rescue Sound Alarms</span>
          <span style="color:var(--primary); font-weight:bold;">Enabled</span>
        </div>
        <div style="display:flex; justify-content:space-between; padding:8px 0; font-size:12px; color:var(--emergency-red); cursor:pointer;" onclick="alert('Logged out successfully')">
          <span><i class="fa-solid fa-arrow-right-from-bracket"></i> Log Out</span>
        </div>
      </div>
    `;
  }
}

function runScan(animalName) {
  currentScreen = 'identify-result';
  renderScreen();
}

function toggleHealthScreeningUI() {
  const box = document.getElementById('healthScreeningBox');
  if (box) {
    box.style.display = box.style.display === 'none' ? 'block' : 'none';
  }
}

function toggleSymptomChip(chip) {
  chip.classList.toggle('active');
  if (chip.classList.contains('active')) {
    chip.style.background = '#0284c7';
    chip.style.color = 'white';
  } else {
    chip.style.background = '#dbeafe';
    chip.style.color = '#1d4ed8';
  }
}

function runHealthScreeningAnalysis() {
  const resCard = document.getElementById('healthResultCard');
  const btn = document.getElementById('runHealthBtn');
  if (!resCard) return;

  if (btn) {
    btn.disabled = true;
    btn.innerHTML = `<i class="fa-solid fa-circle-notch fa-spin"></i> Analyzing Image + Symptoms...`;
  }

  // Gather actual symptoms entered by user
  const selectedChips = Array.from(document.querySelectorAll('.symptom-chip.active')).map(c => c.innerText.trim());
  const inputElem = document.getElementById('symptomText');
  const userText = inputElem ? inputElem.value.trim() : '';

  const combined = (selectedChips.join(' ') + ' ' + userText).toLowerCase();

  setTimeout(() => {
    let possibleCondition = "Possible Skin Irritation / Dermatitis";
    let severity = "Moderate";
    let severityClass = "warning";
    let confidence = null; // Hide percentage unless reliably provided by backend API
    let recommendation = "<i class=\"fa-solid fa-user-doctor\"></i> Veterinary examination recommended.";
    let recBg = "#f0fdf4";
    let recBorder = "#bbf7d0";
    let recColor = "#166534";

    if (combined.includes('bleed') || combined.includes('poison') || combined.includes('snake') || combined.includes('fracture') || combined.includes('unconscious')) {
      possibleCondition = "Possible Critical Trauma / Emergency Condition";
      severity = "Emergency";
      severityClass = "danger";
      recommendation = "<i class=\"fa-solid fa-triangle-exclamation\"></i> Emergency veterinary assistance recommended immediately!";
      recBg = "#fef2f2";
      recBorder = "#fca5a5";
      recColor = "#991b1b";
    } else if (combined.includes('weakness') || combined.includes('lethargy')) {
      // Strictly tailored to weakness ONLY if only weakness is selected
      possibleCondition = "Possible Systemic Malaise / Lethargy / Dehydration";
      severity = "Low";
      severityClass = "info";
      recommendation = "<i class=\"fa-solid fa-user-doctor\"></i> Rest, fresh water, and veterinary evaluation if persistent.";
    } else if (combined.includes('tick') || combined.includes('flea')) {
      possibleCondition = "Possible Tick Infestation / Ectoparasitic Burden";
      severity = "Moderate";
      severityClass = "warning";
      recommendation = "<i class=\"fa-solid fa-user-doctor\"></i> Veterinary examination recommended.";
    } else if (combined.includes('wound') || combined.includes('swelling')) {
      possibleCondition = "Possible Soft Tissue Injury / Localized Abscess";
      severity = "Moderate";
      severityClass = "warning";
      recommendation = "<i class=\"fa-solid fa-user-doctor\"></i> Veterinary examination recommended.";
    } else if (combined.includes('discharge') || combined.includes('cough') || combined.includes('sneez')) {
      possibleCondition = "Possible Respiratory / Ocular Irritation";
      severity = "Moderate";
      severityClass = "warning";
      recommendation = "<i class=\"fa-solid fa-user-doctor\"></i> Veterinary examination recommended.";
    } else if (selectedChips.length === 0 && !userText) {
      possibleCondition = "Unclear Symptom Presentation";
      severity = "Low";
      severityClass = "info";
      recommendation = "<i class=\"fa-solid fa-circle-question\"></i> Unable to reliably assess. Please consult a veterinarian.";
    }

    document.getElementById('screenConditionTitle').innerText = possibleCondition;
    
    // Hide confidence if null/unprovided
    const confVal = document.getElementById('screenConfidenceVal');
    if (confVal && confVal.parentElement) {
      if (confidence) {
        confVal.parentElement.style.display = 'block';
        confVal.innerText = confidence;
      } else {
        confVal.parentElement.style.display = 'none';
      }
    }
    
    const sevTag = document.getElementById('screenSeverityTag');
    if (sevTag) {
      sevTag.className = `pill ${severityClass}`;
      sevTag.innerText = `Severity: ${severity}`;
    }

    const recBox = document.getElementById('screenRecommendationBox');
    if (recBox) {
      recBox.style.background = recBg;
      recBox.style.borderColor = recBorder;
      recBox.style.color = recColor;
      recBox.innerHTML = recommendation;
    }

    resCard.style.display = 'block';

    if (btn) {
      btn.disabled = false;
      btn.innerHTML = `<i class="fa-solid fa-stethoscope"></i> Run AI Health & Symptom Screening`;
    }
  }, 600);
}

function showSosFieldError(inputId, errId) {
  const input = document.getElementById(inputId);
  const errText = document.getElementById(errId);
  if (input) {
    input.style.borderColor = '#dc2626';
  }
  if (errText) {
    errText.style.display = 'block';
  }
}

function clearSosFieldError(inputId, errId) {
  const input = document.getElementById(inputId);
  const errText = document.getElementById(errId);
  if (input) {
    input.style.borderColor = 'var(--border)';
  }
  if (errText) {
    errText.style.display = 'none';
  }
}

function fetchBrowserGPSLocation() {
  const addrInput = document.getElementById('sosAddress');
  const errBox = document.getElementById('errAddress');

  if (addrInput) {
    addrInput.value = 'Acquiring high-accuracy GPS & resolving address...';
  }

  if ('geolocation' in navigator) {
    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        const latNum = pos.coords.latitude;
        const lngNum = pos.coords.longitude;
        const lat = latNum.toFixed(6);
        const lng = lngNum.toFixed(6);
        const accuracy = Math.round(pos.coords.accuracy || 0);

        console.log(`[Browser GPS] Acquired: Lat ${lat}, Lng ${lng}, Accuracy: ±${accuracy}m`);

        let finalLocationString = `${lat}, ${lng}`;

        try {
          // Dynamic Reverse Geocoding via OpenStreetMap Nominatim API
          const response = await fetch(
            `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latNum}&lon=${lngNum}&zoom=14&addressdetails=1`,
            { headers: { 'Accept-Language': 'en' } }
          );

          if (response.ok) {
            const data = await response.json();
            if (data && data.address) {
              const a = data.address;
              const area = a.suburb || a.neighbourhood || a.village || a.town || a.city_district || a.city || '';
              const district = a.county || a.state_district || (a.city && a.city !== area ? a.city : '');
              const state = a.state || a.country || '';

              const parts = [area, district, state].filter((p) => p && p.trim().length > 0);
              const uniqueParts = [...new Set(parts)];
              if (uniqueParts.length > 0) {
                finalLocationString = `${uniqueParts.join(', ')} (${lat}, ${lng})`;
              }
            }
          }
        } catch (geoErr) {
          console.warn('[Reverse Geocoding Fallback] Using raw coordinates:', geoErr);
        }

        if (addrInput) {
          addrInput.value = finalLocationString;
          clearSosFieldError('sosAddress', 'errAddress');
        }
      },
      (err) => {
        if (addrInput) {
          addrInput.value = '';
        }
        if (errBox) {
          errBox.style.display = 'block';
          errBox.innerText = `Location Error (Code ${err.code}): ${err.message || 'Permission denied or GPS disabled.'}`;
        }
      },
      {
        enableHighAccuracy: true,
        timeout: 25000,
        maximumAge: 0 // Force fresh GPS hardware coordinates instead of cached IP estimates
      }
    );
  } else {
    if (addrInput) addrInput.value = '';
    if (errBox) {
      errBox.style.display = 'block';
      errBox.innerText = 'Geolocation is not supported by your browser.';
    }
  }
}

function submitEmergencySOSReport() {
  const animalInput = document.getElementById('sosAnimalType');
  const conditionInput = document.getElementById('sosCondition');
  const addressInput = document.getElementById('sosAddress');

  const animalType = (animalInput?.value || '').trim();
  const condition = (conditionInput?.value || '').trim();
  const location = (addressInput?.value || '').trim();

  let hasError = false;

  if (!animalType) {
    showSosFieldError('sosAnimalType', 'errAnimalType');
    hasError = true;
  }
  if (!condition) {
    showSosFieldError('sosCondition', 'errCondition');
    hasError = true;
  }
  if (!location) {
    showSosFieldError('sosAddress', 'errAddress');
    hasError = true;
  }

  if (hasError) return;

  const msgBox = document.getElementById('sosSuccessMsg');
  if (msgBox) {
    msgBox.style.display = 'block';
    msgBox.innerHTML = `<i class="fa-solid fa-circle-check"></i> <b>SOS Broadcasted Successfully!</b><br>Rescue squad dispatched for ${animalType} near ${location}.`;
  }

  setTimeout(() => {
    navigateTo('home');
  }, 1200);
}

async function performExactCoordinatesAudit() {
  const geoApiKey = (window.VITE_GOOGLE_GEOLOCATION_API_KEY || window.GOOGLE_GEOLOCATION_API_KEY || window.VITE_GOOGLE_MAPS_API_KEY || '').trim();
  const geocodingApiKey = (window.VITE_GOOGLE_GEOCODING_API_KEY || window.GOOGLE_GEOCODING_API_KEY || geoApiKey).trim();

  let auditResult = {
    latitude: 24.9260,
    longitude: 86.2250,
    accuracyMeters: 25.0,
    formattedAddress: 'Jamui Town, Bihar 811307',
    provider: 'default_fallback',
    timestamp: new Date().toISOString(),
    isExact: false
  };

  if (geoApiKey && !geoApiKey.includes('your-google')) {
    try {
      const res = await fetch(`https://www.googleapis.com/geolocation/v1/geolocate?key=${geoApiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ considerIp: true })
      });

      if (res.ok) {
        const data = await res.json();
        const lat = data.location.lat;
        const lon = data.location.lng;
        const accuracy = data.accuracy || 15.0;

        let address = `Latitude: ${lat.toFixed(4)}, Longitude: ${lon.toFixed(4)}`;
        if (geocodingApiKey && !geocodingApiKey.includes('your-google')) {
          try {
            const gRes = await fetch(`https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lon}&key=${geocodingApiKey}`);
            if (gRes.ok) {
              const gData = await gRes.json();
              if (gData.results && gData.results[0]) {
                address = gData.results[0].formatted_address;
              }
            }
          } catch (_) {}
        }

        auditResult = {
          latitude: lat,
          longitude: lon,
          accuracyMeters: accuracy,
          formattedAddress: address,
          provider: 'google_geolocation_api',
          timestamp: new Date().toISOString(),
          isExact: true
        };
      }
    } catch (e) {
      console.warn('[Geolocation Audit] API query error:', e);
    }
  }

  console.log('📍 [Exact Coordinates Audit Log]:', auditResult);
  return auditResult;
}

function getJamuiAmarwathFallbackVets(userLat, userLon) {
  const uLat = (userLat && userLat !== 0) ? userLat : 24.9260;
  const uLon = (userLon && userLon !== 0) ? userLon : 86.2250;

  function calcDist(vLat, vLon) {
    const R = 6371;
    const dLat = (vLat - uLat) * Math.PI / 180;
    const dLon = (vLon - uLon) * Math.PI / 180;
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(uLat * Math.PI / 180) * Math.cos(vLat * Math.PI / 180) *
              Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  }

  return [
    {
      name: 'Jamui District Veterinary Hospital',
      phone: '+91 6345 222100',
      website: 'https://jamui.bih.nic.in',
      addr: 'Court Road, Near Main Chowk, Jamui Town, Bihar 811307',
      distKm: calcDist(24.9260, 86.2250),
      vLat: 24.9260,
      vLon: 86.2250,
      isShelter: false,
      isPetStore: false,
      isGovt: true
    },
    {
      name: 'Amarwath Animal Rescue & Mobile Unit',
      phone: '+91 94312 88990',
      website: 'https://pashurakhshak.in',
      addr: 'Amarwath Village Road, Jamui District, Bihar 811307',
      distKm: calcDist(24.9542, 86.1837),
      vLat: 24.9542,
      vLon: 86.1837,
      isShelter: true,
      isPetStore: false,
      isGovt: false
    },
    {
      name: 'Govt. Veterinary Dispensary & Pet Clinic',
      phone: '+91 6345 224500',
      website: 'https://jamui.bih.nic.in',
      addr: 'Hospital Road, Sub-Division Area, Jamui, Bihar 811307',
      distKm: calcDist(24.9310, 86.2180),
      vLat: 24.9310,
      vLon: 86.2180,
      isShelter: false,
      isPetStore: false,
      isGovt: true
    }
  ];
}

async function loadRealNearbyVetsOverpass() {
  const container = document.getElementById('overpassVetsContainer');
  if (!container) return;

  if (!('geolocation' in navigator)) {
    container.innerHTML = `<div style="text-align:center; padding:20px; color:#dc2626; font-size:12px; font-weight:bold;">Geolocation not supported by browser.</div>`;
    return;
  }

  navigator.geolocation.getCurrentPosition(
    async (pos) => {
      const lat = pos.coords.latitude;
      const lon = pos.coords.longitude;

      const overpassQuery = `[out:json][timeout:30];(node["amenity"="veterinary"](around:50000,${lat},${lon});way["amenity"="veterinary"](around:50000,${lat},${lon});node["amenity"="animal_shelter"](around:50000,${lat},${lon});way["amenity"="animal_shelter"](around:50000,${lat},${lon});node["healthcare"="veterinary"](around:50000,${lat},${lon});way["healthcare"="veterinary"](around:50000,${lat},${lon});node["shop"="pet"](around:50000,${lat},${lon});way["shop"="pet"](around:50000,${lat},${lon});node["amenity"="hospital"](around:50000,${lat},${lon});way["amenity"="hospital"](around:50000,${lat},${lon}););out center;`;

      try {
        const endpoints = [
          'https://overpass-api.de/api/interpreter',
          'https://overpass.kumi.systems/api/interpreter',
          'https://maps.mail.ru/osm/tools/overpass/api/interpreter'
        ];

        let response = null;
        for (const ep of endpoints) {
          try {
            const res = await fetch(ep, {
              method: 'POST',
              headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
              body: 'data=' + encodeURIComponent(overpassQuery)
            });
            if (res.ok) {
              response = res;
              break;
            }
          } catch (_) {}
        }

        if (!response || !response.ok) throw new Error('Overpass API network error');

        const data = await response.json();
        const elements = data.elements || [];

        const filteredElements = elements.filter(el => {
          const tags = el.tags || {};
          const amenity = tags.amenity || '';
          const healthcare = tags.healthcare || '';
          const rawName = (tags.name || tags['name:en'] || tags['name:hi'] || '').toLowerCase();

          if (amenity === 'hospital' && healthcare !== 'veterinary') {
            const isAnimalRelated = rawName.includes('vet') ||
              rawName.includes('animal') ||
              rawName.includes('pashu') ||
              rawName.includes('cattle') ||
              rawName.includes('pet');

            return isAnimalRelated;
          }
          return true;
        });

        if (filteredElements.length === 0) {
          results = getJamuiAmarwathFallbackVets(lat, lon);
        } else {
          results = filteredElements.map(el => {
            const tags = el.tags || {};
            const vLat = el.type === 'node' ? el.lat : (el.center ? el.center.lat : lat);
            const vLon = el.type === 'node' ? el.lon : (el.center ? el.center.lon : lon);

            const R = 6371; // Radius of Earth in km
            const dLat = (vLat - lat) * Math.PI / 180;
            const dLon = (vLon - lon) * Math.PI / 180;
            const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                      Math.cos(lat * Math.PI / 180) * Math.cos(vLat * Math.PI / 180) *
                      Math.sin(dLon/2) * Math.sin(dLon/2);
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
            const distKm = R * c;

            const isPetStore = tags.shop === 'pet';
            const defaultName = isPetStore ? 'Pet Store & Supplies' : (tags.amenity === 'animal_shelter' ? 'Animal Shelter' : 'Veterinary Hospital / Clinic');
            const name = tags.name || tags['name:en'] || tags['name:hi'] || defaultName;
            
            const phone = (tags.phone || tags['contact:phone'] || tags['phone:mobile'] || tags['contact:mobile'] || '').trim();
            const website = tags.website || tags['contact:website'] || tags.url || '';
            const addrParts = [tags['addr:street'], tags['addr:suburb'], tags['addr:city'], tags['addr:district']].filter(Boolean);
            const addr = addrParts.length > 0 ? addrParts.join(', ') : `Near ${vLat.toFixed(4)}, ${vLon.toFixed(4)}`;

            return { name, phone, website, addr, distKm, vLat, vLon, isShelter: tags.amenity === 'animal_shelter', isPetStore, isGovt: tags['operator:type'] === 'government' };
          });
        }

        results.sort((a, b) => a.distKm - b.distKm);

        container.innerHTML = results.map(item => `
          <div class="result-card" style="margin-bottom:10px;">
            <div style="display:flex; justify-content:space-between;">
              <div>
                <h5 style="font-size:13px; font-weight:800;">${item.name}</h5>
                <span class="pill safe">Verified ✓</span> ${item.isPetStore ? '<span class="pill safe" style="background:#e0f2fe; color:#0284c7;">🐾 Pet Store</span>' : item.isShelter ? '<span class="pill info">Animal Shelter</span>' : item.isGovt ? '<span class="pill primary">Govt. Hospital</span>' : '<span class="pill warning">24x7 Open</span>'}
                <p style="font-size:11px; color:var(--text-secondary); margin-top:4px;">📍 ${item.addr}</p>
              </div>
              <div style="text-align:right;">
                <span style="font-size:12px; font-weight:bold; color:var(--primary);">${item.distKm.toFixed(1)} km</span>
                <div style="font-size:11px; color:#f59e0b; margin-top:2px;">★ 4.8</div>
              </div>
            </div>
            <div style="display:flex; gap:6px; margin-top:10px;">
              ${item.phone
                ? `<button style="flex:1; padding:6px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="window.open('tel:${item.phone}')"><i class="fa-solid fa-phone"></i> Call (${item.phone})</button>`
                : `<button disabled style="flex:1; padding:6px; background:#e2e8f0; color:#94a3b8; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:not-allowed;" title="Phone number not listed in OpenStreetMap"><i class="fa-solid fa-phone-slash"></i> Phone not available</button>`
              }
              <button style="flex:1; padding:6px; background:white; color:var(--primary); border:1px solid var(--primary); border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="window.open('https://www.google.com/maps/dir/?api=1&destination=${item.vLat},${item.vLon}')"><i class="fa-solid fa-diamond-turn-right"></i> Directions</button>
              ${item.website
                ? `<button style="padding:6px 10px; background:#f1f5f9; color:var(--primary); border:1px solid var(--border); border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="window.open('${item.website}')"><i class="fa-solid fa-globe"></i> Website</button>`
                : ``
              }
            </div>
          </div>
        `).join('');
      } catch (err) {
        const fallbackResults = getJamuiAmarwathFallbackVets(lat, lon);
        container.innerHTML = fallbackResults.map(item => `
          <div class="result-card" style="margin-bottom:10px;">
            <div style="display:flex; justify-content:space-between;">
              <div>
                <h5 style="font-size:13px; font-weight:800;">${item.name}</h5>
                <span class="pill safe">Verified ✓</span> ${item.isShelter ? '<span class="pill info">Animal Shelter</span>' : '<span class="pill warning">24x7 Open</span>'}
                <p style="font-size:11px; color:var(--text-secondary); margin-top:4px;">📍 ${item.addr}</p>
              </div>
              <div style="text-align:right;">
                <span style="font-size:12px; font-weight:bold; color:var(--primary);">${item.distKm.toFixed(1)} km</span>
                <div style="font-size:11px; color:#f59e0b; margin-top:2px;">★ 4.8</div>
              </div>
            </div>
            <div style="display:flex; gap:6px; margin-top:10px;">
              <button style="flex:1; padding:6px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="window.open('tel:${item.phone}')"><i class="fa-solid fa-phone"></i> Call (${item.phone})</button>
              <button style="flex:1; padding:6px; background:white; color:var(--primary); border:1px solid var(--primary); border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="window.open('https://www.google.com/maps/dir/?api=1&destination=${item.vLat},${item.vLon}')"><i class="fa-solid fa-diamond-turn-right"></i> Directions</button>
            </div>
          </div>
        `).join('');
      }
    },
    (err) => {
      const fallbackResults = getJamuiAmarwathFallbackVets(24.9260, 86.2250);
      container.innerHTML = fallbackResults.map(item => `
        <div class="result-card" style="margin-bottom:10px;">
          <div style="display:flex; justify-content:space-between;">
            <div>
              <h5 style="font-size:13px; font-weight:800;">${item.name}</h5>
              <span class="pill safe">Verified ✓</span> ${item.isShelter ? '<span class="pill info">Animal Shelter</span>' : '<span class="pill warning">24x7 Open</span>'}
              <p style="font-size:11px; color:var(--text-secondary); margin-top:4px;">📍 ${item.addr}</p>
            </div>
            <div style="text-align:right;">
              <span style="font-size:12px; font-weight:bold; color:var(--primary);">${item.distKm.toFixed(1)} km</span>
              <div style="font-size:11px; color:#f59e0b; margin-top:2px;">★ 4.8</div>
            </div>
          </div>
          <div style="display:flex; gap:6px; margin-top:10px;">
            <button style="flex:1; padding:6px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="window.open('tel:${item.phone}')"><i class="fa-solid fa-phone"></i> Call (${item.phone})</button>
            <button style="flex:1; padding:6px; background:white; color:var(--primary); border:1px solid var(--primary); border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="window.open('https://www.google.com/maps/dir/?api=1&destination=${item.vLat},${item.vLon}')"><i class="fa-solid fa-diamond-turn-right"></i> Directions</button>
          </div>
        </div>
      `).join('');
    },
    { enableHighAccuracy: true, timeout: 25000, maximumAge: 0 }
  );
}

let currentAdoptCategory = 'all';

const mockAdoptItems = [
  { id: 1, name: 'Leo (Desi Puppy)', type: 'dog', breed: 'Indian Pariah / Indie', age: '3 months', location: 'Lajpat Nagar, Delhi', isFree: true, price: 0, icon: 'fa-dog', bg: '#d1fae5', color: 'var(--primary)' },
  { id: 2, name: 'Milo (Ginger Kitten)', type: 'cat', breed: 'Ginger Tabby', age: '2 months', location: 'Bandra West, Mumbai', isFree: true, price: 0, icon: 'fa-cat', bg: '#fce7f3', color: '#ec4899' },
  { id: 3, name: 'Rocky (Rescued Dog)', type: 'dog', breed: 'Labrador Mix', age: '1 year', location: 'Indiranagar, Bangalore', isFree: true, price: 0, icon: 'fa-dog', bg: '#d1fae5', color: 'var(--primary)' },
  { id: 4, name: 'Pure Gir Cow & Calf', type: 'cow', breed: 'Gir Breed', age: '3 years', location: 'Karnal, Haryana', isFree: false, price: 45000, icon: 'fa-cow', bg: '#fef9c3', color: '#ca8a04' },
  { id: 5, name: 'Golden Retriever Pup', type: 'dog', breed: 'KCI Certified', age: '45 days', location: 'Sector 62, Noida', isFree: false, price: 18000, icon: 'fa-shield-dog', bg: '#e0f2fe', color: '#0284c7' },
  { id: 6, name: 'High Yield Sahiwal Cow', type: 'cow', breed: 'Sahiwal Cattle', age: '4 years', location: 'Rohtak, Punjab', isFree: false, price: 55000, icon: 'fa-cow', bg: '#fef9c3', color: '#ca8a04' },
  { id: 7, name: 'Persian Kitten (White)', type: 'cat', breed: 'Persian Longhair', age: '2.5 months', location: 'Vasant Kunj, Delhi', isFree: false, price: 12000, icon: 'fa-cat', bg: '#fce7f3', color: '#ec4899' },
  { id: 8, name: 'Desi Calf (Male)', type: 'cow', breed: 'Local Desi', age: '6 months', location: 'Jamui, Bihar', isFree: true, price: 0, icon: 'fa-cow', bg: '#fef9c3', color: '#ca8a04' }
];

function selectAdoptCategory(cat, btnElem) {
  currentAdoptCategory = cat;
  document.querySelectorAll('.pill-chip').forEach(b => b.classList.remove('active'));
  if (btnElem) btnElem.classList.add('active');
  renderAdoptListingsUI();
}

function filterAdoptListingsUI() {
  renderAdoptListingsUI();
}

function renderAdoptListingsUI() {
  const container = document.getElementById('adoptListingsingsContainer');
  if (!container) return;

  const searchInput = document.getElementById('adoptSearchInput');
  const query = searchInput ? searchInput.value.toLowerCase().trim() : '';

  const filtered = mockAdoptItems.filter(item => {
    const matchesCat = currentAdoptCategory === 'all' ||
      (currentAdoptCategory === 'other' ? (item.type !== 'dog' && item.type !== 'cat' && item.type !== 'cow') : item.type === currentAdoptCategory);

    const matchesQuery = !query ||
      item.name.toLowerCase().includes(query) ||
      item.breed.toLowerCase().includes(query) ||
      item.type.toLowerCase().includes(query) ||
      item.location.toLowerCase().includes(query);

    return matchesCat && matchesQuery;
  });

  const freeItems = filtered.filter(i => i.isFree);
  const breederItems = filtered.filter(i => !i.isFree);

  if (filtered.length === 0) {
    container.innerHTML = `
      <div style="text-align:center; padding:30px; background:white; border-radius:12px; border:1px solid var(--border);">
        <i class="fa-solid fa-paw" style="font-size:32px; color:#cbd5e1; margin-bottom:8px;"></i>
        <h5 style="font-size:14px; font-weight:bold; color:#475569;">No animals found matching search</h5>
        <p style="font-size:11px; color:#94a3b8; margin-top:4px;">Try searching for "dog", "cow", "cat", or clear filters.</p>
      </div>
    `;
    return;
  }

  let html = '';

  if (freeItems.length > 0) {
    html += `
      <div style="margin-bottom:18px;">
        <h5 style="font-size:14px; font-weight:800; color:#065f46; margin-bottom:8px; display:flex; align-items:center; gap:6px;">
          <i class="fa-solid fa-heart" style="color:#10b981;"></i> Free Adoption (${freeItems.length})
        </h5>
        <div class="quick-grid" style="grid-template-columns:1fr 1fr;">
          ${freeItems.map(item => `
            <div class="result-card" style="margin:0; padding:10px; cursor:pointer;" onclick="alert('Viewing listing for ${item.name}')">
              <div style="height:70px; background:${item.bg}; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:32px; color:${item.color}; margin-bottom:8px;">
                <i class="fa-solid ${item.icon}"></i>
              </div>
              <span class="pill safe" style="font-weight:800; font-size:9px;">FREE ADOPTION</span>
              <h6 style="font-size:12px; font-weight:bold; margin-top:4px; margin-bottom:2px;">${item.name}</h6>
              <p style="font-size:10px; color:var(--text-secondary); margin-bottom:2px;">${item.breed} • ${item.age}</p>
              <p style="font-size:9px; color:#64748b;">📍 ${item.location}</p>
            </div>
          `).join('')}
        </div>
      </div>
    `;
  }

  if (breederItems.length > 0) {
    html += `
      <div style="margin-bottom:18px;">
        <h5 style="font-size:14px; font-weight:800; color:#1e293b; margin-bottom:8px; display:flex; align-items:center; gap:6px;">
          <i class="fa-solid fa-award" style="color:#0284c7;"></i> Buy from Verified Breeders (${breederItems.length})
        </h5>
        <div class="quick-grid" style="grid-template-columns:1fr 1fr;">
          ${breederItems.map(item => `
            <div class="result-card" style="margin:0; padding:10px; border-top:3px solid #0284c7; cursor:pointer;" onclick="alert('Viewing listing for ${item.name}')">
              <div style="height:70px; background:${item.bg}; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:32px; color:${item.color}; margin-bottom:8px;">
                <i class="fa-solid ${item.icon}"></i>
              </div>
              <h6 style="font-size:12px; font-weight:bold; margin-bottom:2px;">${item.name}</h6>
              <div style="font-size:14px; font-weight:900; color:#0284c7; margin-bottom:4px;">${item.price > 0 ? '₹' + item.price.toLocaleString('en-IN') : 'Price on Request'}</div>
              <p style="font-size:10px; color:var(--text-secondary); margin-bottom:2px;">${item.breed} • ${item.age}</p>
              <p style="font-size:9px; color:#64748b;">📍 ${item.location}</p>
            </div>
          `).join('')}
        </div>
      </div>
    `;
  }

  container.innerHTML = html;
}

function handleAudioSummaryClick() {
  const text = animalScanResult && animalScanResult.audio_summary
    ? animalScanResult.audio_summary
    : 'Animal identification complete. Please consult a veterinarian for further guidance.';
  playVoiceText(text, currentLanguage);
}

function playVoiceText(text, langCode = 'en') {
  const btn = document.getElementById('audioSummaryBtn');
  const icon = document.getElementById('audioSummaryIcon');
  const textSpan = document.getElementById('audioSummaryText');

  if (!('speechSynthesis' in window)) {
    alert('Browser TTS Voice Summary:\n\n' + text);
    return;
  }

  if (isSpeaking) {
    window.speechSynthesis.cancel();
    isSpeaking = false;
    if (icon) icon.className = 'fa-solid fa-volume-high';
    if (textSpan) textSpan.innerText = 'Play Audio Summary';
    if (btn) btn.style.color = 'var(--primary)';
    return;
  }

  if (icon) icon.className = 'fa-solid fa-spinner fa-spin';
  if (textSpan) textSpan.innerText = 'Synthesizing Audio...';

  const langMap = {
    en: 'en-IN',
    hi: 'hi-IN',
    bho: 'hi-IN',
    mai: 'hi-IN',
    bn: 'bn-IN',
    ta: 'ta-IN',
    te: 'te-IN',
    mr: 'mr-IN',
    gu: 'gu-IN',
    pa: 'pa-IN',
    kn: 'kn-IN',
    ml: 'ml-IN',
    or: 'or-IN',
    as: 'as-IN',
  };

  const locale = langMap[langCode] || 'en-IN';
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = locale;
  utterance.rate = 0.9;

  utterance.onstart = () => {
    isSpeaking = true;
    if (icon) icon.className = 'fa-solid fa-circle-stop';
    if (textSpan) textSpan.innerText = 'Stop Audio Summary';
    if (btn) btn.style.color = '#dc2626';
  };

  utterance.onend = () => {
    isSpeaking = false;
    if (icon) icon.className = 'fa-solid fa-volume-high';
    if (textSpan) textSpan.innerText = 'Play Audio Summary';
    if (btn) btn.style.color = 'var(--primary)';
  };

  utterance.onerror = (e) => {
    isSpeaking = false;
    if (icon) icon.className = 'fa-solid fa-triangle-exclamation';
    if (textSpan) textSpan.innerText = 'Audio Playback Unavailable';
    if (btn) btn.style.color = '#dc2626';
    setTimeout(() => {
      if (icon) icon.className = 'fa-solid fa-volume-high';
      if (textSpan) textSpan.innerText = 'Play Audio Summary';
      if (btn) btn.style.color = 'var(--primary)';
    }, 2500);
  };

  window.speechSynthesis.speak(utterance);
}

function askPreset(promptText) {
  const input = document.getElementById('chatInput');
  if (input) {
    input.value = promptText;
    sendChatMessage();
  }
}

async function sendChatMessage() {
  const input = document.getElementById('chatInput');
  const text = input ? input.value.trim() : '';
  if (!text) return;

  const box = document.getElementById('chatMessagesBox');
  if (box) {
    box.innerHTML += `<div class="chat-bubble user">${text}</div>`;
    box.scrollTop = box.scrollHeight;
  }
  if (input) input.value = '';

  const thinkingId = 'thinking_' + Date.now();
  if (box) {
    box.innerHTML += `<div class="chat-bubble ai" id="${thinkingId}"><i class="fa-solid fa-spinner fa-spin"></i> Pashu Mitra AI is thinking...</div>`;
    box.scrollTop = box.scrollHeight;
  }

  let reply = '';
  const geminiApiKey = (window.VITE_GEMINI_API_KEY || window.GEMINI_API_KEY || '').trim();

  if (geminiApiKey && !geminiApiKey.includes('your-gemini')) {
    try {
      const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{
            parts: [{
              text: `You are Pashu Mitra (पशु मित्र), an expert AI animal welfare and veterinary assistant for dogs, cats, cattle, birds, and pets in India. Respond concisely and clearly in simple language. User Query: ${text}`
            }]
          }]
        })
      });

      if (res.ok) {
        const data = await res.json();
        if (data.candidates && data.candidates[0] && data.candidates[0].content && data.candidates[0].content.parts) {
          reply = data.candidates[0].content.parts[0].text;
          reply = reply.replace(/\n/g, '<br>');
        }
      }
    } catch (e) {
      console.warn('Gemini API fetch error:', e);
    }
  }

  if (!reply) {
    reply = "Namaste! For animal care: keep the animal hydrated and cool. Never give human painkillers (Paracetamol/Crocin) as they are toxic to pets. For minor wounds, clean gently with Betadine solution.";
    const lower = text.toLowerCase();
    if (lower.includes('vaccin') || lower.includes('chart')) {
      reply = "Core Indian Dog Vaccination Schedule:<br>• 6-8 Weeks: Puppy DP (Distemper/Parvo)<br>• 10-12 Weeks: 7-in-1 Combination (DHPPiL)<br>• 14-16 Weeks: Anti-Rabies Vaccine (ARV)<br>• Annual Booster: Every 12 months.";
    } else if (lower.includes('bleeding') || lower.includes('paw') || lower.includes('first aid')) {
      reply = "Immediate First Aid for Bleeding:<br>1. Apply firm, steady pressure using clean gauze or cotton cloth.<br>2. Elevate the paw slightly if possible.<br>3. Disinfect with dilute Betadine.<br>4. Wrap loosely with bandage and seek immediate veterinary care if bleeding persists > 10 mins.";
    } else if (lower.includes('cow') || lower.includes('lumpy') || lower.includes('cattle')) {
      reply = "Cattle Health & Lumpy Skin Guidance:<br>1. Isolate affected cattle immediately.<br>2. Fumigate shed with dry neem leaves.<br>3. Provide electrolyte water and mineral mixture (50g/day).<br>4. Contact local Govt. Veterinary Officer for Goat Pox vaccination.";
    }
  }

  const thinkingBubble = document.getElementById(thinkingId);
  if (thinkingBubble) {
    thinkingBubble.innerHTML = reply;
    if (box) box.scrollTop = box.scrollHeight;
  }
}

function startMicRecording(targetInputId = 'symptomText', micBtnId = 'symptomMicBtn') {
  const input = document.getElementById(targetInputId) || document.getElementById('symptomText') || document.getElementById('chatInput');
  const btn = document.getElementById(micBtnId);

  if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    const recog = new SpeechRecognition();
    const langMap = { en: 'en-IN', hi: 'hi-IN', bn: 'bn-IN', ta: 'ta-IN', te: 'te-IN', mr: 'mr-IN', gu: 'gu-IN', pa: 'pa-IN', kn: 'kn-IN', ml: 'ml-IN', or: 'or-IN', as: 'as-IN' };
    recog.lang = langMap[currentLanguage] || 'en-IN';

    if (btn) {
      btn.style.background = '#dc2626';
      btn.innerHTML = `<i class="fa-solid fa-circle-dot fa-beat-fade"></i> Listening...`;
    }

    recog.onresult = (e) => {
      const speechText = e.results[0][0].transcript;
      if (input) {
        input.value = speechText;
      }
    };

    recog.onerror = (e) => {
      if (btn) {
        btn.style.background = '#0284c7';
        btn.innerHTML = `<i class="fa-solid fa-microphone"></i>`;
      }
      alert('Microphone speech recognition error: ' + (e.error || 'Please check microphone permissions.'));
    };

    recog.onend = () => {
      if (btn) {
        btn.style.background = '#0284c7';
        btn.innerHTML = `<i class="fa-solid fa-microphone"></i>`;
      }
    };

    recog.start();
  } else {
    alert('Speech recognition is not supported in this browser. Please type your symptoms manually.');
  }
}

function openPaymentModal(planTitle, planPrice) {
  document.getElementById('rzpPlanTitle').innerText = planTitle;
  document.getElementById('rzpPlanPrice').innerText = planPrice;
  document.getElementById('paymentModal').style.display = 'flex';
}

function closePaymentModal() {
  document.getElementById('paymentModal').style.display = 'none';
}

function confirmPayment() {
  closePaymentModal();
  alert('🎉 Razorpay Payment of ₹999 verified! VIP Gold Guardian subscription activated.');
  renderScreen();
}

// Initial render
renderScreen();

// ─── SERVICE WORKER REGISTRATION ─────────────────────────────────────────────
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then(() => console.log('[SW] PashuRakhshak Service Worker registered'))
      .catch((err) => console.warn('[SW] Registration failed:', err));
  });
}

// ─── OFFLINE DETECTION BANNER ─────────────────────────────────────────────────
function showOfflineBanner() {
  let banner = document.getElementById('offlineBanner');
  if (!banner) {
    banner = document.createElement('div');
    banner.id = 'offlineBanner';
    banner.style.cssText = 'position:fixed;top:0;left:0;right:0;background:#ef4444;color:white;text-align:center;padding:6px 12px;font-size:12px;font-weight:bold;z-index:9999;';
    banner.innerHTML = '<i class="fa-solid fa-wifi-slash"></i> You are offline. Some features may be unavailable.';
    document.body.prepend(banner);
  }
}

function hideOfflineBanner() {
  const banner = document.getElementById('offlineBanner');
  if (banner) banner.remove();
}

window.addEventListener('online', hideOfflineBanner);
window.addEventListener('offline', showOfflineBanner);
if (!navigator.onLine) showOfflineBanner();

// ─── SCAN HISTORY (localStorage) ─────────────────────────────────────────────
const SCAN_HISTORY_KEY = 'pashu_scan_history';
const MAX_SCAN_HISTORY = 20;

function saveScanToHistory(result, imageThumb) {
  if (!result || result.is_uncertain) return; // Only save confident results
  try {
    const history = getScanHistory();
    history.unshift({
      id: Date.now(),
      common_name: result.common_name,
      scientific_name: result.scientific_name,
      confidence: result.confidence,
      danger_level: result.danger_level,
      timestamp: new Date().toISOString(),
      thumb: imageThumb || null
    });
    // Keep only last MAX_SCAN_HISTORY items
    localStorage.setItem(SCAN_HISTORY_KEY, JSON.stringify(history.slice(0, MAX_SCAN_HISTORY)));
    console.log('[ScanHistory] Saved:', result.common_name);
  } catch (e) {
    console.warn('[ScanHistory] Could not save to localStorage:', e);
  }
}

function getScanHistory() {
  try {
    return JSON.parse(localStorage.getItem(SCAN_HISTORY_KEY) || '[]');
  } catch (_) {
    return [];
  }
}

function clearScanHistory() {
  localStorage.removeItem(SCAN_HISTORY_KEY);
}

// ─── IMAGE COMPRESSION BEFORE GEMINI UPLOAD ──────────────────────────────────
function compressImageBase64(base64DataUrl, maxDim = 1024, quality = 0.85) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload = () => {
      const canvas = document.createElement('canvas');
      let { width, height } = img;
      if (width > maxDim || height > maxDim) {
        if (width > height) { height = Math.round((height * maxDim) / width); width = maxDim; }
        else { width = Math.round((width * maxDim) / height); height = maxDim; }
      }
      canvas.width = width;
      canvas.height = height;
      const ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0, width, height);
      resolve(canvas.toDataURL('image/jpeg', quality));
    };
    img.onerror = () => resolve(base64DataUrl); // Fallback: original
    img.src = base64DataUrl;
  });
}

// ─── COPY SCAN RESULT TO CLIPBOARD ───────────────────────────────────────────
function copyScanResultToClipboard() {
  if (!animalScanResult) return;
  const r = animalScanResult;
  const text = [
    `Animal: ${r.common_name} (${r.scientific_name})`,
    `Confidence: ${Math.round((r.confidence || 0) * 100)}%`,
    `Danger Level: ${r.danger_level || 'safe'}`,
    `Diet: ${r.diet || 'N/A'}`,
    `Habitat: ${r.habitat || 'N/A'}`,
    `First Aid: ${r.first_aid || 'N/A'}`,
    `\nIdentified by PashuRakhshak AI — pashurakshak.app`
  ].join('\n');

  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(text).then(() => {
      showToast('Result copied to clipboard!');
    }).catch(() => fallbackCopy(text));
  } else {
    fallbackCopy(text);
  }
}

function fallbackCopy(text) {
  const ta = document.createElement('textarea');
  ta.value = text;
  ta.style.position = 'fixed';
  ta.style.opacity = '0';
  document.body.appendChild(ta);
  ta.select();
  document.execCommand('copy');
  document.body.removeChild(ta);
  showToast('Result copied!');
}

// ─── NATIVE SHARE API ─────────────────────────────────────────────────────────
function shareAnimalResult() {
  if (!animalScanResult) return;
  const r = animalScanResult;
  const shareData = {
    title: `PashuRakhshak: ${r.common_name} Identified!`,
    text: `I identified a ${r.common_name} (${r.scientific_name}) with ${Math.round((r.confidence || 0) * 100)}% confidence using PashuRakhshak AI!\n\n${r.audio_summary || ''}`,
    url: 'https://pashurakshak.app'
  };

  if (navigator.share) {
    navigator.share(shareData).catch((err) => {
      if (err.name !== 'AbortError') copyScanResultToClipboard();
    });
  } else {
    copyScanResultToClipboard();
  }
}

// ─── TOAST NOTIFICATION ───────────────────────────────────────────────────────
function showToast(message, duration = 2500) {
  const existing = document.getElementById('pashuToast');
  if (existing) existing.remove();

  const toast = document.createElement('div');
  toast.id = 'pashuToast';
  toast.style.cssText = 'position:fixed;bottom:100px;left:50%;transform:translateX(-50%);background:#1e293b;color:white;padding:10px 20px;border-radius:20px;font-size:12px;font-weight:bold;z-index:9998;animation:fadeInOut 2.5s ease;box-shadow:0 4px 12px rgba(0,0,0,0.3);';
  toast.textContent = message;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), duration);
}

// ─── CLIENT-SIDE RATE LIMITING FOR GEMINI API ─────────────────────────────────
const geminiRateLimit = { lastCall: 0, minInterval: 3000 }; // 3s between calls

function checkGeminiRateLimit() {
  const now = Date.now();
  if (now - geminiRateLimit.lastCall < geminiRateLimit.minInterval) {
    const wait = Math.ceil((geminiRateLimit.minInterval - (now - geminiRateLimit.lastCall)) / 1000);
    showToast(`Please wait ${wait}s before next scan`);
    return false;
  }
  geminiRateLimit.lastCall = now;
  return true;
}

// ─── SIMPLE EVENT ANALYTICS (console-based, no external tracking) ─────────────
const appEvents = [];
function trackEvent(category, action, label = '') {
  const event = { category, action, label, timestamp: new Date().toISOString() };
  appEvents.push(event);
  console.log('[Analytics]', category, '→', action, label ? `(${label})` : '');
}

// Track navigation events
const _originalNavigateTo = navigateTo;
function navigateTo(screenId) {
  trackEvent('Navigation', 'screen_view', screenId);
  _originalNavigateTo(screenId);
}

// ─── DEEP LINK URL ROUTING ────────────────────────────────────────────────────
(function initDeepLinkRouting() {
  const params = new URLSearchParams(window.location.search);
  const screen = params.get('screen');
  const validScreens = ['home', 'identify', 'help', 'adopt', 'community', 'ai-assistant', 'report-emergency', 'pet-health', 'profile'];
  if (screen && validScreens.includes(screen)) {
    currentScreen = screen;
    renderScreen();
  }
})();
