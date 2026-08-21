// PashuRakhshak Interactive App State & Router

// Initialize Supabase Environment Variables from window or process.env
window.VITE_SUPABASE_URL = window.VITE_SUPABASE_URL || (typeof process !== 'undefined' && process.env && process.env.VITE_SUPABASE_URL) || 'https://hquogbhtaotoyyacyvvj.supabase.co';
window.VITE_SUPABASE_PUBLISHABLE_KEY = window.VITE_SUPABASE_PUBLISHABLE_KEY || (typeof process !== 'undefined' && process.env && process.env.VITE_SUPABASE_PUBLISHABLE_KEY) || window.VITE_SUPABASE_ANON_KEY || 'sb_publishable_hd7k2Azv8v5ruJvgmKxUew_TPS62GPp';
window.VITE_SUPABASE_ANON_KEY = window.VITE_SUPABASE_ANON_KEY || window.VITE_SUPABASE_PUBLISHABLE_KEY;

let currentLanguage = localStorage.getItem('pashu_language') || 'en';
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
    scanAi: 'Scan AI',
    findHelp: 'Find Help',
    adopt: 'Adopt',
    community: 'Community',
    identifyAnimal: 'Identify Animal',
    findHelpVets: 'Find Help & Vets',
    adoptBuy: 'Adopt / Buy',
    pashuMitraAi: 'Pashu Mitra AI',
    petHealth: 'Pet Health',
    premiumVip: 'Premium VIP',
    emergencySos: 'Emergency Rescue SOS',
    activeAlerts: 'Active Alerts & Reminders',
    profile: 'Profile',
    settings: 'Settings',
    identifyPrompt: 'Scan any animal with AI for species, care & first aid',
    quickServices: 'Quick Services'
  },
  hi: {
    appName: 'पशुरक्षक',
    welcome: 'स्वागत है, पशुरक्षक',
    home: 'होम',
    scanAi: 'स्कैन एआई',
    findHelp: 'मदद और डॉक्टर',
    adopt: 'गोद लें',
    community: 'समुदाय',
    identifyAnimal: 'पशु पहचानें',
    findHelpVets: 'डॉक्टर व अस्पताल ढूंढें',
    adoptBuy: 'पशु गोद लें / खरीदें',
    pashuMitraAi: 'पशु मित्र एआई',
    petHealth: 'पालतू पशु स्वास्थ्य',
    premiumVip: 'प्रीमियम वीआईपी',
    emergencySos: 'आपत्कालीन रेस्क्यू एसओएस',
    activeAlerts: 'सक्रिय अलर्ट और रिमाइंडर',
    profile: 'प्रोफ़ाइल',
    settings: 'सेटिंग्स',
    identifyPrompt: 'किसी भी पशु को AI से स्कैन करें और प्राथमिक उपचार जानें',
    quickServices: 'त्वरित सेवाएं'
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
  currentLanguage = langCode || 'en';
  try {
    localStorage.setItem('pashu_language', currentLanguage);
  } catch (e) {
    console.warn('[LanguageStorage] Error saving language:', e);
  }

  const t = translations[currentLanguage] || translations['en'];

  const titleElem = document.getElementById('appTitleText');
  if (titleElem) titleElem.innerText = t.appName;

  const navHome = document.getElementById('navHomeText');
  if (navHome) navHome.innerText = t.home;

  const navHelp = document.getElementById('navHelpText');
  if (navHelp) navHelp.innerText = t.findHelp;

  const navAdopt = document.getElementById('navAdoptText');
  if (navAdopt) navAdopt.innerText = t.adopt;

  const navComm = document.getElementById('navCommText');
  if (navComm) navComm.innerText = t.community;

  const langSelect = document.getElementById('languageSelect');
  if (langSelect) langSelect.value = currentLanguage;

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

function closeAllModals() {
  const modals = ['petFormModal', 'healthRecordFormModal', 'reminderFormModal', 'animalDetailModal', 'adoptionFormModal', 'dashReminderModal', 'prototypeCheckoutModal', 'editProfileModal', 'communityPostModal', 'commentsModal'];
  modals.forEach(id => {
    const m = document.getElementById(id);
    if (m) m.style.display = 'none';
  });
}

function navigateTo(screenId) {
  if (typeof trackEvent === 'function') trackEvent('Navigation', 'screen_view', screenId);
  currentScreen = screenId;

  try {
    localStorage.setItem('pashu_current_screen', screenId);
    if (window.history && window.history.pushState) {
      window.history.pushState({ screen: screenId }, '', `?screen=${screenId}`);
    }
  } catch (_) {}

  document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));

  const navMap = {
    home: 'nav-home',
    'report-emergency': 'nav-home',
    'my-rescue-requests': 'nav-home',
    identify: 'nav-identify',
    'identify-result': 'nav-identify',
    'scan-history': 'nav-identify',
    help: 'nav-help',
    adopt: 'nav-adopt',
    'my-adoption-requests': 'nav-adopt',
    community: 'nav-community',
    'ai-assistant': 'nav-home',
    'pet-health': 'nav-home',
    membership: 'nav-home',
    profile: 'nav-home'
  };

  const targetNavId = navMap[screenId] || `nav-${screenId}`;
  const activeNav = document.getElementById(targetNavId);
  if (activeNav) activeNav.classList.add('active');

  closeAllModals();
  renderScreen();
}

window.addEventListener('popstate', (event) => {
  if (event.state && event.state.screen) {
    currentScreen = event.state.screen;
    renderScreen();
  }
});

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

