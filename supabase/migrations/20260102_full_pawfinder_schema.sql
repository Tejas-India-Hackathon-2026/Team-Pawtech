-- ==============================================================================
-- PawFinder (पशुरक्षक) - Comprehensive PostgreSQL Database Schema & RLS
-- Migration: 20260102_full_pawfinder_schema.sql
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Create Enums
DO $$ BEGIN
    CREATE TYPE user_role_type AS ENUM ('user', 'seller', 'ngo', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE seller_verification_status_enum AS ENUM ('unverified', 'pending', 'verified', 'rejected');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE referral_status_enum AS ENUM ('pending', 'accepted', 'in_progress', 'resolved', 'rejected');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE health_report_type_enum AS ENUM ('pdf', 'image', 'prescription', 'lab_report', 'xray');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE moderation_status_enum AS ENUM ('allowed', 'flagged_for_review', 'removed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Update/Create Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone TEXT,
    role user_role_type DEFAULT 'user' NOT NULL,
    avatar_url TEXT,
    is_premium BOOLEAN DEFAULT FALSE NOT NULL,
    verification_status seller_verification_status_enum DEFAULT 'unverified' NOT NULL,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_badge BOOLEAN DEFAULT FALSE NOT NULL,
    location TEXT,
    location_geom GEOMETRY(Point, 4326),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Seller Verifications Table
CREATE TABLE IF NOT EXISTS public.seller_verifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    full_legal_name TEXT NOT NULL,
    government_id_type TEXT NOT NULL, -- Aadhar, PAN, Driving License
    government_id_number TEXT NOT NULL,
    document_url TEXT NOT NULL,
    address_proof_url TEXT,
    notes TEXT,
    status seller_verification_status_enum DEFAULT 'pending' NOT NULL,
    reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Pets / Animals for Adoption & Sale Marketplace Table
CREATE TABLE IF NOT EXISTS public.pets_for_adoption (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    seller_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    species TEXT NOT NULL, -- Dog, Cat, Bird, Cattle, Other
    breed TEXT NOT NULL,
    category TEXT NOT NULL, -- Rescues, Dogs, Cats, Birds, Cattle, Products
    age_months INTEGER NOT NULL,
    gender TEXT NOT NULL, -- Male, Female, Unknown
    price_inr INTEGER DEFAULT 0 NOT NULL,
    is_free_adoption BOOLEAN DEFAULT TRUE NOT NULL,
    is_vaccinated BOOLEAN DEFAULT TRUE NOT NULL,
    is_dewormed BOOLEAN DEFAULT TRUE NOT NULL,
    location TEXT NOT NULL,
    location_geom GEOMETRY(Point, 4326),
    description TEXT NOT NULL,
    contact_phone TEXT NOT NULL,
    photos TEXT[] DEFAULT ARRAY[]::TEXT[],
    verified_seller_status BOOLEAN DEFAULT FALSE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Community Feed Posts Table
CREATE TABLE IF NOT EXISTS public.community_posts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    author_name TEXT NOT NULL,
    author_avatar TEXT,
    content TEXT NOT NULL,
    image_url TEXT,
    likes_count INTEGER DEFAULT 0 NOT NULL,
    comments_count INTEGER DEFAULT 0 NOT NULL,
    is_flagged BOOLEAN DEFAULT FALSE NOT NULL,
    risk_score NUMERIC(3, 2) DEFAULT 0.0 NOT NULL,
    moderation_reason TEXT,
    moderation_status moderation_status_enum DEFAULT 'allowed' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. Post Comments Table
CREATE TABLE IF NOT EXISTS public.community_comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES public.community_posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    author_name TEXT NOT NULL,
    author_avatar TEXT,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 7. Post Likes Table
CREATE TABLE IF NOT EXISTS public.community_likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES public.community_posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(post_id, user_id)
);

-- 8. Content Reports Table
CREATE TABLE IF NOT EXISTS public.community_reports (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    reporter_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    target_type TEXT NOT NULL, -- post, comment, listing, user
    target_id UUID NOT NULL,
    reason TEXT NOT NULL,
    status TEXT DEFAULT 'pending' NOT NULL, -- pending, reviewed, dismissed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 9. Pets Profile Management Table
CREATE TABLE IF NOT EXISTS public.pets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    photo_url TEXT,
    species TEXT NOT NULL,
    breed TEXT NOT NULL,
    dob DATE,
    age_years NUMERIC(4, 1) DEFAULT 1.0 NOT NULL,
    gender TEXT DEFAULT 'Unknown' NOT NULL,
    weight_kg NUMERIC(5, 2) DEFAULT 0.0 NOT NULL,
    allergies TEXT DEFAULT 'None' NOT NULL,
    existing_conditions TEXT DEFAULT 'None' NOT NULL,
    emergency_contact TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 10. Vaccinations Record Table
CREATE TABLE IF NOT EXISTS public.vaccinations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
    vaccine_name TEXT NOT NULL,
    date_administered DATE NOT NULL,
    next_due_date DATE NOT NULL,
    vet_name TEXT NOT NULL,
    certificate_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 11. Medical Records Table
CREATE TABLE IF NOT EXISTS public.medical_records (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
    diagnosis TEXT NOT NULL,
    treatment TEXT NOT NULL,
    record_date DATE NOT NULL,
    vet_name TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 12. Medicines Table
CREATE TABLE IF NOT EXISTS public.medicines (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
    medicine_name TEXT NOT NULL,
    dosage TEXT NOT NULL,
    frequency TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    vet_name TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 13. Vet Visits Table
CREATE TABLE IF NOT EXISTS public.vet_visits (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
    visit_date DATE NOT NULL,
    clinic_name TEXT NOT NULL,
    reason TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 14. Health Reports / Documents Upload Table
CREATE TABLE IF NOT EXISTS public.health_reports (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
    report_type health_report_type_enum NOT NULL,
    title TEXT NOT NULL,
    file_url TEXT NOT NULL,
    report_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 15. Health Reminders Table
CREATE TABLE IF NOT EXISTS public.health_reminders (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    reminder_type TEXT NOT NULL, -- vaccination, medicine, vet_visit, checkup
    reminder_time TIMESTAMP WITH TIME ZONE NOT NULL,
    is_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    snooze_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 16. Rescue Organizations Directory Table
CREATE TABLE IF NOT EXISTS public.rescue_organizations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    category org_category_enum DEFAULT 'animal_ngo' NOT NULL,
    phone TEXT NOT NULL,
    emergency_phone TEXT,
    address TEXT NOT NULL,
    opening_hours TEXT DEFAULT '24 Hours Open' NOT NULL,
    verified BOOLEAN DEFAULT TRUE NOT NULL,
    website_url TEXT DEFAULT 'https://pashurakhshak.in' NOT NULL,
    location_geom GEOMETRY(Point, 4326) NOT NULL,
    rating NUMERIC(3, 2) DEFAULT 4.8 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_rescue_orgs_geom ON public.rescue_organizations USING GIST (location_geom);

-- 17. NGO Referrals Table
CREATE TABLE IF NOT EXISTS public.referrals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    animal_type TEXT NOT NULL,
    problem TEXT NOT NULL,
    description TEXT NOT NULL,
    photo_url TEXT,
    address TEXT NOT NULL,
    location_geom GEOMETRY(Point, 4326),
    urgency TEXT DEFAULT 'high' NOT NULL,
    contact_info TEXT NOT NULL,
    required_category org_category_enum NOT NULL,
    assigned_ngo_id UUID REFERENCES public.rescue_organizations(id) ON DELETE SET NULL,
    status referral_status_enum DEFAULT 'pending' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 18. AI Chatbot Sessions & History Table
CREATE TABLE IF NOT EXISTS public.chat_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT DEFAULT 'Pet Consultation' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    session_id UUID REFERENCES public.chat_sessions(id) ON DELETE CASCADE NOT NULL,
    sender TEXT NOT NULL, -- user or assistant
    message TEXT NOT NULL,
    language TEXT DEFAULT 'en' NOT NULL,
    is_priority BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 19. Subscriptions Table
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    plan subscription_plan_type NOT NULL,
    razorpay_order_id TEXT NOT NULL,
    razorpay_payment_id TEXT,
    amount_inr INTEGER NOT NULL,
    status TEXT DEFAULT 'pending' NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 20. Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    notification_type TEXT DEFAULT 'general' NOT NULL,
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 21. User Preferences Table
CREATE TABLE IF NOT EXISTS public.user_preferences (
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE PRIMARY KEY,
    language_code TEXT DEFAULT 'en' NOT NULL,
    voice_assistant_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    voice_response_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    vaccination_reminders_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    medicine_reminders_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    community_notifications_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    referral_notifications_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    location_permission_granted BOOLEAN DEFAULT TRUE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS Configuration & Security Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seller_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets_for_adoption ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vaccinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medicines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vet_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rescue_organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- Public Read Policies
CREATE POLICY "Public readable listings" ON public.pets_for_adoption FOR SELECT USING (true);
CREATE POLICY "Public readable community posts" ON public.community_posts FOR SELECT USING (moderation_status != 'removed');
CREATE POLICY "Public readable comments" ON public.community_comments FOR SELECT USING (true);
CREATE POLICY "Public readable rescue orgs" ON public.rescue_organizations FOR SELECT USING (true);

-- Authenticated User Specific Policies
CREATE POLICY "Users view own pets" ON public.pets FOR SELECT USING (auth.uid() = owner_id);
CREATE POLICY "Users insert own pets" ON public.pets FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Users update own pets" ON public.pets FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "Users delete own pets" ON public.pets FOR DELETE USING (auth.uid() = owner_id);

CREATE POLICY "Users view own health reports" ON public.health_reports FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.pets WHERE id = health_reports.pet_id AND owner_id = auth.uid())
);

CREATE POLICY "Users view own referrals" ON public.referrals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users insert referrals" ON public.referrals FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users view own seller verification" ON public.seller_verifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users submit seller verification" ON public.seller_verifications FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Storage Buckets Configuration (8 Secure Storage Buckets)
INSERT INTO storage.buckets (id, name, public) VALUES 
('pet-photos', 'pet-photos', true),
('health-reports', 'health-reports', false), -- Private medical records
('prescriptions', 'prescriptions', false),   -- Private medical records
('animal-images', 'animal-images', true),
('community-images', 'community-images', true),
('listing-images', 'listing-images', true),
('profile-images', 'profile-images', true),
('verification-documents', 'verification-documents', false) -- Private verification docs
ON CONFLICT (id) DO NOTHING;
