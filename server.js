const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const envPath = path.join(__dirname, '.env');

function loadEnvVars() {
  if (fs.existsSync(envPath)) {
    try {
      const envContent = fs.readFileSync(envPath, 'utf8');
      envContent.split('\n').forEach(line => {
        const trimmed = line.trim();
        if (trimmed && !trimmed.startsWith('#') && trimmed.includes('=')) {
          const idx = trimmed.indexOf('=');
          const key = trimmed.substring(0, idx).trim();
          const value = trimmed.substring(idx + 1).trim();
          if (key) {
            process.env[key] = value;
          }
        }
      });
    } catch (e) {
      console.warn('[EnvLoader] Error reading .env:', e);
    }
  }
}

// Initial load
loadEnvVars();

const PORT = process.env.PORT || 8080;
const PREVIEW_DIR = path.join(__dirname, 'preview');

const MIME_TYPES = {
  '.html': 'text/html; charset=UTF-8',
  '.js': 'application/javascript; charset=UTF-8',
  '.css': 'text/css; charset=UTF-8',
  '.json': 'application/json; charset=UTF-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf'
};

async function callGeminiApi(payload, apiKey) {
  const models = ['gemini-1.5-flash', 'gemini-2.0-flash', 'gemini-1.5-pro'];
  for (const model of models) {
    try {
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey.trim()}`;
      const res = await fetch(geminiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        const data = await res.json();
        const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (text) {
          return { text, model };
        }
      }
    } catch (err) {
      console.warn(`[GeminiCall] Model ${model} failed:`, err.message);
    }
  }
  return null;
}

const server = http.createServer(async (req, res) => {
  // Hot reload .env on incoming requests
  loadEnvVars();

  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // Enable CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // --- API ENDPOINTS ---
  if (pathname === '/api/config') {
    const rawKey = process.env.GEMINI_API_KEY || process.env.VITE_GEMINI_API_KEY || '';
    const hasKey = !!rawKey && rawKey.trim().length > 10;
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      googleMapsApiKey: process.env.VITE_GOOGLE_MAPS_API_KEY || '',
      hasGeminiKey: hasKey,
      geminiKeyStatus: hasKey ? 'Configured & Active' : 'Waiting for key in .env',
      supabaseUrl: process.env.VITE_SUPABASE_URL || 'https://hquogbhtaotoyyacyvvj.supabase.co'
    }));
    return;
  }

  if (pathname === '/api/ai/chat' && req.method === 'POST') {
    let bodyStr = '';
    req.on('data', chunk => { bodyStr += chunk; });
    req.on('end', async () => {
      try {
        const body = JSON.parse(bodyStr || '{}');
        const userPrompt = body.message || body.prompt || '';
        const apiKey = (process.env.GEMINI_API_KEY || process.env.VITE_GEMINI_API_KEY || '').trim();

        if (apiKey && apiKey.length > 10) {
          const systemPrompt = "You are Pashu Mitra AI, an empathetic Indian veterinary assistant. Provide concise, expert advice for animal healthcare, stray rescue, monsoon safety, and nutrition. Always include a brief emergency disclaimer when medical symptoms are mentioned.";
          const payload = {
            contents: [
              {
                role: 'user',
                parts: [{ text: `${systemPrompt}\n\nUser Question: ${userPrompt}` }]
              }
            ]
          };

          const geminiResult = await callGeminiApi(payload, apiKey);
          if (geminiResult && geminiResult.text) {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ reply: geminiResult.text, source: geminiResult.model }));
            return;
          }
        }

        // Smart Vet Rule Fallback if key unconfigured or call fails
        let fallbackReply = "Namaste! I am Pashu Mitra AI, your veterinary assistant. ";
        const lower = userPrompt.toLowerCase();
        if (lower.includes('fever') || lower.includes('vomit') || lower.includes('blood') || lower.includes('injury')) {
          fallbackReply += "⚠️ Emergency Alert: The symptoms described may require immediate medical attention. Please consult a nearby veterinarian or contact an emergency animal shelter immediately!";
        } else if (lower.includes('puppy') || lower.includes('dog')) {
          fallbackReply += "For puppies and dogs: ensure core vaccinations (Rabies, DHPP) are up to date. Keep fresh water accessible, provide balanced high-protein food, and avoid giving cooked bones or chocolate.";
        } else if (lower.includes('cat') || lower.includes('kitten')) {
          fallbackReply += "For kittens and cats: provide wet and dry cat food rich in taurine. Ensure clean litter boxes and schedule annual health checkups.";
        } else if (lower.includes('hi') || lower.includes('hello') || lower.includes('hey')) {
          fallbackReply += "How can I help you today? Ask me any questions about pet care, vaccinations, stray rescue, or nutrition!";
        } else {
          fallbackReply += "For general animal care: ensure daily clean drinking water, adequate dry shelter, timely vaccination boosters, and regular deworming.";
        }

        fallbackReply += "<br><br><span style='font-size:10px; color:#64748b;'>🔑 <i>Note: Paste your <b>GEMINI_API_KEY</b> in the <code>.env</code> file to unlock live Gemini 1.5 Flash AI responses!</i></span>";

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ reply: fallbackReply, source: 'pashu-mitra-fallback' }));
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  if (pathname === '/api/ai/analyze-image' && req.method === 'POST') {
    let bodyStr = '';
    req.on('data', chunk => { bodyStr += chunk; });
    req.on('end', async () => {
      try {
        const body = JSON.parse(bodyStr || '{}');
        const imageBase64 = body.imageBase64 || '';
        const mimeType = body.mimeType || 'image/jpeg';
        const apiKey = (process.env.GEMINI_API_KEY || process.env.VITE_GEMINI_API_KEY || '').trim();

        if (apiKey && apiKey.length > 10 && imageBase64) {
          const cleanData = imageBase64.replace(/^data:image\/\w+;base64,/, '');
          const promptText = `You are an expert zoologist and animal identification AI assistant.
CRITICAL INSTRUCTION: Analyze ONLY the provided image itself. Do NOT infer or guess from filenames, UI text, or example data. Examine visual evidence visible in the image (ears, snout, coat, paws, wings, beak, body structure).

You MUST respond ONLY with valid JSON using this exact format (no markdown fences around JSON if possible, or simple raw JSON):
{
  "animal_name": "Common species name (e.g. Rabbit, Domestic Cat, Indian Street Dog, Rose-ringed Parakeet, Cow, Horse, Snake, etc.)",
  "scientific_name": "Binomial scientific name (e.g. Oryctolagus cuniculus)",
  "confidence": 0.92,
  "species_group": "Taxonomic group (e.g. Mammal, Bird, Reptile, Amphibian)",
  "domestic_or_wild": "Domestic or Wild",
  "visual_evidence": ["Key visual feature 1", "Key visual feature 2"],
  "basic_care": ["Care instruction 1", "Care instruction 2"],
  "food_guidance": ["Diet guidance 1", "Diet guidance 2"],
  "safety_guidance": "Safety precautions for handling or approaching",
  "needs_professional_verification": false
}

If the image is blurry, cropped, too dark, corrupted, or does NOT contain a clearly recognizable animal, return:
{
  "animal_name": "Unknown / Unclear Image",
  "scientific_name": "",
  "confidence": 0.0,
  "species_group": "Uncertain",
  "domestic_or_wild": "Uncertain",
  "visual_evidence": ["Visual evidence insufficient for identification"],
  "basic_care": ["Please upload a clearer, well-lit photo of the animal"],
  "food_guidance": ["Unable to determine diet"],
  "safety_guidance": "Consult a veterinarian or wildlife expert for assistance",
  "needs_professional_verification": true
}`;

          const payload = {
            contents: [
              {
                parts: [
                  { text: promptText },
                  { inlineData: { mimeType, data: cleanData } }
                ]
              }
            ]
          };

          const geminiResult = await callGeminiApi(payload, apiKey);
          if (geminiResult && geminiResult.text) {
            try {
              const cleanedText = geminiResult.text.replace(/```json/g, '').replace(/```/g, '').trim();
              const parsed = JSON.parse(cleanedText);
              
              // Normalize keys for UI compatibility
              const normalized = {
                common_name: parsed.animal_name || parsed.common_name || "Unknown",
                animal_name: parsed.animal_name || parsed.common_name || "Unknown",
                scientific_name: parsed.scientific_name || "",
                confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0.9,
                species_group: parsed.species_group || "Mammal",
                is_domestic: (parsed.domestic_or_wild || '').toLowerCase().includes('domestic'),
                visual_evidence: parsed.visual_evidence || [],
                general_care: Array.isArray(parsed.basic_care) ? parsed.basic_care.join('. ') : (parsed.basic_care || parsed.general_care || ''),
                food_needs: Array.isArray(parsed.food_guidance) ? parsed.food_guidance.join('. ') : (parsed.food_guidance || parsed.food_needs || ''),
                safety_guidance: parsed.safety_guidance || '',
                needs_professional_verification: parsed.needs_professional_verification === true || (parsed.confidence || 0) < 0.7,
                is_uncertain: parsed.needs_professional_verification === true || (parsed.confidence || 0) < 0.7
              };

              res.writeHead(200, { 'Content-Type': 'application/json' });
              res.end(JSON.stringify(normalized));
              return;
            } catch (pErr) {
              console.warn('[VisionJSON] Error parsing Gemini JSON output:', pErr);
            }
          }
        }

        // Unconfigured API Key or API error fallback (NO HARDCODED FAKE SPECIES)
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          common_name: "Identification Uncertain (GEMINI_API_KEY Required)",
          animal_name: "Unknown / Requires GEMINI_API_KEY",
          scientific_name: "Unconfigured Backend Vision AI",
          confidence: 0.0,
          is_uncertain: true,
          needs_professional_verification: true,
          visual_evidence: ["Gemini 1.5 Vision API Key is unconfigured in .env"],
          general_care: "Paste your GEMINI_API_KEY in the project .env file to run live AI vision identification on actual uploaded images.",
          food_needs: "Live image recognition requires GEMINI_API_KEY.",
          safety_guidance: "Always approach unfamiliar animals with caution. Consult a licensed veterinarian.",
          uncertainty_warning: "Unable to run live AI vision analysis. Please add your GEMINI_API_KEY to the .env file."
        }));
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // --- STATIC FILE SERVER ---
  let filePath = path.join(PREVIEW_DIR, pathname === '/' ? 'index.html' : pathname);
  const extname = String(path.extname(filePath)).toLowerCase();
  const contentType = MIME_TYPES[extname] || 'application/octet-stream';

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      filePath = path.join(PREVIEW_DIR, 'index.html');
    }
    fs.readFile(filePath, (readErr, content) => {
      if (readErr) {
        res.writeHead(500);
        res.end('Server Error: File not found.');
      } else {
        res.writeHead(200, { 'Content-Type': contentType });
        res.end(content, 'utf-8');
      }
    });
  });
});

server.listen(PORT, () => {
  console.log(`================================================================`);
  console.log(` PashuRakhshak Server running on http://localhost:${PORT}`);
  console.log(` Real-time .env Hot Reload Active for GEMINI_API_KEY & VITE_GOOGLE_MAPS_API_KEY`);
  console.log(`================================================================`);
});
// Commit 15: Gemini 1.5 Flash Vision backend endpoint
// Commit 16: Multimodal inlineData payload parser
// Commit 17: Structured species JSON parser
// Commit 26: Server-side Gemini chat endpoint
// Commit 27: Veterinary prompt engineering
// Commit 60: Node.js backend server with live .env hot reloading
