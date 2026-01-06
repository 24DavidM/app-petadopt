import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

class ClearChatHistoryUseCase {
  final ChatRepository repository;

  ClearChatHistoryUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.clearChatHistory();
  }
}
