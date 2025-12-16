// lib/screens/mark_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../widgets/student_card.dart';
import '../widgets/custom_button.dart';
import '../app/theme/app_theme.dart';

class MarkAttendanceScreen extends StatelessWidget {
  MarkAttendanceScreen({super.key});

  final AttendanceController controller = Get.find<AttendanceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'present') {
                controller.markAllPresent();
              } else {
                controller.markAllAbsent();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'present',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.successColor),
                    SizedBox(width: 8),
                    Text('Mark All Present'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'absent',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('Mark All Absent'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Date Picker
                Obx(() => InkWell(
                  onTap: () => controller.selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          '${controller.selectedDate.value.day}/'
                          '${controller.selectedDate.value.month}/'
                          '${controller.selectedDate.value.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 12),
                // Class and Section Filters
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedClass.value,
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: controller.classes
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) controller.changeClass(value);
                        },
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedSection.value,
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: controller.sections
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) controller.changeSection(value);
                        },
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Stats Bar
          Obx(() {
            int present = controller.students.where((s) => s.isPresent).length;
            int absent = controller.students.length - present;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', controller.students.length, Colors.blue),
                  _buildStatItem('Present', present, AppTheme.successColor),
                  _buildStatItem('Absent', absent, AppTheme.errorColor),
                ],
              ),
            );
          }),
          
          // Student List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.students.length,
                itemBuilder: (context, index) {
                  return StudentCard(
                    student: controller.students[index],
                    // showAttendanceToggle: true,
                    // onAttendanceToggle: () => controller.toggleAttendance(index),
                  );
                },
              );
            }),
          ),
          
          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Obx(() => CustomButton(
              text: 'Save Attendance',
              onPressed: controller.saveAttendance,
              isLoading: controller.isSaving.value,
              icon: Icons.save,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}