import React, { useEffect, useState, useRef } from 'react';
import {
  View,
  Text,
  Alert,
  Linking,
  Platform,
  PermissionsAndroid,
  TouchableOpacity,
  ScrollView,
  TextInput,
  StyleSheet,
  Dimensions,
} from 'react-native';
import MapView, { Marker, Callout, PROVIDER_GOOGLE } from 'react-native-maps';
import Geolocation from 'react-native-geolocation-service';
import { createClient } from '@supabase/supabase-js';
import {
  List,
  Card,
  Button,
  Tag,
  Spin,
  NavBar,
  Toast,
} from 'antd-mobile-rn'; // Ant Design Mobile v5 React Native interface

// ============================================================================
// TYPES & INTERFACES
// ============================================================================
export interface Vet {
  id: string;
  name: string;
  address: string;
  phone: string;
  website?: string | null;
  is_verified: boolean;
  is_24x7: boolean;
  rating: number;
  distance_km: number;
  vet_lat: number;
  vet_lng: number;
}

export interface UserLocation {
  latitude: number;
  longitude: number;
}

// ============================================================================
// SUPABASE CLIENT INITIALIZATION
// Replace with your actual Supabase Project URL and Anon Key
// ============================================================================
const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL || process.env.VITE_SUPABASE_URL || '';
const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || process.env.VITE_SUPABASE_ANON_KEY || '';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const SCREEN_HEIGHT = Dimensions.get('window').height;

