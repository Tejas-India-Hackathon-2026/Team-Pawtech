const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

function loadEnvVars() {
  const possiblePaths = [
    path.join(__dirname, '.env'),
    path.join(__dirname, '.env.local'),
    path.join(__dirname, '.env.development'),
    path.join(__dirname, '.env.production')
  ];

  possiblePaths.forEach(p => {
    if (fs.existsSync(p)) {
      try {
        const envContent = fs.readFileSync(p, 'utf8');
        envContent.split('\n').forEach(line => {
          const trimmed = line.trim();
          if (trimmed && !trimmed.startsWith('#') && trimmed.includes('=')) {
            const idx = trimmed.indexOf('=');
            const key = trimmed.substring(0, idx).trim();
            let value = trimmed.substring(idx + 1).trim();
            if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
              value = value.substring(1, value.length - 1);
            }
            if (key && value) {
              process.env[key] = value;
            }
          }
        });
      } catch (e) {
        console.warn('[EnvLoader] Error reading:', p, e.message);
      }
    }
  });
}

function getGeminiApiKey() {
  const keys = [
    process.env.GEMINI_API_KEY,
    process.env.VITE_GEMINI_API_KEY,
    process.env.GOOGLE_API_KEY,
    process.env.GEMINI_KEY,
    process.env.GOOGLE_GEMINI_API_KEY,
    process.env.GEMINI_VISION_API_KEY
  ];
  for (const k of keys) {
    if (k && k.trim().length > 10) {
      return k.trim();
    }
  }
  return null;
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
  let lastStatus = 500;
  let lastErrorText = 'Gemini service is temporarily unavailable. Please retry.';

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
          return { ok: true, text, model };
        }
      } else {
        lastStatus = res.status;
        if (res.status === 401) {
          lastErrorText = "Gemini API authentication failed. Check the API key in .env.";
          break;
        } else if (res.status === 403) {
          lastErrorText = "Gemini API access is not permitted for this project/key.";
          break;
        } else if (res.status === 404) {
          lastErrorText = "Gemini model or API endpoint was not found. Check the configured model/API version.";
        } else if (res.status === 429) {
          lastErrorText = "Gemini usage limit reached. Please try again later.";
        } else {
          lastErrorText = `Gemini API returned HTTP status ${res.status}. Please retry.`;
        }
      }
    } catch (err) {
      console.warn(`[GeminiCall] Model ${model} network error:`, err.message);
      lastErrorText = "Gemini service network connection failed. Please check network connection.";
    }
  }
  return { ok: false, status: lastStatus, error: lastErrorText };
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
    const rawKey = getGeminiApiKey();
    const hasKey = !!rawKey;
    console.log(`[ConfigDiagnostic] Gemini API key configured: ${hasKey}`);
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

        if (!userPrompt || userPrompt.trim().length === 0) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Empty message prompt provided.' }));
          return;
        }

        const apiKey = getGeminiApiKey();

        if (!apiKey) {
          res.writeHead(401, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            status: 401,
            error: "Gemini API authentication failed. GEMINI_API_KEY is unconfigured in .env.",
            reply: "🔑 <b>Gemini API Key Required:</b> Please paste your <code>GEMINI_API_KEY</code> into the project <code>.env</code> file to enable live Gemini AI chat."
          }));
          return;
        }

        const systemInstruction = "You are Pashu Mitra AI, an empathetic Indian veterinary and animal welfare assistant. Provide expert, concise advice on pet care, stray animal rescue, nutrition, vaccination schedules, and preventive care. For medical emergencies (bleeding, poisoning, seizures, fractures, trauma), clearly advise contacting a qualified veterinarian or emergency shelter immediately rather than presenting AI output as a medical diagnosis.";

        const contents = [];
        const history = body.history;
        if (Array.isArray(history) && history.length > 0) {
          history.slice(-10).forEach(m => {
            if (m.text && !m.isLoading && !m.text.includes('thinking...')) {
              contents.push({
                role: m.role === 'user' ? 'user' : 'model',
                parts: [{ text: m.text.replace(/<br>/g, '\n').replace(/<[^>]*>/g, '') }]
              });
            }
          });
        }
        contents.push({
          role: 'user',
          parts: [{ text: `${systemInstruction}\n\nUser Question: ${userPrompt}` }]
        });

        const payload = { contents };

        const geminiResult = await callGeminiApi(payload, apiKey);
        if (geminiResult && geminiResult.ok && geminiResult.text) {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ reply: geminiResult.text, source: geminiResult.model }));
          return;
        } else {
          res.writeHead(geminiResult.status || 500, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            status: geminiResult.status || 500,
            error: geminiResult.error || "Gemini service error",
            reply: `⚠️ <b>Gemini Service Error (${geminiResult.status || 500}):</b> ${geminiResult.error}`
          }));
          return;
        }
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message, reply: `⚠️ Server Error: ${err.message}` }));
      }
    });
    return;
  }

  if ((pathname === '/api/identify-animal' || pathname === '/api/ai/analyze-image') && req.method === 'POST') {
    let bodyStr = '';
    req.on('data', chunk => { bodyStr += chunk; });
    req.on('end', async () => {
      try {
        const body = JSON.parse(bodyStr || '{}');
        const imageBase64 = body.imageBase64 || body.image || '';
        const mimeType = body.mimeType || 'image/jpeg';
        const apiKey = getGeminiApiKey();

        console.log(`[AnimalID] Request received — Image present: ${!!imageBase64}, MIME: ${mimeType}, Size: ${imageBase64 ? imageBase64.length : 0} bytes, Gemini API key configured: ${!!apiKey}`);

        if (!imageBase64) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            success: false,
            errorCode: "IMAGE_UPLOAD_ERROR",
            message: "No image payload received. Please select an image file."
          }));
          return;
        }

        if (!apiKey) {
          res.writeHead(401, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            success: false,
            errorCode: "GEMINI_KEY_MISSING",
            message: "Gemini API Key is unconfigured in .env file.",
            common_name: "Identification Uncertain (GEMINI_API_KEY Required)",
            animal_name: "Unknown / Requires GEMINI_API_KEY",
            scientific_name: "Unconfigured Backend Vision AI",
            confidence: 0.0,
            is_uncertain: true,
            needs_expert_verification: true,
            needs_professional_verification: true,
            visual_evidence: ["GEMINI_API_KEY is missing from server environment"],
            general_care: "Paste your GEMINI_API_KEY in the project .env file to enable live AI vision species identification.",
            care: ["Paste your GEMINI_API_KEY in the project .env file"],
            food_guidance: "Live image recognition requires GEMINI_API_KEY.",
            safety_guidance: "Always consult a licensed veterinarian.",
            uncertainty_warning: "Unable to run live AI vision analysis. Please add your GEMINI_API_KEY to the .env file."
          }));
          return;
        }

        const cleanData = imageBase64.replace(/^data:image\/\w+;base64,/, '');
        const promptText = `You are an expert zoologist and animal identification AI assistant.
CRITICAL INSTRUCTION: Analyze ONLY the provided image itself. Do NOT use the filename, previous identification result, cached state, UI text, mock data, or example animal. Focus strictly on the visual evidence visible in the image bytes (ears, snout, coat, paws, wings, beak, body structure).

You MUST respond ONLY with valid JSON using this exact format (no markdown fences if possible, or plain raw JSON):
{
  "animal_name": "Common species name (e.g. Rabbit, Domestic Short Hair Cat, Indian Street Dog, Rose-ringed Parakeet, Zebu Cow, Horse, Snake, etc.)",
  "scientific_name": "Binomial scientific name (e.g. Oryctolagus cuniculus)",
  "confidence": 0.94,
  "species_group": "Taxonomic group (e.g. Mammal, Bird, Reptile, Amphibian)",
  "classification": "Domestic or Wild",
  "visual_evidence": ["Key visual feature 1 visible in image", "Key visual feature 2 visible in image"],
  "care": ["Care & housing instruction 1", "Care & housing instruction 2"],
  "food": ["Diet & nutrition guideline 1", "Diet & nutrition guideline 2"],
  "safety": "Safety precautions for handling or approaching",
  "needs_expert_verification": false
}

If the image is blurry, cropped, too dark, corrupted, or does NOT contain a clearly recognizable animal, return:
{
  "animal_name": "Unknown / Unclear Image",
  "scientific_name": "",
  "confidence": 0.0,
  "species_group": "Uncertain",
  "classification": "Uncertain",
  "visual_evidence": ["Visual evidence insufficient for identification"],
  "care": ["Please upload a clearer, well-lit photo of the animal"],
  "food": ["Unable to determine diet"],
  "safety": "Consult a veterinarian or wildlife expert for assistance",
  "needs_expert_verification": true
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
        if (geminiResult && geminiResult.ok && geminiResult.text) {
          try {
            const cleanedText = geminiResult.text.replace(/```json/g, '').replace(/```/g, '').trim();
            const parsed = JSON.parse(cleanedText);

            const animalName = parsed.animal_name || parsed.common_name || "Unknown";
            const confidenceVal = typeof parsed.confidence === 'number' ? parsed.confidence : 0.9;
            const isLowConf = parsed.needs_expert_verification === true || confidenceVal < 0.7;

            const normalized = {
              success: true,
              common_name: animalName,
              animal_name: animalName,
              scientific_name: parsed.scientific_name || "",
              confidence: confidenceVal,
              species_group: parsed.species_group || "Mammal",
              classification: parsed.classification || (parsed.domestic_or_wild || "Domestic"),
              is_domestic: String(parsed.classification || parsed.domestic_or_wild || '').toLowerCase().includes('domestic'),
              visual_evidence: parsed.visual_evidence || [],
              general_care: Array.isArray(parsed.care) ? parsed.care.join('. ') : (parsed.care || parsed.general_care || ''),
              care: Array.isArray(parsed.care) ? parsed.care : [parsed.care || ''],
              food_needs: Array.isArray(parsed.food) ? parsed.food.join('. ') : (parsed.food || parsed.food_needs || ''),
              food: Array.isArray(parsed.food) ? parsed.food : [parsed.food || ''],
              safety_guidance: parsed.safety || parsed.safety_guidance || '',
              safety: parsed.safety || parsed.safety_guidance || '',
              needs_expert_verification: isLowConf,
              is_uncertain: isLowConf
            };

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(normalized));
            return;
          } catch (pErr) {
            console.warn('[VisionJSON] Error parsing Gemini output:', pErr);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
              success: false,
              errorCode: "INVALID_GEMINI_RESPONSE",
              message: "Gemini response parsing error.",
              error: pErr.message
            }));
            return;
          }
        } else {
          const errCode = geminiResult.status === 401 ? "GEMINI_AUTH_ERROR" :
                          geminiResult.status === 403 ? "GEMINI_PERMISSION_ERROR" :
                          geminiResult.status === 404 ? "GEMINI_MODEL_ERROR" :
                          geminiResult.status === 429 ? "GEMINI_RATE_LIMIT" : "BACKEND_CONNECTION_ERROR";

          res.writeHead(geminiResult.status || 500, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            success: false,
            errorCode: errCode,
            message: geminiResult.error || "Gemini vision analysis failed."
          }));
          return;
        }

      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: false,
          errorCode: "BACKEND_CONNECTION_ERROR",
          message: err.message
        }));
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
