class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final FilterController controller;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 10.w),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text('Filter', style: CustomTextTheme.bodySmallPBold),
          const Spacer(),
          _buildDropdownContainer(context),
          SizedBox(width: ScreenUtil().screenWidth * 0.04),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer(BuildContext context) {
    return Container(
      height: 30.w,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: _getBorderColor(context),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: _buildDropdown(context),
    );
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white;
  }

  Widget _buildDropdown(BuildContext context) {
    return Obx(
      () => DropdownButton<String>(
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(10),
        icon: const Icon(Icons.keyboard_arrow_down),
        style: _getDropdownTextStyle(context),
        value: controller.selectedValue.value,
        items: _buildDropdownItems(),
        onChanged: (value) => controller.changeFilter(value!),
      ),
    );
  }

  TextStyle _getDropdownTextStyle(BuildContext context) {
    return CustomTextTheme.bodySmallP.copyWith(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
      fontWeight: FontWeight.w500,
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return items.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value,
          style: CustomTextTheme.bodySmallP.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }).toList();
  }
}
