import 'package:athletica/features/coach/complete_profile/presentation/cubits/add_certificate_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCertificateCubit extends Cubit<AddCertificateState> {
  AddCertificateCubit() : super(AddCertificateInitial());

  // TODO: inject AddCertificateUseCase when API is wired up.
  Future<void> saveCertificate({
    required String name,
    required String description,
  }) async {
    if (name.trim().isEmpty) {
      emit(AddCertificateFailure(message: 'Certificate name is required'));
      return;
    }
    emit(AddCertificateSaving());
    // Stub — replace with actual use case call.
    await Future.delayed(const Duration(seconds: 1));
    emit(AddCertificateSuccess());
  }
}
