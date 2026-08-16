import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/usecases/get_coach_clients_usecase.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachClientsCubit extends Cubit<CoachClientsState> {
  CoachClientsCubit(this._getCoachClients) : super(CoachClientsInitial());

  final GetCoachClientsUseCase _getCoachClients;

  Future<void> loadClients() async {
    if (state is CoachClientsLoading) return;

    emit(CoachClientsLoading());

    final trainerId = await TokenStorageService.instance.getTrainerId();
    if (trainerId == null) {
      emit(CoachClientsError('Trainer ID not found. Please log in again.'));
      return;
    }

    final result = await _getCoachClients(trainerId);
    switch (result) {
      case ApiSuccess(:final data):
        emit(CoachClientsLoaded(data));
      case ApiError(:final failure):
        emit(CoachClientsError(failure.message));
    }
  }
}
