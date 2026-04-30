import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/usecases/get_client_intake_answers_usecase.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  ProfileInfoCubit(this._getClientIntakeAnswers)
      : super(const ProfileInfoInitial());

  final GetClientIntakeAnswersUseCase _getClientIntakeAnswers;

  Future<void> loadAnswers(String clientId) async {
    emit(const ProfileInfoLoading());
    final result = await _getClientIntakeAnswers(clientId);
    switch (result) {
      case ApiSuccess(:final data):
        emit(ProfileInfoLoaded(data.answers));
      case ApiError(:final failure):
        emit(ProfileInfoError(failure.message));
    }
  }
}