import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/main.dart';

class IssueController extends GetxController {
  Rx isLoading = false.obs;
  RxString errorMessage = ''.obs;
  var selectedIssues = <String>[].obs;

  void toggleIssueSelection(int index, String name) {
    if (selectedIssues.contains(name)) {
      selectedIssues.remove(name);
    } else {
      selectedIssues.add(name);
    }
  }

  Future<void> submitIssue(String concern, List<String> issues,
      {required String bikeId}) async {
    try {
      String authToken = await Get.find<LocalStorage>().getToken() ?? "";
      isLoading.value = true;
      final response =
          await apiService.post(endpoint: ApiConstants.issues, headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        'X-Karma-App': 'dafjcnalnsjn',
      }, body: {
        'bike_id': bikeId,
        'description': concern,
        'type': issues.join(',')
      });
      if (response['success']) {
        Toast.show(message: response['message'], type: ToastType.success);
        return;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Toast.show(
          message: e.toString().substring(0, 10), type: ToastType.success);
      return;
    } finally {
      isLoading.value = false;
      return;
    }
  }
}
