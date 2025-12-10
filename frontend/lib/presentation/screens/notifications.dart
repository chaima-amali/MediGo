import 'package:flutter/material.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
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
                    loc.notifTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Filter Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterButton(
                    label: loc.filterAll,
                    isSelected: selectedFilter == 'All',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'All';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  FilterButton(
                    label: loc.filterReminders,
                    isSelected: selectedFilter == 'Reminders',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Reminders';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  FilterButton(
                    label: loc.filterStock,
                    isSelected: selectedFilter == 'Stock/Reserv',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Stock/Reserv';
                      });
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Content based on filter
            Expanded(
              child: selectedFilter == 'Stock/Reserv'
                  ? _buildPremiumContent(loc)
                  : _buildNotificationsList(loc),
            ),
          ],
        ),
      ),
    );
  }

  // Premium Content for Medicine Stock/Reservation
  Widget _buildPremiumContent(AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 60,
                color: Colors.amber.shade700,
              ),
            ),
            SizedBox(height: 24),
            
            // Title
            Text(
              loc.premiumTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            
            // Description
            Text(
              loc.premiumDesc,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            
            // Get Premium Button
            ElevatedButton(
              onPressed: () {
                _showPremiumDialog(context, loc);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 20),
                  SizedBox(width: 8),
                  Text(
                    loc.premiumBtn,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // Premium Features List
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.premiumBenefitsTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildBenefitItem(Icons.inventory, loc.premiumBenefit1),
                  _buildBenefitItem(Icons.bookmark, loc.premiumBenefit2),
                  _buildBenefitItem(Icons.notifications_active, loc.premiumBenefit3),
                  _buildBenefitItem(Icons.support_agent, loc.premiumBenefit4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber.shade700, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Notifications List
  Widget _buildNotificationsList(AppLocalizations loc) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Today Section
        Text(
          loc.labelToday,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        
        NotificationCard(
          time: '8:30 pm',
          message: loc.notifMsg1,
        ),
        
        NotificationCard(
          time: '8:30 pm',
          message: loc.notifMsg2,
        ),
        
        NotificationCard(
          time: '8:30 pm',
          message: loc.notifMsg3,
        ),
        
        NotificationCard(
          time: '8:30 am',
          message: loc.notifMsg4,
        ),
        
        SizedBox(height: 24),
        
        // Yesterday Section
        Text(
          loc.labelYesterday,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        
        NotificationCard(
          time: '8:30 pm',
          message: loc.notifMsg1,
        ),
        
        NotificationCard(
          time: '8:30 pm',
          message: loc.notifMsg2,
        ),
        
        NotificationCard(
          time: '8:30 pm',
          message: loc.notifMsg2,
        ),
        
        SizedBox(height: 20),
      ],
    );
  }

  // Show Premium Dialog
  void _showPremiumDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber.shade700),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.dialogTitle,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(loc.dialogMsg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                loc.btnCancel,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to premium subscription page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.msgComingSoon),
                    backgroundColor: Colors.amber.shade700,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(loc.btnSubscribe),
            ),
          ],
        );
      },
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Color(0xFFB2EBF2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF4DD0E1) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: Colors.black87,
          ),
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

// Custom Back Arrow Widget
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