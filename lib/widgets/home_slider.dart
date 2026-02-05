import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeSlider extends StatelessWidget {
  const HomeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final images = [
      'assets/images/photo6.jpg',
      'assets/images/photo4.jpg',
      'assets/images/photo3.jpg',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        viewportFraction: 0.9,
        enlargeCenterPage: true,
      ),
      items: images.map((image) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            image,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }).toList(),
    );
  }
}
