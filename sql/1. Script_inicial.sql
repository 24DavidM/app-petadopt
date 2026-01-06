
BEGIN;

-- 1. LIMPIEZA SEGURA (Solo borramos triggers de tablas del sistema como auth.users)
-- Los triggers de tus tablas se borrarán solos al hacer DROP TABLE CASCADE
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. BORRAR OBJETOS EXISTENTES (Orden correcto)
-- CASCADE se encarga de borrar las FKs, Triggers y Policies asociadas
DROP VIEW IF EXISTS public.users_with_profiles CASCADE;
DROP VIEW IF EXISTS public.animals_with_shelter_info CASCADE;

DROP TABLE IF EXISTS public.adoption_requests CASCADE;
DROP TABLE IF EXISTS public.animals CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;

-- 3. BORRAR FUNCIONES (Después de las tablas para evitar dependencias huerfanas)
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.handle_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.sync_user_role(UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.check_animal_deletion() CASCADE;
DROP FUNCTION IF EXISTS public.has_active_adoption_requests(UUID) CASCADE;

-- 4. CREAR BUCKET DE IMÁGENES (Si no existe)
INSERT INTO storage.buckets (id, name, public)
VALUES ('animal_images', 'animal_images', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 5. CREACIÓN DE TABLAS
-- ============================================

-- A. Perfiles
CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  phone TEXT,
  role TEXT CHECK (role IN ('adoptante', 'refugio')),
  provider TEXT DEFAULT 'email',
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- B. Animales
CREATE TABLE public.animals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  species TEXT NOT NULL CHECK (species IN ('Perro', 'Gato', 'Conejo', 'Hámster', 'Ave', 'Reptil', 'Peces', 'Hurón', 'Chinchilla', 'Cobaya', 'Tortuga', 'Erizo', 'Otro')),
  breed TEXT,
  age TEXT CHECK (age IN ('Cachorro', 'Joven', 'Adulto', 'Senior', 'No especificado')),
  gender TEXT CHECK (gender IN ('Macho', 'Hembra', 'No especificado')),
  size TEXT CHECK (size IN ('Pequeño', 'Mediano', 'Grande', 'No aplica')),
  description TEXT,
  personality TEXT[] DEFAULT '{}',
  health_status TEXT[] DEFAULT '{}',
  notes TEXT,
  image_urls TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'available' CHECK (status IN ('available', 'adopted', 'pending')),
  shelter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  distance TEXT DEFAULT '0 km',
  views_count INTEGER DEFAULT 0,
  likes_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- C. Solicitudes
CREATE TABLE public.adoption_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  animal_id UUID NOT NULL REFERENCES public.animals(id) ON DELETE CASCADE,
  adopter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  shelter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  -- Se elimina la constraint que incluía `status` porque impedía recrear solicitudes rechazadas
  -- Ahora se crea un índice parcial más abajo para evitar solicitudes activas duplicadas
);

-- Índice único parcial: previene múltiples solicitudes activas (pendientes o aprobadas)
CREATE UNIQUE INDEX IF NOT EXISTS unique_active_request ON public.adoption_requests (animal_id, adopter_id) WHERE status IN ('pending', 'approved');

-- ============================================
-- 6. SEGURIDAD (RLS)
-- ============================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.adoption_requests ENABLE ROW LEVEL SECURITY;

-- Policies: Perfiles
CREATE POLICY "Ver perfil propio" ON public.user_profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Ver perfiles refugio" ON public.user_profiles FOR SELECT USING (role = 'refugio');
CREATE POLICY "Refugio ve adoptantes con solicitudes" ON public.user_profiles FOR SELECT USING (
  role = 'adoptante' AND EXISTS (
    SELECT 1 FROM public.adoption_requests 
    WHERE adopter_id = user_profiles.id 
    AND shelter_id = auth.uid()
  )
);
CREATE POLICY "Actualizar perfil propio" ON public.user_profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Insertar perfil propio" ON public.user_profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Policies: Animales
CREATE POLICY "Ver animales" ON public.animals FOR SELECT USING (status = 'available' OR auth.uid() = shelter_id);
CREATE POLICY "Refugio crea animales" ON public.animals FOR INSERT WITH CHECK (auth.uid() = shelter_id AND EXISTS (SELECT 1 FROM public.user_profiles WHERE id = auth.uid() AND role = 'refugio'));
CREATE POLICY "Refugio edita animales" ON public.animals FOR UPDATE USING (auth.uid() = shelter_id);
CREATE POLICY "Refugio borra animales" ON public.animals FOR DELETE USING (auth.uid() = shelter_id);

-- Policies: Solicitudes
CREATE POLICY "Ver solicitudes" ON public.adoption_requests FOR SELECT USING (auth.uid() = adopter_id OR auth.uid() = shelter_id);
CREATE POLICY "Crear solicitud" ON public.adoption_requests FOR INSERT WITH CHECK (auth.uid() = adopter_id AND EXISTS (SELECT 1 FROM public.user_profiles WHERE id = auth.uid() AND role = 'adoptante'));
CREATE POLICY "Refugio gestiona" ON public.adoption_requests FOR UPDATE USING (auth.uid() = shelter_id);
CREATE POLICY "Adoptante cancela" ON public.adoption_requests FOR UPDATE USING (auth.uid() = adopter_id AND status = 'pending');

-- ============================================
-- 7. FUNCIONES Y TRIGGERS
-- ============================================

-- A. Función Updated At
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_animals_updated_at BEFORE UPDATE ON public.animals FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_adoption_requests_updated_at BEFORE UPDATE ON public.adoption_requests FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- B. Función Nuevo Usuario (Auth -> Profile)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER SECURITY DEFINER SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
  extracted_role TEXT;
BEGIN
  extracted_role := NEW.raw_user_meta_data->>'role';
  -- Solo asignar rol si viene en los metadatos
  -- Si no viene, dejar NULL para que el usuario lo seleccione luego
  IF extracted_role IS NOT NULL AND extracted_role IN ('adoptante', 'refugio') THEN
    -- El rol viene en metadatos
  ELSE
    -- No asignar rol automáticamente
    extracted_role := NULL;
  END IF;

  INSERT INTO public.user_profiles (id, email, full_name, provider, avatar_url, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_app_meta_data->>'provider', 'email'),
    NEW.raw_user_meta_data->>'avatar_url',
    extracted_role
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- C. Regla de Negocio: No borrar si hay solicitudes
CREATE OR REPLACE FUNCTION public.check_animal_deletion()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.adoption_requests WHERE animal_id = OLD.id AND status IN ('pending', 'approved')) THEN
    RAISE EXCEPTION 'No puedes eliminar esta mascota porque tiene solicitudes activas.';
  END IF;
  RETURN OLD;
