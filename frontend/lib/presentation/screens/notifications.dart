import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button and title
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CustomBackArrow(
                    backgroundColor: Color(0xFF80DEEA),
                    iconColor: Color(0xFF4DD0E1),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Today Section
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  NotificationCard(
                    time: '8:30 pm',
                    message: 'Time for your medicine "Aspirin" — your health will thank you',
                  ),
                  
                  NotificationCard(
                    time: '8:30 pm',
                    message: 'Hey there! Don\'t forget your dose of "Telfast" small steps for a healthier you.',
                  ),
                  
                  NotificationCard(
                    time: '8:30 pm',
                    message: 'Evening dose time  take your medicine "Aspirin" and rest easy tonight',
                  ),
                  
                  NotificationCard(
                    time: '8:30 am',
                    message: 'Good morning! It\'s time to take your medicine and start your day right.',
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Yesterday Section
                  Text(
                    'Yesterday',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  NotificationCard(
                    time: '8:30 pm',
                    message: 'Time for your medicine "Aspirin" — your health will thank you',
                  ),
                  
                  NotificationCard(
                    time: '8:30 pm',
                    message: 'Hey there! Don\'t forget your dose of "Telfast" small steps for a healthier you.',
                  ),
                  
                  NotificationCard(
                    time: '8:30 pm',
                    message: 'Hey there! Don\'t forget your dose of "Telfast" small steps for a healthier you.',
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String time;
  final String message;

  const NotificationCard({
    Key? key,
    required this.time,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Back Arrow Widget (same as before)
class CustomBackArrow extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? imagePath;
  final double size;

  const CustomBackArrow({
    Key? key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.imagePath,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0xFF80DEEA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
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
            padding: EdgeInsets.all(8),
            child: imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: 24,
                    height: 24,
                    color: iconColor ?? Color(0xFF4DD0E1),
                    fit: BoxFit.contain,
                  )
                : Icon(
                    Icons.arrow_back_ios_new,
                    color: iconColor ?? Color(0xFF4DD0E1),
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}