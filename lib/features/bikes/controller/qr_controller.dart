import 'dart:convert';
import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/storage/local_storage.dart';
import '../../../main.dart';
import '../../../shared/models/trips/trips_model.dart';
import '../controller/bike_controller.dart';
import '../controller/bike_metrics_controller.dart';
import 'trips_control_service.dart';

class QrScannerController extends BaseController {
  final LocalStorage localStorage = Get.find<LocalStorage>();
  final BikeController bikeController = Get.find<BikeController>();
  final BikeMetricsController bikeMetricsController =
      Get.find<BikeMetricsController>();
  final TripControlService tripControlService = Get.find<TripControlService>();

  final RxBool isProcessing = false.obs;
  final RxString scannedDeviceId = ''.obs;

  Future<bool> processQrCode(String qrCode) async {
    if (isProcessing.value) return false;

    try {
      isProcessing.value = true;
      errorMessage.value = '';

      final deviceId = _extractDeviceId(qrCode);
      if (deviceId == null) {
        errorMessage.value = 'Invalid QR Code format';
        return false;
      }

      scannedDeviceId.value = deviceId;

      final encodedDeviceId = base64Encode(utf8.encode(deviceId));

      final toggleSuccess = await _toggleDevice(encodedDeviceId);
      if (!toggleSuccess) {
        errorMessage.value = 'Failed to activate bike';
        return false;
      }

      await bikeController.fetchBikeData(deviceId);

      final startTripData = StartTrip(
        bikeId: deviceId,
        stationId: bikeController.bikeData.value?.stationId ?? "0",
      );

      final tripStarted = await tripControlService.startTrip(startTripData);

      if (tripStarted) {
        bikeMetricsController.bikeEncoded.value = encodedDeviceId;
        await localStorage.setString('encodedId', encodedDeviceId);
        await localStorage.setString('deviceId', deviceId);

        return true;
      }

      return false;
    } catch (e) {
      handleError('Error processing QR code: $e');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  String? _extractDeviceId(String qrCode) {
    try {
      final qrData = jsonDecode(qrCode);
      final deviceId = qrData["device"] as String?;

      if (deviceId == null || deviceId.isEmpty) {
        return null;
      }

      if (!_isValidDeviceId(deviceId)) {
        return null;
      }

      return deviceId;
    } catch (e) {
      print('Error parsing QR code: $e');
      return null;
    }
  }

  bool _isValidDeviceId(String deviceId) {
    return deviceId.length >= 5 &&
        deviceId.length <= 20 &&
        RegExp(r'^[a-zA-Z0-9/]+$').hasMatch(deviceId);
  }

  Future<bool> _toggleDevice(String encodedDeviceId) async {
    try {
      final String? authToken = localStorage.getToken();
      final response = await apiService.post(
        endpoint: ApiConstants.toggleBike,
        headers: {
          'Authorization': 'Bearer $authToken',
          'X-Karma-App': 'dafjcnalnsjn'
        },
        body: {'device_id': encodedDeviceId},
      );

      return response?.statusCode == 200;
    } catch (e) {
      print('Error toggling device: $e');
      return false;
    }
  }

  Future<bool> startDemoTrip() async {
    try {
      isLoading.value = true;

      const demoDeviceId = "775tg4cmmp";

      final startTripData = StartTrip(
        bikeId: demoDeviceId,
        stationId: "6xugln92qx",
        // startTimestamp: DateTime.now(),
      );

      final success = await tripControlService.startTrip(startTripData);

      if (success) {
        scannedDeviceId.value = demoDeviceId;
        await localStorage.setString('deviceId', demoDeviceId);
      }

      return success;
    } catch (e) {
      handleError('Failed to start demo trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
