import 'package:flutter/material.dart';
import 'package:frontend/presentation/theme/app_theme.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'edit_medicine_page.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: EditContent(),
        ),
      ),
    );
  }
}

class EditContent extends StatefulWidget {
  const EditContent({super.key});

  @override
  State<EditContent> createState() => _EditContentState();
}

class _EditContentState extends State<EditContent> {


  final List<Map<String, dynamic>> medicines = [
    {
      'name': 'Telfast',
      'color': AppColors.yellowCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Aspirin',
      'color': AppColors.pinkCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Diclofenac',
      'color': AppColors.blueCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Naproxen',
      'color': AppColors.coralCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Vitamin C',
      'color': AppColors.lavenderCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),

          const Text(
            "Your current medicines",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),

          const SizedBox(height: 15),

          // 💊 Medicine List
          Column(
            children: medicines.map((medicine) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: medicine['color'],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medicine['details'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditMedicinePage(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(context),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 22,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ✅ Delete confirmation dialog
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Delete Medicine",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this medicine?",
            style: TextStyle(color: Colors.black87),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.darkBlue,
                  ),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Implement deletion if needed
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
