import 'package:flutter/material.dart';
import 'notifications.dart' as notif_page;
import '../services/mock_database_service.dart';
import '../theme/app_colors.dart';

class RemindersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final schedule = MockDataService.getTodayMedicineSchedule();
    final adherence = MockDataService.getAdherenceStats();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          title: Text(
            'Have you taken your medicine Today?',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const notif_page.NotificationsPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Date selector with month and date circles
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'September 2025',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: AppColors.primary),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Date circles (12, 13, 14, 15, 16, 17, 18, 19)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(8, (index) {
                        final date = 12 + index;
                        final isSelected = date == 16;
                        return Container(
                          margin: EdgeInsets.only(right: 8),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$date',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs (Tracking / Statistics / Edit)
            TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Tracking'),
                Tab(text: 'Statistics'),
                Tab(text: 'Edit'),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  // Tracking Tab
                  _buildTrackingTab(schedule),

                  // Statistics Tab
                  _buildStatisticsTab(adherence),

                  // Edit Tab
                  _buildEditTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/add-medicine'),
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add),
        ),
        // TODO: Add CustomBottomNavBar widget when created
        // bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
      ),
    );
  }

  Widget _buildTrackingTab(List<Map<String, dynamic>> schedule) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        final timeSlot = schedule[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeSlot['time_label'],
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            ...((timeSlot['medicines'] as List).map(
              (med) => MedicineTrackingCard(medicine: med),
            )),
            SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildStatisticsTab(Map<String, dynamic> adherence) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Your Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20),

          // Circular progress (92% from design)
          Container(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.92,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                Text(
                  '92%',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),
          Text(
            "DON'T STOP you're so close to finish your treatment",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTab() {
    final medicines = MockDataService.getUserMedicines();
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final med = medicines[index];
        // TODO: Create MedicineEditCard widget
        return Card(
          child: ListTile(
            title: Text(med['name'] ?? 'Medicine'),
            subtitle: Text('Tap to edit'),
          ),
        );
        // return MedicineEditCard(medicine: med);
      },
    );
  }
}

class MedicineTrackingCard extends StatelessWidget {
  final Map<String, dynamic> medicine;

  MedicineTrackingCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final bool isTaken = medicine['status'] == 'taken';

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(int.parse(medicine['color'].replaceFirst('#', '0xFF'))),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['medicine_name'],
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  '(${medicine['dosage']} ${medicine['unit']}, ${medicine['frequency']}, ${medicine['notes']})',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isTaken ? AppColors.success : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isTaken ? AppColors.success : Colors.grey,
              ),
            ),
            child: Icon(
              isTaken ? Icons.check : Icons.circle_outlined,
              color: isTaken ? Colors.white : Colors.grey,
              size: 20,
            ),
          ),
          SizedBox(width: 8),
          Text(
            isTaken ? 'Marked as done' : 'Marked as done',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
