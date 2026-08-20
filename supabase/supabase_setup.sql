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
    'Max Vets Super Speciality Hospital',
    'E-40, Greater Kailash 2, New Delhi, Delhi 110048',
    '+911141635555',
    'https://maxvets.com',
    true, true, 4.8,
    ST_SetSRID(ST_MakePoint(77.2432, 28.5355), 4326)::geography
  ),
  (
    'Sanjay Gandhi Animal Care Centre',
    'Raja Garden, Near Shivaji College, New Delhi, Delhi 110027',
    '+911125448062',
    'https://sgacc.org',
    true, true, 4.6,
    ST_SetSRID(ST_MakePoint(77.1215, 28.6492), 4326)::geography
  ),
  (
    'Crown Vet Clinic',
    'Defence Colony, Ring Road, New Delhi, Delhi 110024',
    '+919820123456',
    'https://crownvet.com',
    true, false, 4.7,
    ST_SetSRID(ST_MakePoint(77.2310, 28.5721), 4326)::geography
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
