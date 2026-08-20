-- ==============================================================================
-- PashuRakhshak (पशुरक्षक) - Supabase PostgreSQL Schema & RLS Policies
-- ==============================================================================

-- 1. Enable PostGIS for high-performance geospatial NGO and SOS searches
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. User Roles Enum & Categories
CREATE TYPE user_role_type AS ENUM ('user', 'seller', 'ngo', 'admin');
CREATE TYPE urgency_severity AS ENUM ('critical', 'moderate', 'minor');
CREATE TYPE rescue_status_type AS ENUM ('reported', 'assigned', 'enRoute', 'rescued', 'closed');
CREATE TYPE org_category_enum AS ENUM (
    'vet_hospital', 
    'vet_clinic', 
    'rescue_center', 
    'shelter', 
    'wildlife_rescue', 
    'animal_ngo', 
    'govt_vet_hospital'
);
CREATE TYPE subscription_plan_type AS ENUM ('monthly_99', 'yearly_999');

-- 3. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone TEXT,
    role user_role_type DEFAULT 'user' NOT NULL,
    avatar_url TEXT,
    is_premium BOOLEAN DEFAULT FALSE NOT NULL,
    location TEXT,
    location_geom GEOMETRY(Point, 4326),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Animal Sightings Table (Storage Logs)
CREATE TABLE IF NOT EXISTS public.animal_sightings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    image_url TEXT NOT NULL,
    prediction TEXT NOT NULL,
    confidence NUMERIC(5, 4) NOT NULL,
    model_used TEXT NOT NULL,
    health_screening_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Rescue Organizations / Vet Directory
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

-- 6. Emergency SOS Rescue Reports
CREATE TABLE IF NOT EXISTS public.emergency_reports (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    reporter_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    animal_type TEXT NOT NULL,
    condition TEXT NOT NULL,
    urgency_level urgency_severity DEFAULT 'critical' NOT NULL,
    address TEXT NOT NULL,
    location_geom GEOMETRY(Point, 4326) NOT NULL,
    photo_url TEXT,
    reporter_phone TEXT NOT NULL,
    status rescue_status_type DEFAULT 'reported' NOT NULL,
    assigned_ngo_id UUID REFERENCES public.rescue_organizations(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_emergency_geom ON public.emergency_reports USING GIST (location_geom);

-- 7. Pets & Cattle Marketplace / Adoption Listings
CREATE TABLE IF NOT EXISTS public.pets_for_adoption (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    seller_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    species TEXT NOT NULL,
    breed TEXT NOT NULL,
    category TEXT NOT NULL,
    age_months INTEGER NOT NULL,
    gender TEXT NOT NULL,
    price_inr INTEGER DEFAULT 0 NOT NULL,
    is_free_adoption BOOLEAN DEFAULT TRUE NOT NULL,
    is_vaccinated BOOLEAN DEFAULT TRUE NOT NULL,
    is_dewormed BOOLEAN DEFAULT TRUE NOT NULL,
    location TEXT NOT NULL,
    description TEXT NOT NULL,
    images TEXT[] DEFAULT ARRAY[]::TEXT[],
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 8. Subscriptions & Payment Logs
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

-- ==============================================================================
-- Geospatial Stored Procedure: Find Nearby NGOs sorted by distance
-- ==============================================================================
CREATE OR REPLACE FUNCTION get_nearby_ngos(
    user_lat DOUBLE PRECISION,
    user_lon DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 15.0,
    target_category org_category_enum DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    category org_category_enum,
    phone TEXT,
    emergency_phone TEXT,
    address TEXT,
    opening_hours TEXT,
    verified BOOLEAN,
    website_url TEXT,
    distance_km DOUBLE PRECISION,
    rating NUMERIC(3, 2)
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        o.id,
        o.name,
        o.category,
        o.phone,
        o.emergency_phone,
        o.address,
        o.opening_hours,
        o.verified,
        o.website_url,
        ROUND((ST_Distance(
            o.location_geom,
            ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography
        ) / 1000.0)::numeric, 2)::DOUBLE PRECISION AS distance_km,
        o.rating
    FROM public.rescue_organizations o
    WHERE ST_DWithin(
        o.location_geom,
        ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography,
        radius_km * 1000
    )
    AND (target_category IS NULL OR o.category = target_category)
    ORDER BY distance_km ASC;
$$;

-- ==============================================================================
-- Row Level Security (RLS) Policies
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.animal_sightings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rescue_organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets_for_adoption ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Sightings: User can view and insert their own predictions
CREATE POLICY "Users can view own sightings" ON public.animal_sightings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own sightings" ON public.animal_sightings FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Rescue Organizations: Viewable by everyone
CREATE POLICY "Orgs viewable by everyone" ON public.rescue_organizations FOR SELECT USING (true);
