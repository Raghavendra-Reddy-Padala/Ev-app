import 'package:get/get.dart';

import '../utils/helpers.dart';

class GraphController extends GetxController {
  final RxMap<int, double> data = <int, double>{}.obs;
  final RxMap<int, String> labels = <int, String>{}.obs;
  final RxDouble total = 0.0.obs;
  final RxBool isLoading = true.obs;

  void setData(Map<int, double> newData) {
    data.assignAll(newData);
    total.value = GraphDataProcessor.calculateTotal(newData);
  }

  void setLabels(Map<int, String> newLabels) {
    labels.assignAll(newLabels);
  }

  void reset() {
    data.clear();
    labels.clear();
    total.value = 0.0;
    isLoading.value = true;
  }
}
