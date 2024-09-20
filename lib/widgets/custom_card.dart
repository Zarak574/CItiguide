import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({Key? key}) : super(key: key);


@override
  Widget build(BuildContext context) {
  return Stack(
    children: [
      Card(
        elevation: 8, // Increase elevation for more pronounced shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Theme.of(context).colorScheme.primary,
        // Color(0xFFFFF6F1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.asset(
                './images/cardImg.jpg', // Replace with your image path
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.1), // Overlay color and opacity
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Explore Cities!",
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enjoy your tour!",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Positioned(
      //   top: 4,
      //   left: 4,
      //   right: 4,
      //   child: ClipRRect(
      //     borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      //     child: Container(
      //       height: 8, // Adjust the height of the border
      //       decoration: BoxDecoration(
      //         borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      //         color: Color(0xFFB75019), // Border color
      //       ),
      //     ),
      //   ),
      // ),
    ],
  );
}
}