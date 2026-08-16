import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/usecases/get_client_profile_usecase.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getClientProfile) : super(ProfileInitial());

  final GetClientProfileUseCase _getClientProfile;

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && (state is ProfileLoaded || state is ProfileLoading)) return;
    emit(ProfileLoading());
    final result = await _getClientProfile();
    switch (result) {
      case ApiSuccess(:final data):
        emit(ProfileLoaded(data));
      case ApiError(:final failure):
        emit(ProfileError(failure.message));
    }
  }
}