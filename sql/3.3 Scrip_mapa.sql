-- =====================================================
-- 🗺️ SISTEMA DE MAPA Y UBICACIONES DE REFUGIOS
-- =====================================================
-- Sistema simplificado: SOLO user_id, coordenadas y dirección
-- Toda la info del refugio (phone, email, description, website)
-- se obtiene desde user_profiles mediante user_id
-- =====================================================

-- =====================================================
-- 1. TABLA: shelter_locations (Ubicaciones de Refugios)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.shelter_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  address TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  -- Validaciones
  CONSTRAINT valid_latitude CHECK (latitude >= -90 AND latitude <= 90),
  CONSTRAINT valid_longitude CHECK (longitude >= -180 AND longitude <= 180),
  CONSTRAINT one_location_per_user UNIQUE (user_id)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_shelter_locations_coords ON public.shelter_locations (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_shelter_locations_user_id ON public.shelter_locations (user_id);
CREATE INDEX IF NOT EXISTS idx_shelter_locations_active ON public.shelter_locations (is_active);

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_shelter_locations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_shelter_locations_updated_at_trigger
  BEFORE UPDATE ON public.shelter_locations
  FOR EACH ROW
  EXECUTE FUNCTION update_shelter_locations_updated_at();

-- Comentarios
COMMENT ON TABLE public.shelter_locations IS 'Ubicaciones geográficas de refugios - Info del refugio viene de user_profiles';
COMMENT ON COLUMN public.shelter_locations.user_id IS 'Usuario dueño del refugio (rol=refugio)';
COMMENT ON COLUMN public.shelter_locations.latitude IS 'Latitud en grados decimales (-90 a 90)';
COMMENT ON COLUMN public.shelter_locations.longitude IS 'Longitud en grados decimales (-180 a 180)';
COMMENT ON COLUMN public.shelter_locations.is_active IS 'Si la ubicación está activa y visible en el mapa';

-- =====================================================
-- 2. DATOS DE PRUEBA (Seeds)
-- =====================================================
INSERT INTO public.shelter_locations (user_id, latitude, longitude, address, is_active) VALUES
  ('57aa2cd5-7f40-47c1-9c94-9a56c6a4eba5', -0.1807, -78.4678, 'Avenida de los Shyris 456, Quito, Ecuador', true),
  ('29b572c9-7e32-48a6-b427-b5a6fa248799', -0.2298, -78.5249, 'Calle de las Flores 123, Quito, Ecuador', true)
ON CONFLICT (user_id) DO UPDATE SET
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  address = EXCLUDED.address,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now());

-- =====================================================
-- 3. FUNCIÓN: Calcular distancia entre dos puntos GPS
-- =====================================================
CREATE OR REPLACE FUNCTION calculate_distance(
  lat1 DOUBLE PRECISION,
  lon1 DOUBLE PRECISION,
  lat2 DOUBLE PRECISION,
  lon2 DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION AS $$
DECLARE
  R DOUBLE PRECISION := 6371; -- Radio de la Tierra en km
  dLat DOUBLE PRECISION;
  dLon DOUBLE PRECISION;
  a DOUBLE PRECISION;
  c DOUBLE PRECISION;
BEGIN
  dLat := radians(lat2 - lat1);
  dLon := radians(lon2 - lon1);
  
  a := sin(dLat/2) * sin(dLat/2) +
       cos(radians(lat1)) * cos(radians(lat2)) *
       sin(dLon/2) * sin(dLon/2);
  
  c := 2 * atan2(sqrt(a), sqrt(1-a));
  
  RETURN R * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_distance IS 'Calcula distancia en km usando fórmula de Haversine';

-- =====================================================
-- 4. FUNCIÓN: Obtener refugios cercanos con info de usuario
-- =====================================================
CREATE OR REPLACE FUNCTION get_nearby_shelters(
  user_lat DOUBLE PRECISION,
  user_lon DOUBLE PRECISION,
  radius_km DOUBLE PRECISION DEFAULT 50.0
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  shelter_name TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  address TEXT,
  phone TEXT,
  email TEXT,
  avatar_url TEXT,
  distance_km DOUBLE PRECISION
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    sl.id,
    sl.user_id,
    up.full_name AS shelter_name,
    sl.latitude,
    sl.longitude,
    sl.address,
    up.phone,
    up.email,
    up.avatar_url,
    calculate_distance(user_lat, user_lon, sl.latitude, sl.longitude) AS distance_km
  FROM public.shelter_locations sl
  INNER JOIN public.user_profiles up ON sl.user_id = up.id
  WHERE sl.is_active = true
    AND up.role = 'refugio'
    AND calculate_distance(user_lat, user_lon, sl.latitude, sl.longitude) <= radius_km
  ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_nearby_shelters IS 'Obtiene refugios activos dentro de un radio (en km) con info de user_profiles';

-- =====================================================
-- 5. FUNCIÓN: Obtener MI ubicación de refugio
-- =====================================================
CREATE OR REPLACE FUNCTION get_my_shelter_location()
RETURNS TABLE (
  id UUID,
  user_id UUID,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  address TEXT,
  is_active BOOLEAN,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    sl.id,
    sl.user_id,
    sl.latitude,
    sl.longitude,
    sl.address,
    sl.is_active,
    sl.created_at,
    sl.updated_at
  FROM public.shelter_locations sl
  WHERE sl.user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_my_shelter_location IS 'Obtiene la ubicación del refugio del usuario autenticado';

-- =====================================================
-- 6. POLÍTICAS RLS PARA shelter_locations
-- =====================================================
ALTER TABLE public.shelter_locations ENABLE ROW LEVEL SECURITY;

-- ✅ ADOPTANTES: Pueden ver todas las ubicaciones activas
CREATE POLICY "Adoptantes can view active shelter locations"
  ON public.shelter_locations
  FOR SELECT
  USING (
    is_active = true
    AND EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role = 'adoptante'
    )
  );

-- ✅ REFUGIOS: Pueden ver TODAS las ubicaciones
CREATE POLICY "Refugios can view all shelter locations"
  ON public.shelter_locations
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role = 'refugio'
    )
  );

-- ✅ REFUGIOS: Solo pueden crear SU PROPIA ubicación
CREATE POLICY "Refugios can create own location"
  ON public.shelter_locations
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role = 'refugio'
    )
  );

-- ✅ REFUGIOS: Solo pueden actualizar SU PROPIA ubicación
CREATE POLICY "Refugios can update own location"
  ON public.shelter_locations
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ✅ REFUGIOS: Solo pueden eliminar SU PROPIA ubicación
CREATE POLICY "Refugios can delete own location"
  ON public.shelter_locations
  FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- 7. VERIFICACIÓN: Consultas de ejemplo
-- =====================================================

-- Ver MI ubicación (si soy refugio)
-- SELECT * FROM get_my_shelter_location();

-- Buscar refugios cercanos a Quito en un radio de 50km
-- SELECT * FROM get_nearby_shelters(-0.1807, -78.4678, 50.0);

-- Calcular distancia entre dos puntos en Quito
-- SELECT calculate_distance(-0.1807, -78.4678, -0.2298, -78.5249) as distancia_km;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================
