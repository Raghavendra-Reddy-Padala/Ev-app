import 'package:get/get.dart';

class FilterController extends GetxController {
  final RxString selectedValue = 'Pts'.obs;

  void changeFilter(String value) {
    selectedValue.value = value;
  }

  List<User> sortUsers(List<User> users) {
    users.sort((a, b) => b.points.compareTo(a.points));
    return users;
  }

  List<Group> sortGroups(List<Group> groups) {
    switch (selectedValue.value) {
      case 'Pts':
        groups.sort((a, b) => _comparePoints(a, b));
        break;
      case 'Km':
        groups.sort((a, b) => _compareDistance(a, b));
        break;
      case 'Carbon':
        groups.sort((a, b) => _compareCarbon(a, b));
        break;
    }
    return groups;
  }

  int _comparePoints(Group a, Group b) {
    final int pointsA = a.aggregatedData?.totalPoints ?? a.totalTrips;
    final int pointsB = b.aggregatedData?.totalPoints ?? b.totalTrips;
    return pointsB.compareTo(pointsA);
  }

  int _compareDistance(Group a, Group b) {
    final double distanceA = a.aggregatedData?.totalKm ?? a.totalDistance;
    final double distanceB = b.aggregatedData?.totalKm ?? b.totalDistance;
    return distanceB.compareTo(distanceA);
  }

  int _compareCarbon(Group a, Group b) {
    final double carbonA =
        a.aggregatedData?.totalCarbon ?? (a.averageSpeed / 1000);
    final double carbonB =
        b.aggregatedData?.totalCarbon ?? (b.averageSpeed / 1000);
    return carbonB.compareTo(carbonA);
  }
}
