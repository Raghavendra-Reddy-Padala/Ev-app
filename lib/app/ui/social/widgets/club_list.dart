class ClubList extends StatelessWidget {
  const ClubList({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();
    groupController.getAlreadyJoinedGroups();
    groupController.getGroups();

    final double cardWidth = ScreenUtil().screenWidth / 2 - 30.w;
    final FilterController filterController = Get.find<FilterController>();

    return Obx(() {
      if (groupController.allGroups.value == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final sortedGroups = filterController.sortGroups(
        List.from(groupController.allGroups.value!.groups),
      );

      if (sortedGroups.isEmpty) {
        return _buildEmptyState();
      }

      return _buildClubGrid(sortedGroups, cardWidth);
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: SizedBox(
              width: 100.w,
              height: 100.h,
              child: Image.asset('assets/images/no-data.png'),
            ),
          ),
          Text(
            'No Users found!',
            style: CustomTextTheme.bodyMediumPBold.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildClubGrid(List<Group> groups, double cardWidth) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(
        groups.length,
        (index) {
          return SizedBox(
            width: cardWidth,
            height: 140.h,
            child: ClubCard(club: groups[index]),
          );
        },
      ),
    );
  }
}
