    -- =====================================================
    -- SQL FUNCIONALIDADES: FAVORITOS Y VISUALIZACIONES
    -- =====================================================

    -- =====================================================
    -- 1. TABLA: favorites (Mascotas favoritas)
    -- =====================================================
    CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    animal_id UUID NOT NULL REFERENCES public.animals(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Un usuario solo puede marcar como favorita una mascota una vez
    CONSTRAINT unique_user_animal_favorite UNIQUE (user_id, animal_id)
    );

    -- Índices
    CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites (user_id);
    CREATE INDEX IF NOT EXISTS idx_favorites_animal_id ON public.favorites (animal_id);

    -- RLS Policies
    ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

    CREATE POLICY "Users can view own favorites"
    ON public.favorites FOR SELECT
    USING (auth.uid() = user_id);

    CREATE POLICY "Users can insert own favorites"
    ON public.favorites FOR INSERT
    WITH CHECK (auth.uid() = user_id);

    CREATE POLICY "Users can delete own favorites"
    ON public.favorites FOR DELETE
    USING (auth.uid() = user_id);

    -- =====================================================
    -- 2. TABLA: animal_views (Visualizaciones de mascotas)
    -- =====================================================
    CREATE TABLE IF NOT EXISTS public.animal_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Puede ser nulo si permitimos anónimos, pero idealmente auth
    animal_id UUID NOT NULL REFERENCES public.animals(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
    );

    -- Índices
    CREATE INDEX IF NOT EXISTS idx_animal_views_animal_id ON public.animal_views (animal_id);
    CREATE INDEX IF NOT EXISTS idx_animal_views_created_at ON public.animal_views (created_at);

    -- RLS Policies
    ALTER TABLE public.animal_views ENABLE ROW LEVEL SECURITY;

    -- Todos pueden insertar vistas (incluso anónimos si se permite, pero aquí restringimos a auth por seguridad básica)
    CREATE POLICY "Authenticated users can insert views"
    ON public.animal_views FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

    -- Solo refugios (dueños de los animales) deberían ver las estadísticas, o todos?
    -- Por ahora permitimos ver a todos para simplificar, o restringir si es necesario.
    CREATE POLICY "Everyone can view views count"
    ON public.animal_views FOR SELECT
    USING (true);

    -- =====================================================
    -- 3. VISTA: animal_stats (Estadísticas agregadas)
    -- =====================================================
    CREATE OR REPLACE VIEW public.animal_stats AS
    SELECT 
    a.id AS animal_id,
    COUNT(DISTINCT f.user_id) AS favorites_count,
    COUNT(v.id) AS views_count
    FROM public.animals a
    LEFT JOIN public.favorites f ON a.id = f.animal_id
    LEFT JOIN public.animal_views v ON a.id = v.animal_id
    GROUP BY a.id;

    COMMENT ON VIEW public.animal_stats IS 'Estadísticas de favoritos y visualizaciones por mascota';
