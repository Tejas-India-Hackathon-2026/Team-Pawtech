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
    const { amount, currency = "INR", receipt } = await req.json();

    const keyId = Deno.env.get("RAZORPAY_KEY_ID") || "rzp_test_pashu12345678";
    const keySecret = Deno.env.get("RAZORPAY_KEY_SECRET") || "dummy_secret";

    const authHeader = "Basic " + btoa(`${keyId}:${keySecret}`);

    const res = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": authHeader,
      },
      body: JSON.stringify({
        amount, // in paise (e.g. 9900 for ₹99, 99900 for ₹999)
        currency,
        receipt: receipt || `rcpt_${Date.now()}`,
      }),
    });

    const data = await res.json();
    return new Response(JSON.stringify(data), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
