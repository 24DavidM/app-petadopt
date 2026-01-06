import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/message_model.dart';

abstract class GeminiDataSource {
  Future<MessageModel> sendMessage(String message);
}

class GeminiDataSourceImpl implements GeminiDataSource {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  GeminiDataSourceImpl() {
    final apiKey = ApiConstants.geminiApiKey;
    if (apiKey.isEmpty) {
      // Fallback o manejo de error si no hay API key
      print('⚠️ Warning: Gemini API Key is missing. Chat will not work.');
    }

    // Inicializar modelo Gemini con especialización en adopción de mascotas
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey.isNotEmpty
          ? apiKey
          : 'dummy_key', // Evitar crash inmediato si está vacío
      systemInstruction: Content.system(
        '''Eres un asistente virtual especializado en adopción de mascotas y cuidados veterinarios. 
  Responde preguntas de forma clara y amigable, pero **limita tus respuestas a 75 palabras o menos

TUS RESPONSABILIDADES:
1. Procesar consultas en lenguaje natural sobre mascotas, adopción y cuidados
2. Generar respuestas detalladas sobre salud, nutrición y bienestar animal
3. Mantener contexto de la conversación anterior para respuestas personalizadas
4. Formular respuestas usando MARKDOWN para mejor legibilidad

REGLAS DE FORMATO:
- Usa títulos con # ## ### para estructurar información
- Usa **negrita** para destacar puntos clave
- Usa listas con - o números para itemizar
- Usa > para citas o advertencias importantes
- Usa código con \`texto\` para nombres científicos o comandos

ESPECIALIDADES:
- Nutrición y dieta según raza, edad y tamaño
- Comportamiento y entrenamiento
- Vacunas, desparasitación y salud preventiva
- Signos de enfermedad y primeros auxilios
- Procesos de adopción
- Diferencias entre razas y cruzas

TONO: Amigable, empático, profesional pero accesible. Siempre humaniza el contenido.

IMPORTANTE: Todas tus respuestas deben estar en MARKDOWN para una visualización clara.''',
      ),
    );
    
    // Iniciar sesión de chat que mantendrá el contexto conversacional
    // Esta sesión persiste mientras la app esté abierta
    _chatSession = _model.startChat();
  }

  @override
  Future<MessageModel> sendMessage(String message) async {
    try {
      // Crear contenido de texto desde el mensaje del usuario
      final content = Content.text(message);
      
      // Enviar al ChatSession que mantiene el contexto conversacional
      // Gemini recuerda automáticamente todos los mensajes anteriores
      final response = await _chatSession.sendMessage(content);

      // Validar que la respuesta no esté vacía
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('No se recibió respuesta de la IA');
      }

      // Retornar respuesta formateada en MARKDOWN para buena visualización
      return MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response.text!,
        isUser: false,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error al comunicarse con Gemini: $e');
    }
  }
}
