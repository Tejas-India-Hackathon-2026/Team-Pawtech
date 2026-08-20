-- PashuRakhshak Database Migrations
-- Migration: 001 - Add user_feedback table for AI scan result ratings
-- Run this against your Supabase PostgreSQL database

-- ============================================================
-- Migration 001: AI Scan Feedback Table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_scan_feedback (
    id              BIGSERIAL PRIMARY KEY,
    session_id      TEXT NOT NULL,                  -- Anonymous session identifier
    common_name     TEXT NOT NULL,                  -- Species the AI identified
    scientific_name TEXT,
    confidence      FLOAT CHECK (confidence BETWEEN 0 AND 1),
    is_accurate     BOOLEAN,                        -- User thumbs up/down
    user_comment    TEXT,                           -- Optional free-text correction
    user_lang       CHAR(5) DEFAULT 'en',
    image_quality   TEXT CHECK (image_quality IN ('good', 'acceptable', 'poor')),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security: anonymous inserts allowed, no reads without auth
ALTER TABLE public.ai_scan_feedback ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous insert" ON public.ai_scan_feedback
    FOR INSERT WITH CHECK (true);

-- Index for quick aggregation by species accuracy
CREATE INDEX idx_ai_feedback_species ON public.ai_scan_feedback (common_name);
CREATE INDEX idx_ai_feedback_accuracy ON public.ai_scan_feedback (is_accurate);

-- ============================================================
-- Migration 002: Add scan_count to user_profiles table
-- ============================================================
ALTER TABLE public.user_profiles
    ADD COLUMN IF NOT EXISTS total_scans INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS accurate_scans INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS last_scan_at TIMESTAMPTZ;

-- ============================================================
-- Migration 003: Add vet_reviews table for user-submitted ratings
-- ============================================================
CREATE TABLE IF NOT EXISTS public.vet_reviews (
    id              BIGSERIAL PRIMARY KEY,
    vet_osm_id      BIGINT NOT NULL,               -- OpenStreetMap node ID
    vet_name        TEXT NOT NULL,
    rating          SMALLINT CHECK (rating BETWEEN 1 AND 5),
    review_text     TEXT,
    user_id         UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.vet_reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated insert" ON public.vet_reviews
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Allow public read" ON public.vet_reviews
    FOR SELECT USING (true);

CREATE INDEX idx_vet_reviews_osm ON public.vet_reviews (vet_osm_id);

-- ============================================================
-- Migration 004: Add rescued_animals case tracking table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.rescue_cases (
    id              BIGSERIAL PRIMARY KEY,
    reporter_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    animal_type     TEXT NOT NULL,
    severity        TEXT CHECK (severity IN ('minor', 'moderate', 'critical', 'emergency')),
    location_text   TEXT,
    lat             DOUBLE PRECISION,
    lon             DOUBLE PRECISION,
    location_point  GEOGRAPHY(POINT, 4326) GENERATED ALWAYS AS (
                        ST_MakePoint(lon, lat)::geography
                    ) STORED,
    status          TEXT DEFAULT 'reported' CHECK (status IN ('reported', 'dispatched', 'rescued', 'closed')),
    assigned_ngo    TEXT,
    notes           TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.rescue_cases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow insert for all" ON public.rescue_cases FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow select for all" ON public.rescue_cases FOR SELECT USING (true);
CREATE POLICY "Allow update for owner" ON public.rescue_cases
    FOR UPDATE USING (auth.uid() = reporter_id);

-- Geospatial index for nearby case lookup
CREATE INDEX idx_rescue_cases_location ON public.rescue_cases USING GIST (location_point);
CREATE INDEX idx_rescue_cases_status ON public.rescue_cases (status);
