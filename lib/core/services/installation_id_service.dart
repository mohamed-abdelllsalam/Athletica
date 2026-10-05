import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class InstallationIdService {
  Future<String>? _pending;
  Future<String> getOrCreate() => _pending ??= _load();

  Future<String> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'athletica_device_id';
      final stored = prefs.getString(key);
      if (stored != null &&
          Uuid.isValidUUID(fromString: stored) &&
          stored[14] == '4') {
        return stored;
      }
      final id = const Uuid().v4();
      if (!await prefs.setString(key, id)) {
        throw StateError('Installation identity could not be persisted.');
      }
      return id;
    } catch (_) {
      _pending = null;
      rethrow;
    }
  }
}
