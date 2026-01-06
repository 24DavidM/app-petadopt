import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/clear_chat_history_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final ClearChatHistoryUseCase clearChatHistoryUseCase;
  final List<MessageEntity> _messages = [];

  ChatBloc({
    required this.sendMessageUseCase,
    required this.getChatHistoryUseCase,
    required this.clearChatHistoryUseCase,
  }) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatEvent>(_onClearChat);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    // Load history immediately to maintain conversation context
    add(LoadChatHistoryEvent());
  }

  /// Procesa mensajes del usuario y mantiene el contexto conversacional
  /// con Gemini AI para respuestas personalizadas y coherentes
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Validar input del usuario
    final trimmedMessage = event.message.trim();
    if (trimmedMessage.isEmpty) {
      emit(
        ChatError(
          message: 'El mensaje no puede estar vacío',
          messages: _messages,
        ),
      );
      return;
    }

    // Agregar mensaje del usuario a la lista (CONTEXTO LOCAL)
    final userMessage = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmedMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    emit(ChatSending(_messages));

    // Enviar mensaje a Gemini (mantiene contexto automático)
    final result = await sendMessageUseCase(trimmedMessage);

    result.fold(
      (failure) {
        emit(ChatError(message: failure.message, messages: _messages));
      },
      (aiMessage) {
        _messages.add(aiMessage);
        emit(ChatLoaded(_messages));
      },
    );
  }

  Future<void> _onClearChat(
    ClearChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    await clearChatHistoryUseCase();
    _messages.clear();
    emit(ChatInitial());
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await getChatHistoryUseCase();

    result.fold(
      (failure) {
        emit(
          ChatError(
            message: 'Error cargando historial: ${failure.message}',
            messages: _messages,
          ),
        );
      },
      (history) {
        _messages.clear();
        _messages.addAll(history);
        if (_messages.isEmpty) {
          emit(ChatInitial());
        } else {
          emit(ChatLoaded(List.from(_messages)));
        }
      },
    );
  }
}
