import 'package:flutter/services.dart';
import '../../domain/repositories/device_control_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';

/// Implementation of DeviceControlRepository using MethodChannel
class DeviceControlRepositoryImpl implements DeviceControlRepository {
  DeviceControlRepositoryImpl(
    this._deviceControlChannel,
    this._securityChannel,
  );

  final MethodChannel _deviceControlChannel;
  final MethodChannel _securityChannel;

  @override
  Future<Failure?> enableKioskMode() async {
    try {
      await _deviceControlChannel.invokeMethod<bool>(AppConstants.enableKioskMode);
      return null;
    } on PlatformException catch (e) {
      return DeviceControlFailure(e.message ?? 'Failed to enable kiosk mode');
    } catch (e) {
      return DeviceControlFailure('Unknown error: $e');
    }
  }

  @override
  Future<Failure?> disableKioskMode() async {
    try {
      await _deviceControlChannel.invokeMethod<bool>(AppConstants.disableKioskMode);
      return null;
    } on PlatformException catch (e) {
      return DeviceControlFailure(e.message ?? 'Failed to disable kiosk mode');
    } catch (e) {
      return DeviceControlFailure('Unknown error: $e');
    }
  }

  @override
  Future<Failure?> lockDevice() async {
    try {
      await _deviceControlChannel.invokeMethod<bool>(AppConstants.lockDevice);
      return null;
    } on PlatformException catch (e) {
      return DeviceControlFailure(e.message ?? 'Failed to lock device');
    } catch (e) {
      return DeviceControlFailure('Unknown error: $e');
    }
  }

  @override
  Future<Failure?> preventScreenshot() async {
    try {
      await _securityChannel.invokeMethod<bool>(AppConstants.preventScreenshot);
      return null;
    } on PlatformException catch (e) {
      return DeviceControlFailure(e.message ?? 'Failed to prevent screenshots');
    } catch (e) {
      return DeviceControlFailure('Unknown error: $e');
    }
  }

  @override
  Future<Failure?> allowScreenshot() async {
    try {
      await _securityChannel.invokeMethod<bool>(AppConstants.allowScreenshot);
      return null;
    } on PlatformException catch (e) {
      return DeviceControlFailure(e.message ?? 'Failed to allow screenshots');
    } catch (e) {
      return DeviceControlFailure('Unknown error: $e');
    }
  }

  @override
  Future<({Failure? failure, bool? isRooted})> checkRootAccess() async {
    try {
      final result = await _securityChannel.invokeMethod<bool>(
        AppConstants.checkRootAccess,
      );
      return (failure: null, isRooted: result ?? false);
    } on PlatformException catch (e) {
      return (
        failure: DeviceControlFailure(e.message ?? 'Failed to check root access'),
        isRooted: null,
      );
    } catch (e) {
      return (
        failure: DeviceControlFailure('Unknown error: $e'),
        isRooted: null,
      );
    }
  }
}