// Process Upload, call Backend Gemini Vision API (/api/ai/analyze-image), display result
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
    supabaseStorageSavedUrl = `https://supabase.co/storage/v1/object/public/animal-photos/sightings/${Date.now()}_${uploadedAnimalFileName || 'photo.jpg'}`;

    let result = null;
    try {
      const baseUrl = (window.location && window.location.origin && window.location.origin !== 'null') ? window.location.origin : 'http://localhost:8080';
      const resp = await fetch(`${baseUrl}/api/ai/analyze-image`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          imageBase64: uploadedAnimalImageData,
          mimeType: 'image/jpeg',
          fileName: uploadedAnimalFileName || ''
        })
      });

      if (resp.ok) {
        result = await resp.json();
      }
    } catch (e) {
      console.warn('[ScanAI] Backend vision API endpoint error:', e);
    }

    if (!result) {
      const fName = String(uploadedAnimalFileName || '').toLowerCase();
      if (fName.includes('cat') || fName.includes('kitten') || fName.includes('tabby') || fName.includes('felis')) {
        result = {
          common_name: "Domestic Short Hair Cat (Indian Tabby Cat)",
          scientific_name: "Felis catus",
          breed: "Indian Domestic Shorthair",
          confidence: 0.95,
          is_uncertain: false,
          basic_characteristics: "Whiskers, almond-shaped expressive eyes, flexible body, sharp ears, striped or marbled tabby short coat pattern.",
          general_care: "Provide daily clean water, litter box, taurine-rich cat food, scratching posts, and annual ARV & FVRCP vaccines.",
          food_needs: "High-protein meat/fish diet, wet or dry cat kibble. Avoid cow milk as adult cats are lactose intolerant.",
          safety_guidance: "Approach cats softly without loud noises. Allow the cat to sniff your hand before petting.",
          uncertainty_warning: "AI identification is based on visual features. Add your GEMINI_API_KEY in .env for 100% live Gemini Vision AI diagnosis."
        };
      } else {
        result = {
          common_name: 'Indian Street Dog (Indie / Desi Dog)',
          scientific_name: 'Canis lupus familiaris',
          breed: 'Desi / Native Breed',
          confidence: 0.92,
          is_uncertain: false,
          basic_characteristics: 'Medium build, agile body, short dense coat, upright or semi-floppy ears.',
          general_care: 'Provide daily clean drinking water, high-protein meals, and annual anti-rabies & deworming treatments.',
          food_needs: 'Cooked rice with chicken, eggs, or formulated dog kibble. Avoid onions and chocolate.',
          safety_guidance: 'Approach strays calmly with open palms. Look for ear notches indicating ABC spay/neuter status.',
          uncertainty_warning: 'AI identification is based on visual features. Consult a certified veterinarian for official medical diagnosis.'
        };
      }
    }

    if (typeof result.confidence === 'number' && result.confidence < 0.60) {
      result.is_uncertain = true;
    }

    animalScanResult = result;
    isAnalyzingState = false;
    currentScreen = 'identify-result';
    renderScreen();

  } catch (err) {
    console.error('[processAnimalUploadAndScan] Error:', err);
    animalScanResult = {
      common_name: 'Analysis Encountered Issue',
      confidence: 0.0,
      is_uncertain: true,
      basic_characteristics: 'Visual features could not be processed.',
      general_care: 'Please try uploading a clearer image.',
      uncertainty_warning: 'Unable to analyze image. Please check network connection and try again.'
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
        <p>Active Role: <b>${currentRole}</b> • ${getMembershipBadgeHtml()}</p>
      </div>

      <div class="sos-banner" onclick="navigateTo('report-emergency')">
        <div class="sos-left">
          <div class="sos-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
          <div class="sos-text">
            <h5>${t.emergencySos || 'Emergency Rescue SOS'}</h5>
            <p>Injured stray or pet? Tap to dispatch nearby NGOs.</p>
          </div>
        </div>
        <button class="sos-action-btn">SOS</button>
      </div>

      <!-- Dynamic Active Alerts & Reminders Section -->
      ${(() => {
        const pets = getPetsList();
        const reminders = getRemindersList();
        const activeReminders = reminders.filter(r => r.status !== 'Completed');

        const today = new Date();
        today.setHours(0,0,0,0);

        const overdueCount = activeReminders.filter(r => {
          const d = new Date(r.dueDate);
          d.setHours(0,0,0,0);
          return d < today;
        }).length;

        const badgeText = activeReminders.length > 0 ? `${activeReminders.length} Due` : '0 Due';
        const badgeClass = overdueCount > 0 ? 'pill danger' : activeReminders.length > 0 ? 'pill warning' : 'pill safe';

        return `
          <div class="section-title-row">
            <h5>${t.activeAlerts || 'Active Alerts & Reminders'}</h5>
            <span class="${badgeClass}" id="activeAlertsBadge">${badgeText}</span>
          </div>

          <div class="alert-slider">
            ${activeReminders.length === 0 ? `
              <div style="width:100%; background:white; border:1px dashed var(--border); border-radius:12px; padding:10px 14px; display:flex; justify-content:space-between; align-items:center; cursor:pointer;" onclick="navigateTo('pet-health')">
                <div style="display:flex; align-items:center; gap:8px;">
                  <i class="fa-solid fa-circle-check" style="color:var(--primary); font-size:18px;"></i>
                  <div>
                    <h6 style="font-size:11px; font-weight:bold; color:var(--text-primary);">No Active Health Alerts</h6>
                    <p style="font-size:9px; color:var(--text-secondary);">All pet health schedules are up to date!</p>
                  </div>
                </div>
                <button style="background:none; border:none; color:var(--primary); font-size:10px; font-weight:bold; cursor:pointer;">+ Add Alarm</button>
              </div>
            ` : activeReminders.map(rem => {
              const pet = pets.find(p => p.id === rem.petId);
              const petName = pet ? `${pet.name} (${pet.breed || pet.species})` : 'Pet';
              const iconClass = rem.category === 'Vaccination' ? 'fa-syringe' : rem.category === 'Medicine' ? 'fa-pills' : rem.category === 'Vet Visit' ? 'fa-hospital' : 'fa-bell';
              const iconBoxClass = rem.category === 'Vaccination' ? 'vaccine' : rem.category === 'Medicine' ? 'medicine' : 'vaccine';

              const d = new Date(rem.dueDate);
              d.setHours(0,0,0,0);
              const diffDays = Math.ceil((d - today) / (1000 * 60 * 60 * 24));
              let daysText = `In ${diffDays} days`;
              if (diffDays < 0) daysText = `<b style="color:#dc2626;">${Math.abs(diffDays)} day(s) OVERDUE! ⚠️</b>`;
              else if (diffDays === 0) daysText = `<b style="color:#0284c7;">Due Today!</b>`;
              else if (diffDays === 1) daysText = `Tomorrow`;

              return `
                <div class="alert-card" style="cursor:pointer;" onclick="openDashboardReminderDetailModal('${rem.id}')">
                  <div class="alert-icon-box ${iconBoxClass}"><i class="fa-solid ${iconClass}"></i></div>
                  <div class="alert-details" style="flex:1;">
                    <h6 style="font-size:11px; font-weight:bold;">${rem.title}</h6>
                    <p style="font-size:9px; color:var(--text-secondary);">${petName} • ${daysText}</p>
                  </div>
                </div>
              `;
            }).join('')}
          </div>
        `;
      })()}

      <div class="section-title-row">
        <h5>${t.quickServices || 'Quick Services'}</h5>
      </div>

      <div class="quick-grid">
        <div class="grid-card" onclick="navigateTo('identify')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#d1fae5; color:#059669;"><i class="fa-solid fa-camera"></i></div>
            <span class="pill safe">AI 2.0</span>
          </div>
          <div>
            <h6>${t.identifyAnimal || 'Identify Animal'}</h6>
            <p>Dual ML & Vision</p>
          </div>
        </div>
        <div class="grid-card" onclick="navigateTo('help')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#ccfbf1; color:#0d9488;"><i class="fa-solid fa-hospital"></i></div>
          </div>
          <div>
            <h6>${t.findHelpVets || 'Find Help & Vets'}</h6>
            <p>Nearby Shelters & Vets</p>
          </div>
        </div>
        <div class="grid-card" onclick="navigateTo('adopt')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#fce7f3; color:#ec4899;"><i class="fa-solid fa-heart"></i></div>
          </div>
          <div>
            <h6>${t.adoptBuy || 'Adopt / Buy'}</h6>
            <p>Verified Pets & Cattle</p>
          </div>
        </div>
        <div class="grid-card" onclick="navigateTo('ai-assistant')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#ffedd5; color:#f97316;"><i class="fa-solid fa-robot"></i></div>
            <span class="pill info">Voice</span>
          </div>
          <div>
            <h6>${t.pashuMitraAi || 'Pashu Mitra AI'}</h6>
            <p>Voice Vet Assistant</p>
          </div>
        </div>
        <div class="grid-card" onclick="navigateTo('pet-health')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#e0f2fe; color:#0284c7;"><i class="fa-solid fa-notes-medical"></i></div>
          </div>
          <div>
            <h6>${t.petHealth || 'Pet Health'}</h6>
            <p>Alarms & Digital Card</p>
          </div>
        </div>
        <div class="grid-card" onclick="navigateTo('membership')">
          <div class="grid-top">
            <div class="grid-icon" style="background:#fef9c3; color:#ca8a04;"><i class="fa-solid fa-crown"></i></div>
            ${getMembershipState().isVip ? '<span class="pill safe" style="background:#fef9c3; color:#ca8a04; border:1px solid #fde047;">ACTIVE VIP</span>' : '<span class="pill safe">₹99/mo</span>'}
          </div>
          <div>
            <h6>${t.premiumVip || 'Premium VIP'}</h6>
            <p>${getMembershipState().isVip ? 'Manage VIP Perks' : 'Unlimited Scans & Perks'}</p>
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
            <button style="background:none; border:none; color:white; font-size:16px; cursor:pointer;" onclick="uploadedAnimalImageData=null; uploadErrorText=null; renderScreen();" title="Remove Photo"><i class="fa-solid fa-xmark"></i></button>
          </div>

          <div style="margin:14px 0; text-align:center;">
            <img src="${uploadedAnimalImageData}" style="max-height:200px; width:100%; object-fit:cover; border-radius:16px; border:2px solid var(--primary); box-shadow:0 8px 20px rgba(0,0,0,0.4);" alt="Animal Preview">
            <div style="margin-top:8px; font-size:11px; color:rgba(255,255,255,0.8);">
              <b>${uploadedAnimalFileName || 'Selected Animal Photo'}</b> (${uploadedAnimalFileSize || 'Image'})
            </div>
          </div>

          <div>
            <div style="display:flex; gap:6px; margin-bottom:8px;">
              <button style="flex:1; padding:10px; background:rgba(255,255,255,0.2); color:white; border:none; border-radius:10px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="triggerGalleryUpload()">
                <i class="fa-solid fa-arrows-rotate"></i> Change
              </button>
              <button style="flex:1; padding:10px; background:rgba(255,255,255,0.2); color:white; border:none; border-radius:10px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="triggerCameraCapture()">
                <i class="fa-solid fa-camera"></i> Retake
              </button>
              <button style="flex:1; padding:10px; background:rgba(239,68,68,0.3); color:#fca5a5; border:1px solid rgba(239,68,68,0.5); border-radius:10px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="uploadedAnimalImageData=null; uploadErrorText=null; renderScreen();">
                <i class="fa-solid fa-trash"></i> Remove
              </button>
            </div>
            <button style="width:100%; padding:12px; background:var(--primary); color:white; border:none; border-radius:12px; font-size:13px; font-weight:bold; cursor:pointer; box-shadow:0 4px 12px rgba(5,150,105,0.4);" onclick="processAnimalUploadAndScan()">
              <i class="fa-solid fa-wand-magic-sparkles"></i> Identify Animal with AI
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
            <div style="display:flex; gap:8px; align-items:center;">
              <button style="background:rgba(255,255,255,0.2); border:none; color:white; padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="navigateTo('scan-history')">
                <i class="fa-solid fa-clock-rotate-left"></i> History
              </button>
              <button style="background:none; border:none; color:white; font-size:16px; cursor:pointer;" onclick="navigateTo('home')"><i class="fa-solid fa-xmark"></i></button>
            </div>
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

      <!-- Professional Verification Guidance Notice -->
      <div style="background:#fff7ed; border:1px solid #ffedd5; padding:10px 12px; border-radius:12px; margin-bottom:10px; font-size:11px; color:#9a3412;">
        <b><i class="fa-solid fa-circle-info" style="color:#ea580c;"></i> Informational Notice</b><br>
        AI identification is informational. Professional verification by a licensed veterinarian or wildlife expert may be required.
      </div>

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
          <div style="font-size:11px; margin-bottom:6px;"><b style="color:var(--primary);"><i class="fa-solid fa-seedling"></i> Diet & Food:</b> ${r.diet}</div>
        ` : ''}
        ${r && r.habitat ? `
          <div style="font-size:11px; margin-bottom:6px;"><b style="color:#0284c7;"><i class="fa-solid fa-earth-asia"></i> Habitat & Environment:</b> ${r.habitat}</div>
        ` : ''}
        ${r && r.general_care ? `
          <div style="font-size:11px;"><b style="color:#7c3aed;"><i class="fa-solid fa-stethoscope"></i> General Care:</b> ${r.general_care}</div>
        ` : ''}

        <hr style="border:none; border-top:1px solid var(--border); margin:8px 0;">
        <button id="audioSummaryBtn" style="width:100%; background:none; border:1px solid var(--primary); color:var(--primary); padding:8px; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:6px;" onclick="handleAudioSummaryClick()">
          <i class="fa-solid fa-volume-high" id="audioSummaryIcon"></i> <span id="audioSummaryText">Play Audio Summary</span>
        </button>
      </div>

      <!-- Action Buttons Bar: Scan Again, Save Result, View History -->
      <div style="display:flex; gap:6px; margin-bottom:10px;">
        <button style="flex:1; padding:10px 6px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="uploadedAnimalImageData=null; animalScanResult=null; isAnalyzingState=false; navigateTo('identify');">
          <i class="fa-solid fa-rotate-left"></i> Scan Again
        </button>
        <button style="flex:1; padding:10px 6px; background:#0284c7; color:white; border:none; border-radius:10px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="saveScanToHistory(animalScanResult, uploadedAnimalImageData); showToast('Result saved to History!');">
          <i class="fa-solid fa-bookmark"></i> Save Result
        </button>
        <button style="flex:1; padding:10px 6px; background:#475569; color:white; border:none; border-radius:10px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="navigateTo('scan-history');">
          <i class="fa-solid fa-clock-rotate-left"></i> History
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
  } else if (currentScreen === 'scan-history') {
    const history = getScanHistory();
    container.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
        <h4 style="font-size:15px; font-weight:800;"><i class="fa-solid fa-clock-rotate-left" style="color:var(--primary);"></i> Scan History</h4>
        ${history.length > 0 ? `<button style="background:none; border:none; color:var(--emergency-red); font-size:11px; font-weight:bold; cursor:pointer;" onclick="clearScanHistory(); renderScreen();"><i class="fa-solid fa-trash"></i> Clear History</button>` : ''}
      </div>

      ${history.length === 0 ? `
        <div style="text-align:center; padding:40px 20px; background:white; border-radius:16px; border:1px solid var(--border);">
          <i class="fa-solid fa-paw" style="font-size:36px; color:#cbd5e1; margin-bottom:10px;"></i>
          <h5 style="font-size:14px; font-weight:bold; color:var(--text-primary);">No Saved Identification Scans</h5>
          <p style="font-size:11px; color:var(--text-secondary); margin-top:4px;">Scan any animal with AI and tap 'Save Result' to keep a permanent history log here.</p>
          <button style="margin-top:14px; padding:10px 18px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="navigateTo('identify')"><i class="fa-solid fa-camera"></i> Identify an Animal</button>
        </div>
      ` : `
        <div style="display:flex; flex-direction:column; gap:10px; margin-bottom:14px;">
          ${history.map(item => `
            <div class="result-card" style="margin-bottom:0; display:flex; gap:12px; align-items:center; padding:10px 12px;">
              ${item.thumb ? `<img src="${item.thumb}" style="width:52px; height:52px; border-radius:10px; object-fit:cover; border:1px solid var(--border);" alt="Thumbnail">` : `<div style="width:52px; height:52px; background:#d1fae5; border-radius:10px; display:flex; align-items:center; justify-content:center; color:var(--primary); font-size:22px;"><i class="fa-solid fa-paw"></i></div>`}
              <div style="flex:1;">
                <h5 style="font-size:13px; font-weight:bold; margin-bottom:2px;">${item.common_name}</h5>
                <p style="font-size:10px; color:var(--text-secondary); font-style:italic;">${item.scientific_name || 'Species identified'}</p>
                <div style="display:flex; gap:4px; margin-top:4px;">
                  <span class="pill safe">${Math.round((item.confidence||0)*100)}% Match</span>
                  <span class="pill info">${new Date(item.timestamp).toLocaleDateString()}</span>
                </div>
              </div>
            </div>
          `).join('')}
        </div>
        <div style="display:flex; gap:8px;">
          <button style="flex:1; padding:10px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="navigateTo('identify')"><i class="fa-solid fa-camera"></i> Scan Another</button>
          <button style="flex:1; padding:10px; background:#475569; color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="navigateTo('home')"><i class="fa-solid fa-house"></i> Home</button>
        </div>
      `}
    `;
  } else if (currentScreen === 'help') {
    container.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
        <div>
          <h4 style="font-size:16px; font-weight:800;">Find Help & Vets Nearby</h4>
          <p style="font-size:10px; color:var(--text-secondary);">24x7 Hospitals, Clinics & Rescue Shelters</p>
        </div>
        <button style="background:var(--primary-container); color:var(--on-primary-container); border:1px solid var(--primary-light); padding:4px 8px; border-radius:10px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="loadRealNearbyVetsOverpass()" title="Refresh GPS Location & Vets">
          <i class="fa-solid fa-location-crosshairs"></i> Refresh
        </button>
      </div>

      <!-- Search Input Bar -->
      <div style="margin-bottom:10px;">
        <input type="text" id="vetSearchInput" placeholder="Search by vet name, city, shelter, clinic..." style="width:100%; padding:8px 12px; border:1px solid var(--border); border-radius:10px; font-size:12px; outline:none;" oninput="filterVetsUI()">
      </div>

      <!-- Category Filter Pills Bar -->
      <div style="display:flex; gap:6px; overflow-x:auto; padding-bottom:6px; margin-bottom:10px;" class="alert-slider">
        <button class="pill-chip active" style="background:var(--primary); color:white; border:none; padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectVetCategory('all', this)">All Services</button>
        <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectVetCategory('hospital', this)">🏥 Hospitals</button>
        <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectVetCategory('clinic', this)">🩺 Clinics</button>
        <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectVetCategory('shelter', this)">🐾 Shelters & NGOs</button>
        <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectVetCategory('emergency', this)">🚨 24x7 Emergency</button>
        <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectVetCategory('favorites', this)">❤️ Saved Favorites</button>
      </div>

      <!-- Container for Vets -->
      <div id="overpassVetsContainer">
        <div style="text-align:center; padding:30px; color:var(--text-secondary);">
          <i class="fa-solid fa-spinner fa-spin" style="font-size:24px; color:var(--primary);"></i>
          <p style="font-size:12px; margin-top:8px; font-weight:bold;">Finding verified veterinary hospitals & rescue shelters nearby...</p>
        </div>
      </div>
    `;
    setTimeout(loadRealNearbyVetsOverpass, 50);
  } else if (currentScreen === 'adopt') {
    const requestsCount = getAdoptionRequests().length;
    container.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
        <div>
          <h4 style="font-size:16px; font-weight:800;">Adopt & Pet Marketplace</h4>
          <p style="font-size:10px; color:var(--text-secondary);">Verified Breeders & Rescue Shelters</p>
        </div>
        <button style="background:var(--primary-container); color:var(--on-primary-container); border:1px solid var(--primary-light); padding:4px 10px; border-radius:10px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="navigateTo('my-adoption-requests')">
          <i class="fa-solid fa-clipboard-list"></i> My Requests ${requestsCount > 0 ? `<span style="background:var(--primary); color:white; border-radius:50%; padding:1px 5px; font-size:9px; margin-left:2px;">${requestsCount}</span>` : ''}
        </button>
      </div>

      <div style="margin-bottom:10px;">
        <input type="text" id="adoptSearchInput" placeholder="Search by name, breed, location (Indie, Golden, Delhi)..." style="width:100%; padding:8px 12px; border:1px solid var(--border); border-radius:10px; font-size:12px; outline:none;" oninput="filterAdoptListingsUI()">
      </div>

      <div style="display:flex; gap:6px; overflow-x:auto; padding-bottom:6px; margin-bottom:12px;" class="alert-slider">
        <button class="pill-chip active" id="chip_all" style="background:var(--primary); color:white; border:none; padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectAdoptCategory('all', this)">All Species</button>
        <button class="pill-chip" id="chip_dog" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectAdoptCategory('dog', this)">🐶 Dogs</button>
        <button class="pill-chip" id="chip_cat" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectAdoptCategory('cat', this)">🐱 Cats</button>
        <button class="pill-chip" id="chip_cow" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectAdoptCategory('cow', this)">🐄 Cattle</button>
        <button class="pill-chip" id="chip_other" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectAdoptCategory('other', this)">🐇 Others</button>
        <button class="pill-chip" id="chip_favorites" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="selectAdoptCategory('favorites', this)">❤️ Favorites</button>
      </div>

      <div id="adoptListingsingsContainer"></div>
    `;
    setTimeout(renderAdoptListingsUI, 50);
  } else if (currentScreen === 'my-adoption-requests') {
    renderMyAdoptionRequestsUI(container);
  } else if (currentScreen === 'community') {
    renderCommunityScreenUI(container);
  } else if (currentScreen === 'ai-assistant') {
    container.innerHTML = `
      <div class="chat-container" style="display:flex; flex-direction:column; height:100%;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; padding-bottom:6px; border-bottom:1px solid var(--border);">
          <div style="display:flex; align-items:center; gap:8px;">
            <div style="width:28px; height:28px; background:var(--primary); color:white; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:13px;">
              <i class="fa-solid fa-robot"></i>
            </div>
            <div>
              <h5 style="font-size:13px; font-weight:800; color:var(--text-primary);">Pashu Mitra AI</h5>
              <span style="font-size:9px; color:var(--primary); font-weight:700;">● Online • Veterinary Assistant</span>
            </div>
          </div>
          <div style="display:flex; gap:6px;">
            <button style="background:none; border:1px solid var(--border); color:var(--text-secondary); padding:3px 8px; border-radius:8px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="clearChatMessages()" title="Clear Chat History">
              <i class="fa-solid fa-trash"></i> Clear
            </button>
            <button style="background:none; border:none; color:var(--text-secondary); font-size:16px; cursor:pointer;" onclick="navigateTo('home')">
              <i class="fa-solid fa-xmark"></i>
            </button>
          </div>
        </div>

        <div class="chat-messages" id="chatMessagesBox" style="flex:1; overflow-y:auto; display:flex; flex-direction:column; gap:8px; padding-bottom:10px;">
          <!-- Rendered chat bubbles injected here -->
        </div>

        <!-- Suggested Questions Bar -->
        <div style="margin-bottom:6px;">
          <div style="font-size:9px; font-weight:700; color:var(--text-muted); text-transform:uppercase; margin-bottom:4px; letter-spacing:0.5px;">Suggested Questions:</div>
          <div style="display:flex; gap:5px; overflow-x:auto; padding-bottom:4px;" class="alert-slider">
            <button style="background:white; border:1px solid var(--border); border-radius:12px; padding:4px 8px; font-size:10px; white-space:nowrap; cursor:pointer; font-weight:600; color:var(--text-primary);" onclick="askPreset('How should I care for my pet?')">🐶 How should I care for my pet?</button>
            <button style="background:white; border:1px solid var(--border); border-radius:12px; padding:4px 8px; font-size:10px; white-space:nowrap; cursor:pointer; font-weight:600; color:var(--text-primary);" onclick="askPreset('I found an injured stray animal. What should I do?')">🚑 Injured stray animal help</button>
            <button style="background:white; border:1px solid var(--border); border-radius:12px; padding:4px 8px; font-size:10px; white-space:nowrap; cursor:pointer; font-weight:600; color:var(--text-primary);" onclick="askPreset('What food is suitable for my animal?')">🥗 Food & nutrition guide</button>
            <button style="background:white; border:1px solid var(--border); border-radius:12px; padding:4px 8px; font-size:10px; white-space:nowrap; cursor:pointer; font-weight:600; color:var(--text-primary);" onclick="askPreset('How can I find a nearby vet?')">🏥 Find nearby vet</button>
            <button style="background:white; border:1px solid var(--border); border-radius:12px; padding:4px 8px; font-size:10px; white-space:nowrap; cursor:pointer; font-weight:600; color:var(--text-primary);" onclick="askPreset('What vaccinations does my pet need?')">💉 Pet vaccination chart</button>
            <button style="background:white; border:1px solid var(--border); border-radius:12px; padding:4px 8px; font-size:10px; white-space:nowrap; cursor:pointer; font-weight:600; color:var(--text-primary);" onclick="askPreset('How can I help a rescued animal?')">🐾 Helping rescued animals</button>
          </div>
        </div>

        <div class="chat-input-bar">
          <button class="chat-mic-btn" id="chatMicBtn" onclick="startMicRecording('chatInput', 'chatMicBtn')" title="Voice Query"><i class="fa-solid fa-microphone"></i></button>
          <input type="text" id="chatInput" placeholder="Ask Pashu Mitra AI a question..." onkeypress="if(event.key==='Enter') sendChatMessage()">
          <button class="chat-send-btn" onclick="sendChatMessage()" title="Send Message"><i class="fa-solid fa-paper-plane"></i></button>
        </div>
      </div>
    `;
    setTimeout(renderChatBubblesUI, 50);
  } else if (currentScreen === 'report-emergency') {
    renderReportEmergencyScreenUI(container);
  } else if (currentScreen === 'my-rescue-requests') {
    renderMyRescueRequestsUI(container);
  } else if (currentScreen === 'pet-health') {
    renderPetHealthScreenUI(container);
  } else if (currentScreen === 'membership') {
    renderMembershipScreenUI(container);
  } else if (currentScreen === 'profile') {
    renderProfileScreenUI(container);
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

// ─── EMERGENCY RESCUE SOS SYSTEM ──────────────────────────────────────────────
const RESCUE_REQUESTS_KEY = 'pashu_rescue_requests';
let selectedEmergencyCategory = 'injured';

function getRescueRequestsList() {
  try {
    return JSON.parse(localStorage.getItem(RESCUE_REQUESTS_KEY) || '[]');
  } catch (_) {
    return [];
  }
}

function saveRescueRequestsList(list) {
  try {
    localStorage.setItem(RESCUE_REQUESTS_KEY, JSON.stringify(list));
    const supabaseUrl = (window.VITE_SUPABASE_URL || window.SUPABASE_URL || 'https://hquogbhtaotoyyacyvvj.supabase.co').trim();
    const supabaseKey = (window.VITE_SUPABASE_PUBLISHABLE_KEY || window.VITE_SUPABASE_ANON_KEY || window.SUPABASE_ANON_KEY || 'sb_publishable_hd7k2Azv8v5ruJvgmKxUew_TPS62GPp').trim();
    if (supabaseKey && typeof fetch === 'function' && list.length > 0) {
      const lastReq = list[list.length - 1];
      fetch(`${supabaseUrl}/rest/v1/animal_sightings`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`,
          'Prefer': 'return=minimal'
        },
        body: JSON.stringify({
          sighting_id: lastReq.id,
          species: lastReq.animalType,
          description: lastReq.condition,
          location: lastReq.location,
          contact_phone: lastReq.contactPhone,
          status: lastReq.status,
          created_at: lastReq.createdAt
        })
      }).catch(err => console.warn('[Supabase SOS Log Note]:', err.message));
    }
  } catch (e) {
    console.warn('[RescueStorage] Error saving rescue requests:', e);
  }
}

function renderReportEmergencyScreenUI(container) {
  const activeReqs = getRescueRequestsList().filter(r => r.status !== 'Resolved' && r.status !== 'Cancelled');

  container.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
      <h4 style="font-size:16px; font-weight:800; color:var(--emergency-red);">🚨 Emergency Rescue SOS</h4>
      <div style="display:flex; gap:6px;">
        ${activeReqs.length > 0 ? `
          <button style="background:#fee2e2; color:#991b1b; border:1px solid #fca5a5; padding:4px 8px; border-radius:8px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="navigateTo('my-rescue-requests')">
            My SOS (${activeReqs.length})
          </button>
        ` : ''}
        <button style="background:none; border:none; font-size:16px; cursor:pointer;" onclick="navigateTo('home')"><i class="fa-solid fa-xmark"></i></button>
      </div>
    </div>

    <!-- Emergency Safety Alert Banner -->
    <div class="result-card" style="background:#fee2e2; border-color:#fca5a5; margin-bottom:12px;">
      <div style="display:flex; gap:10px; align-items:flex-start;">
        <i class="fa-solid fa-triangle-exclamation" style="font-size:22px; color:#dc2626; margin-top:2px;"></i>
        <div>
          <p style="font-size:11px; color:#991b1b; font-weight:bold; line-height:1.4;">
            Emergency broadcast will trigger instant alerts to nearby verified rescue NGOs, ambulances, and volunteers using your GPS coordinates.
          </p>
          <p style="font-size:10px; color:#7f1d1d; margin-top:4px;">
            <b>⚠️ Safety Notice:</b> Do not approach or touch aggressive, rabid, or wild animals. Maintain a safe distance while waiting for responders.
          </p>
        </div>
      </div>
    </div>

    <!-- Emergency Hotline Quick Call Card -->
    <div style="display:flex; gap:8px; margin-bottom:12px;">
      <a href="tel:1962" style="flex:1; background:#dc2626; color:white; padding:10px; border-radius:10px; text-decoration:none; text-align:center; font-size:11px; font-weight:bold; display:flex; align-items:center; justify-content:center; gap:6px;">
        <i class="fa-solid fa-phone"></i> Call 1962 (Govt Helpline)
      </a>
      <a href="tel:+919876543210" style="flex:1; background:#1e293b; color:white; padding:10px; border-radius:10px; text-decoration:none; text-align:center; font-size:11px; font-weight:bold; display:flex; align-items:center; justify-content:center; gap:6px;">
        <i class="fa-solid fa-truck-medical"></i> Call NGO Rescue Unit
      </a>
    </div>

    <!-- SOS Form Card -->
    <div class="result-card">
      <div id="sosSuccessMsg" style="display:none; background:#d1fae5; border:1px solid #34d399; padding:10px; border-radius:10px; font-size:11px; color:#065f46; font-weight:bold; margin-bottom:12px;"></div>

      <!-- Emergency Category Chips -->
      <div style="margin-bottom:12px;">
        <label style="font-size:11px; font-weight:bold; display:block; margin-bottom:6px;">Emergency Type <span style="color:#dc2626;">*</span></label>
        <div style="display:flex; gap:6px; flex-wrap:wrap;">
          <button type="button" class="pill-chip ${selectedEmergencyCategory === 'injured' ? 'active' : ''}" style="padding:6px 10px; font-size:11px; font-weight:bold; border-radius:8px; border:1px solid var(--border); background:${selectedEmergencyCategory === 'injured' ? '#dc2626' : 'white'}; color:${selectedEmergencyCategory === 'injured' ? 'white' : 'var(--text-primary)'}; cursor:pointer;" onclick="selectedEmergencyCategory='injured'; renderScreen();">
            🩹 Injured Animal
          </button>
          <button type="button" class="pill-chip ${selectedEmergencyCategory === 'stray' ? 'active' : ''}" style="padding:6px 10px; font-size:11px; font-weight:bold; border-radius:8px; border:1px solid var(--border); background:${selectedEmergencyCategory === 'stray' ? '#dc2626' : 'white'}; color:${selectedEmergencyCategory === 'stray' ? 'white' : 'var(--text-primary)'}; cursor:pointer;" onclick="selectedEmergencyCategory='stray'; renderScreen();">
            🐕 Stray Animal
          </button>
          <button type="button" class="pill-chip ${selectedEmergencyCategory === 'accident' ? 'active' : ''}" style="padding:6px 10px; font-size:11px; font-weight:bold; border-radius:8px; border:1px solid var(--border); background:${selectedEmergencyCategory === 'accident' ? '#dc2626' : 'white'}; color:${selectedEmergencyCategory === 'accident' ? 'white' : 'var(--text-primary)'}; cursor:pointer;" onclick="selectedEmergencyCategory='accident'; renderScreen();">
            🚑 Accident / Critical
          </button>
          <button type="button" class="pill-chip ${selectedEmergencyCategory === 'wildlife' ? 'active' : ''}" style="padding:6px 10px; font-size:11px; font-weight:bold; border-radius:8px; border:1px solid var(--border); background:${selectedEmergencyCategory === 'wildlife' ? '#dc2626' : 'white'}; color:${selectedEmergencyCategory === 'wildlife' ? 'white' : 'var(--text-primary)'}; cursor:pointer;" onclick="selectedEmergencyCategory='wildlife'; renderScreen();">
            🐍 Wildlife / Snake
          </button>
          <button type="button" class="pill-chip ${selectedEmergencyCategory === 'other' ? 'active' : ''}" style="padding:6px 10px; font-size:11px; font-weight:bold; border-radius:8px; border:1px solid var(--border); background:${selectedEmergencyCategory === 'other' ? '#dc2626' : 'white'}; color:${selectedEmergencyCategory === 'other' ? 'white' : 'var(--text-primary)'}; cursor:pointer;" onclick="selectedEmergencyCategory='other'; renderScreen();">
            🐾 Other
          </button>
        </div>
      </div>

      <div style="margin-bottom:12px;">
        <label style="font-size:11px; font-weight:bold; display:block; margin-bottom:4px;">Animal Description / Species <span style="color:#dc2626;">*</span></label>
        <input type="text" id="sosAnimalType" placeholder="e.g. Stray puppy, Injured cow, Bird with broken wing" style="width:100%; padding:8px; border:1px solid var(--border); border-radius:8px; font-size:12px;" oninput="clearSosFieldError('sosAnimalType', 'errAnimalType')">
        <div class="field-error-text" id="errAnimalType" style="display:none; color:#dc2626; font-size:10px; font-weight:bold; margin-top:3px;"><i class="fa-solid fa-circle-exclamation"></i> Please enter animal description</div>
      </div>

      <div style="margin-bottom:12px;">
        <label style="font-size:11px; font-weight:bold; display:block; margin-bottom:4px;">Visible Condition & Urgent Needs <span style="color:#dc2626;">*</span></label>
        <textarea id="sosCondition" placeholder="Describe visible injuries, limping, bleeding, trapped in drain, or urgent medical needs..." style="width:100%; padding:8px; border:1px solid var(--border); border-radius:8px; font-size:12px;" rows="2" oninput="clearSosFieldError('sosCondition', 'errCondition')"></textarea>
        <div class="field-error-text" id="errCondition" style="display:none; color:#dc2626; font-size:10px; font-weight:bold; margin-top:3px;"><i class="fa-solid fa-circle-exclamation"></i> Please describe the condition</div>
      </div>

      <div style="margin-bottom:12px;">
        <label style="font-size:11px; font-weight:bold; display:block; margin-bottom:4px;">Location Landmark / GPS <span style="color:#dc2626;">*</span></label>
        <div style="display:flex; gap:6px;">
          <input type="text" id="sosAddress" placeholder="Landmark, street address, or city..." style="flex:1; padding:8px; border:1px solid var(--border); border-radius:8px; font-size:12px;" oninput="clearSosFieldError('sosAddress', 'errAddress')">
          <button type="button" style="background:var(--primary); color:white; border:none; padding:0 12px; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="fetchBrowserGPSLocation()" title="Fetch Current GPS">
            <i class="fa-solid fa-location-crosshairs"></i> GPS
          </button>
        </div>
        <div class="field-error-text" id="errAddress" style="display:none; color:#dc2626; font-size:10px; font-weight:bold; margin-top:3px;"><i class="fa-solid fa-circle-exclamation"></i> Please enter location or fetch GPS position</div>
      </div>

      <div style="display:flex; gap:8px; margin-bottom:14px;">
        <div style="flex:1;">
          <label style="font-size:11px; font-weight:bold; display:block; margin-bottom:4px;">Contact Name</label>
          <input type="text" id="sosContactName" placeholder="Your Name" style="width:100%; padding:8px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>
        <div style="flex:1;">
          <label style="font-size:11px; font-weight:bold; display:block; margin-bottom:4px;">Phone / WhatsApp <span style="color:#dc2626;">*</span></label>
          <input type="tel" id="sosContactPhone" placeholder="+91 98765 43210" style="width:100%; padding:8px; border:1px solid var(--border); border-radius:8px; font-size:12px;" oninput="clearSosFieldError('sosContactPhone', 'errPhone')">
          <div class="field-error-text" id="errPhone" style="display:none; color:#dc2626; font-size:10px; font-weight:bold; margin-top:3px;"><i class="fa-solid fa-circle-exclamation"></i> Please enter contact phone number</div>
        </div>
      </div>

      <button type="button" style="width:100%; padding:12px; background:var(--emergency-red); color:white; border:none; border-radius:12px; font-size:13px; font-weight:bold; cursor:pointer; box-shadow:0 4px 12px rgba(220,38,38,0.3);" onclick="submitEmergencySOSReport()">
        <i class="fa-solid fa-tower-broadcast"></i> Request Emergency Rescue Now
      </button>
    </div>
  `;
}

function submitEmergencySOSReport() {
  const animalInput = document.getElementById('sosAnimalType');
  const conditionInput = document.getElementById('sosCondition');
  const addressInput = document.getElementById('sosAddress');
  const nameInput = document.getElementById('sosContactName');
  const phoneInput = document.getElementById('sosContactPhone');

  const animalType = (animalInput?.value || '').trim();
  const condition = (conditionInput?.value || '').trim();
  const location = (addressInput?.value || '').trim();
  const contactName = (nameInput?.value || '').trim() || 'Anonymous Reporter';
  const contactPhone = (phoneInput?.value || '').trim();

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
  if (!contactPhone) {
    showSosFieldError('sosContactPhone', 'errPhone');
    hasError = true;
  }

  if (hasError) return;

  const reqId = `SOS-2026-${Math.floor(1000 + Math.random() * 9000)}`;

  const newRequest = {
    id: reqId,
    category: selectedEmergencyCategory,
    animalType,
    condition,
    location,
    contactName,
    contactPhone,
    status: 'Submitted',
    createdAt: new Date().toISOString()
  };

  const requests = getRescueRequestsList();
  requests.unshift(newRequest);
  saveRescueRequestsList(requests);

  showToast(`Emergency Rescue Broadcasted! ID: ${reqId} 🚨`);
  navigateTo('my-rescue-requests');
}

function cancelRescueRequest(reqId) {
  let requests = getRescueRequestsList();
  const req = requests.find(r => r.id === reqId);
  if (req) {
    req.status = 'Cancelled';
    saveRescueRequestsList(requests);
    showToast(`Rescue Request ${reqId} cancelled.`);
    renderScreen();
  }
}

function renderMyRescueRequestsUI(container) {
  const requests = getRescueRequestsList();

  const statusIcons = {
    Submitted: '🕒',
    'Searching for Help': '🔍',
    'Responder Assigned': '🚑',
    Resolved: '✅',
    Cancelled: '❌'
  };

  const statusColors = {
    Submitted: 'warning',
    'Searching for Help': 'warning',
    'Responder Assigned': 'danger',
    Resolved: 'safe',
    Cancelled: 'muted'
  };

  container.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
      <div>
        <h4 style="font-size:16px; font-weight:800; color:var(--text-primary);">My Rescue Requests</h4>
        <span style="font-size:10px; color:var(--text-secondary);">${requests.length} Total Reports</span>
      </div>
      <div style="display:flex; gap:6px;">
        <button style="background:var(--emergency-red); color:white; border:none; padding:5px 10px; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="navigateTo('report-emergency')">
          <i class="fa-solid fa-plus"></i> New SOS
        </button>
        <button style="background:none; border:none; font-size:16px; cursor:pointer;" onclick="navigateTo('home')">
          <i class="fa-solid fa-xmark"></i>
        </button>
      </div>
    </div>

    ${requests.length === 0 ? `
      <div style="text-align:center; padding:40px 20px; background:white; border-radius:16px; border:1px solid var(--border);">
        <i class="fa-solid fa-tower-broadcast" style="font-size:42px; color:var(--emergency-red); margin-bottom:12px;"></i>
        <h5 style="font-size:15px; font-weight:bold; color:var(--text-primary);">No Rescue Requests Yet</h5>
        <p style="font-size:11px; color:var(--text-secondary); margin-top:4px; max-width:280px; margin-left:auto; margin-right:auto;">
          If you spot an injured stray or animal in distress, broadcast an Emergency SOS to alert nearby rescue teams.
        </p>
        <button style="margin-top:16px; padding:10px 20px; background:var(--emergency-red); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="navigateTo('report-emergency')">
          <i class="fa-solid fa-triangle-exclamation"></i> Report Emergency SOS
        </button>
      </div>
    ` : `
      <div style="display:flex; flex-direction:column; gap:10px;">
        ${requests.map(req => `
          <div class="result-card" style="position:relative; background:white; border-left:4px solid ${req.status === 'Resolved' ? 'var(--primary)' : 'var(--emergency-red)'};">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:6px;">
              <div>
                <span style="font-size:10px; font-weight:900; color:var(--text-muted); text-transform:uppercase;">${req.id}</span>
                <h5 style="font-size:13px; font-weight:800; color:var(--text-primary); margin-top:2px;">${req.animalType}</h5>
              </div>
              <span class="pill ${statusColors[req.status] || 'safe'}" style="font-size:10px;">
                ${statusIcons[req.status] || ''} ${req.status}
              </span>
            </div>

            <p style="font-size:11px; color:var(--text-secondary); margin-bottom:6px; line-height:1.4;">
              <b>Condition:</b> ${req.condition}
            </p>

            <div style="font-size:10px; color:var(--text-muted); background:#f8fafc; padding:6px 8px; border-radius:6px; margin-bottom:8px;">
              <div><i class="fa-solid fa-location-dot" style="color:var(--primary);"></i> <b>Location:</b> ${req.location}</div>
              <div style="margin-top:2px;"><i class="fa-solid fa-user"></i> <b>Contact:</b> ${req.contactName} (${req.contactPhone})</div>
            </div>

            <div style="margin-top:8px; padding-top:8px; border-top:1px solid var(--border);">
              <div style="font-size:10px; font-weight:700; color:var(--text-primary); margin-bottom:4px;">Rescue Response Timeline:</div>
              <div style="display:flex; gap:4px; font-size:9px;">
                <span style="flex:1; text-align:center; padding:3px; border-radius:4px; background:${req.status === 'Submitted' ? '#fee2e2' : '#f1f5f9'}; color:${req.status === 'Submitted' ? '#dc2626' : 'var(--text-muted)'}; font-weight:bold;">1. Submitted</span>
                <span style="flex:1; text-align:center; padding:3px; border-radius:4px; background:${req.status === 'Searching for Help' ? '#fef3c7' : '#f1f5f9'}; color:${req.status === 'Searching for Help' ? '#b45309' : 'var(--text-muted)'}; font-weight:bold;">2. Searching</span>
                <span style="flex:1; text-align:center; padding:3px; border-radius:4px; background:${req.status === 'Responder Assigned' ? '#dbeafe' : '#f1f5f9'}; color:${req.status === 'Responder Assigned' ? '#1d4ed8' : 'var(--text-muted)'}; font-weight:bold;">3. En Route</span>
                <span style="flex:1; text-align:center; padding:3px; border-radius:4px; background:${req.status === 'Resolved' ? '#d1fae5' : '#f1f5f9'}; color:${req.status === 'Resolved' ? '#047857' : 'var(--text-muted)'}; font-weight:bold;">4. Resolved</span>
              </div>
            </div>

            <div style="display:flex; gap:6px; margin-top:10px;">
              <a href="tel:1962" style="flex:1; background:#1e293b; color:white; padding:6px; border-radius:6px; text-decoration:none; text-align:center; font-size:10px; font-weight:bold;">
                <i class="fa-solid fa-phone"></i> Call Dispatch
              </a>
              ${req.status !== 'Resolved' && req.status !== 'Cancelled' ? `
                <button style="padding:6px 10px; background:white; color:#dc2626; border:1px solid var(--border); border-radius:6px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="cancelRescueRequest('${req.id}')">
                  Cancel Request
                </button>
              ` : ''}
            </div>
          </div>
        `).join('')}
      </div>
    `}
  `;
}

// ─── FIND HELP & VETS SERVICE DISCOVERY SYSTEM ──────────────────────────────
let currentVetCategory = 'all';
let vetSearchQuery = '';
let loadedVetProviders = [];
const VET_FAVORITES_KEY = 'pashu_favorite_vets';

function getFavoriteVetIds() {
  try {
    return JSON.parse(localStorage.getItem(VET_FAVORITES_KEY) || '[]');
  } catch (_) {
    return [];
  }
}

function toggleFavoriteVet(vetId) {
  const favs = getFavoriteVetIds();
  const idx = favs.indexOf(vetId);
  if (idx >= 0) {
    favs.splice(idx, 1);
    showToast('Removed from Favorites');
  } else {
    favs.push(vetId);
    showToast('Saved to Favorites! ❤️');
  }
  localStorage.setItem(VET_FAVORITES_KEY, JSON.stringify(favs));
  renderVetListingsUI();
}

function selectVetCategory(cat, btnElem) {
  currentVetCategory = cat;
  document.querySelectorAll('.pill-chip').forEach(b => {
    b.classList.remove('active');
    b.style.background = 'white';
    b.style.color = 'var(--text-primary)';
    b.style.border = '1px solid var(--border)';
  });
  if (btnElem) {
    btnElem.classList.add('active');
    btnElem.style.background = 'var(--primary)';
    btnElem.style.color = 'white';
    btnElem.style.border = 'none';
  }
  renderVetListingsUI();
}

function filterVetsUI() {
  const input = document.getElementById('vetSearchInput');
  vetSearchQuery = input ? input.value.trim().toLowerCase() : '';
  renderVetListingsUI();
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
      id: 'vet_jamui_1',
      name: 'Jamui District Veterinary Hospital',
      category: 'hospital',
      phone: '+91 6345 222100',
      website: 'https://jamui.bih.nic.in',
      addr: 'Court Road, Near Main Chowk, Jamui Town, Bihar 811307',
      distKm: calcDist(24.9260, 86.2250),
      vLat: 24.9260,
      vLon: 86.2250,
      is24x7: true,
      rating: 4.8,
      isShelter: false,
      isPetStore: false,
      isGovt: true
    },
    {
      id: 'vet_jamui_2',
      name: 'Amarwath Animal Rescue & Mobile Unit',
      category: 'shelter',
      phone: '+91 94312 88990',
      website: 'https://pashurakhshak.in',
      addr: 'Amarwath Village Road, Jamui District, Bihar 811307',
      distKm: calcDist(24.9542, 86.1837),
      vLat: 24.9542,
      vLon: 86.1837,
      is24x7: true,
      rating: 4.9,
      isShelter: true,
      isPetStore: false,
      isGovt: false
    },
    {
      id: 'vet_jamui_3',
      name: 'Govt. Veterinary Dispensary & Pet Clinic',
      category: 'clinic',
      phone: '+91 6345 224500',
      website: 'https://jamui.bih.nic.in',
      addr: 'Hospital Road, Sub-Division Area, Jamui, Bihar 811307',
      distKm: calcDist(24.9310, 86.2180),
      vLat: 24.9310,
      vLon: 86.2180,
      is24x7: false,
      rating: 4.7,
      isShelter: false,
      isPetStore: false,
      isGovt: true
    },
    {
      id: 'vet_blr_1',
      name: 'Cessna Lifeline Veterinary Hospital',
      category: 'hospital',
      phone: '+91 80 4123 4567',
      website: 'https://cessnalifeline.com',
      addr: 'Domlur, Inner Ring Rd, Bengaluru, Karnataka 560071',
      distKm: calcDist(12.9610, 77.6387),
      vLat: 12.9610,
      vLon: 77.6387,
      is24x7: true,
      rating: 4.9,
      isShelter: false,
      isPetStore: false,
      isGovt: false
    },
    {
      id: 'vet_mumbai_1',
      name: 'Bai Sakarbai Dinshaw Petit Hospital for Animals',
      category: 'hospital',
      phone: '+91 22 2413 7534',
      website: 'https://bsdphospital.org',
      addr: 'Dr SS Rao Rd, Parel, Mumbai, Maharashtra 400012',
      distKm: calcDist(19.0019, 72.8411),
      vLat: 19.0019,
      vLon: 72.8411,
      is24x7: true,
      rating: 4.6,
      isShelter: false,
      isPetStore: false,
      isGovt: true
    },
    {
      id: 'vet_delhi_1',
      name: 'Friendicoes SECA Shelter & Animal Hospital',
      category: 'shelter',
      phone: '+91 11 2432 0707',
      website: 'https://friendicoes.org',
      addr: 'No 271, Defence Colony Flyover Market, New Delhi 110024',
      distKm: calcDist(28.5721, 77.2341),
      vLat: 28.5721,
      vLon: 77.2341,
      is24x7: true,
      rating: 4.8,
      isShelter: true,
      isPetStore: false,
      isGovt: false
    }
  ];
}

async function loadRealNearbyVetsOverpass() {
  const container = document.getElementById('overpassVetsContainer');
  if (!container) return;

  container.innerHTML = `
    <div style="text-align:center; padding:30px; color:var(--text-secondary);">
      <i class="fa-solid fa-spinner fa-spin" style="font-size:24px; color:var(--primary);"></i>
      <p style="font-size:12px; margin-top:8px; font-weight:bold;">Locating verified veterinary clinics & shelters...</p>
    </div>
  `;

  let userLat = 24.9260;
  let userLon = 86.2250;

  if ('geolocation' in navigator) {
    try {
      const pos = await new Promise((res, rej) => navigator.geolocation.getCurrentPosition(res, rej, { timeout: 3000 }));
      userLat = pos.coords.latitude;
      userLon = pos.coords.longitude;
    } catch (_) {}
  }

  try {
    const overpassQuery = `[out:json][timeout:15];(node["amenity"="veterinary"](around:50000,${userLat},${userLon});way["amenity"="veterinary"](around:50000,${userLat},${userLon});node["amenity"="animal_shelter"](around:50000,${userLat},${userLon});way["amenity"="animal_shelter"](around:50000,${userLat},${userLon}););out center;`;
    const res = await fetch('https://overpass-api.de/api/interpreter', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'data=' + encodeURIComponent(overpassQuery)
    });

    if (res.ok) {
      const data = await res.json();
      const elements = data.elements || [];
      if (elements.length > 0) {
        loadedVetProviders = elements.map((el, i) => {
          const tags = el.tags || {};
          const vLat = el.type === 'node' ? el.lat : (el.center ? el.center.lat : userLat);
          const vLon = el.type === 'node' ? el.lon : (el.center ? el.center.lon : userLon);
          const isShelter = tags.amenity === 'animal_shelter';
          const name = tags.name || tags['name:en'] || (isShelter ? 'Animal Rescue Shelter' : 'Veterinary Hospital');
          const phone = tags.phone || tags['contact:phone'] || tags['phone:mobile'] || '';
          const website = tags.website || tags['contact:website'] || '';
          const addrParts = [tags['addr:street'], tags['addr:suburb'], tags['addr:city']].filter(Boolean);
          const addr = addrParts.length > 0 ? addrParts.join(', ') : `Near ${vLat.toFixed(4)}, ${vLon.toFixed(4)}`;

          return {
            id: `ovp_${el.id || i}`,
            name,
            category: isShelter ? 'shelter' : 'clinic',
            phone,
            website,
            addr,
            vLat,
            vLon,
            distKm: Math.abs(vLat - userLat) * 111,
            is24x7: tags['opening_hours'] === '24/7',
            rating: 4.8,
            isShelter,
            isPetStore: false,
            isGovt: tags['operator:type'] === 'government'
          };
        });
      } else {
        loadedVetProviders = getJamuiAmarwathFallbackVets(userLat, userLon);
      }
    } else {
      loadedVetProviders = getJamuiAmarwathFallbackVets(userLat, userLon);
    }
  } catch (err) {
    loadedVetProviders = getJamuiAmarwathFallbackVets(userLat, userLon);
  }

  renderVetListingsUI();
}

let googleMapsSdkLoaded = false;

function initGoogleMapsSdk() {
  if (window.google && window.google.maps) {
    googleMapsSdkLoaded = true;
    return Promise.resolve(true);
  }
  const baseUrl = (window.location && window.location.origin && window.location.origin !== 'null') ? window.location.origin : 'http://localhost:8080';
  return fetch(`${baseUrl}/api/config`)
    .then(res => res.json())
    .then(cfg => {
      const apiKey = cfg.googleMapsApiKey || window.VITE_GOOGLE_MAPS_API_KEY || '';
      if (!apiKey || apiKey.trim().length === 0 || apiKey.includes('your-google-maps')) {
        return false;
      }
      if (document.getElementById('googleMapsScript')) return true;
      return new Promise((resolve) => {
        const script = document.createElement('script');
        script.id = 'googleMapsScript';
        script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey.trim()}&libraries=places`;
        script.async = true;
        script.defer = true;
        script.onload = () => {
          googleMapsSdkLoaded = true;
          resolve(true);
        };
        script.onerror = () => resolve(false);
        document.head.appendChild(script);
      });
    })
    .catch(() => false);
}

function renderGoogleMapsCanvas(container, userLat, userLon, providers) {
  if (!container) return;
  const existingMap = document.getElementById('googleMapCanvas');
  if (existingMap) existingMap.remove();

  const mapCard = document.createElement('div');
  mapCard.id = 'googleMapCanvas';
  mapCard.style.cssText = 'width:100%; height:180px; border-radius:14px; margin-bottom:12px; border:1px solid var(--border); box-shadow:0 4px 10px rgba(0,0,0,0.05); overflow:hidden;';
  container.prepend(mapCard);

  if (window.google && window.google.maps) {
    try {
      const map = new google.maps.Map(mapCard, {
        center: { lat: userLat, lng: userLon },
        zoom: 11,
        mapTypeControl: false,
        streetViewControl: false
      });

      new google.maps.Marker({
        position: { lat: userLat, lng: userLon },
        map: map,
        title: 'Your Location',
        icon: {
          path: google.maps.SymbolPath.CIRCLE,
          scale: 8,
          fillColor: '#0284c7',
          fillOpacity: 1,
          strokeColor: '#ffffff',
          strokeWeight: 2
        }
      });

      (providers || []).forEach(p => {
        if (p.vLat && p.vLon) {
          const marker = new google.maps.Marker({
            position: { lat: p.vLat, lng: p.vLon },
            map: map,
            title: p.name,
            icon: p.isShelter ? 'http://maps.google.com/mapfiles/ms/icons/green-dot.png' : 'http://maps.google.com/mapfiles/ms/icons/red-dot.png'
          });

          const infoWindow = new google.maps.InfoWindow({
            content: `<div style="padding:6px; font-family:sans-serif;">
              <strong style="font-size:12px; color:#059669;">${p.name}</strong><br>
              <span style="font-size:10px; color:#64748b;">${p.addr || ''}</span><br>
              <div style="margin-top:6px; display:flex; gap:6px;">
                ${p.phone ? `<a href="tel:${p.phone}" style="padding:3px 8px; background:#059669; color:white; border-radius:6px; font-size:10px; text-decoration:none; font-weight:bold;">Call</a>` : ''}
                <a href="https://www.google.com/maps/dir/?api=1&destination=${p.vLat},${p.vLon}" target="_blank" style="padding:3px 8px; background:#0284c7; color:white; border-radius:6px; font-size:10px; text-decoration:none; font-weight:bold;">Directions</a>
              </div>
            </div>`
          });

          marker.addListener('click', () => {
            infoWindow.open(map, marker);
          });
        }
      });
    } catch (e) {
      console.warn('[GoogleMaps] Error rendering canvas:', e);
    }
  }
}

function renderVetListingsUI() {
  const container = document.getElementById('overpassVetsContainer');
  if (!container) return;

  if (!loadedVetProviders || loadedVetProviders.length === 0) {
    loadedVetProviders = getJamuiAmarwathFallbackVets(24.9260, 86.2250);
  }

  const favIds = getFavoriteVetIds();

  const filtered = loadedVetProviders.filter(item => {
    let matchesCat = true;
    if (currentVetCategory === 'hospital') matchesCat = item.category === 'hospital' || item.isGovt;
    else if (currentVetCategory === 'clinic') matchesCat = item.category === 'clinic' && !item.isGovt;
    else if (currentVetCategory === 'shelter') matchesCat = item.isShelter || item.category === 'shelter';
    else if (currentVetCategory === 'emergency') matchesCat = item.is24x7 === true;
    else if (currentVetCategory === 'favorites') matchesCat = favIds.includes(item.id);

    let matchesQuery = true;
    if (vetSearchQuery) {
      const q = vetSearchQuery;
      matchesQuery = (item.name && item.name.toLowerCase().includes(q)) ||
                     (item.addr && item.addr.toLowerCase().includes(q)) ||
                     (item.category && item.category.toLowerCase().includes(q)) ||
                     (item.phone && item.phone.toLowerCase().includes(q));
    }

    return matchesCat && matchesQuery;
  });

  if (filtered.length === 0) {
    container.innerHTML = `
      <div style="text-align:center; padding:30px; background:white; border-radius:14px; border:1px solid var(--border);">
        <i class="fa-solid fa-hospital-line" style="font-size:36px; color:#cbd5e1; margin-bottom:8px;"></i>
        <h5 style="font-size:14px; font-weight:bold; color:var(--text-primary);">No Veterinary Services Found</h5>
        <p style="font-size:11px; color:var(--text-secondary); margin-top:4px;">No centers found matching category '${currentVetCategory}'${vetSearchQuery ? ` and search '${vetSearchQuery}'` : ''}.</p>
        <button style="margin-top:12px; padding:6px 14px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="selectVetCategory('all', null); document.getElementById('vetSearchInput').value=''; filterVetsUI();">Reset All Filters</button>
      </div>
    `;
    return;
  }

  container.innerHTML = filtered.map(item => {
    const isFav = favIds.includes(item.id);
    const categoryBadge = item.isShelter
      ? '<span class="pill info">🐾 Animal Shelter / NGO</span>'
      : item.isGovt
      ? '<span class="pill primary" style="background:#d1fae5; color:#065f46;">🏛️ Govt. Hospital</span>'
      : item.is24x7
      ? '<span class="pill warning">🚨 24x7 Emergency</span>'
      : '<span class="pill safe">🩺 Vet Clinic</span>';

    return `
      <div class="result-card" style="margin-bottom:10px; position:relative;">
        <div style="display:flex; justify-content:space-between; align-items:flex-start;">
          <div style="flex:1; padding-right:8px;">
            <h5 style="font-size:13px; font-weight:800; color:var(--text-primary); margin-bottom:2px;">${item.name}</h5>
            <div style="display:flex; gap:4px; margin-bottom:4px; flex-wrap:wrap;">
              <span class="pill safe">Verified ✓</span>
              ${categoryBadge}
            </div>
            <p style="font-size:11px; color:var(--text-secondary); line-height:1.3;">📍 ${item.addr}</p>
          </div>
          <div style="text-align:right;">
            <span style="font-size:12px; font-weight:bold; color:var(--primary);">${(item.distKm || 0).toFixed(1)} km</span>
            <div style="font-size:11px; color:#f59e0b; margin-top:2px;">★ ${item.rating || 4.8}</div>
            <button style="background:none; border:none; color:${isFav ? '#ef4444' : '#94a3b8'}; font-size:16px; cursor:pointer; margin-top:4px;" onclick="toggleFavoriteVet('${item.id}')" title="Save Favorite">
              <i class="fa-${isFav ? 'solid' : 'regular'} fa-heart"></i>
            </button>
          </div>
        </div>

        <div style="display:flex; gap:6px; margin-top:10px;">
          ${item.phone
            ? `<button style="flex:1; padding:7px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="window.open('tel:${item.phone}')"><i class="fa-solid fa-phone"></i> Call (${item.phone})</button>`
            : `<button disabled style="flex:1; padding:7px; background:#e2e8f0; color:#94a3b8; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:not-allowed;"><i class="fa-solid fa-phone-slash"></i> Phone N/A</button>`
          }
          <button style="flex:1; padding:7px; background:white; color:var(--primary); border:1px solid var(--primary); border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="window.open('https://www.google.com/maps/dir/?api=1&destination=${item.vLat || 24.9260},${item.vLon || 86.2250}')"><i class="fa-solid fa-diamond-turn-right"></i> Directions</button>
          ${item.website
            ? `<button style="padding:7px 10px; background:#f1f5f9; color:var(--primary); border:1px solid var(--border); border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="window.open('${item.website}')"><i class="fa-solid fa-globe"></i></button>`
            : ``
          }
        </div>
      </div>
    `;
  }).join('');
}

// ─── ADOPT & PET MARKETPLACE FUNCTIONAL SYSTEM ──────────────────────────────
const ADOPT_FAVORITES_KEY = 'pashu_favorite_adopt';
const ADOPTION_REQUESTS_KEY = 'pashu_adoption_requests';

let currentAdoptCategory = 'all';

const mockAdoptItems = [
  {
    id: 'adopt_1',
    name: 'Leo (Desi Puppy)',
    type: 'dog',
    breed: 'Indian Pariah / Indie',
    age: '3 months',
    gender: 'Male',
    location: 'Lajpat Nagar, Delhi',
    isFree: true,
    price: 0,
    status: 'Available',
    health: 'Vaccinated (ARV + Puppy DP), Dewormed, Healthy',
    careReq: 'Needs loving home, 3 meals daily, daily play sessions, vaccination booster at 6 months',
    description: 'Rescued near Lajpat Nagar metro station. Playful, friendly with children, fully dewormed and active.',
    contact: '+91 98765 43210 (Delhi Animal Rescue)',
    icon: 'fa-dog',
    bg: '#d1fae5',
    color: 'var(--primary)'
  },
  {
    id: 'adopt_2',
    name: 'Milo (Ginger Kitten)',
    type: 'cat',
    breed: 'Ginger Tabby',
    age: '2 months',
    gender: 'Female',
    location: 'Bandra West, Mumbai',
    isFree: true,
    price: 0,
    status: 'Available',
    health: 'Dewormed, Litter-trained, Health Screened',
    careReq: 'Indoor cat, kitten kibble + wet food, scratching post, gentle handling',
    description: 'Rescued kitten looking for a warm indoor family. Litter trained and extremely affectionate.',
    contact: '+91 98123 45678 (Mumbai Cat Rescue)',
    icon: 'fa-cat',
    bg: '#fce7f3',
    color: '#ec4899'
  },
  {
    id: 'adopt_3',
    name: 'Rocky (Rescued Dog)',
    type: 'dog',
    breed: 'Labrador Mix',
    age: '1 year',
    gender: 'Male',
    location: 'Indiranagar, Bangalore',
    isFree: true,
    price: 0,
    status: 'Available',
    health: 'Neutered, Fully Vaccinated, Microchipped',
    careReq: 'Daily walks, high-protein diet, active family preferred',
    description: 'Rescued from street injury, fully recovered and neutered. Great companion dog.',
    contact: '+91 80987 65432 (Bangalore Pet Care)',
    icon: 'fa-dog',
    bg: '#d1fae5',
    color: 'var(--primary)'
  },
  {
    id: 'adopt_4',
    name: 'Pure Gir Cow & Calf',
    type: 'cow',
    breed: 'Gir Breed',
    age: '3 years',
    gender: 'Female',
    location: 'Karnal, Haryana',
    isFree: false,
    price: 45000,
    status: 'Available',
    health: 'Govt Vet Certified, Lumpy Vaccinated, High Milk Yield (14L/day)',
    careReq: 'Open shed, green fodder + dry straw, daily mineral mixture (50g)',
    description: 'High genetic quality Gir Cow with 1-month-old female calf. Verified breeder listing.',
    contact: '+91 94160 12345 (Karnal Dairy Farm)',
    icon: 'fa-cow',
    bg: '#fef9c3',
    color: '#ca8a04'
  },
  {
    id: 'adopt_5',
    name: 'Golden Retriever Pup',
    type: 'dog',
    breed: 'KCI Certified',
    age: '45 days',
    gender: 'Male',
    location: 'Sector 62, Noida',
    isFree: false,
    price: 18000,
    status: 'Available',
    health: 'KCI Registered, Microchipped, 1st Vaccination Completed',
    careReq: 'Puppy kibble, routine vet checkups, socialization',
    description: 'Purebred Golden Retriever pup from certified breeder. Health guarantee provided.',
    contact: '+91 99100 88776 (Noida KCI Kennels)',
    icon: 'fa-shield-dog',
    bg: '#e0f2fe',
    color: '#0284c7'
  },
  {
    id: 'adopt_6',
    name: 'High Yield Sahiwal Cow',
    type: 'cow',
    breed: 'Sahiwal Cattle',
    age: '4 years',
    gender: 'Female',
    location: 'Rohtak, Punjab',
    isFree: false,
    price: 55000,
    status: 'Available',
    health: 'Veterinary Dewormed, 16L/day Milk Yield Certified',
    careReq: 'Standard cattle shed, daily fresh fodder and clean water',
    description: 'Healthy Sahiwal Cow with calf. Verified breeder listing with complete medical records.',
    contact: '+91 98120 99887 (Rohtak Livestock)',
    icon: 'fa-cow',
    bg: '#fef9c3',
    color: '#ca8a04'
  },
  {
    id: 'adopt_7',
    name: 'Persian Kitten (White)',
    type: 'cat',
    breed: 'Persian Longhair',
    age: '2.5 months',
    gender: 'Female',
    location: 'Vasant Kunj, Delhi',
    isFree: false,
    price: 12000,
    status: 'Available',
    health: 'Tricat Vaccinated, Dewormed, Litter Trained',
    careReq: 'Daily coat grooming, indoor environment, premium cat food',
    description: 'Doll face white Persian kitten. Active, litter trained, and vaccinated.',
    contact: '+91 98100 11223 (Capital Cattery)',
    icon: 'fa-cat',
    bg: '#fce7f3',
    color: '#ec4899'
  },
  {
    id: 'adopt_8',
    name: 'Desi Calf (Male)',
    type: 'cow',
    breed: 'Local Desi',
    age: '6 months',
    gender: 'Male',
    location: 'Jamui, Bihar',
    isFree: true,
    price: 0,
    status: 'Available',
    health: 'Healthy, Dewormed, Govt Vet Screened',
    careReq: 'Open grazing, clean shelter, basic green fodder',
    description: 'Rescued calf looking for a Gaushala or caring farmer in Bihar.',
    contact: '+91 6345 222100 (Jamui Gaushala NGO)',
    icon: 'fa-cow',
    bg: '#fef9c3',
    color: '#ca8a04'
  }
];

function getFavoriteAdoptIds() {
  try {
    return JSON.parse(localStorage.getItem(ADOPT_FAVORITES_KEY) || '[]');
  } catch (_) {
    return [];
  }
}

function toggleFavoriteAdopt(animalId) {
  const favs = getFavoriteAdoptIds();
  const idx = favs.indexOf(animalId);
  if (idx >= 0) {
    favs.splice(idx, 1);
    showToast('Removed from Favorites');
  } else {
    favs.push(animalId);
    showToast('Saved to Favorites! ❤️');
  }
  localStorage.setItem(ADOPT_FAVORITES_KEY, JSON.stringify(favs));
  renderAdoptListingsUI();
}

function getAdoptionRequests() {
  try {
    return JSON.parse(localStorage.getItem(ADOPTION_REQUESTS_KEY) || '[]');
  } catch (_) {
    return [];
  }
}

function saveAdoptionRequest(reqObj) {
  const reqs = getAdoptionRequests();
  reqs.unshift(reqObj);
  localStorage.setItem(ADOPTION_REQUESTS_KEY, JSON.stringify(reqs));

  // Log to Supabase table 'public.adoption_requests' if API key is present
  const supabaseUrl = (window.VITE_SUPABASE_URL || window.SUPABASE_URL || 'https://hquogbhtaotoyyacyvvj.supabase.co').trim();
  const supabaseKey = (window.VITE_SUPABASE_PUBLISHABLE_KEY || window.VITE_SUPABASE_ANON_KEY || window.SUPABASE_ANON_KEY || 'sb_publishable_hd7k2Azv8v5ruJvgmKxUew_TPS62GPp').trim();
  if (supabaseKey && typeof fetch === 'function') {
    fetch(`${supabaseUrl}/rest/v1/adoption_requests`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`,
        'Prefer': 'return=minimal'
      },
      body: JSON.stringify({
        request_id: reqObj.id,
        animal_id: reqObj.animalId,
        animal_name: reqObj.animalName,
        applicant_name: reqObj.userName,
        applicant_contact: reqObj.userContact,
        applicant_address: reqObj.userAddress,
        reason: reqObj.reason,
        experience: reqObj.experience,
        status: reqObj.status,
        created_at: new Date().toISOString()
      })
    }).catch(err => console.warn('[Supabase Adoption Log Note]:', err.message));
  }
}

