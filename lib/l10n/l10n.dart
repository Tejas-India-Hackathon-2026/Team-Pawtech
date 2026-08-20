import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportedLocale {
  final String code;
  final String englishName;
  final String nativeName;

  const SupportedLocale({
    required this.code,
    required this.englishName,
    required this.nativeName,
  });
}

class AppLanguages {
  static const List<SupportedLocale> supportedLocales = [
    SupportedLocale(code: 'en', englishName: 'English', nativeName: 'English'),
    SupportedLocale(code: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी'),
    SupportedLocale(code: 'bho', englishName: 'Bhojpuri', nativeName: 'भोजपुरी'),
    SupportedLocale(code: 'bn', englishName: 'Bengali', nativeName: 'বাংলা'),
    SupportedLocale(code: 'ta', englishName: 'Tamil', nativeName: 'தமிழ்'),
    SupportedLocale(code: 'te', englishName: 'Telugu', nativeName: 'తెలుగు'),
    SupportedLocale(code: 'mr', englishName: 'Marathi', nativeName: 'मराठी'),
    SupportedLocale(code: 'gu', englishName: 'Gujarati', nativeName: 'ગુજરાતી'),
    SupportedLocale(code: 'pa', englishName: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
    SupportedLocale(code: 'kn', englishName: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    SupportedLocale(code: 'ml', englishName: 'Malayalam', nativeName: 'മലയാളം'),
    SupportedLocale(code: 'or', englishName: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
    SupportedLocale(code: 'as', englishName: 'Assamese', nativeName: 'অসমীয়া'),
  ];

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'appName': 'PashuRakhshak',
      'tagline': 'Protect, Identify & Care for Animals',
      'home': 'Home',
      'identifyAnimal': 'Identify Animal',
      'findHelp': 'Find Help',
      'adoptBuy': 'Adopt / Buy',
      'community': 'Community',
      'petHealth': 'Pet Health',
      'aiAssistant': 'Pashu Mitra AI',
      'premium': 'Premium',
      'settings': 'Settings',
      'profile': 'Profile',
      'emergencySos': 'Emergency SOS',
      'welcomeBack': 'Welcome,',
      'identifyPrompt': 'Scan any animal with AI to get instant species info, care & first aid',
      'activeAlerts': 'Active Alerts',
      'vaccinationReminder': 'Vaccination Due Soon',
      'medicineReminder': 'Medicine Reminder',
      'recentRescues': 'Recent Rescues Nearby',
      'findVetsNgos': 'Find Vets & NGOs',
      'reportEmergency': 'Report Animal in Distress',
      'scanNow': 'Scan Now',
      'selectFromGallery': 'Upload from Gallery',
      'analyzingImage': 'Analyzing with PashuRakhshak AI...',
      'primaryModel': 'On-Device Fast ML',
      'cloudGeminiVision': 'Deep Vision Analysis (Cloud)',
      'confidence': 'Confidence',
      'species': 'Species',
      'breed': 'Breed / Subspecies',
      'dangerLevel': 'Danger Level',
      'diet': 'Diet & Feeding',
      'firstAid': 'First Aid & Immediate Care',
      'listenAudio': 'Listen Voice Guide',
      'pricingTitle': 'PashuRakhshak Premium',
      'monthlyPlan': 'Monthly Plan - ₹99',
      'yearlyPlan': 'Yearly Plan - ₹999 (Save 16%)',
      'subscribeWithRazorpay': 'Pay with Razorpay',
    },
    'hi': {
      'appName': 'पशुरक्षक',
      'tagline': 'पशुओं की रक्षा, पहचान और देखभाल',
      'home': 'होम',
      'identifyAnimal': 'पशु पहचानें',
      'findHelp': 'मदद खोजें',
      'adoptBuy': 'गोद लें / खरीदें',
      'community': 'समुदाय',
      'petHealth': 'पशु स्वास्थ्य',
      'aiAssistant': 'पशु मित्र AI',
      'premium': 'प्रीमियम',
      'settings': 'सेटिंग्स',
      'profile': 'प्रोफ़ाइल',
      'emergencySos': 'आपातकालीन SOS',
      'welcomeBack': 'स्वागत है,',
      'identifyPrompt': 'किसी भी पशु को AI से स्कैन करें और प्रजाति, देखभाल और प्राथमिक उपचार जानें',
      'activeAlerts': 'सक्रिय अलर्ट',
      'vaccinationReminder': 'टीकाकरण का समय आ गया',
      'medicineReminder': 'दवा का समय',
      'recentRescues': 'आसपास के हालिया बचाव',
      'findVetsNgos': 'पशु चिकित्सक और NGO खोजें',
      'reportEmergency': 'घायल पशु की रिपोर्ट करें',
      'scanNow': 'अभी स्कैन करें',
      'selectFromGallery': 'गैलरी से चुनें',
      'analyzingImage': 'पशुरक्षक AI द्वारा विश्लेषण जारी...',
      'primaryModel': 'डिवाइस फास्ट ML',
      'cloudGeminiVision': 'डीप विज़न विश्लेषण (क्लाउड)',
      'confidence': 'सटीकता',
      'species': 'प्रजाति',
      'breed': 'नस्ल',
      'dangerLevel': 'खतरे का स्तर',
      'diet': 'आहार और खानपान',
      'firstAid': 'प्राथमिक उपचार व तुरंत देखभाल',
      'listenAudio': 'आवाज़ में सुनें',
      'pricingTitle': 'पशुरक्षक प्रीमियम',
      'monthlyPlan': 'मासिक प्लान - ₹99',
      'yearlyPlan': 'वार्षिक प्लान - ₹999 (16% बचत)',
      'subscribeWithRazorpay': 'Razorpay से भुगतान करें',
    },
    'bho': {
      'appName': 'पशुरक्षक',
      'tagline': 'जानवरन के सुरक्षा, पहचान आ देखभाल',
      'home': 'होम',
      'identifyAnimal': 'जानवर पहचानीं',
      'findHelp': 'मदद खोजीं',
      'adoptBuy': 'गोद लीं / खरीदीं',
      'community': 'समाज',
      'petHealth': 'पशु स्वास्थ्य',
      'aiAssistant': 'पशु मित्र AI',
      'emergencySos': 'आपातकालीन SOS',
      'welcomeBack': 'प्रणाम,',
      'scanNow': 'स्कैन करीं',
    },
    'bn': {
      'appName': 'পশুরক্ষক',
      'tagline': 'পশুদের সুরক্ষা, শনাক্তকরণ ও যত্ন',
      'home': 'হোম',
      'identifyAnimal': 'পশু শনাক্ত করুন',
      'findHelp': 'সাহায্য খুঁজুন',
      'adoptBuy': 'দত্তক / ক্রয়',
      'emergencySos': 'জরুরি SOS',
      'welcomeBack': 'স্বাগতম,',
    },
    'ta': {
      'appName': 'பசுரக்ஷக்',
      'tagline': 'விலங்குகள் பாதுகாப்பு, அடையாளம் மற்றும் பராமரிப்பு',
      'home': 'முகப்பு',
      'identifyAnimal': 'விலங்கை அடையாளம் காண்க',
      'findHelp': 'உதவி தேடுங்கள்',
      'emergencySos': 'அவசர SOS',
    },
    'te': {
      'appName': 'పశురక్షక్',
      'tagline': 'జంతువుల రక్షణ, గుర్తింపు మరియు సంరక్షణ',
      'home': 'హోమ్',
      'identifyAnimal': 'జంతువును గుర్తించండి',
      'findHelp': 'సహాయం పొందండి',
      'emergencySos': 'అత్యవసర SOS',
    },
    'mr': {
      'appName': 'पशुरक्षक',
      'tagline': 'प्राण्यांचे संरक्षण, ओळख आणि काळजी',
      'home': 'होम',
      'identifyAnimal': 'प्राणी ओळखा',
      'findHelp': 'मदत शोधा',
      'emergencySos': 'तातडीचे SOS',
    },
    'gu': {
      'appName': 'પશુરક્ષક',
      'tagline': 'પ્રાણીઓનું રક્ષણ, ઓળખ અને સંભાળ',
      'home': 'હોમ',
      'identifyAnimal': 'પ્રાણી ઓળખો',
      'findHelp': 'મદદ શોધો',
      'emergencySos': 'ઇમરજન્સી SOS',
    },
    'pa': {
      'appName': 'ਪਸ਼ੂਰੱਖਿਅਕ',
      'tagline': 'ਜਾਨਵਰਾਂ ਦੀ ਸੁਰੱਖਿਆ, ਪਛਾਣ ਅਤੇ ਦੇਖਭਾਲ',
      'home': 'ਹੋਮ',
      'identifyAnimal': 'ਜਾਨਵਰ ਪਛਾਣੋ',
      'findHelp': 'ਮਦਦ ਲੱਭੋ',
      'emergencySos': 'ਐਮਰਜੈਂਸੀ SOS',
    },
    'kn': {
      'appName': 'ಪಶುರಕ್ಷಕ್',
      'tagline': 'ಪ್ರಾಣಿಗಳ ರಕ್ಷಣೆ, ಗುರುತಿಸುವಿಕೆ ಮತ್ತು ಆರೈಕೆ',
      'home': 'ಮುಖಪುಟ',
      'identifyAnimal': 'ಪ್ರಾಣಿ ಗುರುತಿಸಿ',
      'emergencySos': 'ತುರ್ತು SOS',
    },
    'ml': {
      'appName': 'പശുരക്ഷക്',
      'tagline': 'മൃഗസംരക്ഷണം, തിരിച്ചറിയൽ, പരിചരണം',
      'home': 'ഹോം',
      'identifyAnimal': 'മൃഗത്തെ തിരിച്ചറിയുക',
      'emergencySos': 'അടിയന്തര SOS',
    },
    'or': {
      'appName': 'ପଶୁରକ୍ଷକ',
      'tagline': 'ପଶୁମାନଙ୍କ ସୁରକ୍ଷା, ଚିହ୍ନଟ ଓ ଯତ୍ନ',
      'home': 'ହୋମ୍',
      'identifyAnimal': 'ପଶୁ ଚିହ୍ନଟ କରନ୍ତୁ',
      'emergencySos': 'ଜରୁରୀକାଳୀନ SOS',
    },
    'as': {
      'appName': 'পশুৰক্ষক',
      'tagline': 'পশুৰ সুৰক্ষা, চিনাক্তকৰণ আৰু যত্ন',
      'home': 'গৃহ',
      'identifyAnimal': 'পশু চিনাক্ত কৰক',
      'emergencySos': 'জৰুৰীকালীন SOS',
    },
  };

  static String get(String key, String langCode) {
    if (_translations.containsKey(langCode) &&
        _translations[langCode]!.containsKey(key)) {
      return _translations[langCode]![key]!;
    }
    if (_translations['en']!.containsKey(key)) {
      return _translations['en']![key]!;
    }
    return key;
  }
}

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(String languageCode) {
    state = Locale(languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
