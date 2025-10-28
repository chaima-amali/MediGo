import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppText {
  static const TextStyle regular = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    color: AppColors.darkBlue,
  );

  static const TextStyle medium = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    color: AppColors.darkBlue,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    color: AppColors.darkBlue,
  );
}
/*use it like this :
Text('Hello, World!', style: AppText.regular); 
Text('Hello', style: AppText.bold);

*/