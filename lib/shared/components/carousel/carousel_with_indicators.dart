import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../constants/colors.dart';

class CarouselController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final CarouselController carouselController = CarouselController();

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }
}

class CarouselWithIndicator extends StatelessWidget {
  final List<String> imageUrls;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final double viewportFraction;
  final double aspectRatio;
  final double height;
  final bool enlargeCenterPage;
  final EdgeInsets margin;
  final BorderRadius borderRadius;
  final BoxFit imageFit;

  CarouselWithIndicator({
    Key? key,
    required this.imageUrls,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.viewportFraction = 1.0,
    this.aspectRatio = 16 / 9,
    this.height = 200,
    this.enlargeCenterPage = true,
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.imageFit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CarouselController controller = Get.put(CarouselController());

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: height.h,
            autoPlay: autoPlay,
            enlargeCenterPage: enlargeCenterPage,
            aspectRatio: aspectRatio,
            viewportFraction: viewportFraction,
            autoPlayInterval: autoPlayInterval,
            onPageChanged: (index, reason) {
              controller.setCurrentIndex(index);
            },
          ),
          items: imageUrls.map((url) => _buildCarouselItem(url)).toList(),
        ),
        SizedBox(height: 8.h),
        _buildIndicators(controller, context),
      ],
    );
  }

  Widget _buildCarouselItem(String imageUrl) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: imageUrl.startsWith('http') || imageUrl.startsWith('https')
            ? Image.network(
                imageUrl,
                fit: imageFit,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                    size: 40.w,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
            : Image.asset(
                imageUrl,
                fit: imageFit,
                width: double.infinity,
              ),
      ),
    );
  }

  Widget _buildIndicators(CarouselController controller, BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imageUrls.asMap().entries.map((entry) {
            final bool isSelected = controller.currentIndex.value == entry.key;
            final Color dotColor =
                Theme.of(context).brightness == Brightness.light
                    ? (isSelected ? Colors.black : Colors.grey.withOpacity(0.4))
                    : (isSelected
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.4));

            return Container(
              width: isSelected ? 20.w : 8.w,
              height: 8.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }).toList(),
        ));
  }
}
