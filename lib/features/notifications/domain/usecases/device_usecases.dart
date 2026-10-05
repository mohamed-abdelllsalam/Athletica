import 'package:athletica/core/utils/api_result.dart';
import '../repositories/device_repository.dart';
import '../entities/device_registration.dart';

class RegisterDevice {
  RegisterDevice(this._repository);
  final DeviceRepository _repository;
  Future<ApiResult<DeviceRegistration>> call(
    String token,
    String platform,
    String deviceId,
    int generation,
  ) => _repository.register(token, platform, deviceId, generation);
}

class HeartbeatDevice {
  HeartbeatDevice(this._repository);
  final DeviceRepository _repository;
  Future<ApiResult<bool>> call(String deviceId, int generation) =>
      _repository.heartbeat(deviceId, generation);
}

class CancelDeviceWork {
  CancelDeviceWork(this._repository);
  final DeviceRepository _repository;
  void call() => _repository.cancel();
}
