// lib/screens/students_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_controller.dart';
import '../widgets/student_card.dart';
import '../widgets/custom_text_field.dart';
import '../app/theme/app_theme.dart';

class StudentsScreen extends StatelessWidget {
  StudentsScreen({Key? key}) : super(key: key);

  final StudentController controller = Get.find<StudentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: controller.searchController,
              hintText: 'Search students...',
              prefixIcon: Icons.search,
              suffixIcon: Obx(() => controller.searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.searchController.clear();
                      },
                    )
                  : const SizedBox()),
            ),
          ),
          
          // Filter Chips
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: Text('Class: ${controller.selectedClass.value}'),
                  selected: controller.selectedClass.value != 'All',
                  onSelected: (_) => _showFilterBottomSheet(context),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('Section: ${controller.selectedSection.value}'),
                  selected: controller.selectedSection.value != 'All',
                  onSelected: (_) => _showFilterBottomSheet(context),
                ),
                const Spacer(),
                Text(
                  '${controller.filteredStudents.length} students',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
          
          // Student List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredStudents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No students found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.filteredStudents.length,
                itemBuilder: (context, index) {
                  return StudentCard(
                    student: controller.filteredStudents[index],
                    onTap: () => _showStudentDetails(
                        context, controller.filteredStudents[index]),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar(
            'Info',
            'Add student feature coming soon!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Students',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Class'),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              children: controller.classes.map((c) {
                return ChoiceChip(
                  label: Text(c),
                  selected: controller.selectedClass.value == c,
                  onSelected: (_) => controller.filterByClass(c),
                );
              }).toList(),
            )),
            const SizedBox(height: 16),
            const Text('Section'),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              children: controller.sections.map((s) {
                return ChoiceChip(
                  label: Text(s),
                  selected: controller.selectedSection.value == s,
                  onSelected: (_) => controller.filterBySection(s),
                );
              }).toList(),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetails(BuildContext context, student) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                student.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              student.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Roll Number: ${student.rollNumber}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem('Class', student.className),
                _buildInfoItem('Section', student.section),
                _buildInfoItem('Attendance', '95%'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Parent'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.history),
                    label: const Text('View History'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}