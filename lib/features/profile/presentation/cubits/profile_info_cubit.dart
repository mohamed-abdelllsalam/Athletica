import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/usecases/get_client_intake_answers_usecase.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  ProfileInfoCubit(this._getClientIntakeAnswers)
    : super(const ProfileInfoInitial());

  final GetClientIntakeAnswersUseCase _getClientIntakeAnswers;
  String? _loadedClientId;
  String? _loadingClientId;

  Future<void> loadAnswers(String clientId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      if (state is ProfileInfoLoading && _loadingClientId == clientId) return;
      if (state is ProfileInfoLoaded && _loadedClientId == clientId) return;
    }
    _loadingClientId = clientId;
    emit(const ProfileInfoLoading());
    final result = await _getClientIntakeAnswers(clientId);
    switch (result) {
      case ApiSuccess(:final data):
        _loadedClientId = clientId;
        _loadingClientId = null;
        emit(ProfileInfoLoaded(data.answers));
      case ApiError(:final failure):
        _loadingClientId = null;
        emit(ProfileInfoError(failure.message));
    }
  }
}
