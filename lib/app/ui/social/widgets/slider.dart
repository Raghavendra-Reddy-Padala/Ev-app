import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarouselController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final CarouselController controller = CarouselController();

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }
}

class CarouselWithIndicator extends StatelessWidget {
  final List<String> imgList;

  const CarouselWithIndicator({super.key, required this.imgList});

  @override
  Widget build(BuildContext context) {
    final CarouselController controller = Get.put(CarouselController());

    return Column(
      children: [
        _buildCarousel(controller),
        _buildIndicators(controller, context),
      ],
    );
  }

  Widget _buildCarousel(CarouselController controller) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.w,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 1,
        autoPlayInterval: const Duration(seconds: 3),
        onPageChanged: (index, reason) {
          controller.setCurrentIndex(index);
        },
      ),
      items: imgList.map(_buildCarouselItem).toList(),
    );
  }

  Widget _buildCarouselItem(String item) {
    return Container(
      height: 200.w,
      margin: EdgeInsets.all(20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Image.asset(
          item,
          fit: BoxFit.fill,
          width: ScreenUtil().screenWidth,
        ),
      ),
    );
  }

  Widget _buildIndicators(CarouselController controller, BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return _buildIndicatorDot(
                entry.key, controller.currentIndex.value, context);
          }).toList(),
        ));
  }

  Widget _buildIndicatorDot(int index, int currentIndex, BuildContext context) {
    final bool isSelected = currentIndex == index;
    final Color dotColor = _getDotColor(isSelected, context);

    return Container(
      width: 5.w,
      height: 5.w,
      margin: EdgeInsets.symmetric(horizontal: 4.h),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor,
      ),
    );
  }

  Color _getDotColor(bool isSelected, BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isSelected) {
      return isDarkMode
          ? const Color.fromRGBO(216, 216, 216, 0.66)
          : Colors.black;
    } else {
      return isDarkMode
          ? Colors.black
          : const Color.fromRGBO(216, 216, 216, 0.66);
    }
  }
}
