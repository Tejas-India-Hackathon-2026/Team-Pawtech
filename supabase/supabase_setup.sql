-- ============================================================================
-- PashuRakhshak (पशुरक्षक) - Supabase + PostGIS Nearby Vets Setup Script
-- ============================================================================

-- 1. Enable PostGIS Extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Create 'vets' Table with Spatial GEOGRAPHY Column
CREATE TABLE IF NOT EXISTS public.vets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT NOT NULL,
    website TEXT,
    is_verified BOOLEAN DEFAULT true,
    is_24x7 BOOLEAN DEFAULT false,
    rating NUMERIC(2, 1) DEFAULT 4.5,
    -- GEOGRAPHY(Point, 4326) uses WGS 84 spatial reference (longitude, latitude)
    location GEOGRAPHY(Point, 4326) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Create Spatial Index using GIST for ultra-fast spatial querying
CREATE INDEX IF NOT EXISTS vets_geo_idx ON public.vets USING GIST (location);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.vets ENABLE ROW LEVEL SECURITY;

-- Allow public read access to vets table
CREATE POLICY "Allow public read access to vets"
    ON public.vets FOR SELECT
    USING (true);

-- 5. RPC Function: get_nearby_vets
-- Finds up to 10 nearest veterinary hospitals within specified radius using PostGIS ST_DWithin & ST_Distance
CREATE OR REPLACE FUNCTION public.get_nearby_vets(
    user_lat FLOAT,
    user_lng FLOAT,
    radius_meters INT DEFAULT 10000
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    address TEXT,
    phone TEXT,
    website TEXT,
    is_verified BOOLEAN,
    is_24x7 BOOLEAN,
    rating NUMERIC,
    distance_km FLOAT,
    vet_lat FLOAT,
    vet_lng FLOAT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    -- WGS 84 geography point (Longitude first, then Latitude)
    user_point GEOGRAPHY;
BEGIN
    user_point := ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography;

    RETURN QUERY
    SELECT 
        v.id,
        v.name,
        v.address,
        v.phone,
        v.website,
        v.is_verified,
        v.is_24x7,
        v.rating,
        -- Calculate distance in kilometers rounded to 2 decimal places
        ROUND((ST_Distance(v.location, user_point) / 1000.0)::numeric, 2)::FLOAT AS distance_km,
        ST_Y(v.location::geometry) AS vet_lat,
        ST_X(v.location::geometry) AS vet_lng
    FROM public.vets v
    WHERE ST_DWithin(v.location, user_point, radius_meters)
    ORDER BY ST_Distance(v.location, user_point) ASC
    LIMIT 10;
END;
$$;

-- Grant execution permission on RPC to anon and authenticated roles
GRANT EXECUTE ON FUNCTION public.get_nearby_vets(FLOAT, FLOAT, INT) TO anon, authenticated;


-- ============================================================================
-- SAMPLE SEED DATA (Indian Cities: Delhi, Bangalore, Mumbai)
-- Note: ST_MakePoint takes (longitude, latitude)
-- ============================================================================

INSERT INTO public.vets (name, address, phone, website, is_verified, is_24x7, rating, location)
VALUES
  (
    'Jamui District Veterinary Hospital',
    'Court Road, Near Main Chowk, Jamui Town, Bihar 811307',
    '+916345222100',
    'https://jamui.bih.nic.in',
    true, true, 4.8,
    ST_SetSRID(ST_MakePoint(86.2250, 24.9260), 4326)::geography
  ),
  (
    'Amarwath Animal Rescue & Mobile Unit',
    'Amarwath Village Road, Jamui District, Bihar 811307',
    '+919431288990',
    'https://pashurakhshak.in',
    true, true, 4.9,
    ST_SetSRID(ST_MakePoint(86.1837, 24.9542), 4326)::geography
  ),
  (
    'Govt. Veterinary Dispensary & Pet Clinic',
    'Hospital Road, Sub-Division Area, Jamui, Bihar 811307',
    '+916345224500',
    'https://jamui.bih.nic.in',
    true, false, 4.7,
    ST_SetSRID(ST_MakePoint(86.2180, 24.9310), 4326)::geography
  ),
  (
    'Cessna Lifeline Veterinary Hospital',
    'Domlur, Inner Ring Rd, Bengaluru, Karnataka 560071',
    '+918041234567',
    'https://cessnalifeline.com',
    true, true, 4.9,
    ST_SetSRID(ST_MakePoint(77.6387, 12.9610), 4326)::geography
  ),
  (
    'Government Veterinary Hospital',
    'Queens Road, Vasanth Nagar, Bengaluru, Karnataka 560001',
    '+918022864321',
    NULL,
    true, false, 4.2,
    ST_SetSRID(ST_MakePoint(77.5975, 12.9866), 4326)::geography
  ),
  (
    'Bai Sakarbai Dinshaw Petit Hospital for Animals',
    'Dr SS Rao Rd, Parel, Mumbai, Maharashtra 400012',
    '+912224137534',
    'https://bsdphospital.org',
    true, true, 4.5,
    ST_SetSRID(ST_MakePoint(72.8411, 19.0019), 4326)::geography
  ),
  (
    'Happy Tails Veterinary Clinic',
    'Bandra West, Hill Road, Mumbai, Maharashtra 400050',
    '+912226409999',
    'https://happytailspets.in',
    true, false, 4.8,
    ST_SetSRID(ST_MakePoint(72.8315, 19.0544), 4326)::geography
  )
ON CONFLICT DO NOTHING;
