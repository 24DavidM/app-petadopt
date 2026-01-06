import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/gemini_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final GeminiDataSource geminiDataSource;
  final SupabaseClient supabaseClient;

  ChatRepositoryImpl({
    required this.geminiDataSource,
    SupabaseClient? supabaseClient,
  }) : supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(String message) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      if (userId != null) {
        await supabaseClient.from('chat_history').insert({
          'user_id': userId,
          'message': message,
          'is_user_message': true,
        });
      }

      final response = await geminiDataSource.sendMessage(message);

      if (userId != null) {
        await supabaseClient.from('chat_history').insert({
          'user_id': userId,
          'message': response.text,
          'is_user_message': false,
        });
      }

      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getChatHistory() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Right([]);

      final response = await supabaseClient
          .from('chat_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final List data = response as List? ?? [];
      final messages = data.map((item) {
        return MessageEntity(
          id:
              item['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          text: item['message']?.toString() ?? '',
          isUser: item['is_user_message'] == true,
          timestamp: item['created_at'] != null
              ? DateTime.parse(item['created_at'])
              : DateTime.now(),
        );
      }).toList();

      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearChatHistory() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        await supabaseClient
            .from('chat_history')
            .delete()
            .eq('user_id', userId);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
