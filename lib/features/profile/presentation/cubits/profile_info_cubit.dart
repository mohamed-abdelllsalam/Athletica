import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/usecases/get_client_answers_usecase.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  ProfileInfoCubit(this._getClientAnswers) : super(const ProfileInfoInitial());

  final GetClientAnswersUseCase _getClientAnswers;
  bool _loaded = false;

  Future<void> loadAnswers({bool forceRefresh = false}) async {
    if (!forceRefresh && (_loaded || state is ProfileInfoLoading)) return;
    emit(const ProfileInfoLoading());
    final result = await _getClientAnswers();
    switch (result) {
      case ApiSuccess(:final data):
        _loaded = true;
        if (isClosed) return;
        emit(ProfileInfoLoaded(data.answers));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(ProfileInfoError(failure.message));
    }
  }
}
