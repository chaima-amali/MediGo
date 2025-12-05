import 'package:flutter/material.dart';

class CustomBackArrow extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? imagePath;
  final double size;

  // Default constructor with all optional parameters
  const CustomBackArrow({
    Key? key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.imagePath,
    this.size = 40,
  }) : super(key: key);

  // Factory constructor for the specific case with imagePath and custom colors
  factory CustomBackArrow.withImage({
    Key? key,
    VoidCallback? onPressed,
    String imagePath = 'images/back_arrow.png',
    Color backgroundColor = const Color(0xFF80DEEA),
    Color iconColor = const Color(0xFF4DD0E1), // Darker shade of the background
    double size = 40,
  }) {
    return CustomBackArrow(
      key: key,
      onPressed: onPressed,
      imagePath: imagePath,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color.fromARGB(255, 160, 238, 248), // Light blue background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed ?? () => Navigator.pop(context),
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(8),
            child: imagePath != null
                ? Image.asset(
                    imagePath!, 
                    width: 24,
                    height: 24,
                    color: iconColor ?? const Color(0xFF4DD0E1), // Slightly darker than background
                    fit: BoxFit.contain,
                  )
                : Icon(
                    Icons.arrow_back_ios_new,
                    color: iconColor ?? const Color(0xFF4DD0E1), // Slightly darker than background
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
