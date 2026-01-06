import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository repository;

  GetChatHistoryUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call() async {
    return await repository.getChatHistory();
  }
}