// ============================================================================
// MAIN COMPONENT: FindVetsNearbyScreen
// ============================================================================
export const FindVetsNearbyScreen: React.FC = () => {
  const [userLocation, setUserLocation] = useState<UserLocation | null>(null);
  const [vets, setVets] = useState<Vet[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [permissionDenied, setPermissionDenied] = useState<boolean>(false);
  const [manualPincode, setManualPincode] = useState<string>('');
  const [isManualMode, setIsManualMode] = useState<boolean>(false);
  const [selectedVetId, setSelectedVetId] = useState<string | null>(null);

  const mapRef = useRef<MapView | null>(null);

  // --------------------------------------------------------------------------
  // 1. LIFECYCLE: Request Location Permission & Get Location on Mount
  // --------------------------------------------------------------------------
  useEffect(() => {
    getUserLocation();
  }, []);

  // --------------------------------------------------------------------------
  // 2. LOCATION PERMISSION & GPS FETCHING
  // --------------------------------------------------------------------------
  const requestLocationPermission = async (): Promise<boolean> => {
    if (Platform.OS === 'android') {
      try {
        const granted = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
          {
            title: 'PashuRakhshak Location Permission',
            message:
              'PashuRakhshak needs access to your GPS location to find the nearest veterinary hospitals for emergency care.',
            buttonNeutral: 'Ask Me Later',
            buttonNegative: 'Cancel',
            buttonPositive: 'OK',
          }
        );
        return granted === PermissionsAndroid.RESULTS.GRANTED;
      } catch (err) {
        console.warn('Location permission request error:', err);
        return false;
      }
    } else if (Platform.OS === 'ios') {
      const auth = await Geolocation.requestAuthorization('whenInUse');
      return auth === 'granted';
    }
    return true;
  };

  const getUserLocation = async () => {
    setLoading(true);
    setPermissionDenied(false);

    const hasPermission = await requestLocationPermission();

    if (!hasPermission) {
      setPermissionDenied(true);
      setLoading(false);
      Toast.show({
        content: 'Location permission denied. You can search manually by Pincode.',
        duration: 3000,
      });
      return;
    }

    Geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        const coords = { latitude, longitude };
        setUserLocation(coords);

        // Fetch nearest vets using PostGIS RPC
        fetchNearbyVets(latitude, longitude);
      },
      (error) => {
        console.error('GPS Location Error:', error);
        setPermissionDenied(true);
        setLoading(false);
        Alert.alert(
          'GPS Error',
          'Failed to retrieve GPS location. Please check location settings or enter Pincode manually.'
        );
      },
      {
        enableHighAccuracy: true,
        timeout: 15000,
        maximumAge: 10000,
      }
    );
  };

  // --------------------------------------------------------------------------
  // 3. SUPABASE POSTGIS RPC CALL: get_nearby_vets
  // --------------------------------------------------------------------------
  const fetchNearbyVets = async (lat: number, lng: number, radiusMeters: number = 10000) => {
    try {
      setLoading(true);

      const { data, error } = await supabase.rpc('get_nearby_vets', {
        user_lat: lat,
        user_lng: lng,
        radius_meters: radiusMeters,
      });

      if (error) {
        console.error('Supabase RPC Error:', error);
        Toast.show({ content: 'Error loading nearby vets: ' + error.message });
      } else if (data) {
        setVets(data as Vet[]);
        if (data.length === 0) {
          Toast.show({ content: 'No veterinary hospitals found within 10 km radius.' });
        }
      }
    } catch (err) {
      console.error('Unexpected error fetching vets:', err);
    } finally {
      setLoading(false);
    }
  };

  // --------------------------------------------------------------------------
  // 4. MANUAL PINCODE / LOCATION FALLBACK
  // --------------------------------------------------------------------------
  const handleManualPincodeSearch = () => {
    if (!manualPincode.trim() || manualPincode.length < 6) {
      Alert.alert('Invalid Pincode', 'Please enter a valid 6-digit Indian Pincode.');
      return;
    }

    // Default fallback coordinates (e.g. New Delhi Central) for demonstration
    const fallbackLat = 28.6139;
    const fallbackLng = 77.2090;

    setUserLocation({ latitude: fallbackLat, longitude: fallbackLng });
    setIsManualMode(false);
    fetchNearbyVets(fallbackLat, fallbackLng);
  };

  // --------------------------------------------------------------------------
  // 5. HELPER ACTIONS (Call, Directions, Website)
  // --------------------------------------------------------------------------
  const handleCall = (phone: string) => {
    const url = `tel:${phone}`;
    Linking.openURL(url).catch(() => {
      Alert.alert('Error', 'Unable to initiate call from this device.');
    });
  };

  const handleDirections = (lat: number, lng: number, name: string) => {
    const url = `https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}&destination_place_id=${encodeURIComponent(
      name
    )}`;
    Linking.openURL(url).catch(() => {
      Alert.alert('Error', 'Could not open Google Maps.');
    });
  };

  const handleOpenWebsite = (website?: string | null) => {
    if (!website) {
      Toast.show({ content: 'No official website listed for this hospital.' });
      return;
    }
    const formattedUrl = website.startsWith('http') ? website : `https://${website}`;
    Linking.openURL(formattedUrl).catch(() => {
      Alert.alert('Error', 'Could not open website URL.');
    });
  };

  const focusMapOnVet = (vet: Vet) => {
    setSelectedVetId(vet.id);
    mapRef.current?.animateToRegion(
      {
        latitude: vet.vet_lat,
        longitude: vet.vet_lng,
        latitudeDelta: 0.02,
        longitudeDelta: 0.02,
      },
      800
    );
  };

  // --------------------------------------------------------------------------
  // 6. RENDER ERROR / PERMISSION DENIED STATE
  // --------------------------------------------------------------------------
  if (permissionDenied || isManualMode) {
    return (
      <View className="flex-1 bg-slate-50 justify-center items-center p-6">
        <NavBar back={null} className="w-full bg-emerald-700 text-white mb-6">
          Find Help & Vets Nearby
        </NavBar>

        <View className="bg-white p-6 rounded-2xl shadow-md w-full max-w-sm border border-slate-100 items-center">
          <Text className="text-4xl mb-2">📍</Text>
          <Text className="text-xl font-bold text-slate-800 text-center mb-2">
            Location Access Needed
          </Text>
          <Text className="text-slate-500 text-center text-sm mb-6">
            We need location access to find emergency veterinary care near you via PostGIS spatial queries.
          </Text>

          <View className="w-full mb-4">
            <Text className="text-xs font-semibold text-slate-700 uppercase mb-1">
              Enter Pincode Manually
            </Text>
            <TextInput
              placeholder="e.g. 110001 or 560001"
              value={manualPincode}
              onChangeText={setManualPincode}
              keyboardType="numeric"
              maxLength={6}
              className="bg-slate-100 border border-slate-300 rounded-xl px-4 py-3 text-slate-800 font-medium text-base"
            />
          </View>

          <Button
            type="primary"
            color="success"
            block
            shape="rounded"
            onPress={handleManualPincodeSearch}
            className="mb-3"
          >
            Search by Pincode
          </Button>

          <Button
            type="default"
            block
            shape="rounded"
            onPress={getUserLocation}
          >
            Try GPS Again 🔄
          </Button>
        </View>
      </View>
    );
  }

  // --------------------------------------------------------------------------
  // 7. RENDER MAIN SCREEN
  // --------------------------------------------------------------------------
  return (
    <View className="flex-1 bg-slate-100">
      {/* TOP NAV BAR */}
      <NavBar
        back={null}
        right={
          <Tag color="success" fill="outline" className="font-bold border-emerald-600">
            ⚡ PostGIS Active
          </Tag>
        }
        className="bg-emerald-800 text-white font-bold"
      >
        <Text className="text-white font-bold text-lg">Find Help & Vets Nearby</Text>
      </NavBar>

      {/* LOADING OVERLAY */}
      {loading && (
        <View className="absolute inset-0 z-50 bg-white/80 justify-center items-center">
          <Spin loading text="Finding vets near you..." size="large" />
          <Text className="mt-4 text-emerald-800 font-semibold text-sm">
            Executing PostGIS ST_DWithin Query...
          </Text>
        </View>
      )}

      {/* TOP HALF: MAP VIEW */}
      <View style={{ height: SCREEN_HEIGHT * 0.38 }} className="w-full relative shadow-sm">
        {userLocation ? (
          <MapView
            ref={mapRef}
            provider={PROVIDER_GOOGLE}
            className="w-full h-full"
            initialRegion={{
              latitude: userLocation.latitude,
              longitude: userLocation.longitude,
              latitudeDelta: 0.0922,
              longitudeDelta: 0.0421,
            }}
            showsUserLocation
            showsMyLocationButton
          >
            {/* User Location Marker */}
            <Marker
              coordinate={{
                latitude: userLocation.latitude,
                longitude: userLocation.longitude,
              }}
              title="Your Location"
              description="Current GPS Position"
              pinColor="blue"
            />

            {/* Nearby Vet Markers */}
            {vets.map((vet) => (
              <Marker
                key={vet.id}
                coordinate={{
                  latitude: vet.vet_lat,
                  longitude: vet.vet_lng,
                }}
                pinColor={vet.is_24x7 ? 'red' : 'green'}
                onPress={() => setSelectedVetId(vet.id)}
              >
                <Callout onPress={() => handleDirections(vet.vet_lat, vet.vet_lng, vet.name)}>
                  <View className="p-2 min-w-[150px]">
                    <Text className="font-bold text-slate-900 text-sm">{vet.name}</Text>
                    <Text className="text-xs text-emerald-700 font-semibold mt-1">
                      📍 {vet.distance_km} km away
                    </Text>
                    <Text className="text-xs text-amber-600 mt-1">⭐ {vet.rating} / 5.0</Text>
                  </View>
                </Callout>
              </Marker>
            ))}
          </MapView>
        ) : (
          <View className="w-full h-full bg-slate-200 justify-center items-center">
            <Text className="text-slate-500 font-medium">Acquiring GPS Signal...</Text>
          </View>
        )}
      </View>

      {/* BOTTOM HALF: VETS LIST */}
      <View className="flex-1 bg-slate-50 border-t border-slate-200">
        <View className="flex-row justify-between items-center px-4 py-3 bg-white border-b border-slate-200">
          <Text className="text-slate-800 font-bold text-base">
            Nearest Hospitals ({vets.length})
          </Text>

          <TouchableOpacity onPress={getUserLocation}>
            <Text className="text-emerald-700 font-semibold text-xs">Refresh GPS 🔄</Text>
          </TouchableOpacity>
        </View>

        <ScrollView className="flex-1 p-3">
          <List className="bg-transparent">
            {vets.length === 0 && !loading ? (
              <View className="py-12 items-center justify-center">
                <Text className="text-4xl mb-2">🏥</Text>
                <Text className="text-slate-600 font-semibold text-base">
                  No Veterinary Hospitals Found
                </Text>
                <Text className="text-slate-400 text-xs mt-1 text-center px-6">
                  Try expanding your search radius or search using a different location.
                </Text>
              </View>
            ) : (
              vets.map((vet) => {
                const isSelected = selectedVetId === vet.id;

                return (
                  <TouchableOpacity
                    key={vet.id}
                    activeOpacity={0.9}
                    onPress={() => focusMapOnVet(vet)}
                    className="mb-3"
                  >
                    <Card
                      headerStyle={{ borderBottomWidth: 0, paddingBottom: 0 }}
                      className={`rounded-2xl border ${
                        isSelected ? 'border-emerald-500 bg-emerald-50/30' : 'border-slate-200 bg-white'
                      } shadow-sm`}
                    >
                      {/* CARD HEADER: VET NAME & DISTANCE */}
                      <View className="flex-row justify-between items-start mb-1">
                        <View className="flex-1 pr-2">
                          <Text className="text-slate-900 font-bold text-base">{vet.name}</Text>
                        </View>

                        <View className="bg-emerald-100 px-2 py-1 rounded-full">
                          <Text className="text-emerald-800 font-bold text-xs">
                            {vet.distance_km} km away
                          </Text>
                        </View>
                      </View>

                      {/* ADDRESS */}
                      <Text className="text-slate-600 text-xs mb-2 leading-relaxed">
                        📍 {vet.address}
                      </Text>

                      {/* TAGS & RATING */}
                      <View className="flex-row items-center flex-wrap gap-1.5 mb-3">
                        {vet.is_verified && (
                          <Tag color="success" fill="outline" className="text-xs font-semibold">
                            ✓ Verified
                          </Tag>
                        )}

                        {vet.is_24x7 && (
                          <Tag color="warning" className="text-xs font-semibold">
                            🚨 24x7 Emergency
                          </Tag>
                        )}

                        <View className="flex-row items-center bg-amber-50 px-2 py-0.5 rounded border border-amber-200 ml-auto">
                          <Text className="text-amber-600 text-xs font-bold mr-1">
                            ⭐ {vet.rating}
                          </Text>
                          <Text className="text-amber-500 text-[10px]">(5.0)</Text>
                        </View>
                      </View>

                      {/* ACTION BUTTONS */}
                      <View className="flex-row justify-between items-center pt-2 border-t border-slate-100 gap-2">
                        <Button
                          type="primary"
                          color="success"
                          size="mini"
                          shape="rounded"
                          onPress={() => handleCall(vet.phone)}
                          className="flex-1"
                        >
                          📞 Call
                        </Button>

                        <Button
                          type="default"
                          size="mini"
                          shape="rounded"
                          onPress={() => handleDirections(vet.vet_lat, vet.vet_lng, vet.name)}
                          className="flex-1 border-emerald-600 text-emerald-700"
                        >
                          🗺️ Directions
                        </Button>

                        <Button
                          type="default"
                          size="mini"
                          shape="rounded"
                          disabled={!vet.website}
                          onPress={() => handleOpenWebsite(vet.website)}
                          className="flex-1"
                        >
                          🌐 Website
                        </Button>
                      </View>
                    </Card>
                  </TouchableOpacity>
                );
              })
            )}
          </List>
        </ScrollView>
      </View>
    </View>
  );
};

export default FindVetsNearbyScreen;
