-- =====================================================
-- 💬 SISTEMA DE CHAT CON IA
-- =====================================================
-- Sistema independiente para historial de conversaciones con IA
-- =====================================================

-- =====================================================
-- 1. TABLA: chat_history (Historial de Chat con IA)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.chat_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  is_user_message BOOLEAN NOT NULL DEFAULT true,
  ai_response TEXT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  CONSTRAINT chat_history_message_length CHECK (char_length(message) > 0 AND char_length(message) <= 5000),
  CONSTRAINT chat_history_response_length CHECK (ai_response IS NULL OR char_length(ai_response) <= 10000)
);

-- Índices para consultas rápidas
CREATE INDEX IF NOT EXISTS idx_chat_history_user_id ON public.chat_history (user_id);
CREATE INDEX IF NOT EXISTS idx_chat_history_created_at ON public.chat_history (created_at DESC);

-- Comentarios
COMMENT ON TABLE public.chat_history IS 'Historial de conversaciones con la IA';
COMMENT ON COLUMN public.chat_history.is_user_message IS 'true si es mensaje del usuario, false si es respuesta de la IA';

-- =====================================================
-- 2. POLÍTICAS RLS PARA chat_history
-- =====================================================
ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;

-- Los usuarios solo pueden ver su propio historial
CREATE POLICY "Users can view own chat history"
  ON public.chat_history
  FOR SELECT
  USING (auth.uid() = user_id);

-- Los usuarios solo pueden crear su propio historial
CREATE POLICY "Users can create own chat history"
  ON public.chat_history
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Los usuarios solo pueden actualizar su propio historial
CREATE POLICY "Users can update own chat history"
  ON public.chat_history
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Los usuarios solo pueden eliminar su propio historial
CREATE POLICY "Users can delete own chat history"
  ON public.chat_history
  FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- 3. FUNCIÓN: Limpiar historial antiguo
-- =====================================================
CREATE OR REPLACE FUNCTION cleanup_old_chat_history()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM public.chat_history
  WHERE created_at < (timezone('utc'::text, now()) - INTERVAL '30 days');
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cleanup_old_chat_history IS 'Elimina mensajes de chat con más de 30 días';

-- =====================================================
-- 4. VERIFICACIÓN: Consultas de ejemplo
-- =====================================================

-- Ver historial de chat del usuario autenticado
-- SELECT * FROM public.chat_history WHERE user_id = auth.uid() ORDER BY created_at DESC;

-- Limpiar historial antiguo
-- SELECT cleanup_old_chat_history();

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================
