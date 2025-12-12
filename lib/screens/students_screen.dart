// lib/screens/students_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/student_controller.dart';
// import '../widgets/student_card.dart';
// import '../widgets/custom_text_field.dart';
// import '../app/theme/app_theme.dart';

// class StudentsScreen extends StatelessWidget {
//   StudentsScreen({Key? key}) : super(key: key);

//   final StudentController controller = Get.find<StudentController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Students'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: () => _showFilterBottomSheet(context),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: CustomTextField(
//               controller: controller.searchController,
//               hintText: 'Search students...',
//               prefixIcon: Icons.search,
//               suffixIcon: Obx(() => controller.searchController.text.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         controller.searchController.clear();
//                       },
//                     )
//                   : const SizedBox()),
//             ),
//           ),
          
//           // Filter Chips
//           Obx(() => Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 FilterChip(
//                   label: Text('Class: ${controller.selectedClass.value}'),
//                   selected: controller.selectedClass.value != 'All',
//                   onSelected: (_) => _showFilterBottomSheet(context),
//                 ),
//                 const SizedBox(width: 8),
//                 FilterChip(
//                   label: Text('Section: ${controller.selectedSection.value}'),
//                   selected: controller.selectedSection.value != 'All',
//                   onSelected: (_) => _showFilterBottomSheet(context),
//                 ),
//                 const Spacer(),
//                 Text(
//                   '${controller.filteredStudents.length} students',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           )),
//           const SizedBox(height: 8),
          
