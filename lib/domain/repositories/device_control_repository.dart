import '../../core/errors/failures.dart';

/// Device control repository interface
abstract class DeviceControlRepository {
  /// Enable kiosk mode
  Future<Failure?> enableKioskMode();

  /// Disable kiosk mode
  Future<Failure?> disableKioskMode();

  /// Lock device
  Future<Failure?> lockDevice();

  /// Prevent screenshots
  Future<Failure?> preventScreenshot();

  /// Allow screenshots
  Future<Failure?> allowScreenshot();

  /// Check root access
  Future<({Failure? failure, bool? isRooted})> checkRootAccess();
}