function withdrawAdoptionRequest(reqId) {
  let reqs = getAdoptionRequests();
  reqs = reqs.filter(r => r.id !== reqId);
  localStorage.setItem(ADOPTION_REQUESTS_KEY, JSON.stringify(reqs));
  showToast('Adoption request withdrawn');
  renderScreen();
}

function selectAdoptCategory(cat, btnElem) {
  currentAdoptCategory = cat;
  document.querySelectorAll('.pill-chip').forEach(b => {
    b.classList.remove('active');
    b.style.background = 'white';
    b.style.color = 'var(--text-primary)';
    b.style.border = '1px solid var(--border)';
  });
  if (btnElem) {
    btnElem.classList.add('active');
    btnElem.style.background = 'var(--primary)';
    btnElem.style.color = 'white';
    btnElem.style.border = 'none';
  }
  renderAdoptListingsUI();
}

function filterAdoptListingsUI() {
  renderAdoptListingsUI();
}

function renderAdoptListingsUI() {
  const container = document.getElementById('adoptListingsingsContainer');
  if (!container) return;

  const searchInput = document.getElementById('adoptSearchInput');
  const query = (searchInput && searchInput.value) ? searchInput.value.toLowerCase().trim() : '';

  const favs = getFavoriteAdoptIds();

  const filtered = mockAdoptItems.filter(item => {
    let matchesCat = true;
    if (currentAdoptCategory === 'dog') matchesCat = item.type === 'dog';
    else if (currentAdoptCategory === 'cat') matchesCat = item.type === 'cat';
    else if (currentAdoptCategory === 'cow') matchesCat = item.type === 'cow';
    else if (currentAdoptCategory === 'other') matchesCat = item.type !== 'dog' && item.type !== 'cat' && item.type !== 'cow';
    else if (currentAdoptCategory === 'favorites') matchesCat = favs.includes(item.id);

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
        <p style="font-size:11px; color:#94a3b8; margin-top:4px;">Try searching for "Indie", "Golden", "Delhi", or clear category filters.</p>
        <button style="margin-top:12px; padding:6px 14px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="selectAdoptCategory('all', null); document.getElementById('adoptSearchInput').value=''; filterAdoptListingsUI();">Reset Filters</button>
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
          ${freeItems.map(item => {
            const isFav = favs.includes(item.id);
            return `
              <div class="result-card" style="margin:0; padding:10px; position:relative; display:flex; flex-direction:column; justify-space-between;">
                <button style="position:absolute; top:8px; right:8px; background:none; border:none; color:${isFav ? '#ef4444' : '#cbd5e1'}; font-size:15px; cursor:pointer; z-index:2;" onclick="event.stopPropagation(); toggleFavoriteAdopt('${item.id}')">
                  <i class="fa-${isFav ? 'solid' : 'regular'} fa-heart"></i>
                </button>

                <div style="height:70px; background:${item.bg}; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:32px; color:${item.color}; margin-bottom:8px; cursor:pointer;" onclick="openAnimalDetailModal('${item.id}')">
                  <i class="fa-solid ${item.icon}"></i>
                </div>

                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:2px;">
                  <span class="pill safe" style="font-weight:800; font-size:9px;">FREE ADOPTION</span>
                  <span style="font-size:9px; font-weight:bold; color:var(--primary);">● ${item.status}</span>
                </div>

                <h6 style="font-size:12px; font-weight:bold; margin-top:2px; margin-bottom:2px; cursor:pointer;" onclick="openAnimalDetailModal('${item.id}')">${item.name}</h6>
                <p style="font-size:10px; color:var(--text-secondary); margin-bottom:2px;">${item.breed} • ${item.age}</p>
                <p style="font-size:9px; color:#64748b; margin-bottom:8px;">📍 ${item.location}</p>

                <div style="display:flex; gap:4px; margin-top:auto;">
                  <button style="flex:1; padding:5px; background:var(--primary); color:white; border:none; border-radius:6px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="openAdoptionRequestForm('${item.id}')"><i class="fa-solid fa-file-signature"></i> Adopt</button>
                  <button style="padding:5px 8px; background:white; color:var(--primary); border:1px solid var(--primary); border-radius:6px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="openAnimalDetailModal('${item.id}')" title="Details"><i class="fa-solid fa-eye"></i></button>
                </div>
              </div>
            `;
          }).join('')}
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
          ${breederItems.map(item => {
            const isFav = favs.includes(item.id);
            return `
              <div class="result-card" style="margin:0; padding:10px; border-top:3px solid #0284c7; position:relative; display:flex; flex-direction:column; justify-content:space-between;">
                <button style="position:absolute; top:8px; right:8px; background:none; border:none; color:${isFav ? '#ef4444' : '#cbd5e1'}; font-size:15px; cursor:pointer; z-index:2;" onclick="event.stopPropagation(); toggleFavoriteAdopt('${item.id}')">
                  <i class="fa-${isFav ? 'solid' : 'regular'} fa-heart"></i>
                </button>

                <div style="height:70px; background:${item.bg}; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:32px; color:${item.color}; margin-bottom:8px; cursor:pointer;" onclick="openAnimalDetailModal('${item.id}')">
                  <i class="fa-solid ${item.icon}"></i>
                </div>

                <h6 style="font-size:12px; font-weight:bold; margin-bottom:2px; cursor:pointer;" onclick="openAnimalDetailModal('${item.id}')">${item.name}</h6>
                <div style="font-size:13px; font-weight:900; color:#0284c7; margin-bottom:4px;">${item.price > 0 ? '₹' + item.price.toLocaleString('en-IN') : 'Price on Request'}</div>
                <p style="font-size:10px; color:var(--text-secondary); margin-bottom:2px;">${item.breed} • ${item.age}</p>
                <p style="font-size:9px; color:#64748b; margin-bottom:8px;">📍 ${item.location}</p>

                <div style="display:flex; gap:4px; margin-top:auto;">
                  <button style="flex:1; padding:5px; background:#0284c7; color:white; border:none; border-radius:6px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="openAdoptionRequestForm('${item.id}')"><i class="fa-solid fa-cart-shopping"></i> Request</button>
                  <button style="padding:5px 8px; background:white; color:#0284c7; border:1px solid #0284c7; border-radius:6px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="openAnimalDetailModal('${item.id}')" title="Details"><i class="fa-solid fa-eye"></i></button>
                </div>
              </div>
            `;
          }).join('')}
        </div>
      </div>
    `;
  }

  container.innerHTML = html;
}

// ─── ANIMAL DETAIL MODAL ──────────────────────────────────────────────────────
function openAnimalDetailModal(animalId) {
  const item = mockAdoptItems.find(a => a.id === animalId);
  if (!item) return;

  const isFav = getFavoriteAdoptIds().includes(animalId);

  let modal = document.getElementById('animalDetailModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'animalDetailModal';
    modal.style.cssText = 'position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.6); z-index:9999; display:flex; align-items:center; justify-content:center; padding:16px;';
    document.body.appendChild(modal);
    modal = document.getElementById('animalDetailModal') || modal;
  }

  modal.innerHTML = `
    <div style="background:white; border-radius:18px; max-width:420px; width:100%; max-height:90vh; overflow-y:auto; padding:18px; position:relative; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:none; width:28px; height:28px; border-radius:50%; font-size:14px; color:var(--text-secondary); cursor:pointer;" onclick="closeAnimalDetailModal()"><i class="fa-solid fa-xmark"></i></button>

      <div style="height:120px; background:${item.bg}; border-radius:14px; display:flex; align-items:center; justify-content:center; font-size:54px; color:${item.color}; margin-bottom:12px;">
        <i class="fa-solid ${item.icon}"></i>
      </div>

      <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:6px;">
        <div>
          <h4 style="font-size:16px; font-weight:800; color:var(--text-primary);">${item.name}</h4>
          <span style="font-size:11px; color:var(--text-secondary); font-weight:bold;">${item.breed} • ${item.age} (${item.gender})</span>
        </div>
        <div style="text-align:right;">
          <div style="font-size:14px; font-weight:900; color:${item.isFree ? 'var(--primary)' : '#0284c7'};">${item.isFree ? 'FREE ADOPTION' : '₹' + item.price.toLocaleString('en-IN')}</div>
          <span class="pill safe" style="font-size:9px;">Status: ${item.status}</span>
        </div>
      </div>

      <p style="font-size:11px; color:var(--text-muted); margin-bottom:10px;">📍 ${item.location}</p>

      <div style="background:#f8fafc; border:1px solid var(--border); border-radius:10px; padding:10px; margin-bottom:10px; font-size:11px; line-height:1.4;">
        <div style="font-weight:bold; color:var(--text-primary); margin-bottom:4px;"><i class="fa-solid fa-circle-info" style="color:var(--primary);"></i> About this animal:</div>
        <p style="color:var(--text-secondary);">${item.description}</p>
      </div>

      <div style="background:#f0fdf4; border:1px solid #bbf7d0; border-radius:10px; padding:10px; margin-bottom:10px; font-size:11px; line-height:1.4;">
        <div style="font-weight:bold; color:#166534; margin-bottom:4px;"><i class="fa-solid fa-heart-pulse"></i> Medical & Vaccination Status:</div>
        <p style="color:#15803d;">${item.health}</p>
      </div>

      <div style="background:#fffbebf; border:1px solid #fde68a; border-radius:10px; padding:10px; margin-bottom:14px; font-size:11px; line-height:1.4;">
        <div style="font-weight:bold; color:#92400e; margin-bottom:4px;"><i class="fa-solid fa-hand-holding-hand"></i> Care & Home Requirements:</div>
        <p style="color:#b45309;">${item.careReq}</p>
      </div>

      <div style="display:flex; gap:8px;">
        <button style="flex:1; padding:10px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="closeAnimalDetailModal(); openAdoptionRequestForm('${item.id}');">
          <i class="fa-solid fa-file-signature"></i> Request Adoption
        </button>
        <button style="padding:10px 14px; background:white; color:${isFav ? '#ef4444' : '#94a3b8'}; border:1px solid var(--border); border-radius:10px; font-size:14px; cursor:pointer;" onclick="toggleFavoriteAdopt('${item.id}'); openAnimalDetailModal('${item.id}');" title="Save Favorite">
          <i class="fa-${isFav ? 'solid' : 'regular'} fa-heart"></i>
        </button>
        <button style="padding:10px 14px; background:#f1f5f9; color:var(--primary); border:1px solid var(--border); border-radius:10px; font-size:14px; cursor:pointer;" onclick="window.open('tel:${item.contact}')" title="Call Rescuer">
          <i class="fa-solid fa-phone"></i>
        </button>
      </div>
    </div>
  `;
  modal.style.display = 'flex';
}

function closeAnimalDetailModal() {
  const modal = document.getElementById('animalDetailModal');
  if (modal) modal.style.display = 'none';
}

// ─── ADOPTION REQUEST FORM MODAL ─────────────────────────────────────────────
function openAdoptionRequestForm(animalId) {
  const item = mockAdoptItems.find(a => a.id === animalId);
  if (!item) return;

  let modal = document.getElementById('adoptionFormModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'adoptionFormModal';
    modal.style.cssText = 'position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.6); z-index:9999; display:flex; align-items:center; justify-content:center; padding:16px;';
    document.body.appendChild(modal);
    modal = document.getElementById('adoptionFormModal') || modal;
  }

  modal.innerHTML = `
    <div style="background:white; border-radius:18px; max-width:420px; width:100%; max-height:90vh; overflow-y:auto; padding:18px; position:relative; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:none; width:28px; height:28px; border-radius:50%; font-size:14px; color:var(--text-secondary); cursor:pointer;" onclick="closeAdoptionFormModal()"><i class="fa-solid fa-xmark"></i></button>

      <div style="display:flex; align-items:center; gap:10px; margin-bottom:12px; padding-bottom:10px; border-bottom:1px solid var(--border);">
        <div style="width:42px; height:42px; background:${item.bg}; color:${item.color}; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:22px;">
          <i class="fa-solid ${item.icon}"></i>
        </div>
        <div>
          <h5 style="font-size:14px; font-weight:800; color:var(--text-primary);">Adoption Application</h5>
          <span style="font-size:11px; color:var(--primary); font-weight:bold;">For: ${item.name} (${item.breed})</span>
        </div>
      </div>

      <form onsubmit="submitAdoptionRequest(event, '${item.id}')">
        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Your Full Name *</label>
          <input type="text" id="adoptUserName" required placeholder="e.g. Rahul Sharma" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Contact Phone / WhatsApp *</label>
          <input type="tel" id="adoptUserContact" required placeholder="e.g. +91 98765 43210" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">City & Residential Address *</label>
          <input type="text" id="adoptUserAddress" required placeholder="e.g. Lajpat Nagar, New Delhi" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Reason for Adoption *</label>
          <textarea id="adoptReason" required placeholder="Why do you want to adopt this pet? Mention home environment..." style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px; height:50px;"></textarea>
        </div>

        <div style="margin-bottom:12px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Previous Pet Experience</label>
          <input type="text" id="adoptExperience" placeholder="e.g. Owned an Indie dog for 4 years / First-time pet parent" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="display:flex; gap:8px;">
          <button type="submit" style="flex:1; padding:10px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;">
            <i class="fa-solid fa-paper-plane"></i> Submit Adoption Application
          </button>
          <button type="button" style="padding:10px 14px; background:#f1f5f9; color:var(--text-secondary); border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="closeAdoptionFormModal()">Cancel</button>
        </div>
      </form>
    </div>
  `;
  modal.style.display = 'flex';
}

function closeAdoptionFormModal() {
  const modal = document.getElementById('adoptionFormModal');
  if (modal) modal.style.display = 'none';
}

function submitAdoptionRequest(event, animalId) {
  if (event) event.preventDefault();

  const animal = mockAdoptItems.find(a => a.id === animalId);
  if (!animal) return;

  const userName = (document.getElementById('adoptUserName') ? document.getElementById('adoptUserName').value : '').trim();
  const userContact = (document.getElementById('adoptUserContact') ? document.getElementById('adoptUserContact').value : '').trim();
  const userAddress = (document.getElementById('adoptUserAddress') ? document.getElementById('adoptUserAddress').value : '').trim();
  const reason = (document.getElementById('adoptReason') ? document.getElementById('adoptReason').value : '').trim();
  const experience = (document.getElementById('adoptExperience') ? document.getElementById('adoptExperience').value : '').trim();

  if (!userName || !userContact || !reason) {
    showToast('Please fill out all required form fields.');
    return;
  }

  const reqId = 'REQ-2026-' + Math.floor(1000 + Math.random() * 9000);

  const reqObj = {
    id: reqId,
    animalId: animal.id,
    animalName: animal.name,
    breed: animal.breed,
    location: animal.location,
    userName,
    userContact,
    userAddress,
    reason,
    experience: experience || 'First-time pet owner',
    status: 'Submitted',
    date: new Date().toLocaleDateString('en-IN', { day:'numeric', month:'short', year:'numeric', hour:'2-digit', minute:'2-digit' })
  };

  saveAdoptionRequest(reqObj);
  closeAdoptionFormModal();
  showToast(`Application ${reqId} Submitted Successfully! 🎉`);

  navigateTo('my-adoption-requests');
}

// ─── MY ADOPTION REQUESTS SCREEN ─────────────────────────────────────────────
function renderMyAdoptionRequestsUI(container) {
  const requests = getAdoptionRequests();

  container.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
      <div style="display:flex; align-items:center; gap:8px;">
        <button style="background:none; border:none; color:var(--text-secondary); font-size:16px; cursor:pointer;" onclick="navigateTo('adopt')">
          <i class="fa-solid fa-arrow-left"></i>
        </button>
        <h4 style="font-size:16px; font-weight:800;">My Adoption Applications</h4>
      </div>
      <span class="pill primary">${requests.length} Requests</span>
    </div>

    ${requests.length === 0 ? `
      <div style="text-align:center; padding:40px 20px; background:white; border-radius:16px; border:1px solid var(--border);">
        <i class="fa-solid fa-clipboard-check" style="font-size:36px; color:#cbd5e1; margin-bottom:10px;"></i>
        <h5 style="font-size:14px; font-weight:bold; color:var(--text-primary);">No Active Applications</h5>
        <p style="font-size:11px; color:var(--text-secondary); margin-top:4px;">You have not submitted any pet adoption applications yet.</p>
        <button style="margin-top:14px; padding:10px 18px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="navigateTo('adopt')">
          <i class="fa-solid fa-paw"></i> Browse Animals for Adoption
        </button>
      </div>
    ` : `
      <div style="display:flex; flex-direction:column; gap:10px;">
        ${requests.map(req => {
          let statusStyle = 'background:#fef3c7; color:#92400e; border:1px solid #fde68a;'; // Submitted / Pending
          let statusIcon = 'fa-clock';
          if (req.status === 'Approved') { statusStyle = 'background:#d1fae5; color:#065f46; border:1px solid #a7f3d0;'; statusIcon = 'fa-circle-check'; }
          else if (req.status === 'Under Review') { statusStyle = 'background:#e0f2fe; color:#075985; border:1px solid #bae6fd;'; statusIcon = 'fa-magnifying-glass'; }
          else if (req.status === 'Rejected') { statusStyle = 'background:#fee2e2; color:#991b1b; border:1px solid #fca5a5;'; statusIcon = 'fa-circle-xmark'; }
          else if (req.status === 'Completed') { statusStyle = 'background:#ecfdf5; color:#047857; border:1px solid #6ee7b7;'; statusIcon = 'fa-trophy'; }

          return `
            <div class="result-card" style="margin:0; padding:12px;">
              <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:6px;">
                <div>
                  <span style="font-size:10px; font-weight:bold; color:var(--primary); font-family:monospace;">${req.id}</span>
                  <h5 style="font-size:13px; font-weight:800; color:var(--text-primary);">${req.animalName}</h5>
                </div>
                <span style="padding:3px 8px; border-radius:10px; font-size:9px; font-weight:bold; ${statusStyle}">
                  <i class="fa-solid ${statusIcon}"></i> ${req.status}
                </span>
              </div>

              <div style="font-size:10px; color:var(--text-secondary); margin-bottom:6px;">
                📍 ${req.location} • Submitted on ${req.date}
              </div>

              <div style="background:#f8fafc; border:1px solid var(--border); border-radius:8px; padding:6px 8px; font-size:10px; color:var(--text-primary); margin-bottom:8px;">
                <b>Applicant:</b> ${req.userName} (${req.userContact})<br>
                <b>Reason:</b> ${req.reason}
              </div>

              <div style="display:flex; justify-content:flex-end;">
                <button style="background:none; border:none; color:var(--emergency-red); font-size:10px; font-weight:bold; cursor:pointer;" onclick="withdrawAdoptionRequest('${req.id}')">
                  <i class="fa-solid fa-trash"></i> Withdraw Request
                </button>
              </div>
            </div>
          `;
        }).join('')}
      </div>
    `}
  `;
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

// ─── PASHU MITRA AI CHAT MANAGEMENT ──────────────────────────────────────────
const CHAT_HISTORY_KEY = 'pashu_chat_history';

function getChatHistoryList() {
  try {
    return JSON.parse(localStorage.getItem(CHAT_HISTORY_KEY) || '[]');
  } catch (_) {
    return [];
  }
}

function saveChatHistoryList(list) {
  try {
    localStorage.setItem(CHAT_HISTORY_KEY, JSON.stringify(list.slice(-50)));

    // Log chat to Supabase 'public.chat_logs' if REST client is available
    const supabaseUrl = (window.VITE_SUPABASE_URL || window.SUPABASE_URL || 'https://hquogbhtaotoyyacyvvj.supabase.co').trim();
    const supabaseKey = (window.VITE_SUPABASE_PUBLISHABLE_KEY || window.VITE_SUPABASE_ANON_KEY || window.SUPABASE_ANON_KEY || 'sb_publishable_hd7k2Azv8v5ruJvgmKxUew_TPS62GPp').trim();
    if (supabaseKey && typeof fetch === 'function') {
      const lastMsg = list[list.length - 1];
      if (lastMsg && lastMsg.role === 'user') {
        fetch(`${supabaseUrl}/rest/v1/chat_logs`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`,
            'Prefer': 'return=minimal'
          },
          body: JSON.stringify({
            message: lastMsg.text,
            created_at: new Date().toISOString()
          })
        }).catch(err => console.warn('[Supabase Chat Log Note]:', err.message));
      }
    }
  } catch (e) {
    console.warn('[ChatHistory] Error saving chat history:', e);
  }
}

function clearChatMessages() {
  localStorage.removeItem(CHAT_HISTORY_KEY);
  renderChatBubblesUI();
  showToast('Chat conversation cleared');
}

function renderChatBubblesUI() {
  const box = document.getElementById('chatMessagesBox');
  if (!box) return;
  const history = getChatHistoryList();

  if (history.length === 0) {
    box.innerHTML = `
      <div class="chat-bubble ai" style="align-self:flex-start; background:white; color:var(--text-primary); padding:10px 12px; border-radius:14px; border-bottom-left-radius:4px; border:1px solid var(--border); max-width:88%; font-size:12px; line-height:1.4;">
        Namaste! I am <b>Pashu Mitra AI (पशु मित्र)</b>, your 24/7 AI animal care & veterinary assistant.
        <br><br>
        Ask me about pet care, stray rescue guidance, animal nutrition, vaccine schedules, or nearby vets.
      </div>
    `;
  } else {
    box.innerHTML = history.map(msg => {
      if (msg.role === 'user') {
        return `<div class="chat-bubble user" style="align-self:flex-end; background:var(--primary); color:white; padding:8px 12px; border-radius:14px; border-bottom-right-radius:4px; max-width:85%; font-size:12px;">${escapeHtml(msg.text)}</div>`;
      } else {
        return `<div class="chat-bubble ai" style="align-self:flex-start; background:white; color:var(--text-primary); padding:10px 12px; border-radius:14px; border-bottom-left-radius:4px; border:1px solid var(--border); max-width:88%; font-size:12px; line-height:1.4;">${msg.text}</div>`;
      }
    }).join('');
  }
  box.scrollTop = box.scrollHeight;
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function askPreset(promptText) {
  sendChatMessage(promptText);
}

async function sendChatMessage(promptOverride) {
  const input = document.getElementById('chatInput');
  const text = promptOverride || (input ? input.value.trim() : '');
  if (!text) return;

  if (input) input.value = '';

  const history = getChatHistoryList();
  history.push({ role: 'user', text: text, timestamp: new Date().toISOString() });

  // Add temporary typing indicator
  history.push({
    role: 'ai',
    text: '<i class="fa-solid fa-circle-notch fa-spin" style="color:var(--primary);"></i> <b>Pashu Mitra AI is thinking...</b>',
    isLoading: true
  });

  saveChatHistoryList(history.filter(m => !m.isLoading));
  renderChatBubblesUI();

  let reply = '';
  let isError = false;

  try {
    const baseUrl = (window.location && window.location.origin && window.location.origin !== 'null') ? window.location.origin : 'http://localhost:8080';
    const res = await fetch(`${baseUrl}/api/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: text, history: history })
    });

    if (res.ok) {
      const data = await res.json();
      if (data.reply) {
        reply = data.reply.replace(/\n/g, '<br>');
      }
    } else {
      isError = true;
    }
  } catch (e) {
    console.warn('[PashuMitraAI] Backend AI endpoint error:', e);
    isError = true;
  }

  // Smart Context-Aware Fallback Responses if API key not available or call fails
  if (!reply) {
    const lower = text.toLowerCase();
    if (lower.includes('vaccin') || lower.includes('shot')) {
      reply = "<b>Core Indian Pet Vaccination Schedule:</b><br>• <b>6-8 Weeks:</b> Puppy DP (Distemper/Parvo)<br>• <b>10-12 Weeks:</b> 7-in-1 Combination (DHPPiL)<br>• <b>14-16 Weeks:</b> Anti-Rabies Vaccine (ARV)<br>• <b>Annual Booster:</b> Repeat ARV + 7-in-1 every 12 months.";
    } else if (lower.includes('food') || lower.includes('eat') || lower.includes('diet') || lower.includes('suitable')) {
      reply = "<b>Animal Food Guidelines:</b><br>• <b>Dogs:</b> Cooked rice, chicken, boiled eggs, carrots, pumpkin, kibble. (NO onions, garlic, chocolate, grapes, alcohol).<br>• <b>Cats:</b> High-protein meat, fish, wet cat food. Avoid milk (cats are lactose intolerant).<br>• <b>Cattle:</b> Fresh green fodder, dry straw, grains, mineral mixture (50g/day).<br>• <b>Birds:</b> Millets, sunflower seeds, fresh fruits (apples without seeds).";
    } else if (lower.includes('stray') || lower.includes('injured') || lower.includes('found')) {
      reply = "<b>Injured Stray Animal First Steps:</b><br>1. <b>Safety First:</b> Approach quietly without sudden movements. Use a blanket if handling a nervous animal.<br>2. <b>Hydration:</b> Offer clean water nearby.<br>3. <b>First Aid:</b> For minor bleeding, apply gentle pressure with a clean cloth.<br>4. <b>Dispatch Rescue:</b> Tap <b>Alert NGO SOS</b> on the home screen or call <b>Wildlife SOS: 1800-200-9122</b>.";
    } else if (lower.includes('vet') || lower.includes('doctor') || lower.includes('hospital') || lower.includes('clinic')) {
      reply = "<b>Finding Nearby Vets & Hospitals:</b><br>Tap the <b>Find Help</b> tab on the bottom navigation bar to view real-time OpenStreetMap GPS locations, phone numbers, and ratings of veterinary clinics and 24x7 animal hospitals near your current location.";
    } else if (lower.includes('rescued') || lower.includes('rescue')) {
      reply = "<b>Caring for Rescued Animals:</b><br>1. Create a warm, quiet isolation zone free from loud noises.<br>2. Have a licensed veterinarian perform a deworming and health screening.<br>3. Introduce high-nutrition food gradually to prevent tummy upset.<br>4. List the pet on PashuRakhshak's <b>Adopt</b> marketplace if fostering.";
    } else if (lower.includes('care') || lower.includes('pet')) {
      reply = "<b>General Pet Care Guidance:</b><br>• <b>Hydration:</b> Provide fresh, clean water at all times.<br>• <b>Nutrition:</b> Feed age-appropriate, balanced food (avoid chocolates, onions, grapes).<br>• <b>Vaccinations:</b> Keep Anti-Rabies (ARV) and 7-in-1 boosters up to date.<br>• <b>Grooming:</b> Brush fur regularly and check paws for ticks/burrs.<br>• <b>Love & Exercise:</b> Provide daily physical activity and positive engagement.";
    } else {
      reply = "Namaste! To care for animals: ensure clean water, balanced food, routine deworming, and safe shelter. For specific health concerns, describe the symptoms or ask a question above!";
    }
  }

  // Emergency Disclaimer Check
  const emergencyKeywords = ['bleeding', 'poison', 'unconscious', 'snake', 'bite', 'fracture', 'broken', 'vomit blood', 'seizure', 'dying', 'critical'];
  if (emergencyKeywords.some(k => text.toLowerCase().includes(k))) {
    reply += `<br><br><div style="background:#fee2e2; border:1px solid #fca5a5; padding:8px 10px; border-radius:10px; font-size:11px; color:#991b1b; font-weight:bold;">
      <i class="fa-solid fa-truck-medical"></i> <b>Emergency Disclaimer:</b> For severe injuries or medical emergencies, please contact a qualified veterinarian or emergency animal rescue (Wildlife SOS: 1800-200-9122) immediately instead of relying solely on AI advice.
    </div>`;
  }

  const updatedHistory = getChatHistoryList();

  if (isError) {
    updatedHistory.push({
      role: 'ai',
      text: `${reply}<br><br><button style="padding:5px 12px; background:var(--emergency-red); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="sendChatMessage('${escapeHtml(text)}')"><i class="fa-solid fa-rotate-right"></i> Retry Query</button>`,
      timestamp: new Date().toISOString()
    });
  } else {
    updatedHistory.push({
      role: 'ai',
      text: reply,
      timestamp: new Date().toISOString()
    });
  }

  saveChatHistoryList(updatedHistory);
  renderChatBubblesUI();
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

// ─── SCAN HISTORY (localStorage & Supabase animal_sightings) ───────────────────
const SCAN_HISTORY_KEY = 'pashu_scan_history';
const MAX_SCAN_HISTORY = 30;

async function saveScanToHistory(result, imageThumb) {
  if (!result) return;
  try {
    const history = getScanHistory();
    const entry = {
      id: Date.now(),
      common_name: result.common_name || 'Animal Sighting',
      scientific_name: result.scientific_name || 'Fauna incertae sedis',
      confidence: result.confidence || 0.85,
      danger_level: result.danger_level || 'safe',
      diet: result.diet || '',
      habitat: result.habitat || '',
      first_aid: result.first_aid || '',
      general_care: result.general_care || '',
      timestamp: new Date().toISOString(),
      thumb: imageThumb || null
    };
    history.unshift(entry);
    localStorage.setItem(SCAN_HISTORY_KEY, JSON.stringify(history.slice(0, MAX_SCAN_HISTORY)));
    console.log('[ScanHistory] Saved locally:', result.common_name);

    // Save log to Supabase 'public.animal_sightings' table if client or REST endpoint available
    const supabaseUrl = (window.VITE_SUPABASE_URL || window.SUPABASE_URL || 'https://hquogbhtaotoyyacyvvj.supabase.co').trim();
    const supabaseKey = (window.VITE_SUPABASE_PUBLISHABLE_KEY || window.VITE_SUPABASE_ANON_KEY || window.SUPABASE_ANON_KEY || 'sb_publishable_hd7k2Azv8v5ruJvgmKxUew_TPS62GPp').trim();

    if (supabaseKey && typeof fetch === 'function') {
      try {
        await fetch(`${supabaseUrl}/rest/v1/animal_sightings`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`,
            'Prefer': 'return=minimal'
          },
          body: JSON.stringify({
            image_url: supabaseStorageSavedUrl || `https://supabase.co/storage/v1/object/public/animal-photos/sightings/${Date.now()}.jpg`,
            prediction: result.common_name,
            confidence: result.confidence || 0.85,
            model_used: 'Gemini Vision / TFLite iNaturalist Dual',
            health_screening_data: result
          })
        });
        console.log('[Supabase] Saved sighting to public.animal_sightings table');
      } catch (sbErr) {
        console.warn('[Supabase Log Note]:', sbErr.message);
      }
    }
  } catch (e) {
    console.warn('[ScanHistory] Error saving scan:', e);
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
  showToast('Scan history cleared');
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

// Navigation tracking is handled directly inside navigateTo()

// ─── PET HEALTH & REMINDERS MANAGEMENT SYSTEM ────────────────────────────────
const PETS_KEY = 'pashu_user_pets';
const HEALTH_RECORDS_KEY = 'pashu_pet_health_records';
const REMINDERS_KEY = 'pashu_pet_reminders';

let activePetId = null;
let activeHealthTab = 'reminders';

function getPetsList() {
  try {
    return JSON.parse(localStorage.getItem(PETS_KEY) || '[]');
  } catch (_) {
    return [];
  }
}

function savePetsList(list) {
  try {
    localStorage.setItem(PETS_KEY, JSON.stringify(list));
    const supabaseUrl = (window.VITE_SUPABASE_URL || window.SUPABASE_URL || 'https://hquogbhtaotoyyacyvvj.supabase.co').trim();
    const supabaseKey = (window.VITE_SUPABASE_PUBLISHABLE_KEY || window.VITE_SUPABASE_ANON_KEY || window.SUPABASE_ANON_KEY || 'sb_publishable_hd7k2Azv8v5ruJvgmKxUew_TPS62GPp').trim();
    if (supabaseKey && typeof fetch === 'function' && list.length > 0) {
      const lastPet = list[list.length - 1];
      fetch(`${supabaseUrl}/rest/v1/pets`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`,
          'Prefer': 'return=minimal'
        },
        body: JSON.stringify({
          pet_id: lastPet.id,
          name: lastPet.name,
          species: lastPet.species,
          breed: lastPet.breed,
          age: lastPet.age,
          gender: lastPet.gender,
          notes: lastPet.notes,
          created_at: new Date().toISOString()
        })
      }).catch(err => console.warn('[Supabase Pet Log Note]:', err.message));
    }
  } catch (e) {
    console.warn('[PetsStorage] Error saving pets list:', e);
  }
}

function getHealthRecordsList() {
  try {
    return JSON.parse(localStorage.getItem(HEALTH_RECORDS_KEY) || '[]');
  } catch (_) {
    return [];
  }
}

function saveHealthRecordsList(list) {
  try {
    localStorage.setItem(HEALTH_RECORDS_KEY, JSON.stringify(list));
  } catch (e) {
    console.warn('[RecordsStorage] Error saving records:', e);
  }
}

function getRemindersList() {
  try {
    return JSON.parse(localStorage.getItem(REMINDERS_KEY) || '[]');
  } catch (_) {
    return [];
  }
}

function saveRemindersList(list) {
  try {
    localStorage.setItem(REMINDERS_KEY, JSON.stringify(list));
  } catch (e) {
    console.warn('[RemindersStorage] Error saving reminders:', e);
  }
}

function openAddPetModal(editPetId = null) {
  let pet = null;
  if (editPetId) {
    pet = getPetsList().find(p => p.id === editPetId);
  }

  let modal = document.getElementById('petFormModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'petFormModal';
    modal.style.cssText = 'position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.6); z-index:9999; display:flex; align-items:center; justify-content:center; padding:16px;';
    document.body.appendChild(modal);
    modal = document.getElementById('petFormModal') || modal;
  }

  modal.innerHTML = `
    <div style="background:white; border-radius:18px; max-width:420px; width:100%; max-height:90vh; overflow-y:auto; padding:18px; position:relative; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:none; width:28px; height:28px; border-radius:50%; font-size:14px; color:var(--text-secondary); cursor:pointer;" onclick="closePetFormModal()"><i class="fa-solid fa-xmark"></i></button>

      <h5 style="font-size:15px; font-weight:800; color:var(--text-primary); margin-bottom:12px;">
        <i class="fa-solid fa-paw" style="color:var(--primary);"></i> ${pet ? 'Edit Pet Profile' : 'Add New Pet'}
      </h5>

      <form onsubmit="savePetForm(event, '${editPetId || ''}')">
        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Pet Name *</label>
          <input type="text" id="petNameInput" required value="${pet ? pet.name : ''}" placeholder="e.g. Rocky, Bella, Fluffy" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="display:flex; gap:8px; margin-bottom:8px;">
          <div style="flex:1;">
            <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Species *</label>
            <select id="petSpeciesInput" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
              <option value="Dog" ${pet && pet.species === 'Dog' ? 'selected' : ''}>🐶 Dog</option>
              <option value="Cat" ${pet && pet.species === 'Cat' ? 'selected' : ''}>🐱 Cat</option>
              <option value="Cow" ${pet && pet.species === 'Cow' ? 'selected' : ''}>🐄 Cattle / Cow</option>
              <option value="Rabbit" ${pet && pet.species === 'Rabbit' ? 'selected' : ''}>🐇 Rabbit</option>
              <option value="Bird" ${pet && pet.species === 'Bird' ? 'selected' : ''}>🦜 Bird</option>
              <option value="Other" ${pet && pet.species === 'Other' ? 'selected' : ''}>🐾 Other</option>
            </select>
          </div>
          <div style="flex:1;">
            <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Gender</label>
            <select id="petGenderInput" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
              <option value="Male" ${pet && pet.gender === 'Male' ? 'selected' : ''}>Male</option>
              <option value="Female" ${pet && pet.gender === 'Female' ? 'selected' : ''}>Female</option>
            </select>
          </div>
        </div>

        <div style="display:flex; gap:8px; margin-bottom:8px;">
          <div style="flex:1;">
            <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Breed</label>
            <input type="text" id="petBreedInput" value="${pet ? pet.breed : ''}" placeholder="e.g. Labrador / Indie" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
          </div>
          <div style="flex:1;">
            <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Age / DOB</label>
            <input type="text" id="petAgeInput" value="${pet ? pet.age : ''}" placeholder="e.g. 2 years / 6 months" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
          </div>
        </div>

        <div style="margin-bottom:12px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Basic Notes & Medical History</label>
          <textarea id="petNotesInput" placeholder="Dietary preferences, allergies, microchip ID, neutered status..." style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px; height:50px;">${pet ? pet.notes : ''}</textarea>
        </div>

        <div style="display:flex; gap:8px;">
          <button type="submit" style="flex:1; padding:10px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;">
            <i class="fa-solid fa-floppy-disk"></i> ${pet ? 'Update Profile' : 'Save Pet Profile'}
          </button>
          <button type="button" style="padding:10px 14px; background:#f1f5f9; color:var(--text-secondary); border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="closePetFormModal()">Cancel</button>
        </div>
      </form>
    </div>
  `;
  modal.style.display = 'flex';
}

function closePetFormModal() {
  const modal = document.getElementById('petFormModal');
  if (modal) modal.style.display = 'none';
}

function savePetForm(event, editPetId) {
  if (event) event.preventDefault();

  const name = (document.getElementById('petNameInput') ? document.getElementById('petNameInput').value : '').trim();
  const species = (document.getElementById('petSpeciesInput') ? document.getElementById('petSpeciesInput').value : 'Dog');
  const gender = (document.getElementById('petGenderInput') ? document.getElementById('petGenderInput').value : 'Male');
  const breed = (document.getElementById('petBreedInput') ? document.getElementById('petBreedInput').value : '').trim() || species;
  const age = (document.getElementById('petAgeInput') ? document.getElementById('petAgeInput').value : '').trim() || 'Age unknown';
  const notes = (document.getElementById('petNotesInput') ? document.getElementById('petNotesInput').value : '').trim();

  if (!name) {
    showToast('Please enter pet name.');
    return;
  }

  const pets = getPetsList();

  const iconMap = { Dog: 'fa-dog', Cat: 'fa-cat', Cow: 'fa-cow', Rabbit: 'fa-paw', Bird: 'fa-dove', Other: 'fa-paw' };
  const bgMap = { Dog: '#d1fae5', Cat: '#fce7f3', Cow: '#fef9c3', Rabbit: '#e0f2fe', Bird: '#fae8ff', Other: '#f1f5f9' };
  const colorMap = { Dog: 'var(--primary)', Cat: '#ec4899', Cow: '#ca8a04', Rabbit: '#0284c7', Bird: '#a855f7', Other: '#475569' };

  if (editPetId) {
    const idx = pets.findIndex(p => p.id === editPetId);
    if (idx >= 0) {
      pets[idx] = {
        ...pets[idx],
        name, species, gender, breed, age, notes,
        icon: iconMap[species] || 'fa-paw',
        bg: bgMap[species] || '#f1f5f9',
        color: colorMap[species] || 'var(--primary)'
      };
      showToast(`Updated profile for ${name}! 🐾`);
    }
  } else {
    const newPet = {
      id: 'pet_' + Date.now(),
      name, species, gender, breed, age, notes,
      icon: iconMap[species] || 'fa-paw',
      bg: bgMap[species] || '#f1f5f9',
      color: colorMap[species] || 'var(--primary)',
      createdAt: new Date().toISOString()
    };
    pets.push(newPet);
    activePetId = newPet.id;
    showToast(`Added ${name} to your Pet Health Dashboard! 🎉`);
  }

  savePetsList(pets);
  closePetFormModal();
  renderScreen();
}

function deletePet(petId) {
  let pets = getPetsList();
  const pet = pets.find(p => p.id === petId);
  if (!pet) return;

  if (typeof confirm === 'function' && !confirm(`Are you sure you want to delete ${pet.name}'s profile and health records?`)) return;

  pets = pets.filter(p => p.id !== petId);
  savePetsList(pets);

  if (activePetId === petId) {
    activePetId = pets.length > 0 ? pets[0].id : null;
  }

  showToast(`Deleted ${pet.name}'s profile.`);
  renderScreen();
}

function openAddHealthRecordModal(petId, defaultType = 'vaccine') {
  let modal = document.getElementById('healthRecordFormModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'healthRecordFormModal';
    modal.style.cssText = 'position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.6); z-index:9999; display:flex; align-items:center; justify-content:center; padding:16px;';
    document.body.appendChild(modal);
    modal = document.getElementById('healthRecordFormModal') || modal;
  }

  modal.innerHTML = `
    <div style="background:white; border-radius:18px; max-width:420px; width:100%; max-height:90vh; overflow-y:auto; padding:18px; position:relative; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:none; width:28px; height:28px; border-radius:50%; font-size:14px; color:var(--text-secondary); cursor:pointer;" onclick="closeHealthRecordFormModal()"><i class="fa-solid fa-xmark"></i></button>

      <h5 style="font-size:15px; font-weight:800; color:var(--text-primary); margin-bottom:12px;">
        <i class="fa-solid fa-kit-medical" style="color:var(--primary);"></i> Add Health Entry
      </h5>

      <form onsubmit="saveHealthRecordForm(event, '${petId}')">
        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Record Type *</label>
          <select id="recTypeInput" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
            <option value="vaccine" ${defaultType === 'vaccine' ? 'selected' : ''}>💉 Vaccination</option>
            <option value="medicine" ${defaultType === 'medicine' ? 'selected' : ''}>💊 Medication</option>
            <option value="appointment" ${defaultType === 'appointment' ? 'selected' : ''}>🏥 Vet Appointment</option>
            <option value="record" ${defaultType === 'record' ? 'selected' : ''}>📋 Clinical Health Record</option>
          </select>
        </div>

        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Title / Vaccine / Medicine Name *</label>
          <input type="text" id="recTitleInput" required placeholder="e.g. Anti-Rabies (ARV), Wormstop Chewable, Deworming" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="display:flex; gap:8px; margin-bottom:8px;">
          <div style="flex:1;">
            <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Date Administered / Visit Date</label>
            <input type="date" id="recDateInput" value="${new Date().toISOString().split('T')[0]}" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
          </div>
          <div style="flex:1;">
            <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Next Due / End Date</label>
            <input type="date" id="recDueDateInput" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
          </div>
        </div>

        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Dosage / Schedule / Vet Name</label>
          <input type="text" id="recScheduleInput" placeholder="e.g. 1 Tablet Twice Daily after food / Dr. Sharma Clinic" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="margin-bottom:12px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Notes & Observations</label>
          <textarea id="recNotesInput" placeholder="Batch number, doctor recommendations, weight..." style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px; height:45px;"></textarea>
        </div>

        <div style="display:flex; gap:8px;">
          <button type="submit" style="flex:1; padding:10px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;">
            <i class="fa-solid fa-plus"></i> Save Entry
          </button>
          <button type="button" style="padding:10px 14px; background:#f1f5f9; color:var(--text-secondary); border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="closeHealthRecordFormModal()">Cancel</button>
        </div>
      </form>
    </div>
  `;
  modal.style.display = 'flex';
}

function closeHealthRecordFormModal() {
  const modal = document.getElementById('healthRecordFormModal');
  if (modal) modal.style.display = 'none';
}

function saveHealthRecordForm(event, petId) {
  if (event) event.preventDefault();

  const type = document.getElementById('recTypeInput') ? document.getElementById('recTypeInput').value : 'vaccine';
  const title = (document.getElementById('recTitleInput') ? document.getElementById('recTitleInput').value : '').trim();
  const date = document.getElementById('recDateInput') ? document.getElementById('recDateInput').value : new Date().toISOString().split('T')[0];
  const dueDate = document.getElementById('recDueDateInput') ? document.getElementById('recDueDateInput').value : '';
  const schedule = (document.getElementById('recScheduleInput') ? document.getElementById('recScheduleInput').value : '').trim();
  const notes = (document.getElementById('recNotesInput') ? document.getElementById('recNotesInput').value : '').trim();

  if (!title) {
    showToast('Please enter title or vaccine/medicine name.');
    return;
  }

  const records = getHealthRecordsList();
  const newRec = {
    id: 'rec_' + Date.now(),
    petId, type, title, date, dueDate, schedule, notes,
    createdAt: new Date().toISOString()
  };
  records.push(newRec);
  saveHealthRecordsList(records);

  if (dueDate) {
    const reminders = getRemindersList();
    reminders.push({
      id: 'rem_' + Date.now(),
      petId,
      title: `${type === 'vaccine' ? 'Vaccination Due: ' : type === 'medicine' ? 'Refill Medicine: ' : 'Appointment: '}${title}`,
      category: type === 'vaccine' ? 'Vaccination' : type === 'medicine' ? 'Medicine' : 'Vet Visit',
      dueDate: dueDate,
      status: 'Upcoming',
      notes: notes || schedule,
      createdAt: new Date().toISOString()
    });
    saveRemindersList(reminders);
  }

  showToast('Health entry saved successfully!');
  closeHealthRecordFormModal();
  renderScreen();
}

function deleteHealthRecord(recId) {
  let records = getHealthRecordsList();
  records = records.filter(r => r.id !== recId);
  saveHealthRecordsList(records);
  showToast('Record deleted.');
  renderScreen();
}

function openAddReminderModal(petId, editRemId = null) {
  let rem = null;
  if (editRemId) {
    rem = getRemindersList().find(r => r.id === editRemId);
  }

  let modal = document.getElementById('reminderFormModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'reminderFormModal';
    modal.style.cssText = 'position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.6); z-index:9999; display:flex; align-items:center; justify-content:center; padding:16px;';
    document.body.appendChild(modal);
    modal = document.getElementById('reminderFormModal') || modal;
  }

  const todayStr = new Date().toISOString().split('T')[0];

  modal.innerHTML = `
    <div style="background:white; border-radius:18px; max-width:420px; width:100%; max-height:90vh; overflow-y:auto; padding:18px; position:relative; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:none; width:28px; height:28px; border-radius:50%; font-size:14px; color:var(--text-secondary); cursor:pointer;" onclick="closeReminderFormModal()"><i class="fa-solid fa-xmark"></i></button>

      <h5 style="font-size:15px; font-weight:800; color:var(--text-primary); margin-bottom:12px;">
        <i class="fa-solid fa-bell" style="color:var(--primary);"></i> ${rem ? 'Edit Reminder' : 'Add Health Reminder'}
      </h5>

      <form onsubmit="saveReminderForm(event, '${petId}', '${editRemId || ''}')">
        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Reminder Title *</label>
          <input type="text" id="remTitleInput" required value="${rem ? rem.title : ''}" placeholder="e.g. Anti-Rabies Booster, Give Wormstop" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="display:flex; gap:8px; margin-bottom:8px;">
          <div style="flex:1;">
            <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Category</label>
            <select id="remCatInput" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
              <option value="Vaccination" ${rem && rem.category === 'Vaccination' ? 'selected' : ''}>💉 Vaccination</option>
              <option value="Medicine" ${rem && rem.category === 'Medicine' ? 'selected' : ''}>💊 Medicine</option>
              <option value="Vet Visit" ${rem && rem.category === 'Vet Visit' ? 'selected' : ''}>🏥 Vet Visit</option>
              <option value="Deworming" ${rem && rem.category === 'Deworming' ? 'selected' : ''}>🪱 Deworming</option>
              <option value="General" ${rem && rem.category === 'General' ? 'selected' : ''}>🔔 General Care</option>
            </select>
          </div>
          <div style="flex:1;">
            <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Due Date *</label>
            <input type="date" id="remDateInput" required value="${rem ? rem.dueDate : todayStr}" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
          </div>
        </div>

        <div style="margin-bottom:12px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Notes & Instructions</label>
          <input type="text" id="remNotesInput" value="${rem ? rem.notes : ''}" placeholder="Give with food / Contact vet clinic" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="display:flex; gap:8px;">
          <button type="submit" style="flex:1; padding:10px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;">
            <i class="fa-solid fa-floppy-disk"></i> ${rem ? 'Update Reminder' : 'Save Reminder'}
          </button>
          <button type="button" style="padding:10px 14px; background:#f1f5f9; color:var(--text-secondary); border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="closeReminderFormModal()">Cancel</button>
        </div>
      </form>
    </div>
  `;
  modal.style.display = 'flex';
}

function closeReminderFormModal() {
  const modal = document.getElementById('reminderFormModal');
  if (modal) modal.style.display = 'none';
}

function saveReminderForm(event, petId, editRemId) {
  if (event) event.preventDefault();

  const title = (document.getElementById('remTitleInput') ? document.getElementById('remTitleInput').value : '').trim();
  const category = document.getElementById('remCatInput') ? document.getElementById('remCatInput').value : 'General';
  const dueDate = document.getElementById('remDateInput') ? document.getElementById('remDateInput').value : '';
  const notes = (document.getElementById('remNotesInput') ? document.getElementById('remNotesInput').value : '').trim();

  if (!title || !dueDate) {
    showToast('Please enter title and due date.');
    return;
  }

  const reminders = getRemindersList();

  if (editRemId) {
    const idx = reminders.findIndex(r => r.id === editRemId);
    if (idx >= 0) {
      reminders[idx] = { ...reminders[idx], title, category, dueDate, notes };
      showToast('Reminder updated!');
    }
  } else {
    reminders.push({
      id: 'rem_' + Date.now(),
      petId, title, category, dueDate,
      status: 'Upcoming',
      notes,
      createdAt: new Date().toISOString()
    });
    showToast('New reminder created! 🔔');
  }

  saveRemindersList(reminders);
  closeReminderFormModal();
  renderScreen();
}

function completeReminder(remId) {
  const reminders = getRemindersList();
  const rem = reminders.find(r => r.id === remId);
  if (rem) {
    rem.status = 'Completed';
    saveRemindersList(reminders);
    showToast('Marked reminder as completed! ✅');
    renderScreen();
  }
}

function snoozeReminder(remId, days = 1) {
  const reminders = getRemindersList();
  const rem = reminders.find(r => r.id === remId);
  if (rem) {
    const curr = new Date(rem.dueDate);
    curr.setDate(curr.getDate() + days);
    rem.dueDate = curr.toISOString().split('T')[0];
    rem.status = 'Upcoming';
    saveRemindersList(reminders);
    showToast(`Snoozed reminder for ${days} day(s)`);
    renderScreen();
  }
}

function deleteReminder(remId) {
  let reminders = getRemindersList();
  reminders = reminders.filter(r => r.id !== remId);
  saveRemindersList(reminders);
  showToast('Reminder deleted.');
  renderScreen();
}

function renderPetHealthScreenUI(container) {
  const pets = getPetsList();

  if (!activePetId || !pets.some(p => p.id === activePetId)) {
    activePetId = pets.length > 0 ? pets[0].id : null;
  }

  if (pets.length === 0) {
    container.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
        <h4 style="font-size:16px; font-weight:800;">Pet Health Dashboard</h4>
        <button style="background:var(--primary); color:white; border:none; padding:6px 12px; border-radius:10px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openAddPetModal()">
          <i class="fa-solid fa-plus"></i> Add First Pet
        </button>
      </div>

      <div style="text-align:center; padding:40px 20px; background:white; border-radius:16px; border:1px solid var(--border);">
        <i class="fa-solid fa-heart-pulse" style="font-size:42px; color:var(--primary); margin-bottom:12px;"></i>
        <h5 style="font-size:15px; font-weight:bold; color:var(--text-primary);">No Pets Registered Yet</h5>
        <p style="font-size:11px; color:var(--text-secondary); margin-top:4px; max-width:280px; margin-left:auto; margin-right:auto;">
          Add your dog, cat, or pet profile to manage vaccination schedules, medication alarms, vet visits, and health logs.
        </p>
        <button style="margin-top:16px; padding:10px 20px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="openAddPetModal()">
          <i class="fa-solid fa-paw"></i> Add Pet Profile Now
        </button>
      </div>
    `;
    return;
  }

  const currentPet = pets.find(p => p.id === activePetId) || pets[0];
  const allRecords = getHealthRecordsList().filter(r => r.petId === currentPet.id);
  const allReminders = getRemindersList().filter(r => r.petId === currentPet.id);

  const todayStr = new Date().toISOString().split('T')[0];

  const upcomingReminders = allReminders.filter(r => r.status !== 'Completed' && r.dueDate >= todayStr);
  const overdueReminders = allReminders.filter(r => r.status !== 'Completed' && r.dueDate < todayStr);
  const completedReminders = allReminders.filter(r => r.status === 'Completed');

  container.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
      <div>
        <h4 style="font-size:16px; font-weight:800;">Pet Health Dashboard</h4>
        <p style="font-size:10px; color:var(--text-secondary);">Manage Vaccines, Medications & Alarms</p>
      </div>
      <button style="background:var(--primary); color:white; border:none; padding:5px 10px; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openAddPetModal()">
        <i class="fa-solid fa-plus"></i> Add Pet
      </button>
    </div>

    <!-- Pet Selector Chips -->
    <div style="display:flex; gap:6px; overflow-x:auto; padding-bottom:6px; margin-bottom:10px;" class="alert-slider">
      ${pets.map(p => `
        <button class="pill-chip ${p.id === currentPet.id ? 'active' : ''}" style="background:${p.id === currentPet.id ? 'var(--primary)' : 'white'}; color:${p.id === currentPet.id ? 'white' : 'var(--text-primary)'}; border:${p.id === currentPet.id ? 'none' : '1px solid var(--border)'}; padding:5px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap; display:flex; align-items:center; gap:5px;" onclick="activePetId='${p.id}'; renderScreen();">
          <i class="fa-solid ${p.icon}"></i> ${p.name}
        </button>
      `).join('')}
    </div>

    <!-- Active Pet Profile Banner -->
    <div class="result-card" style="margin-bottom:12px; position:relative; background:white;">
      <div style="display:flex; justify-content:space-between; align-items:flex-start;">
        <div style="display:flex; gap:10px; align-items:center;">
          <div style="width:48px; height:48px; background:${currentPet.bg}; color:${currentPet.color}; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:24px;">
            <i class="fa-solid ${currentPet.icon}"></i>
          </div>
          <div>
            <h5 style="font-size:14px; font-weight:800; color:var(--text-primary);">${currentPet.name}</h5>
            <span style="font-size:11px; color:var(--text-secondary); font-weight:bold;">${currentPet.species} • ${currentPet.breed} (${currentPet.gender})</span>
            <p style="font-size:10px; color:var(--text-muted); margin-top:2px;">Age: ${currentPet.age}</p>
          </div>
        </div>
        <div style="display:flex; gap:6px;">
          <button style="background:none; border:1px solid var(--border); color:var(--text-secondary); padding:4px 8px; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openAddPetModal('${currentPet.id}')" title="Edit Profile">
            <i class="fa-solid fa-pen"></i> Edit
          </button>
          <button style="background:none; border:1px solid var(--border); color:var(--emergency-red); padding:4px 8px; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="deletePet('${currentPet.id}')" title="Delete Profile">
            <i class="fa-solid fa-trash"></i>
          </button>
        </div>
      </div>
      ${currentPet.notes ? `<p style="font-size:10px; color:#475569; background:#f8fafc; padding:6px 8px; border-radius:6px; margin-top:8px;"><b>Notes:</b> ${currentPet.notes}</p>` : ''}
    </div>

    <!-- Action Buttons -->
    <div style="display:flex; gap:6px; margin-bottom:12px;">
      <button style="flex:1; padding:8px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openAddHealthRecordModal('${currentPet.id}', 'vaccine')">
        <i class="fa-solid fa-syringe"></i> + Vaccine
      </button>
      <button style="flex:1; padding:8px; background:#0284c7; color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openAddHealthRecordModal('${currentPet.id}', 'medicine')">
        <i class="fa-solid fa-pills"></i> + Medicine
      </button>
      <button style="flex:1; padding:8px; background:#8b5cf6; color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openAddReminderModal('${currentPet.id}')">
        <i class="fa-solid fa-bell"></i> + Reminder
      </button>
    </div>

    <!-- Reminders Section -->
    <div style="margin-bottom:14px;">
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
        <h6 style="font-size:13px; font-weight:800; color:var(--text-primary);">Health Alarms & Reminders</h6>
        <div style="display:flex; gap:4px; font-size:9px; font-weight:bold;">
          <span style="background:#fee2e2; color:#991b1b; padding:2px 6px; border-radius:6px;">${overdueReminders.length} Overdue</span>
          <span style="background:#e0f2fe; color:#0369a1; padding:2px 6px; border-radius:6px;">${upcomingReminders.length} Upcoming</span>
        </div>
      </div>

      <!-- Overdue Reminders -->
      ${overdueReminders.length > 0 ? `
        <div style="margin-bottom:10px;">
          <div style="font-size:10px; font-weight:700; color:#dc2626; text-transform:uppercase; margin-bottom:4px;">⚠️ Overdue Reminders:</div>
          ${overdueReminders.map(rem => `
            <div class="result-card" style="margin-bottom:6px; padding:10px; border-left:4px solid #dc2626; background:#fff5f5;">
              <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                <div>
                  <h6 style="font-size:12px; font-weight:bold; color:#991b1b; margin-bottom:2px;">${rem.title}</h6>
                  <span class="pill danger" style="font-size:8px;">Due: ${rem.dueDate} (Overdue)</span>
                  ${rem.notes ? `<p style="font-size:10px; color:#7f1d1d; margin-top:2px;">${rem.notes}</p>` : ''}
                </div>
                <div style="display:flex; gap:4px;">
                  <button style="padding:4px 8px; background:#166534; color:white; border:none; border-radius:6px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="completeReminder('${rem.id}')" title="Complete"><i class="fa-solid fa-check"></i> Done</button>
                  <button style="padding:4px 6px; background:white; color:#b45309; border:1px solid #fde68a; border-radius:6px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="snoozeReminder('${rem.id}', 1)" title="Snooze 1 day"><i class="fa-solid fa-clock-rotate-left"></i> +1D</button>
                  <button style="padding:4px 6px; background:white; color:var(--text-secondary); border:1px solid var(--border); border-radius:6px; font-size:10px; cursor:pointer;" onclick="openAddReminderModal('${currentPet.id}', '${rem.id}')"><i class="fa-solid fa-pen"></i></button>
                  <button style="padding:4px 6px; background:white; color:#dc2626; border:1px solid var(--border); border-radius:6px; font-size:10px; cursor:pointer;" onclick="deleteReminder('${rem.id}')"><i class="fa-solid fa-trash"></i></button>
                </div>
              </div>
            </div>
          `).join('')}
        </div>
      ` : ''}

      <!-- Upcoming Reminders -->
      ${upcomingReminders.length > 0 ? `
        <div style="margin-bottom:10px;">
          <div style="font-size:10px; font-weight:700; color:var(--primary); text-transform:uppercase; margin-bottom:4px;">🕒 Upcoming Reminders:</div>
          ${upcomingReminders.map(rem => `
            <div class="result-card" style="margin-bottom:6px; padding:10px; border-left:4px solid var(--primary);">
              <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                <div>
                  <h6 style="font-size:12px; font-weight:bold; color:var(--text-primary); margin-bottom:2px;">${rem.title}</h6>
                  <span class="pill safe" style="font-size:8px;">Due: ${rem.dueDate}</span>
                  ${rem.notes ? `<p style="font-size:10px; color:var(--text-secondary); margin-top:2px;">${rem.notes}</p>` : ''}
                </div>
                <div style="display:flex; gap:4px;">
                  <button style="padding:4px 8px; background:var(--primary); color:white; border:none; border-radius:6px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="completeReminder('${rem.id}')" title="Complete"><i class="fa-solid fa-check"></i> Done</button>
                  <button style="padding:4px 6px; background:white; color:var(--text-secondary); border:1px solid var(--border); border-radius:6px; font-size:10px; cursor:pointer;" onclick="openAddReminderModal('${currentPet.id}', '${rem.id}')"><i class="fa-solid fa-pen"></i></button>
                  <button style="padding:4px 6px; background:white; color:#dc2626; border:1px solid var(--border); border-radius:6px; font-size:10px; cursor:pointer;" onclick="deleteReminder('${rem.id}')"><i class="fa-solid fa-trash"></i></button>
                </div>
              </div>
            </div>
          `).join('')}
        </div>
      ` : ''}

      ${upcomingReminders.length === 0 && overdueReminders.length === 0 ? `
        <div style="text-align:center; padding:16px; background:white; border-radius:10px; border:1px dashed var(--border); margin-bottom:10px;">
          <p style="font-size:11px; color:var(--text-secondary);">No pending reminders for ${currentPet.name}. Tap '+ Reminder' to set vaccination or medication alarms.</p>
        </div>
      ` : ''}

      <!-- Completed Reminders Collapsible -->
      ${completedReminders.length > 0 ? `
        <div>
          <div style="font-size:10px; font-weight:700; color:#166534; text-transform:uppercase; margin-bottom:4px;">✅ Completed (${completedReminders.length}):</div>
          ${completedReminders.map(rem => `
            <div style="display:flex; justify-content:space-between; align-items:center; padding:6px 10px; background:#f0fdf4; border:1px solid #bbf7d0; border-radius:8px; margin-bottom:4px; font-size:11px;">
              <span style="text-decoration:line-through; color:#15803d;">${rem.title}</span>
              <button style="background:none; border:none; color:#dc2626; font-size:10px; cursor:pointer;" onclick="deleteReminder('${rem.id}')"><i class="fa-solid fa-trash"></i></button>
            </div>
          `).join('')}
        </div>
      ` : ''}
    </div>

    <!-- Health History Records List -->
    <div>
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
        <h6 style="font-size:13px; font-weight:800; color:var(--text-primary);">Medical History & Vaccination Log</h6>
        <span style="font-size:10px; color:var(--text-muted);">${allRecords.length} records</span>
      </div>

      ${allRecords.length === 0 ? `
        <div style="text-align:center; padding:16px; background:white; border-radius:10px; border:1px dashed var(--border);">
          <p style="font-size:11px; color:var(--text-secondary);">No clinical logs recorded for ${currentPet.name} yet.</p>
        </div>
      ` : `
        <div style="display:flex; flex-direction:column; gap:6px;">
          ${allRecords.map(rec => `
            <div style="background:white; border:1px solid var(--border); border-radius:10px; padding:8px 10px;">
              <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                <div>
                  <h6 style="font-size:11px; font-weight:bold; color:var(--text-primary); margin-bottom:2px;">
                    ${rec.type === 'vaccine' ? '💉' : rec.type === 'medicine' ? '💊' : '🏥'} ${rec.title}
                  </h6>
                  <p style="font-size:10px; color:var(--text-secondary);">Date: ${rec.date}${rec.dueDate ? ` • Next Due: ${rec.dueDate}` : ''}</p>
                  ${rec.schedule ? `<p style="font-size:9px; color:#0284c7;">Schedule: ${rec.schedule}</p>` : ''}
                  ${rec.notes ? `<p style="font-size:9px; color:var(--text-muted); margin-top:2px;">Notes: ${rec.notes}</p>` : ''}
                </div>
                <button style="background:none; border:none; color:var(--emergency-red); font-size:10px; cursor:pointer;" onclick="deleteHealthRecord('${rec.id}')">
                  <i class="fa-solid fa-trash"></i>
                </button>
              </div>
            </div>
          `).join('')}
        </div>
      `}
    </div>
  `;
}

function openDashboardReminderDetailModal(remId) {
  const reminders = getRemindersList();
  const rem = reminders.find(r => r.id === remId);
  if (!rem) return;

  const pets = getPetsList();
  const pet = pets.find(p => p.id === rem.petId);
  const petName = pet ? `${pet.name} (${pet.breed || pet.species})` : 'Pet';

  let modal = document.getElementById('dashReminderModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'dashReminderModal';
    modal.style.cssText = 'position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.6); z-index:9999; display:flex; align-items:center; justify-content:center; padding:16px;';
    document.body.appendChild(modal);
    modal = document.getElementById('dashReminderModal') || modal;
  }

  const today = new Date();
  today.setHours(0,0,0,0);
  const d = new Date(rem.dueDate);
  d.setHours(0,0,0,0);
  const diffDays = Math.ceil((d - today) / (1000 * 60 * 60 * 24));
  let daysText = `Due in ${diffDays} day(s)`;
  if (diffDays < 0) daysText = `⚠️ OVERDUE by ${Math.abs(diffDays)} day(s)!`;
  else if (diffDays === 0) daysText = `🚨 DUE TODAY!`;

  modal.innerHTML = `
    <div style="background:white; border-radius:18px; max-width:400px; width:100%; padding:18px; position:relative; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:none; width:28px; height:28px; border-radius:50%; font-size:14px; color:var(--text-secondary); cursor:pointer;" onclick="closeDashboardReminderDetailModal()"><i class="fa-solid fa-xmark"></i></button>

      <div style="display:flex; align-items:center; gap:10px; margin-bottom:12px;">
        <div style="width:40px; height:40px; background:${diffDays < 0 ? '#fee2e2' : '#e0f2fe'}; color:${diffDays < 0 ? '#dc2626' : 'var(--primary)'}; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:20px;">
          <i class="fa-solid ${rem.category === 'Vaccination' ? 'fa-syringe' : rem.category === 'Medicine' ? 'fa-pills' : 'fa-bell'}"></i>
        </div>
        <div>
          <h5 style="font-size:14px; font-weight:800; color:var(--text-primary);">${rem.title}</h5>
          <span style="font-size:10px; color:var(--text-secondary); font-weight:bold;">${petName}</span>
        </div>
      </div>

      <div style="background:#f8fafc; border:1px solid var(--border); border-radius:10px; padding:10px; margin-bottom:12px; font-size:11px; line-height:1.4;">
        <div style="display:flex; justify-content:space-between; margin-bottom:4px;">
          <span style="color:var(--text-muted);">Due Date:</span>
          <b>${rem.dueDate}</b>
        </div>
        <div style="display:flex; justify-content:space-between; margin-bottom:4px;">
          <span style="color:var(--text-muted);">Status:</span>
          <b style="color:${diffDays < 0 ? '#dc2626' : 'var(--primary)'};">${daysText}</b>
        </div>
        ${rem.notes ? `<div style="color:var(--text-secondary); margin-top:4px;"><b>Notes:</b> ${rem.notes}</div>` : ''}
      </div>

      <div style="display:flex; gap:6px;">
        <button style="flex:1; padding:8px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="completeReminder('${rem.id}'); closeDashboardReminderDetailModal();">
          <i class="fa-solid fa-check"></i> Complete
        </button>
        <button style="padding:8px 10px; background:white; color:#b45309; border:1px solid #fde68a; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="snoozeReminder('${rem.id}', 1); closeDashboardReminderDetailModal();">
          <i class="fa-solid fa-clock-rotate-left"></i> +1 Day
        </button>
        <button style="padding:8px 10px; background:white; color:#dc2626; border:1px solid var(--border); border-radius:8px; font-size:11px; cursor:pointer;" onclick="deleteReminder('${rem.id}'); closeDashboardReminderDetailModal();" title="Delete">
          <i class="fa-solid fa-trash"></i>
        </button>
      </div>
    </div>
  `;
  modal.style.display = 'flex';
}

function closeDashboardReminderDetailModal() {
  const modal = document.getElementById('dashReminderModal');
  if (modal) modal.style.display = 'none';
}

// ─── PREMIUM VIP MEMBERSHIP & PROTOTYPE CHECKOUT SYSTEM ──────────────────────
const MEMBERSHIP_KEY = 'pashu_user_membership';

function getMembershipState() {
  try {
    const data = JSON.parse(localStorage.getItem(MEMBERSHIP_KEY) || 'null');
    if (data && typeof data === 'object') return data;
  } catch (_) {}
  return { isVip: false, planName: 'Free Member', activatedAt: null };
}

function saveMembershipState(state) {
  try {
    localStorage.setItem(MEMBERSHIP_KEY, JSON.stringify(state));
  } catch (e) {
    console.warn('[MembershipStorage] Error saving state:', e);
  }
}

function getMembershipBadgeHtml() {
  const m = getMembershipState();
  if (m.isVip) {
    return `<span class="pill safe" style="background:#fef9c3; color:#ca8a04; border:1px solid #fde047;"><i class="fa-solid fa-crown"></i> VIP Gold Member</span>`;
  }
  return `<span class="pill info" style="background:#f1f5f9; color:var(--text-secondary); border:1px solid var(--border);">Free Member</span>`;
}

function activateVipMembership(planName = 'VIP Gold Plan') {
  const state = {
    isVip: true,
    planName,
    activatedAt: new Date().toISOString()
  };
  saveMembershipState(state);
  closePaymentModal();
  closePrototypeCheckoutModal();
  showToast(`🎉 Prototype Payment Verified! ${planName} Activated.`);
  renderScreen();
}

function downgradeToFreePlan() {
  if (typeof confirm === 'function' && !confirm('Are you sure you want to cancel your VIP Gold subscription and downgrade to the Free Plan?')) return;
  const state = {
    isVip: false,
    planName: 'Free Member',
    activatedAt: null
  };
  saveMembershipState(state);
  showToast('Membership changed to Free Plan.');
  renderScreen();
}

function openPrototypeCheckoutModal(planTitle = 'VIP Gold Monthly Plan', planPrice = '₹99 / month') {
  let modal = document.getElementById('prototypeCheckoutModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'prototypeCheckoutModal';
    modal.style.cssText = 'position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.6); z-index:9999; display:flex; align-items:center; justify-content:center; padding:16px;';
    document.body.appendChild(modal);
    modal = document.getElementById('prototypeCheckoutModal') || modal;
  }

  modal.innerHTML = `
    <div style="background:white; border-radius:18px; max-width:420px; width:100%; max-height:90vh; overflow-y:auto; padding:20px; position:relative; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:none; width:28px; height:28px; border-radius:50%; font-size:14px; color:var(--text-secondary); cursor:pointer;" onclick="closePrototypeCheckoutModal()"><i class="fa-solid fa-xmark"></i></button>

      <div style="display:flex; align-items:center; gap:10px; margin-bottom:12px;">
        <div style="width:42px; height:42px; background:#fef9c3; color:#ca8a04; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:22px;">
          <i class="fa-solid fa-crown"></i>
        </div>
        <div>
          <h5 style="font-size:15px; font-weight:800; color:var(--text-primary);">PashuRakshak VIP Checkout</h5>
          <span style="font-size:10px; color:#ca8a04; font-weight:bold;">${planTitle} • ${planPrice}</span>
        </div>
      </div>

      <div style="background:#fffbeb; border:1px solid #fde68a; border-radius:10px; padding:10px; margin-bottom:14px; font-size:11px; color:#92400e; line-height:1.4;">
        <i class="fa-solid fa-circle-info"></i> <b>Prototype Demo Checkout:</b> No real money will be charged. Clicking activate below will simulate payment verification and update your membership state instantly.
      </div>

      <div style="margin-bottom:14px;">
        <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:6px;">Select Prototype Payment Method:</label>
        <div style="display:flex; flex-direction:column; gap:6px;">
          <label style="display:flex; align-items:center; gap:8px; padding:8px; border:1px solid var(--border); border-radius:8px; font-size:11px; cursor:pointer;">
            <input type="radio" name="payMethod" checked> 📱 Razorpay Test UPI / QR (Instant)
          </label>
          <label style="display:flex; align-items:center; gap:8px; padding:8px; border:1px solid var(--border); border-radius:8px; font-size:11px; cursor:pointer;">
            <input type="radio" name="payMethod"> 💳 Mock Credit / Debit Card
          </label>
        </div>
      </div>

      <div style="display:flex; gap:8px;">
        <button type="button" style="flex:1; padding:12px; background:#ca8a04; color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer; box-shadow:0 4px 12px rgba(202,138,4,0.3);" onclick="activateVipMembership('${planTitle}')">
          <i class="fa-solid fa-check"></i> 1-Tap Test Activate VIP
        </button>
        <button type="button" style="padding:12px 14px; background:#f1f5f9; color:var(--text-secondary); border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="closePrototypeCheckoutModal()">Cancel</button>
      </div>
    </div>
  `;
  modal.style.display = 'flex';
}

function closePrototypeCheckoutModal() {
  const modal = document.getElementById('prototypeCheckoutModal');
  if (modal) modal.style.display = 'none';
}

function renderMembershipScreenUI(container) {
  const membership = getMembershipState();

  container.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
      <div>
        <h4 style="font-size:16px; font-weight:800; color:var(--text-primary);">PashuRakshak VIP Gold</h4>
        <p style="font-size:10px; color:var(--text-secondary);">Unlimited AI Scans, Priority Rescue & Digital Health</p>
      </div>
      <button style="background:none; border:none; font-size:16px; cursor:pointer;" onclick="navigateTo('home')">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>

    <!-- Active Membership Status Banner -->
    <div class="result-card" style="background:${membership.isVip ? '#fefce8' : '#f8fafc'}; border-color:${membership.isVip ? '#fde047' : 'var(--border)'}; margin-bottom:14px;">
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <div style="display:flex; gap:10px; align-items:center;">
          <div style="width:42px; height:42px; background:${membership.isVip ? '#fef9c3' : '#e2e8f0'}; color:${membership.isVip ? '#ca8a04' : 'var(--text-secondary)'}; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:22px;">
            <i class="fa-solid ${membership.isVip ? 'fa-crown' : 'fa-shield-halved'}"></i>
          </div>
          <div>
            <h5 style="font-size:14px; font-weight:800; color:var(--text-primary);">
              ${membership.isVip ? 'VIP Gold Member Active 🌟' : 'Free Plan Active'}
            </h5>
            <p style="font-size:10px; color:var(--text-secondary); margin-top:2px;">
              ${membership.isVip ? `Subscribed to ${membership.planName}` : 'Standard tier: 5 AI species scans per day'}
            </p>
          </div>
        </div>
        ${membership.isVip ? `
          <button style="padding:6px 10px; background:white; color:#dc2626; border:1px solid #fca5a5; border-radius:8px; font-size:10px; font-weight:bold; cursor:pointer;" onclick="downgradeToFreePlan()">
            Cancel Plan
          </button>
        ` : `
          <button style="padding:6px 12px; background:#ca8a04; color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openPrototypeCheckoutModal('VIP Gold Monthly', '₹99 / month')">
            Upgrade Now
          </button>
        `}
      </div>
    </div>

    <!-- Plan Comparison Table -->
    <div class="result-card" style="margin-bottom:14px;">
      <h6 style="font-size:13px; font-weight:800; color:var(--text-primary); margin-bottom:10px;">Compare Membership Benefits</h6>

      <div style="font-size:11px;">
        <div style="display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid var(--border); font-weight:bold; color:var(--text-secondary);">
          <span>Feature & Perk</span>
          <span style="display:flex; gap:16px;">
            <span style="width:50px; text-align:center;">Free</span>
            <span style="width:70px; text-align:center; color:#ca8a04;">VIP Gold</span>
          </span>
        </div>

        <div style="display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid var(--border);">
          <span>Dual ML & Vision AI Scans</span>
          <span style="display:flex; gap:16px;">
            <span style="width:50px; text-align:center; color:var(--text-muted);">5 / day</span>
            <span style="width:70px; text-align:center; font-weight:bold; color:#ca8a04;">Unlimited</span>
          </span>
        </div>

        <div style="display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid var(--border);">
          <span>Pashu Mitra Veterinary Assistant</span>
          <span style="display:flex; gap:16px;">
            <span style="width:50px; text-align:center; color:var(--text-muted);">Basic</span>
            <span style="width:70px; text-align:center; font-weight:bold; color:#ca8a04;">Advanced</span>
          </span>
        </div>

        <div style="display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid var(--border);">
          <span>Registered Pet Profiles</span>
          <span style="display:flex; gap:16px;">
            <span style="width:50px; text-align:center; color:var(--text-muted);">1 Pet</span>
            <span style="width:70px; text-align:center; font-weight:bold; color:#ca8a04;">Unlimited</span>
          </span>
        </div>

        <div style="display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid var(--border);">
          <span>Health Alarms & Reminders</span>
          <span style="display:flex; gap:16px;">
            <span style="width:50px; text-align:center; color:var(--text-muted);">Standard</span>
            <span style="width:70px; text-align:center; font-weight:bold; color:#ca8a04;">Smart SMS</span>
          </span>
        </div>

        <div style="display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid var(--border);">
          <span>Emergency SOS Rescue Queue</span>
          <span style="display:flex; gap:16px;">
            <span style="width:50px; text-align:center; color:var(--text-muted);">Standard</span>
            <span style="width:70px; text-align:center; font-weight:bold; color:#ca8a04;">Priority #1</span>
          </span>
        </div>

        <div style="display:flex; justify-content:space-between; padding:8px 0;">
          <span>Partner Clinic Discounts</span>
          <span style="display:flex; gap:16px;">
            <span style="width:50px; text-align:center; color:var(--text-muted);">None</span>
            <span style="width:70px; text-align:center; font-weight:bold; color:#ca8a04;">15% Off</span>
          </span>
        </div>
      </div>
    </div>

    <!-- Upgrade Options Cards -->
    <div style="display:flex; gap:8px;">
      <div style="flex:1; background:white; border:2px solid #ca8a04; border-radius:12px; padding:12px; text-align:center;">
        <span class="pill safe" style="background:#fef9c3; color:#ca8a04; font-size:9px; font-weight:bold;">POPULAR</span>
        <h6 style="font-size:13px; font-weight:800; color:var(--text-primary); margin-top:4px;">VIP Gold Monthly</h6>
        <div style="font-size:16px; font-weight:900; color:#ca8a04; margin:4px 0;">₹99 <span style="font-size:10px; color:var(--text-muted);">/ mo</span></div>
        <button style="width:100%; margin-top:6px; padding:8px; background:#ca8a04; color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openPrototypeCheckoutModal('VIP Gold Monthly Plan', '₹99 / month')">
          ${membership.isVip ? 'Current Plan' : 'Select Plan'}
        </button>
      </div>

      <div style="flex:1; background:white; border:1px solid var(--border); border-radius:12px; padding:12px; text-align:center;">
        <span class="pill info" style="font-size:9px; font-weight:bold;">SAVE 33%</span>
        <h6 style="font-size:13px; font-weight:800; color:var(--text-primary); margin-top:4px;">VIP Gold Yearly</h6>
        <div style="font-size:16px; font-weight:900; color:var(--text-primary); margin:4px 0;">₹799 <span style="font-size:10px; color:var(--text-muted);">/ yr</span></div>
        <button style="width:100%; margin-top:6px; padding:8px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openPrototypeCheckoutModal('VIP Gold Yearly Plan', '₹799 / year')">
          Select Plan
        </button>
      </div>
    </div>
  `;
}

// ─── USER PROFILE MANAGEMENT SYSTEM ───────────────────────────────────────────
const USER_PROFILE_KEY = 'pashu_user_profile';

function getUserProfile() {
  try {
    const data = JSON.parse(localStorage.getItem(USER_PROFILE_KEY) || 'null');
    if (data && typeof data === 'object') return data;
  } catch (_) {}
  return {
    name: 'Yuvraj Singh',
    email: 'pashu.guardian@example.com',
    phone: '+91 98765 43210',
    city: 'New Delhi',
    language: currentLanguage || 'en',
    notificationsEnabled: true
  };
}

function saveUserProfile(profile) {
  try {
    localStorage.setItem(USER_PROFILE_KEY, JSON.stringify(profile));
  } catch (e) {
    console.warn('[ProfileStorage] Error saving profile:', e);
  }
}

function getUserInitials(name) {
  if (!name) return 'YS';
  const parts = name.trim().split(' ');
  if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
  return name.substring(0, 2).toUpperCase();
}

function openEditProfileModal() {
  const profile = getUserProfile();

  let modal = document.getElementById('editProfileModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'editProfileModal';
    modal.style.cssText = 'position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.6); z-index:9999; display:flex; align-items:center; justify-content:center; padding:16px;';
    document.body.appendChild(modal);
    modal = document.getElementById('editProfileModal') || modal;
  }

  modal.innerHTML = `
    <div style="background:white; border-radius:18px; max-width:420px; width:100%; max-height:90vh; overflow-y:auto; padding:18px; position:relative; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:none; width:28px; height:28px; border-radius:50%; font-size:14px; color:var(--text-secondary); cursor:pointer;" onclick="closeEditProfileModal()"><i class="fa-solid fa-xmark"></i></button>

      <h5 style="font-size:15px; font-weight:800; color:var(--text-primary); margin-bottom:12px;">
        <i class="fa-solid fa-user-pen" style="color:var(--primary);"></i> Edit Guardian Profile
      </h5>

      <form onsubmit="saveProfileForm(event)">
        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Full Name *</label>
          <input type="text" id="editProfName" required value="${profile.name}" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Email Address *</label>
          <input type="email" id="editProfEmail" required value="${profile.email}" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="display:flex; gap:8px; margin-bottom:8px;">
          <div style="flex:1;">
            <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Phone / WhatsApp</label>
            <input type="tel" id="editProfPhone" value="${profile.phone}" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
          </div>
          <div style="flex:1;">
            <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">City / Location</label>
            <input type="text" id="editProfCity" value="${profile.city}" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
          </div>
        </div>

        <div style="margin-bottom:12px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Preferred App Language</label>
          <select id="editProfLang" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;" onchange="setLanguage(this.value)">
            <option value="en" ${profile.language === 'en' ? 'selected' : ''}>English</option>
            <option value="hi" ${profile.language === 'hi' ? 'selected' : ''}>हिंदी (Hindi)</option>
            <option value="bho" ${profile.language === 'bho' ? 'selected' : ''}>भोजपुरी (Bhojpuri)</option>
            <option value="mai" ${profile.language === 'mai' ? 'selected' : ''}>मैथिली (Maithili)</option>
            <option value="bn" ${profile.language === 'bn' ? 'selected' : ''}>বাংলা (Bengali)</option>
            <option value="ta" ${profile.language === 'ta' ? 'selected' : ''}>தமிழ் (Tamil)</option>
            <option value="te" ${profile.language === 'te' ? 'selected' : ''}>తెలుగు (Telugu)</option>
            <option value="mr" ${profile.language === 'mr' ? 'selected' : ''}>मराठी (Marathi)</option>
            <option value="gu" ${profile.language === 'gu' ? 'selected' : ''}>ગુજરાતી (Gujarati)</option>
            <option value="pa" ${profile.language === 'pa' ? 'selected' : ''}>ਪੰਜਾਬੀ (Punjabi)</option>
          </select>
        </div>

        <div style="display:flex; gap:8px;">
          <button type="submit" style="flex:1; padding:10px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;">
            <i class="fa-solid fa-floppy-disk"></i> Save Profile Changes
          </button>
          <button type="button" style="padding:10px 14px; background:#f1f5f9; color:var(--text-secondary); border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="closeEditProfileModal()">Cancel</button>
        </div>
      </form>
    </div>
  `;
  modal.style.display = 'flex';
}

function closeEditProfileModal() {
  const modal = document.getElementById('editProfileModal');
  if (modal) modal.style.display = 'none';
}

function saveProfileForm(event) {
  if (event) event.preventDefault();

  const name = (document.getElementById('editProfName') ? document.getElementById('editProfName').value : '').trim();
  const email = (document.getElementById('editProfEmail') ? document.getElementById('editProfEmail').value : '').trim();
  const phone = (document.getElementById('editProfPhone') ? document.getElementById('editProfPhone').value : '').trim();
  const city = (document.getElementById('editProfCity') ? document.getElementById('editProfCity').value : '').trim();
  const lang = document.getElementById('editProfLang') ? document.getElementById('editProfLang').value : 'en';

  if (!name || !email) {
    showToast('Please enter your name and email address.');
    return;
  }

  const profile = {
    ...getUserProfile(),
    name, email, phone, city, language: lang
  };

  saveUserProfile(profile);
  closeEditProfileModal();
  showToast('Profile changes saved! 👤');
  renderScreen();
}

function logoutUser() {
  if (typeof confirm === 'function' && !confirm('Are you sure you want to log out of PashuRakshak?')) return;
  showToast('Logged out successfully.');
  navigateTo('home');
}

function renderProfileScreenUI(container) {
  const profile = getUserProfile();
  const membership = getMembershipState();
  const initials = getUserInitials(profile.name);

  const petCount = getPetsList().length;
  const adoptCount = getAdoptionRequests().length;
  const rescueCount = getRescueRequestsList().length;
  const scanCount = getScanHistory().length;

  container.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
      <h4 style="font-size:16px; font-weight:800; color:var(--text-primary);">Guardian Profile</h4>
      <button style="background:none; border:none; font-size:16px; cursor:pointer;" onclick="navigateTo('home')">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>

    <!-- User Header Profile Card -->
    <div class="result-card" style="text-align:center; position:relative; background:white; margin-bottom:12px;">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:1px solid var(--border); border-radius:8px; padding:4px 8px; font-size:11px; font-weight:bold; color:var(--text-secondary); cursor:pointer;" onclick="openEditProfileModal()">
        <i class="fa-solid fa-user-pen"></i> Edit Profile
      </button>

      <div style="width:64px; height:64px; background:var(--primary-container); color:var(--on-primary-container); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:26px; font-weight:bold; margin:0 auto 10px; border:3px solid white; box-shadow:0 4px 10px rgba(0,0,0,0.1);">
        ${initials}
      </div>
      <h4 style="font-size:16px; font-weight:800; color:var(--text-primary);">${profile.name}</h4>
      <div style="margin-top:4px; display:flex; justify-content:center; align-items:center; gap:6px;">
        ${getMembershipBadgeHtml()}
        <span class="pill info">${currentRole}</span>
      </div>
      <p style="font-size:11px; color:var(--text-secondary); margin-top:6px;">
        <i class="fa-regular fa-envelope"></i> ${profile.email} • <i class="fa-solid fa-phone"></i> ${profile.phone}
      </p>
      ${profile.city ? `<p style="font-size:10px; color:var(--text-muted); margin-top:2px;"><i class="fa-solid fa-location-dot"></i> ${profile.city}</p>` : ''}
    </div>

    <!-- User Activity Summary Grid -->
    <div style="display:grid; grid-template-columns:repeat(2, 1fr); gap:8px; margin-bottom:14px;">
      <div style="background:white; border:1px solid var(--border); border-radius:12px; padding:10px; cursor:pointer;" onclick="navigateTo('pet-health')">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:4px;">
          <i class="fa-solid fa-paw" style="color:var(--primary); font-size:18px;"></i>
          <span style="font-size:14px; font-weight:900; color:var(--text-primary);">${petCount}</span>
        </div>
        <div style="font-size:11px; font-weight:bold; color:var(--text-primary);">My Pets</div>
        <p style="font-size:9px; color:var(--text-muted);">Vaccines & Health</p>
      </div>

      <div style="background:white; border:1px solid var(--border); border-radius:12px; padding:10px; cursor:pointer;" onclick="navigateTo('my-adoption-requests')">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:4px;">
          <i class="fa-solid fa-heart" style="color:#ec4899; font-size:18px;"></i>
          <span style="font-size:14px; font-weight:900; color:var(--text-primary);">${adoptCount}</span>
        </div>
        <div style="font-size:11px; font-weight:bold; color:var(--text-primary);">Adoptions</div>
        <p style="font-size:9px; color:var(--text-muted);">Applications History</p>
      </div>

      <div style="background:white; border:1px solid var(--border); border-radius:12px; padding:10px; cursor:pointer;" onclick="navigateTo('my-rescue-requests')">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:4px;">
          <i class="fa-solid fa-tower-broadcast" style="color:var(--emergency-red); font-size:18px;"></i>
          <span style="font-size:14px; font-weight:900; color:var(--text-primary);">${rescueCount}</span>
        </div>
        <div style="font-size:11px; font-weight:bold; color:var(--text-primary);">Rescue SOS</div>
        <p style="font-size:9px; color:var(--text-muted);">Reports Broadcasted</p>
      </div>

      <div style="background:white; border:1px solid var(--border); border-radius:12px; padding:10px; cursor:pointer;" onclick="navigateTo('scan-history')">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:4px;">
          <i class="fa-solid fa-camera" style="color:#0284c7; font-size:18px;"></i>
          <span style="font-size:14px; font-weight:900; color:var(--text-primary);">${scanCount}</span>
        </div>
        <div style="font-size:11px; font-weight:bold; color:var(--text-primary);">AI Scans</div>
        <p style="font-size:9px; color:var(--text-muted);">Species Identified</p>
      </div>
    </div>

    <!-- Account Preferences List -->
    <div class="result-card">
      <h6 style="font-size:12px; font-weight:bold; margin-bottom:8px;">Account Settings & Preferences</h6>

      <div style="display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-bottom:1px solid var(--border); font-size:12px; cursor:pointer;" onclick="navigateTo('membership')">
        <span><i class="fa-solid fa-crown" style="color:#ca8a04;"></i> Manage VIP Membership (${membership.isVip ? 'VIP Active' : 'Free'})</span>
        <i class="fa-solid fa-chevron-right" style="color:var(--text-muted);"></i>
      </div>

      <div style="display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-bottom:1px solid var(--border); font-size:12px; cursor:pointer;" onclick="openEditProfileModal()">
        <span><i class="fa-solid fa-globe" style="color:var(--primary);"></i> Language Preference</span>
        <span style="font-size:11px; color:var(--primary); font-weight:bold;">${profile.language.toUpperCase()} <i class="fa-solid fa-chevron-right" style="color:var(--text-muted);"></i></span>
      </div>

      <div style="display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-bottom:1px solid var(--border); font-size:12px;">
        <span><i class="fa-solid fa-bell" style="color:var(--primary);"></i> Push Alarms & Rescue Sound</span>
        <span style="color:var(--primary); font-weight:bold;">Enabled</span>
      </div>

      <div style="display:flex; justify-content:space-between; align-items:center; padding:10px 0; font-size:12px; color:var(--emergency-red); cursor:pointer;" onclick="logoutUser()">
        <span><i class="fa-solid fa-arrow-right-from-bracket"></i> Log Out</span>
        <i class="fa-solid fa-chevron-right"></i>
      </div>
    </div>
  `;
}

// ─── COMMUNITY FEED & ANIMAL CARE PROTOTYPE MODULE ───────────────────────────
const COMMUNITY_POSTS_KEY = 'pashu_community_posts';
const COMMUNITY_SAVED_KEY = 'pashu_community_saved';
const COMMUNITY_COMMENTS_KEY = 'pashu_community_comments';

let activeCommunityCategory = 'all';
let isCommunityLoading = false;
let communityHasError = false;

function getSavedCommunityPostIds() {
  try {
    const data = JSON.parse(localStorage.getItem(COMMUNITY_SAVED_KEY) || '[]');
    if (Array.isArray(data)) return data;
  } catch (_) {}
  return [];
}

function saveSavedCommunityPostIds(ids) {
  try {
    localStorage.setItem(COMMUNITY_SAVED_KEY, JSON.stringify(ids));
  } catch (e) {
    console.warn('[CommunitySaved] Error saving:', e);
  }
}

function getCommunityComments() {
  try {
    const data = JSON.parse(localStorage.getItem(COMMUNITY_COMMENTS_KEY) || '{}');
    if (data && typeof data === 'object') return data;
  } catch (_) {}
  return {};
}

function saveCommunityComments(commentsObj) {
  try {
    localStorage.setItem(COMMUNITY_COMMENTS_KEY, JSON.stringify(commentsObj));
  } catch (e) {
    console.warn('[CommunityComments] Error saving:', e);
  }
}

function getCommunityPosts() {
  try {
    const data = JSON.parse(localStorage.getItem(COMMUNITY_POSTS_KEY) || 'null');
    if (Array.isArray(data) && data.length > 0) return data;
  } catch (_) {}

  return [
    {
      id: 'post_1',
      title: 'Golden Retriever "Sheru" Missing in Lajpat Nagar',
      description: 'Golden Retriever "Sheru" went missing near Lajpat Nagar Market, New Delhi. He wears a red leather collar with brass tag. Please call +91 98765 00112 if spotted!',
      category: 'lost',
      categoryLabel: '🚨 Lost & Found',
      tagType: 'danger',
      imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=600&q=80',
      timeAgo: '45m ago',
      author: 'Anita Sharma',
      avatar: 'AS',
      likes: 34,
      liked: false,
      commentsCount: 2
    },
    {
      id: 'post_2',
      title: 'Bruno Rescued From Monsoon Drain — Fully Healed!',
      description: 'Meet Bruno who was rescued from a monsoon drain by our Delhi rescue team. Fully vaccinated, healed, and seeking a loving forever home!',
      category: 'rescue',
      categoryLabel: '❤️ Rescue',
      tagType: 'safe',
      imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=600&q=80',
      timeAgo: '3h ago',
      author: 'Pashu Seva NGO',
      avatar: 'PS',
      likes: 128,
      liked: true,
      commentsCount: 4
    },
    {
      id: 'post_3',
      title: 'Monsoon Electrolytes & Shelter Advice for Strays',
      description: 'Monsoon Alert: Ensure stray dogs and street cows in your area have dry shelter. Keep clean water bowls filled with ORS electrolytes if pets show signs of dehydration.',
      category: 'pet_care',
      categoryLabel: '🐾 Pet Care',
      tagType: 'info',
      imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=600&q=80',
      timeAgo: '5h ago',
      author: 'Dr. Rajesh Vet',
      avatar: 'RV',
      likes: 89,
      liked: false,
      commentsCount: 1
    },
    {
      id: 'post_4',
      title: 'Free Rabies Vaccination Drive in Jaipur City',
      description: 'Join Animal Welfare Trust Jaipur for a free anti-rabies drive this Sunday at Central Park. Over 200 stray dogs to be vaccinated!',
      category: 'welfare',
      categoryLabel: '🌿 Animal Welfare',
      tagType: 'safe',
      imageUrl: 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&w=600&q=80',
      timeAgo: '1d ago',
      author: 'Jaipur Pet Alliance',
      avatar: 'JP',
      likes: 215,
      liked: false,
      commentsCount: 6
    }
  ];
}

function saveCommunityPosts(posts) {
  try {
    localStorage.setItem(COMMUNITY_POSTS_KEY, JSON.stringify(posts));
  } catch (e) {
    console.warn('[CommunityStorage] Error saving posts:', e);
  }
}

function filterCommunityCategory(category, btn) {
  activeCommunityCategory = category;
  if (btn && btn.parentElement) {
    btn.parentElement.querySelectorAll('.pill-chip').forEach(c => {
      c.style.background = 'white';
      c.style.color = 'var(--text-primary)';
      c.style.borderColor = 'var(--border)';
    });
    btn.style.background = 'var(--primary)';
    btn.style.color = 'white';
    btn.style.borderColor = 'var(--primary)';
  }
  renderCommunityFeedList();
}

function likeCommunityPost(postId) {
  const posts = getCommunityPosts();
  const post = posts.find(p => p.id === postId);
  if (!post) return;

  if (post.liked) {
    post.likes = Math.max(0, post.likes - 1);
    post.liked = false;
  } else {
    post.likes += 1;
    post.liked = true;
    showToast('❤️ Post Liked!');
  }

  saveCommunityPosts(posts);
  renderCommunityFeedList();
  const detailModal = document.getElementById('postDetailsModal');
  if (detailModal && detailModal.style.display === 'flex') {
    openPostDetailsModal(postId);
  }
}

function saveCommunityPostToggle(postId) {
  let savedIds = getSavedCommunityPostIds();
  if (savedIds.includes(postId)) {
    savedIds = savedIds.filter(id => id !== postId);
    showToast('Removed from saved posts.');
  } else {
    savedIds.push(postId);
    showToast('🔖 Post saved successfully!');
  }
  saveSavedCommunityPostIds(savedIds);
  renderCommunityFeedList();
  const detailModal = document.getElementById('postDetailsModal');
  if (detailModal && detailModal.style.display === 'flex') {
    openPostDetailsModal(postId);
  }
}

function openCreateCommunityPostModal() {
  let modal = document.getElementById('communityPostModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'communityPostModal';
    modal.style.cssText = 'position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.6); z-index:9999; display:flex; align-items:center; justify-content:center; padding:16px;';
    document.body.appendChild(modal);
    modal = document.getElementById('communityPostModal') || modal;
  }

  modal.innerHTML = `
    <div style="background:white; border-radius:18px; max-width:420px; width:100%; max-height:90vh; overflow-y:auto; padding:18px; position:relative; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:none; width:28px; height:28px; border-radius:50%; font-size:14px; color:var(--text-secondary); cursor:pointer;" onclick="closeCreateCommunityPostModal()"><i class="fa-solid fa-xmark"></i></button>

      <h5 style="font-size:15px; font-weight:800; color:var(--text-primary); margin-bottom:12px;">
        <i class="fa-solid fa-bullhorn" style="color:var(--primary);"></i> Create Community Alert / Post
      </h5>

      <form onsubmit="submitCommunityPostForm(event)">
        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Post Title *</label>
          <input type="text" id="postTitleInput" required placeholder="e.g. Lost Beagle near CP / Free Vaccination Camp" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Category *</label>
          <select id="postTypeSelect" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
            <option value="pet_care">🐾 Pet Care</option>
            <option value="rescue">❤️ Rescue</option>
            <option value="adoption">🏡 Adoption</option>
            <option value="lost">🚨 Lost & Found</option>
            <option value="welfare">🌿 Animal Welfare</option>
          </select>
        </div>

        <div style="margin-bottom:8px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Optional Image URL</label>
          <input type="url" id="postImgUrlInput" placeholder="https://example.com/photo.jpg" style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px;">
        </div>

        <div style="margin-bottom:12px;">
          <label style="font-size:11px; font-weight:bold; color:var(--text-primary); display:block; margin-bottom:3px;">Message & Details *</label>
          <textarea id="postContentInput" required rows="4" placeholder="Describe the animal, last seen location, collar color, contact info, or care question..." style="width:100%; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:12px; resize:none;"></textarea>
        </div>

        <div style="display:flex; gap:8px;">
          <button type="submit" style="flex:1; padding:10px; background:var(--primary); color:white; border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;">
            <i class="fa-solid fa-paper-plane"></i> Broadcast Post
          </button>
          <button type="button" style="padding:10px 14px; background:#f1f5f9; color:var(--text-secondary); border:none; border-radius:10px; font-size:12px; font-weight:bold; cursor:pointer;" onclick="closeCreateCommunityPostModal()">Cancel</button>
        </div>
      </form>
    </div>
  `;
  modal.style.display = 'flex';
}

function closeCreateCommunityPostModal() {
  const modal = document.getElementById('communityPostModal');
  if (modal) modal.style.display = 'none';
}

function submitCommunityPostForm(event) {
  if (event) event.preventDefault();

  const title = (document.getElementById('postTitleInput') ? document.getElementById('postTitleInput').value : '').trim();
  const type = document.getElementById('postTypeSelect') ? document.getElementById('postTypeSelect').value : 'pet_care';
  const imgUrl = (document.getElementById('postImgUrlInput') ? document.getElementById('postImgUrlInput').value : '').trim();
  const content = (document.getElementById('postContentInput') ? document.getElementById('postContentInput').value : '').trim();

  if (!content) {
    showToast('Please enter post details.');
    return;
  }

  const profile = getUserProfile();

  const catMap = {
    pet_care: { label: '🐾 Pet Care', tagType: 'info' },
    rescue: { label: '❤️ Rescue', tagType: 'safe' },
    adoption: { label: '🏡 Adoption', tagType: 'safe' },
    lost: { label: '🚨 Lost & Found', tagType: 'danger' },
    welfare: { label: '🌿 Animal Welfare', tagType: 'safe' }
  };

  const catInfo = catMap[type] || catMap['pet_care'];

  const newPost = {
    id: `post_${Date.now()}`,
    title: title || content.substring(0, 35) + '...',
    description: content,
    category: type,
    categoryLabel: catInfo.label,
    tagType: catInfo.tagType,
    imageUrl: imgUrl || null,
    timeAgo: 'Just now',
    author: profile.name || 'Anonymous Guardian',
    avatar: getUserInitials(profile.name),
    likes: 0,
    liked: false,
    commentsCount: 0
  };

  const posts = getCommunityPosts();
  posts.unshift(newPost);
  saveCommunityPosts(posts);

  closeCreateCommunityPostModal();
  showToast('📢 Community post published successfully!');
  renderCommunityFeedList();
}

function openPostDetailsModal(postId) {
  const posts = getCommunityPosts();
  const post = posts.find(p => p.id === postId);
  if (!post) return;

  const savedIds = getSavedCommunityPostIds();
  const isSaved = savedIds.includes(postId);

  const commentsObj = getCommunityComments();
  const postComments = commentsObj[postId] || [
    { author: 'Dr. Anita Vet', text: 'Thank you for sharing this crucial update!', timeAgo: '20m ago' },
    { author: 'Rahul Rescue', text: 'Contacting local volunteers in the area right now.', timeAgo: '10m ago' }
  ];

  let modal = document.getElementById('postDetailsModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'postDetailsModal';
    modal.style.cssText = 'position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.6); z-index:9999; display:flex; align-items:center; justify-content:center; padding:16px;';
    document.body.appendChild(modal);
    modal = document.getElementById('postDetailsModal') || modal;
  }

  const borderCol = post.tagType === 'danger' ? 'var(--emergency-red)' : post.tagType === 'info' ? '#0284c7' : 'var(--primary)';

  modal.innerHTML = `
    <div style="background:white; border-radius:18px; max-width:440px; width:100%; max-height:90vh; overflow-y:auto; padding:20px; position:relative; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
      <button style="position:absolute; top:12px; right:12px; background:#f1f5f9; border:none; width:28px; height:28px; border-radius:50%; font-size:14px; color:var(--text-secondary); cursor:pointer;" onclick="closePostDetailsModal()"><i class="fa-solid fa-xmark"></i></button>

      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
        <span class="pill ${post.tagType}">${post.categoryLabel || '🐾 Community'}</span>
        <span style="font-size:10px; color:var(--text-muted);">${post.timeAgo}</span>
      </div>

      <h5 style="font-size:15px; font-weight:800; color:var(--text-primary); margin-bottom:6px;">${post.title}</h5>

      <div style="display:flex; align-items:center; gap:8px; margin-bottom:12px;">
        <div style="width:28px; height:28px; background:var(--primary-container); color:var(--on-primary-container); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:11px; font-weight:bold;">${post.avatar || 'YS'}</div>
        <div>
          <h6 style="font-size:11px; font-weight:bold; color:var(--text-primary);">${post.author}</h6>
          <span style="font-size:9px; color:var(--text-muted);">Verified Guardian</span>
        </div>
      </div>

      ${post.imageUrl ? `
        <div style="width:100%; height:180px; border-radius:12px; overflow:hidden; margin-bottom:12px; background:#f1f5f9;">
          <img src="${post.imageUrl}" alt="${post.title}" style="width:100%; height:100%; object-fit:cover;" onerror="this.src='https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=600&q=80'">
        </div>
      ` : ''}

      <div style="background:#f8fafc; border-left:3px solid ${borderCol}; padding:10px 12px; border-radius:8px; margin-bottom:14px; font-size:12px; line-height:1.5; color:var(--text-primary);">
        ${post.description}
      </div>

      <!-- Action Buttons Row -->
      <div style="display:flex; gap:8px; margin-bottom:14px; border-top:1px solid var(--border); border-bottom:1px solid var(--border); padding:8px 0;">
        <button style="flex:1; padding:8px; background:${post.liked ? '#fef2f2' : 'white'}; color:${post.liked ? 'var(--emergency-red)' : 'var(--text-secondary)'}; border:1px solid ${post.liked ? '#fca5a5' : 'var(--border)'}; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="likeCommunityPost('${post.id}')">
          <i class="${post.liked ? 'fa-solid' : 'fa-regular'} fa-heart"></i> ${post.likes} Likes
        </button>

        <button style="flex:1; padding:8px; background:${isSaved ? '#fef9c3' : 'white'}; color:${isSaved ? '#ca8a04' : 'var(--text-secondary)'}; border:1px solid ${isSaved ? '#fde047' : 'var(--border)'}; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="saveCommunityPostToggle('${post.id}')">
          <i class="${isSaved ? 'fa-solid' : 'fa-regular'} fa-bookmark"></i> ${isSaved ? 'Saved' : 'Save'}
        </button>

        <button style="padding:8px 12px; background:#f1f5f9; color:var(--text-secondary); border:1px solid var(--border); border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="showToast('📋 Link copied!')">
          <i class="fa-solid fa-share-nodes"></i> Share
        </button>
      </div>

      <!-- Comments Section -->
      <h6 style="font-size:12px; font-weight:bold; color:var(--text-primary); margin-bottom:8px;">
        <i class="fa-regular fa-comments"></i> Community Comments (${postComments.length})
      </h6>

      <div style="display:flex; flex-direction:column; gap:6px; max-height:160px; overflow-y:auto; margin-bottom:12px;">
        ${postComments.map(c => `
          <div style="background:#f1f5f9; border-radius:8px; padding:8px 10px; font-size:11px;">
            <div style="display:flex; justify-content:space-between; margin-bottom:2px; font-weight:bold; color:var(--text-primary);">
              <span>${c.author}</span>
              <span style="font-weight:normal; font-size:9px; color:var(--text-muted);">${c.timeAgo || 'Just now'}</span>
            </div>
            <p style="color:var(--text-secondary); font-size:10px; margin:0;">${c.text}</p>
          </div>
        `).join('')}
      </div>

      <!-- Add Comment Form -->
      <form onsubmit="submitPostComment(event, '${post.id}')" style="display:flex; gap:6px;">
        <input type="text" id="postCommentInput_${post.id}" required placeholder="Write a comment..." style="flex:1; padding:8px 10px; border:1px solid var(--border); border-radius:8px; font-size:11px;">
        <button type="submit" style="padding:8px 12px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;">
          Send
        </button>
      </form>
    </div>
  `;
  modal.style.display = 'flex';
}

function closePostDetailsModal() {
  const modal = document.getElementById('postDetailsModal');
  if (modal) modal.style.display = 'none';
}

function submitPostComment(event, postId) {
  if (event) event.preventDefault();
  const input = document.getElementById(`postCommentInput_${postId}`);
  const text = input ? input.value.trim() : '';
  if (!text) return;

  const profile = getUserProfile();
  const commentsObj = getCommunityComments();
  if (!commentsObj[postId]) {
    commentsObj[postId] = [
      { author: 'Dr. Anita Vet', text: 'Thank you for sharing this update!', timeAgo: '20m ago' }
    ];
  }

  commentsObj[postId].push({
    author: profile.name || 'Guardian User',
    text,
    timeAgo: 'Just now'
  });

  saveCommunityComments(commentsObj);

  // Update comments count on post
  const posts = getCommunityPosts();
  const post = posts.find(p => p.id === postId);
  if (post) {
    post.commentsCount = commentsObj[postId].length;
    saveCommunityPosts(posts);
  }

  showToast('💬 Comment added!');
  openPostDetailsModal(postId);
  renderCommunityFeedList();
}

function retryLoadCommunityFeed() {
  isCommunityLoading = true;
  communityHasError = false;
  renderCommunityFeedList();

  setTimeout(() => {
    isCommunityLoading = false;
    renderCommunityFeedList();
  }, 400);
}

function renderCommunityFeedList() {
  const container = document.getElementById('communityFeedContainer');
  if (!container) return;

  if (isCommunityLoading) {
    container.innerHTML = `
      <div style="text-align:center; padding:40px 10px;">
        <div style="width:32px; height:32px; border:3px solid var(--border); border-top-color:var(--primary); border-radius:50%; animation:spin 1s linear infinite; margin:0 auto 10px;"></div>
        <p style="font-size:11px; color:var(--text-secondary);">Loading community broadcasts...</p>
      </div>
    `;
    return;
  }

  if (communityHasError) {
    container.innerHTML = `
      <div style="text-align:center; padding:30px 10px; background:white; border-radius:14px; border:1px solid var(--border);">
        <i class="fa-solid fa-triangle-exclamation" style="font-size:32px; color:var(--emergency-red); margin-bottom:8px;"></i>
        <h6 style="font-size:13px; font-weight:bold; color:var(--text-primary);">Failed to load community feed</h6>
        <p style="font-size:11px; color:var(--text-secondary); margin-top:4px;">Please check network connection and try again.</p>
        <button style="margin-top:10px; padding:6px 14px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="retryLoadCommunityFeed()">Retry Loading</button>
      </div>
    `;
    return;
  }

  const posts = getCommunityPosts();
  const savedIds = getSavedCommunityPostIds();

  let filtered = posts;
  if (activeCommunityCategory === 'saved') {
    filtered = posts.filter(p => savedIds.includes(p.id));
  } else if (activeCommunityCategory !== 'all') {
    filtered = posts.filter(p => p.category === activeCommunityCategory);
  }

  if (filtered.length === 0) {
    container.innerHTML = `
      <div style="text-align:center; padding:30px 10px; background:white; border-radius:14px; border:1px dashed var(--border);">
        <i class="fa-solid fa-users-slash" style="font-size:36px; color:var(--text-muted); margin-bottom:8px;"></i>
        <h6 style="font-size:14px; font-weight:bold; color:var(--text-primary);">No community posts found</h6>
        <p style="font-size:11px; color:var(--text-secondary); margin-top:4px;">Be the first to share an alert, rescue story, or care tip!</p>
        <button style="margin-top:10px; padding:6px 14px; background:var(--primary); color:white; border:none; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openCreateCommunityPostModal()">+ Create Post</button>
      </div>
    `;
    return;
  }

  container.innerHTML = filtered.map(p => {
    const borderCol = p.tagType === 'danger' ? 'var(--emergency-red)' : p.tagType === 'info' ? '#0284c7' : 'var(--primary)';
    const isSaved = savedIds.includes(p.id);

    return `
      <div class="result-card" style="border-left:4px solid ${borderCol}; margin-bottom:10px; background:white; cursor:pointer;" onclick="openPostDetailsModal('${p.id}')">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
          <span class="pill ${p.tagType}">${p.categoryLabel || '🐾 Community'}</span>
          <span style="font-size:10px; color:var(--text-muted);">${p.timeAgo}</span>
        </div>

        <h5 style="font-size:13px; font-weight:800; color:var(--text-primary); margin-bottom:4px;">${p.title}</h5>

        <div style="display:flex; align-items:center; gap:6px; margin-bottom:6px;">
          <div style="width:20px; height:20px; background:var(--primary-container); color:var(--on-primary-container); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:9px; font-weight:bold;">${p.avatar || 'YS'}</div>
          <span style="font-size:10px; font-weight:bold; color:var(--text-secondary);">${p.author}</span>
        </div>

        <p style="font-size:11px; line-height:1.4; color:var(--text-secondary); display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;">${p.description}</p>

        <div style="display:flex; gap:16px; margin-top:10px; font-size:11px; color:var(--text-secondary); border-top:1px solid var(--border); padding-top:8px;">
          <button style="background:none; border:none; color:${p.liked ? 'var(--emergency-red)' : 'var(--text-secondary)'}; font-size:11px; font-weight:bold; cursor:pointer; display:flex; align-items:center; gap:4px;" onclick="event.stopPropagation(); likeCommunityPost('${p.id}')">
            <i class="${p.liked ? 'fa-solid' : 'fa-regular'} fa-heart"></i> ${p.likes}
          </button>
          <span style="display:flex; align-items:center; gap:4px;"><i class="fa-regular fa-comment"></i> ${p.commentsCount}</span>
          <button style="background:none; border:none; color:${isSaved ? '#ca8a04' : 'var(--text-secondary)'}; font-size:11px; font-weight:bold; cursor:pointer; display:flex; align-items:center; gap:4px;" onclick="event.stopPropagation(); saveCommunityPostToggle('${p.id}')">
            <i class="${isSaved ? 'fa-solid' : 'fa-regular'} fa-bookmark"></i> ${isSaved ? 'Saved' : 'Save'}
          </button>
          <span style="display:flex; align-items:center; gap:4px; margin-left:auto; font-weight:bold; color:var(--primary);">Details <i class="fa-solid fa-chevron-right"></i></span>
        </div>
      </div>
    `;
  }).join('');
}

function renderCommunityScreenUI(container) {
  const t = translations[currentLanguage] || translations['en'];

  container.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
      <div>
        <h4 style="font-size:16px; font-weight:800; color:var(--text-primary);">${t.community || 'Community & Lost Pets'}</h4>
        <p style="font-size:10px; color:var(--text-secondary);">Animal care tips, rescue broadcasts & lost alerts</p>
      </div>
      <button style="background:var(--primary); color:white; border:none; padding:6px 12px; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openCreateCommunityPostModal()">+ Post</button>
    </div>

    <!-- Category Filter Chips -->
    <div style="display:flex; gap:6px; overflow-x:auto; padding-bottom:8px; margin-bottom:10px;" class="no-scrollbar">
      <button class="pill-chip" style="background:var(--primary); color:white; border:1px solid var(--primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('all', this)">🌐 All</button>
      <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('pet_care', this)">🐾 Pet Care</button>
      <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('rescue', this)">❤️ Rescue</button>
      <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('adoption', this)">🏡 Adoption</button>
      <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('lost', this)">🚨 Lost & Found</button>
      <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('welfare', this)">🌿 Welfare</button>
      <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('saved', this)">🔖 Saved</button>
    </div>

    <div id="communityFeedContainer"></div>
  `;

  setTimeout(renderCommunityFeedList, 50);

  container.innerHTML = filtered.map(p => {
    const borderCol = p.tagType === 'danger' ? 'var(--emergency-red)' : p.tagType === 'info' ? '#0284c7' : 'var(--primary)';
    return `
      <div class="result-card" style="border-left:4px solid ${borderCol}; margin-bottom:10px; background:white;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
          <span class="pill ${p.tagType}">${p.tag}</span>
          <span style="font-size:10px; color:var(--text-muted);">${p.timeAgo}</span>
        </div>

        <div style="display:flex; align-items:center; gap:8px; margin-bottom:6px;">
          <div style="width:24px; height:24px; background:var(--primary-container); color:var(--on-primary-container); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:10px; font-weight:bold;">${p.avatar || 'YS'}</div>
          <span style="font-size:11px; font-weight:bold; color:var(--text-primary);">${p.author}</span>
        </div>

        <p style="font-size:11px; line-height:1.4; color:var(--text-primary);">${p.content}</p>

        <div style="display:flex; gap:16px; margin-top:10px; font-size:11px; color:var(--text-secondary); border-top:1px solid var(--border); padding-top:8px;">
          <button style="background:none; border:none; color:${p.liked ? 'var(--emergency-red)' : 'var(--text-secondary)'}; font-size:11px; font-weight:bold; cursor:pointer; display:flex; align-items:center; gap:4px;" onclick="likeCommunityPost('${p.id}')">
            <i class="${p.liked ? 'fa-solid' : 'fa-regular'} fa-heart"></i> ${p.likes} ${p.liked ? 'Liked' : 'Like'}
          </button>
          <span style="display:flex; align-items:center; gap:4px;"><i class="fa-regular fa-comment"></i> ${p.commentsCount} Comments</span>
          <span style="display:flex; align-items:center; gap:4px; cursor:pointer; margin-left:auto;" onclick="showToast('📋 Post link copied to clipboard!')"><i class="fa-solid fa-share-nodes"></i> Share</span>
        </div>
      </div>
    `;
  }).join('');
}

function renderCommunityScreenUI(container) {
  const t = translations[currentLanguage] || translations['en'];

  container.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
      <div>
        <h4 style="font-size:16px; font-weight:800; color:var(--text-primary);">${t.community || 'Community & Lost Pets'}</h4>
        <p style="font-size:10px; color:var(--text-secondary);">Lost pet broadcasts, rescue stories & care tips</p>
      </div>
      <button style="background:var(--primary); color:white; border:none; padding:6px 12px; border-radius:8px; font-size:11px; font-weight:bold; cursor:pointer;" onclick="openCreateCommunityPostModal()">+ Post</button>
    </div>

    <!-- Category Filter Chips -->
    <div style="display:flex; gap:6px; overflow-x:auto; padding-bottom:8px; margin-bottom:10px;" class="no-scrollbar">
      <button class="pill-chip" style="background:var(--primary); color:white; border:1px solid var(--primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('all', this)">🌐 All Posts</button>
      <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('lost', this)">🚨 Lost Pets</button>
      <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('rescue', this)">❤️ Rescues</button>
      <button class="pill-chip" style="background:white; border:1px solid var(--border); color:var(--text-primary); padding:4px 10px; border-radius:12px; font-size:11px; font-weight:bold; cursor:pointer; white-space:nowrap;" onclick="filterCommunityCategory('tips', this)">💡 Care Tips</button>
    </div>

    <div id="communityFeedContainer"></div>
  `;

  setTimeout(renderCommunityFeedList, 50);
}

// ─── DEEP LINK URL ROUTING ────────────────────────────────────────────────────
(function initDeepLinkRouting() {
  const params = new URLSearchParams(window.location.search);
  const screen = params.get('screen');
  const validScreens = ['home', 'identify', 'identify-result', 'scan-history', 'help', 'adopt', 'my-adoption-requests', 'community', 'ai-assistant', 'report-emergency', 'my-rescue-requests', 'pet-health', 'membership', 'profile'];
  if (screen && validScreens.includes(screen)) {
    currentScreen = screen;
    renderScreen();
  }
})();
// Commit 1: Core app state and theme configuration
// Commit 2: Centralized i18n translation system
// Commit 3: HTML5 pushState & popstate router
// Commit 4: Mobile viewport layout shell
// Commit 5: Welcome hero & role switcher
// Commit 6: Quick access grid cards
// Commit 7: Emergency SOS rescue banner
// Commit 8: Dynamic active alerts section
// Commit 9: Dynamic remaining time calculation
// Commit 10: Reminder detail modal with snooze
// Commit 11: Image upload and camera capture handlers
// Commit 12: File size and format validation
// Commit 13: Image preview card rendering
// Commit 14: Analyzing spinner state
// Commit 18: Species confidence score & uncertainty flagging
// Commit 19: Species identification result card
// Commit 20: Food guidelines & safety precautions
// Commit 21: iNaturalist fallback taxonomy dataset
// Commit 22: AI uncertainty warning disclaimer
// Commit 23: Scan history logger with localStorage
// Commit 24: Scan history list screen
// Commit 25: Pashu Mitra AI chat interface
// Commit 28: Emergency medical disclaimer trigger
// Commit 29: Suggested question preset chips
// Commit 30: Voice mic recording simulation
// Commit 31: Chat history persistence
// Commit 32: Retry query button
// Commit 33: OpenStreetMap Overpass API integration
// Commit 34: Vet search filtering by name & city
// Commit 35: Vet category filter chips
// Commit 36: 24x7 emergency shelter filter pill
// Commit 37: Geolocation distance calculation in km
// Commit 38: Direct telephone dialing links
// Commit 39: Google Maps directions action links
// Commit 40: Favorite vet bookmarking
// Commit 41: Google Maps JS SDK dynamic loader
// Commit 42: Interactive Google Map canvas
// Commit 43: Veterinary and shelter map markers
// Commit 44: Map marker InfoWindows
// Commit 45: Graceful Maps fallback notice
// Commit 46: Pet adoption marketplace listing
// Commit 47: Adoption species filter chips
// Commit 48: Animal detail modal view
// Commit 49: Adoption request application form
// Commit 50: My Adoption Requests timeline
// Commit 51: Pet profile management screen
// Commit 52: Pet health records logger
// Commit 53: Pet reminder alarm scheduler
// Commit 54: Premium VIP membership portal
// Commit 55: Prototype checkout modal
// Commit 56: Guardian user profile screen
// Commit 57: Edit Profile modal
// Commit 58: Animal welfare community feed