//           // Student List
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (controller.filteredStudents.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.search_off,
//                           size: 80, color: Colors.grey[400]),
//                       const SizedBox(height: 16),
//                       Text(
//                         'No students found',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               return ListView.builder(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 itemCount: controller.filteredStudents.length,
//                 itemBuilder: (context, index) {
//                   return StudentCard(
//                     student: controller.filteredStudents[index],
//                     onTap: () => _showStudentDetails(
//                         context, controller.filteredStudents[index]),
//                   );
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Get.snackbar(
//             'Info',
//             'Add student feature coming soon!',
//             snackPosition: SnackPosition.BOTTOM,
//           );
//         },
//         backgroundColor: AppTheme.primaryColor,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   void _showFilterBottomSheet(BuildContext context) {
//     Get.bottomSheet(
//       Container(
//         padding: const EdgeInsets.all(24),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Filter Students',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text('Class'),
//             const SizedBox(height: 8),
//             Obx(() => Wrap(
//               spacing: 8,
//               children: controller.classes.map((c) {
//                 return ChoiceChip(
//                   label: Text(c),
//                   selected: controller.selectedClass.value == c,
//                   onSelected: (_) => controller.filterByClass(c),
//                 );
//               }).toList(),
//             )),
//             const SizedBox(height: 16),
//             const Text('Section'),
//             const SizedBox(height: 8),
//             Obx(() => Wrap(
//               spacing: 8,
//               children: controller.sections.map((s) {
//                 return ChoiceChip(
//                   label: Text(s),
//                   selected: controller.selectedSection.value == s,
//                   onSelected: (_) => controller.filterBySection(s),
//                 );
//               }).toList(),
//             )),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('Apply Filters'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showStudentDetails(BuildContext context, student) {
//     Get.bottomSheet(
//       Container(
//         padding: const EdgeInsets.all(24),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircleAvatar(
//               radius: 40,
//               backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
//               child: Text(
//                 student.name[0].toUpperCase(),
//                 style: const TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.primaryColor,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               student.name,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Roll Number: ${student.rollNumber}',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildInfoItem('Class', student.className),
//                 _buildInfoItem('Section', student.section),
//                 _buildInfoItem('Attendance', '95%'),
//               ],
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () {},
//                     icon: const Icon(Icons.phone),
//                     label: const Text('Call Parent'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () {},
//                     icon: const Icon(Icons.history),
//                     label: const Text('View History'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoItem(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: AppTheme.primaryColor,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(color: Colors.grey[600]),
//         ),
//       ],
//     );
//   }
// }

// lib/screens/students_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_controller.dart';
import '../models/student_model.dart';
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
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshStudents(),
            tooltip: 'Refresh',
          ),
          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Filter Chips & Count
          _buildFilterChips(context),

          const SizedBox(height: 8),

          // Student List
          Expanded(
            child: _buildStudentList(),
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

  // ══════════════════════════════════════════════════════════
  // SEARCH BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() => CustomTextField(
        controller: controller.searchController,
        hintText: 'Search by name, roll number...',
        prefixIcon: Icons.search,
        suffixIcon: controller.searchQuery.value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => controller.clearSearch(),
              )
            : controller.isSearching.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
      )),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FILTER CHIPS
  // ══════════════════════════════════════════════════════════
  Widget _buildFilterChips(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Class Filter Chip
          FilterChip(
            label: Text('Class: ${controller.selectedClass.value.isEmpty ? "All" : controller.selectedClass.value}'),
            selected: controller.selectedClass.value.isNotEmpty && 
                      controller.selectedClass.value != 'All',
            onSelected: (_) => _showFilterBottomSheet(context),
            avatar: const Icon(Icons.class_, size: 16),
          ),
          const SizedBox(width: 8),
          
          // Section Filter Chip
          FilterChip(
            label: Text('Section: ${controller.selectedSection.value.isEmpty ? "All" : controller.selectedSection.value}'),
            selected: controller.selectedSection.value.isNotEmpty && 
                      controller.selectedSection.value != 'All',
            onSelected: (_) => _showFilterBottomSheet(context),
            avatar: const Icon(Icons.group, size: 16),
          ),
          
          const Spacer(),
          
          // Student Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${controller.filteredStudents.length} students',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // ══════════════════════════════════════════════════════════
  // STUDENT LIST
  // ══════════════════════════════════════════════════════════
  Widget _buildStudentList() {
    return Obx(() {
      // Loading State
      if (controller.isLoading.value && controller.students.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading students...'),
            ],
          ),
        );
      }

      // Error State
      if (controller.hasError.value && controller.students.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading students',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => controller.refreshStudents(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      // Empty State
      if (controller.filteredStudents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.isFiltered ? Icons.search_off : Icons.people_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                controller.isFiltered
                    ? 'No students match your filters'
                    : 'No students found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              if (controller.isFiltered) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => controller.clearFilters(),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                ),
              ],
            ],
          ),
        );
      }

      // Student List with Pull-to-Refresh
      return RefreshIndicator(
        onRefresh: () => controller.refreshStudents(),
        child: ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.filteredStudents.length + 
                     (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            // Loading more indicator
            if (index >= controller.filteredStudents.length) {
              return _buildLoadingMoreIndicator();
            }

            final student = controller.filteredStudents[index];
            return StudentCard(
              student: student,
              onTap: () => _showStudentDetails(context, student),
              trailing: _buildStudentTrailing(student),
            );
          },
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════
  // LOADING MORE INDICATOR
  // ══════════════════════════════════════════════════════════
  Widget _buildLoadingMoreIndicator() {
    return Obx(() => controller.isLoadingMore.value
        ? const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        : const SizedBox.shrink());
  }

  // ══════════════════════════════════════════════════════════
  // STUDENT TRAILING WIDGET
  // ══════════════════════════════════════════════════════════
  Widget? _buildStudentTrailing(StudentModel student) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: student.isActive
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            student.status.value,
            style: TextStyle(
              color: student.isActive ? Colors.green : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Sync Status
        if (student.isMarkedOnServer)
          const Icon(Icons.cloud_done, color: Colors.green, size: 16),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // FILTER BOTTOM SHEET
  // ══════════════════════════════════════════════════════════
  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Students',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clearFilters();
                      Get.back();
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Class Filter
              const Text(
                'Class',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.classOptions.map((className) {
                  final isSelected = controller.selectedClass.value == className;
                  return ChoiceChip(
                    label: Text(className),
                    selected: isSelected,
                    onSelected: (_) => controller.filterByClass(className),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  );
                }).toList(),
              )),

              const SizedBox(height: 20),

              // Section Filter
              const Text(
                'Section',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.sectionOptions.map((section) {
                  final isSelected = controller.selectedSection.value == section;
                  return ChoiceChip(
                    label: Text(section),
                    selected: isSelected,
                    onSelected: (_) => controller.filterBySection(section),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  );
                }).toList(),
              )),

              const SizedBox(height: 20),

              // Status Filter
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.statusOptions.map((status) {
                  final isSelected = controller.selectedStatus.value == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) => controller.filterByStatus(status),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  );
                }).toList(),
              )),

              const SizedBox(height: 24),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ══════════════════════════════════════════════════════════
  // STUDENT DETAILS BOTTOM SHEET
  // ══════════════════════════════════════════════════════════
  void _showStudentDetails(BuildContext context, StudentModel student) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: student.profileImage != null
                    ? NetworkImage(student.profileImage!)
                    : null,
                child: student.profileImage == null
                    ? Text(
                        student.initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                student.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: student.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  student.status.value,
                  style: TextStyle(
                    color: student.isActive ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Roll Number
              Text(
                'Roll Number: ${student.rollNumber ?? "N/A"}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem('Class', student.className ?? 'N/A'),
                  _buildInfoItem('Section', student.section ?? 'N/A'),
                  _buildInfoItem('Gender', student.gender.value),
                ],
              ),
              const SizedBox(height: 16),

              // Divider
              const Divider(),
              const SizedBox(height: 16),

              // Contact Info
              if (student.email != null || student.mobileNumber != null) ...[
                _buildContactRow(
                  Icons.email,
                  'Email',
                  student.email ?? 'Not available',
                ),
                const SizedBox(height: 8),
                _buildContactRow(
                  Icons.phone,
                  'Phone',
                  student.mobileNumber ?? 'Not available',
                ),
                const SizedBox(height: 16),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: student.mobileNumber != null
                          ? () => _callParent(student)
                          : null,
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewAttendanceHistory(student),
                      icon: const Icon(Icons.history),
                      label: const Text('History'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // QR Code Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showStudentQR(student),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('View QR Code'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ══════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ══════════════════════════════════════════════════════════
  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // ACTION METHODS
  // ══════════════════════════════════════════════════════════
  void _callParent(StudentModel student) {
    // TODO: Implement phone call
    Get.snackbar(
      'Call',
      'Calling ${student.mobileNumber}...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _viewAttendanceHistory(StudentModel student) {
    Get.back(); // Close bottom sheet
    // TODO: Navigate to attendance history screen
    Get.toNamed('/attendance-history', arguments: {'studentId': student.id});
  }

  void _showStudentQR(StudentModel student) {
    Get.back(); // Close bottom sheet
    
    Get.dialog(
      AlertDialog(
        title: Text(student.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Roll: ${student.rollNumber ?? "N/A"}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scan this QR code to mark attendance',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement share QR
              Get.snackbar('Share', 'Share feature coming soon!');
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }
}