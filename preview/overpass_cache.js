// PashuRakhshak Overpass API Result Cache
// Prevents redundant API calls by caching vet/shelter results per GPS location.

const OVERPASS_CACHE_KEY = 'pashu_overpass_cache';
const CACHE_TTL_MS = 30 * 60 * 1000; // 30 minutes

/**
 * Generate a coarse location bucket key (rounds to ~1km grid).
 * @param {number} lat
 * @param {number} lon
 * @returns {string}
 */
export function getLocationBucketKey(lat, lon) {
  const latBucket = Math.round(lat * 100) / 100;  // ~1.1 km precision
  const lonBucket = Math.round(lon * 100) / 100;
  return `${latBucket},${lonBucket}`;
}

/**
 * Store Overpass API results in localStorage cache.
 * @param {number} lat
 * @param {number} lon
 * @param {Array} results
 */
export function cacheOverpassResults(lat, lon, results) {
  try {
    const key = getLocationBucketKey(lat, lon);
    const allCache = getFullCache();
    allCache[key] = {
      timestamp: Date.now(),
      results,
      lat,
      lon
    };
    // Prune entries older than TTL
    for (const k of Object.keys(allCache)) {
      if (Date.now() - allCache[k].timestamp > CACHE_TTL_MS) delete allCache[k];
    }
    localStorage.setItem(OVERPASS_CACHE_KEY, JSON.stringify(allCache));
    console.log(`[OverpassCache] Cached ${results.length} results for (${lat}, ${lon})`);
  } catch (e) {
    console.warn('[OverpassCache] Could not cache results:', e);
  }
}

/**
 * Retrieve cached Overpass results for a location (if fresh).
 * @param {number} lat
 * @param {number} lon
 * @returns {Array|null} cached results or null if expired/missing
 */
export function getCachedOverpassResults(lat, lon) {
  const key = getLocationBucketKey(lat, lon);
  const allCache = getFullCache();
  const entry = allCache[key];
  if (!entry) return null;
  if (Date.now() - entry.timestamp > CACHE_TTL_MS) {
    console.log('[OverpassCache] Cache expired for:', key);
    return null;
  }
  console.log(`[OverpassCache] Cache HIT: ${entry.results.length} results (${Math.round((Date.now()-entry.timestamp)/1000)}s old)`);
  return entry.results;
}

/**
 * Clear all cached Overpass results.
 */
export function clearOverpassCache() {
  localStorage.removeItem(OVERPASS_CACHE_KEY);
  console.log('[OverpassCache] Cache cleared');
}

function getFullCache() {
  try {
    return JSON.parse(localStorage.getItem(OVERPASS_CACHE_KEY) || '{}');
  } catch (_) {
    return {};
  }
}
