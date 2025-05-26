import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/shared/models/group/group_models.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';

class CustomSearchController extends GetxController {
  RxList<dynamic> searchResults = <dynamic>[].obs;
  RxBool isSearching = false.obs;
  final RxBool isLoading = false.obs;
  final debouncer = Debouncer(milliseconds: 500);

  void search(String query, List<User> users, List<AllGroup> groups) {
    debouncer.run(() {
      if (query.isEmpty) {
        searchResults.clear();
        isSearching.value = false;
        return;
      }

      isSearching.value = true;
      isLoading.value = true;

      try {
        List<dynamic> results = [];

        // Search users
        if (users.isNotEmpty) {
          results.addAll(users.where((user) =>
              user.firstName.toLowerCase().contains(query.toLowerCase()) ||
              user.lastName.toLowerCase().contains(query.toLowerCase())));
        }

        // Search groups
        if (groups.isNotEmpty) {
          results.addAll(groups.where((group) =>
              group.name.toLowerCase().contains(query.toLowerCase())));
        }

        searchResults.value = results;
      } catch (e) {
        AppLogger.e('Error during search: $e');
      } finally {
        isLoading.value = false;
      }
    });
  }

  // Clear search results
  void clearSearch() {
    searchResults.clear();
    isSearching.value = false;
    isLoading.value = false;
  }

  @override
  void onClose() {
    clearSearch();
    super.onClose();
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}
