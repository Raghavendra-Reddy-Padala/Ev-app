import 'dart:convert';
import 'package:bolt_ui_kit/components/toast/toast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mjollnir/core/api/api_constants.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/storage/local_storage.dart';
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
  final RxString encodedDeviceId = ''.obs;
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

      final encodedDeviceId = base64Encode(deviceId.codeUnits);
      print("Encoded Device ID: $encodedDeviceId");
      this.encodedDeviceId.value = encodedDeviceId;

      // Always try to toggle device first for new scans
      final toggleSuccess = await toggleDevice(encodedDeviceId, true);
      if (!toggleSuccess) {
        errorMessage.value = 'Failed to activate bike';
        return false;
      }

      // Fetch bike data
      await bikeController.fetchBikeData(deviceId);

      final startTripData = StartTrip(
        bikeId: deviceId,
        stationId: bikeController.bikeData.value?.stationId ?? "0",
        personal: false,
      );

      final tripStarted =
          await tripControlService.startTrip(startTripData, personal: false);

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

  Future<bool> startDemoTrip() async {
    try {
      isLoading.value = true;

      const demoDeviceId = "775tg4cmmp";

      final startTripData = StartTrip(
        bikeId: demoDeviceId,
        stationId: "6xugln92qx",
        personal: true,
      );

      final success =
          await tripControlService.startTrip(startTripData, personal: true);

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

  String? _extractDeviceId(String qrCode) {
    try {
      final qrData = jsonDecode(qrCode);
      final deviceId = qrData["device"] as String?;
      print(deviceId);
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

  Future<bool> toggleDevice(String encodedDeviceId, bool toggle) async {
    try {
      final String? authToken = localStorage.getToken();
      final response = await http.post(
          Uri.parse(
              '${ApiConstants.baseUrl}/${ApiConstants.toggleBike}/$encodedDeviceId'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'X-Karma-App': 'dafjcnalnsjn'
          },
          body: {
            'toggle': toggle.toString()
          });

      print('Toggle device response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          Toast.show(
            message: responseData['message'] ?? 'Device toggled successfully',
            type: ToastType.success,
          );
          return true;
        } else {
          Toast.show(
            message: responseData['error'] ?? 'Failed to toggle device',
            type: ToastType.error,
          );
          return false;
        }
      } else {
        Toast.show(
          message: 'Failed to toggle device. Status: ${response.statusCode}',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      print('Error toggling device: $e');
      Toast.show(
        message: 'Error toggling device: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // Future<bool> startDemoTrip() async {
  //   try {
  //     isLoading.value = true;

  //     const demoDeviceId = "775tg4cmmp";

  //     final startTripData = StartTrip(
  //       bikeId: demoDeviceId,
  //       stationId: "6xugln92qx",
  //     );

  //     final success =
  //         await tripControlService.startTrip(startTripData, personal: true);

  //     if (success) {
  //       scannedDeviceId.value = demoDeviceId;
  //       await localStorage.setString('deviceId', demoDeviceId);
  //     }

  //     return success;
  //   } catch (e) {
  //     handleError('Failed to start demo trip: $e');
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
