import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

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
    const event = body.event;

    // Initialize Supabase Admin Client
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    if (event === "payment.captured" || event === "order.paid") {
      const payment = body.payload.payment.entity;
      const orderId = payment.order_id;
      const email = payment.email;

      // Update user subscription & grant VIP Gold status
      if (email) {
        await supabaseAdmin
          .from("profiles")
          .update({ is_premium: true })
          .eq("email", email);

        await supabaseAdmin.from("subscriptions").insert({
          user_id: payment.notes?.user_id,
          plan: payment.amount >= 90000 ? "yearly_999" : "monthly_99",
          razorpay_order_id: orderId,
          razorpay_payment_id: payment.id,
          amount_inr: payment.amount / 100,
          status: "active",
          expires_at: new Date(
            Date.now() + (payment.amount >= 90000 ? 365 : 30) * 86400000
          ).toISOString(),
        });
      }
    }

    return new Response(JSON.stringify({ status: "success" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
