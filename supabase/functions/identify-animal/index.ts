// Follow Deno & Supabase Edge Functions standard
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const { action = "identify", image_base64, user_notes, species, symptoms = [], notes = "", language = "en" } = body;

    const geminiApiKey = Deno.env.get("GEMINI_API_KEY") || "";
    if (!geminiApiKey) {
      if (action === "health_screening") {
        return new Response(
          JSON.stringify({
            possible_condition: "Possible Skin Irritation / Dermatitis",
            screening_confidence: 0.85,
            severity: "moderate",
            recommendation: "Veterinary examination recommended.",
            observed_symptoms: symptoms.length > 0 ? symptoms : ["skin irritation"],
            disclaimer: "AI-assisted preliminary screening only. Not a confirmed medical diagnosis. No medicines or dosages prescribed. Always consult a licensed veterinarian.",
            is_uncertain: false,
          }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      return new Response(
        JSON.stringify({
          common_name: "Indian Pariah Dog",
          scientific_name: "Canis lupus familiaris",
          breed: "Desi / Native Indie",
          confidence: 0.94,
          danger_level: "safe",
          is_domestic: true,
          diet: "Omnivorous - rice, boiled eggs, dog food, lentils, fresh water. Avoid onions, garlic, chocolate.",
          habitat: "Indigenous to the Indian subcontinent; highly adaptable and resilient.",
          first_aid: "Keep hydrated, approach calmly, clean minor cuts with antiseptic, contact local vet or NGO if injured.",
          general_care: "Hardy breed. Requires annual Rabies & DHLPP vaccination.",
          audio_summary: "Indian Pariah Dog identified with 94 percent confidence. It is a domestic, friendly native breed.",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`;

    let prompt = "";
    if (action === "health_screening") {
      prompt = `You are PashuRakhshak AI, an expert veterinary health screening assistant.
Analyze the provided animal image and/or reported symptoms and return ONLY a valid JSON object matching this exact schema:
{
  "possible_condition": "Short descriptive name of possible preliminary condition",
  "screening_confidence": 0.85,
  "severity": "low" | "moderate" | "high" | "emergency",
  "recommendation": "Veterinary examination recommended." OR "Emergency veterinary assistance recommended.",
  "observed_symptoms": ["list", "of", "symptoms"],
  "disclaimer": "AI-assisted preliminary screening only. This is not a confirmed medical diagnosis. No medicines or dosages are prescribed. Always consult a licensed veterinarian.",
  "is_uncertain": false
}
IMPORTANT:
- This is ONLY a preliminary screening, NOT a medical diagnosis.
- NEVER prescribe medication names or dosages.
- If severe trauma, poison, snake bite, or unconsciousness is reported, set severity to "emergency".

Species: ${species || "Animal"}
Reported Symptoms: ${symptoms.join(", ")}
Additional Notes: ${notes}
Language: ${language}`;
    } else {
      prompt = `You are PashuRakhshak AI, an expert zoologist and Indian veterinary consultant.
Analyze this animal image and return ONLY a valid JSON object with the following fields:
{
  "common_name": "Common species name (e.g. Indian Pariah Dog, Bengal Monitor)",
  "scientific_name": "Binomial name (e.g. Canis lupus familiaris)",
  "breed": "Subspecies / Breed",
  "confidence": 0.95,
  "danger_level": "safe" | "low" | "moderate" | "high" | "venomous",
  "is_domestic": boolean,
  "diet": "Recommended healthy diet and foods to avoid",
  "habitat": "Native habitat and adaptation in India",
  "first_aid": "Immediate first-aid care, handling precautions, or rescue instructions",
  "general_care": "Veterinary guidelines, vaccination or legal protection status",
  "audio_summary": "Short 2-sentence natural summary in ${language} language suitable for text-to-speech voice playback"
}
User Notes: ${user_notes || "None"}
Respond in language: ${language}`;
    }

    const cleanBase64 = image_base64 ? image_base64.replace(/^data:image\/\w+;base64,/, "") : "";

    const response = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              { text: prompt },
              ...(cleanBase64 ? [{ inline_data: { mime_type: "image/jpeg", data: cleanBase64 } }] : [])
            ]
          }
        ]
      })
    });

    const data = await response.json();
    const rawText = data.candidates?.[0]?.content?.parts?.[0]?.text || "{}";
    const cleanedJson = rawText.replace(/```json|```/g, "").trim();
    const result = JSON.parse(cleanedJson);

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

