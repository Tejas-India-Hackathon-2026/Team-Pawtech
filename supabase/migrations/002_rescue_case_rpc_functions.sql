-- Supabase Edge Function: get-rescue-cases
-- Returns nearby open rescue cases within a given radius using PostGIS.
-- Called by the mobile app to display active rescue cases on the map.

-- RPC function: get_nearby_rescue_cases(lat, lon, radius_km)
CREATE OR REPLACE FUNCTION public.get_nearby_rescue_cases(
  user_lat   DOUBLE PRECISION,
  user_lon   DOUBLE PRECISION,
  radius_km  DOUBLE PRECISION DEFAULT 25.0
)
RETURNS TABLE (
  id            BIGINT,
  animal_type   TEXT,
  severity      TEXT,
  location_text TEXT,
  lat           DOUBLE PRECISION,
  lon           DOUBLE PRECISION,
  status        TEXT,
  assigned_ngo  TEXT,
  dist_km       DOUBLE PRECISION,
  created_at    TIMESTAMPTZ
)
LANGUAGE sql STABLE
AS $$
  SELECT
    rc.id,
    rc.animal_type,
    rc.severity,
    rc.location_text,
    rc.lat,
    rc.lon,
    rc.status,
    rc.assigned_ngo,
    ROUND(
      ST_Distance(
        rc.location_point,
        ST_MakePoint(user_lon, user_lat)::geography
      )::NUMERIC / 1000, 2
    ) AS dist_km,
    rc.created_at
  FROM public.rescue_cases rc
  WHERE
    rc.status IN ('reported', 'dispatched')
    AND ST_DWithin(
      rc.location_point,
      ST_MakePoint(user_lon, user_lat)::geography,
      radius_km * 1000  -- convert km to meters
    )
  ORDER BY dist_km ASC
  LIMIT 50;
$$;

-- Grant execute permission to authenticated and anonymous users
GRANT EXECUTE ON FUNCTION public.get_nearby_rescue_cases TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_nearby_rescue_cases TO anon;

-- ============================================================
-- RPC: update_rescue_case_status (for NGO volunteers)
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_rescue_case_status(
  case_id     BIGINT,
  new_status  TEXT,
  ngo_name    TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  IF new_status NOT IN ('reported', 'dispatched', 'rescued', 'closed') THEN
    RAISE EXCEPTION 'Invalid status: %. Must be reported, dispatched, rescued, or closed.', new_status;
  END IF;

  UPDATE public.rescue_cases
  SET
    status       = new_status,
    assigned_ngo = COALESCE(ngo_name, assigned_ngo),
    updated_at   = NOW()
  WHERE id = case_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Rescue case % not found.', case_id;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_rescue_case_status TO authenticated;
