-- =====================================================
-- SISTEMA DE ADOPCIÓN CON ESTADOS AUTOMÁTICOS Y NOTIFICACIONES
-- =====================================================

-- 1. Crear tabla de notificaciones
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL, -- 'new_request', 'request_approved', 'request_rejected'
  related_id UUID, -- ID de la solicitud o animal relacionado
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para notificaciones
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);

-- Habilitar RLS en notificaciones
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Política: Ver solo sus propias notificaciones
CREATE POLICY "Ver notificaciones propias" ON public.notifications 
  FOR SELECT USING (auth.uid() = user_id);

-- Política: Actualizar sus propias notificaciones (marcar como leída)
CREATE POLICY "Actualizar notificaciones propias" ON public.notifications 
  FOR UPDATE USING (auth.uid() = user_id);

-- =====================================================
-- 2. Función para cambiar estado del animal automáticamente
-- =====================================================
CREATE OR REPLACE FUNCTION public.update_animal_status_on_request()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Si la solicitud es NUEVA (pending), cambiar animal a "pending"
  IF (TG_OP = 'INSERT' AND NEW.status = 'pending') THEN
    UPDATE public.animals 
    SET status = 'pending', updated_at = NOW() 
    WHERE id = NEW.animal_id;
    
  -- Si la solicitud es APROBADA, cambiar animal a "adopted"
  ELSIF (NEW.status = 'approved' AND OLD.status != 'approved') THEN
    UPDATE public.animals 
    SET status = 'adopted', updated_at = NOW() 
    WHERE id = NEW.animal_id;
    
  -- Si la solicitud es RECHAZADA o CANCELADA, volver animal a "available"
  ELSIF (NEW.status IN ('rejected', 'cancelled') AND OLD.status = 'pending') THEN
    UPDATE public.animals 
    SET status = 'available', updated_at = NOW() 
    WHERE id = NEW.animal_id;
  END IF;
  
  RETURN NEW;
END;
$$;

-- =====================================================
-- 3. Función para enviar notificaciones
-- =====================================================
CREATE OR REPLACE FUNCTION public.send_adoption_notification()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_animal_name TEXT;
  v_adopter_name TEXT;
  v_shelter_id UUID;
BEGIN
  -- Obtener datos del animal y shelter
  SELECT name, shelter_id INTO v_animal_name, v_shelter_id
  FROM public.animals WHERE id = NEW.animal_id;
  
  -- Obtener nombre del adoptante
  SELECT full_name INTO v_adopter_name
  FROM public.user_profiles WHERE id = NEW.adopter_id;

  -- CASO 1: Nueva solicitud (notificar al refugio)
  IF (TG_OP = 'INSERT' AND NEW.status = 'pending') THEN
    INSERT INTO public.notifications (user_id, title, body, type, related_id)
    VALUES (
      v_shelter_id,
      '¡Nueva Solicitud de Adopción!',
      COALESCE(v_adopter_name, 'Un usuario') || ' quiere adoptar a ' || v_animal_name,
      'new_request',
      NEW.id
    );
    
  -- CASO 2: Solicitud aprobada (notificar al adoptante)
  ELSIF (NEW.status = 'approved' AND OLD.status != 'approved') THEN
    INSERT INTO public.notifications (user_id, title, body, type, related_id)
    VALUES (
      NEW.adopter_id,
      '¡Solicitud Aprobada! 🎉',
      'Tu solicitud para adoptar a ' || v_animal_name || ' ha sido aprobada',
      'request_approved',
      NEW.id
    );
    
  -- CASO 3: Solicitud rechazada (notificar al adoptante)
  ELSIF (NEW.status = 'rejected' AND OLD.status = 'pending') THEN
    INSERT INTO public.notifications (user_id, title, body, type, related_id)
    VALUES (
      NEW.adopter_id,
      'Solicitud No Aprobada',
      'Tu solicitud para adoptar a ' || v_animal_name || ' no fue aprobada',
      'request_rejected',
      NEW.id
    );
  END IF;
  
  RETURN NEW;
END;
$$;

-- =====================================================
-- 4. Función para validar solo UNA solicitud activa por animal
-- =====================================================
CREATE OR REPLACE FUNCTION public.check_active_request_before_insert()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  -- Verificar si ya existe una solicitud activa (pending o approved)
  IF EXISTS (
    SELECT 1 FROM public.adoption_requests 
    WHERE animal_id = NEW.animal_id 
    AND status IN ('pending', 'approved')
    AND id != NEW.id
  ) THEN
    RAISE EXCEPTION 'Este animal ya tiene una solicitud de adopción activa';
  END IF;
  
  -- Verificar que el animal esté disponible
  IF NOT EXISTS (
    SELECT 1 FROM public.animals 
    WHERE id = NEW.animal_id 
    AND status = 'available'
  ) THEN
    RAISE EXCEPTION 'Este animal no está disponible para adopción';
  END IF;
  
  RETURN NEW;
END;
$$;

-- =====================================================
-- 5. Crear TRIGGERS
-- =====================================================

-- Trigger para cambiar estado del animal (INSERT)
DROP TRIGGER IF EXISTS trigger_animal_status_on_insert ON public.adoption_requests;
CREATE TRIGGER trigger_animal_status_on_insert
  AFTER INSERT ON public.adoption_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.update_animal_status_on_request();

-- Trigger para cambiar estado del animal (UPDATE)
DROP TRIGGER IF EXISTS trigger_animal_status_on_update ON public.adoption_requests;
CREATE TRIGGER trigger_animal_status_on_update
  AFTER UPDATE ON public.adoption_requests
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION public.update_animal_status_on_request();

-- Trigger para enviar notificaciones (INSERT)
DROP TRIGGER IF EXISTS trigger_notification_on_request_insert ON public.adoption_requests;
CREATE TRIGGER trigger_notification_on_request_insert
  AFTER INSERT ON public.adoption_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.send_adoption_notification();

-- Trigger para enviar notificaciones (UPDATE)
DROP TRIGGER IF EXISTS trigger_notification_on_request_update ON public.adoption_requests;
CREATE TRIGGER trigger_notification_on_request_update
  AFTER UPDATE ON public.adoption_requests
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION public.send_adoption_notification();

-- Trigger para validar solicitud única (BEFORE INSERT)
DROP TRIGGER IF EXISTS trigger_check_active_request ON public.adoption_requests;
CREATE TRIGGER trigger_check_active_request
  BEFORE INSERT ON public.adoption_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.check_active_request_before_insert();

-- =====================================================
-- 6. Habilitar Realtime en tablas necesarias
-- =====================================================
-- Esto se hace desde el Dashboard de Supabase o con:
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.adoption_requests;

COMMENT ON TABLE public.notifications IS 'Tabla de notificaciones con Realtime habilitado';
COMMENT ON FUNCTION public.update_animal_status_on_request() IS 'Actualiza el estado del animal según el estado de la solicitud';
COMMENT ON FUNCTION public.send_adoption_notification() IS 'Envía notificaciones cuando cambia el estado de una solicitud';
COMMENT ON FUNCTION public.check_active_request_before_insert() IS 'Valida que solo haya una solicitud activa por animal';
