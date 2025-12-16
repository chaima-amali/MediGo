import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/logic/cubits/notifications_cubit.dart';
import 'package:frontend/data/repositories/occurrence_repository.dart';
import 'package:frontend/models/notification_item.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationsCubit(OccurrenceRepository())..loadNotifications(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
                    l10n.notifications,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    label: l10n.all,
                    isSelected: selectedFilter == 'All',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'All';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  FilterButton(
                    label: l10n.reminders,
                    isSelected: selectedFilter == 'Reminders',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Reminders';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  FilterButton(
                    label: l10n.medstock_reserv,
                    isSelected: selectedFilter == 'medicine stock/Reservation',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'medicine stock/Reservation';
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4DD0E1),
                      ),
                    );
                  }

                  if (state.error != null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          state.error!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // Filter notifications based on selected filter
                  final filteredGroups =
                      selectedFilter == 'medicine stock/Reservation'
                      ? <GroupedNotifications>[] // Empty list for medstock/reserv (no medicine reminders)
                      : state.groupedNotifications; // Show all for 'All' and 'Reminders'

                  if (filteredGroups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            l10n.no_notifications_yet,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            selectedFilter == 'medicine stock/Reservation'
                                ? l10n.no_medstock_or_reservation_notifications
                                : l10n.add_medicines_to_see_reminders,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<NotificationsCubit>().loadNotifications(),
                    color: Color(0xFF4DD0E1),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = filteredGroups[index];
                        
                        // Translate group labels
                        String translatedLabel;
                        if (group.label == 'Today') {
                          translatedLabel = l10n.today;
                        } else if (group.label == 'Yesterday') {
                          translatedLabel = l10n.yesterday;
                        } else if (group.label == '2 days ago') {
                          translatedLabel = l10n.days_ago(2);
                        } else {
                          translatedLabel = group.label;
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index > 0) SizedBox(height: 24),
                            Text(
                              translatedLabel,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            ...group.notifications.map((notification) {
                              // Get the localized message based on messageIndex
                              String message = '';
                              switch (notification.messageIndex) {
                                case 1:
                                  message = l10n.notification_message_1(notification.medicineName);
                                  break;
                                case 2:
                                  message = l10n.notification_message_2(notification.medicineName);
                                  break;
                                case 3:
                                  message = l10n.notification_message_3(notification.medicineName);
                                  break;
                                case 4:
                                  message = l10n.notification_message_4(notification.medicineName);
                                  break;
                                case 5:
                                  message = l10n.notification_message_5(notification.medicineName);
                                  break;
                                default:
                                  message = l10n.notification_message_1(notification.medicineName);
                              }
                              
                              return NotificationCard(
                                time: notification.formattedTime,
                                message: message,
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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

  const NotificationCard({Key? key, required this.time, required this.message})
      : super(key: key);

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