END;
$$;

CREATE TRIGGER check_animal_has_no_requests BEFORE DELETE ON public.animals FOR EACH ROW EXECUTE FUNCTION public.check_animal_deletion();

-- D. Función RPC para verificar solicitudes activas
CREATE OR REPLACE FUNCTION public.has_active_adoption_requests(animal_uuid UUID)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM public.adoption_requests 
    WHERE animal_id = animal_uuid 
    AND status IN ('pending', 'approved')
  );
END;
$$;

-- E. Función para sincronizar rol
CREATE OR REPLACE FUNCTION public.sync_user_role(user_id UUID, new_role TEXT)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE public.user_profiles 
  SET role = new_role, updated_at = NOW() 
  WHERE id = user_id;
END;
$$;

-- ============================================
-- 8. POLÍTICAS DE STORAGE
-- ============================================
DROP POLICY IF EXISTS "Storage Insert Refugio" ON storage.objects;
DROP POLICY IF EXISTS "Storage Update Refugio" ON storage.objects;
DROP POLICY IF EXISTS "Storage Delete Refugio" ON storage.objects;
DROP POLICY IF EXISTS "Storage Select Public" ON storage.objects;

CREATE POLICY "Storage Insert Refugio" ON storage.objects FOR INSERT TO authenticated 
  WITH CHECK (bucket_id = 'animal_images' AND EXISTS (SELECT 1 FROM public.user_profiles WHERE id = auth.uid() AND role = 'refugio'));
CREATE POLICY "Storage Update Refugio" ON storage.objects FOR UPDATE TO authenticated 
  USING (bucket_id = 'animal_images' AND owner = auth.uid());
CREATE POLICY "Storage Delete Refugio" ON storage.objects FOR DELETE TO authenticated 
  USING (bucket_id = 'animal_images' AND owner = auth.uid());
CREATE POLICY "Storage Select Public" ON storage.objects FOR SELECT TO public 
  USING (bucket_id = 'animal_images');

-- 9. VISTA DE AYUDA
CREATE OR REPLACE VIEW public.users_with_profiles AS
SELECT u.id, u.email, p.full_name, p.role 
FROM auth.users u 
LEFT JOIN public.user_profiles p ON u.id = p.id;

COMMIT;

SELECT 'CORRECCION APLICADA: TABLAS RE-CREADAS EXITOSAMENTE' as status;