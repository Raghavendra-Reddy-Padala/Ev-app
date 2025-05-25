import 'package:get/get.dart';

class IssueController extends GetxController {
  var selectedIssues = <String>[].obs;

  void toggleIssueSelection(int index, String name) {
    if (selectedIssues.contains(name)) {
      selectedIssues.remove(name);
    } else {
      selectedIssues.add(name);
    }
  }

  Future<bool> submitIssue(String concern, List<String> issues) async {
    await Future.delayed(const Duration(seconds: 1));
    print("Concern: $concern");
    print("Selected Issues: $issues");
    return true;
  }
}