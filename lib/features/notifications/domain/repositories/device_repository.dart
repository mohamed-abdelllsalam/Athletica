import 'package:athletica/core/utils/api_result.dart';
import '../entities/device_registration.dart';

abstract interface class DeviceRepository {
  Future<ApiResult<DeviceRegistration>> register(
    String token,
    String platform,
    String deviceId,
    int generation,
  );
  Future<ApiResult<bool>> heartbeat(String deviceId, int generation);
  void cancel();
}
