// lib/screens/students_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_controller.dart';
import '../models/student_model.dart';
import '../widgets/student_card.dart';
import '../widgets/custom_text_field.dart';
import '../app/theme/app_theme.dart';

class StudentsScreen extends StatelessWidget {
  StudentsScreen({super.key});

  final StudentController controller = Get.find<StudentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Search Bar
                _buildSearchBar(),

                // Scrollable content area
                Expanded(
                  child: Column(
                    children: [
                      // Statistics Cards
                      _buildStatisticsCards(),

                      // Filter Chips & Count
                      _buildFilterChips(context),

                      const SizedBox(height: 8),

                      // Student List
                      Expanded(child: _buildStudentList(context)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ══════════════════════════════════════════════════════════
  // APP BAR
  // ══════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Students'),
      elevation: 0,
      actions: [
        Obx(
          () => IconButton(
            icon: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: controller.isLoading.value
                ? null
                : () => controller.refreshStudents(),
            tooltip: 'Refresh',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterBottomSheet(Get.context!),
          tooltip: 'Filter',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'export':
                _exportStudents();
                break;
              case 'select_all':
                controller.selectAllStudents();
                break;
              case 'deselect_all':
                controller.deselectAllStudents();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 12),
                  Text('Export'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'select_all',
              child: Row(
                children: [
                  Icon(Icons.select_all, size: 20),
                  SizedBox(width: 12),
                  Text('Select All'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'deselect_all',
              child: Row(
                children: [
                  Icon(Icons.deselect, size: 20),
                  SizedBox(width: 12),
                  Text('Deselect All'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // SEARCH BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Obx(
        () => CustomTextField(
          controller: controller.searchController,
          hintText: 'Search by name, roll number, email...',
          prefixIcon: Icons.search,
          fillColor: Colors.white,
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => controller.clearSearch(),
                )
              : controller.isSearching.value
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STATISTICS CARDS
  // ══════════════════════════════════════════════════════════
  // ══════════════════════════════════════════════════════════
  // STATISTICS CARDS - FIXED
  // ══════════════════════════════════════════════════════════
  Widget _buildStatisticsCards() {
    return Obx(
      () => Container(
        height: 100, // Changed from 90 to 100
        margin: const EdgeInsets.only(top: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildStatCard(
              'Total',
              controller.totalCount.toString(),
              Icons.people,
              AppTheme.primaryColor,
            ),
            _buildStatCard(
              'Active',
              controller.activeCount.toString(),
              Icons.check_circle,
              AppTheme.successColor,
            ),
            _buildStatCard(
              'Male',
              controller.maleCount.toString(),
              Icons.male,
              AppTheme.maleColor,
            ),
            _buildStatCard(
              'Female',
              controller.femaleCount.toString(),
              Icons.female,
              AppTheme.femaleColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // Reduced vertical padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Added this
        children: [
          Icon(icon, color: color, size: 22), // Reduced from 24
          const SizedBox(height: 2), // Reduced from 4
          Text(
            value,
            style: TextStyle(
              fontSize: 18, // Reduced from 20
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11, // Reduced from 12
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FILTER CHIPS
  // ══════════════════════════════════════════════════════════
  Widget _buildFilterChips(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      'Status: ${controller.selectedStatus.value}',
                      controller.selectedStatus.value != 'All',
                      Icons.toggle_on,
                      () => _showFilterBottomSheet(context),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Gender: ${controller.selectedGender.value}',
                      controller.selectedGender.value != 'All',
                      Icons.wc,
                      () => _showFilterBottomSheet(context),
                    ),
                    if (controller.isFiltered) ...[
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear'),
                        onPressed: () => controller.clearFilters(),
                        backgroundColor: Colors.red.shade50,
                        labelStyle: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${controller.filteredStudents.length}',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STUDENT LIST
  // ══════════════════════════════════════════════════════════
  Widget _buildStudentList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.students.isEmpty) {
        return _buildLoadingState();
      }

      if (controller.hasError.value && controller.students.isEmpty) {
        return _buildErrorState();
      }

      if (controller.filteredStudents.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshStudents(),
        color: AppTheme.primaryColor,
        child: ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          itemCount:
              controller.filteredStudents.length +
              (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.filteredStudents.length) {
              return _buildLoadingMoreIndicator();
            }

            final student = controller.filteredStudents[index];
            return StudentCard(
              student: student,
              onTap: () => _showStudentDetails(context, student),
              onLongPress: () => controller.toggleStudentSelection(student.id),
              isSelected: student.isSelected,
              showCheckbox: controller.selectedCount > 0,
              onCheckboxChanged: (_) =>
                  controller.toggleStudentSelection(student.id),
            );
          },
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading students...',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.errorMessage.value,
                style: const TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.refreshStudents(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.isFiltered ? Icons.search_off : Icons.people_outline,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              controller.isFiltered
                  ? 'No students match your filters'
                  : 'No students found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.isFiltered
                  ? 'Try adjusting your search or filter criteria'
                  : 'Students will appear here once added',
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (controller.isFiltered) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => controller.clearFilters(),
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Obx(
      () => controller.isLoadingMore.value
          ? Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FLOATING ACTION BUTTON
  // ══════════════════════════════════════════════════════════
  Widget _buildFAB() {
    return Obx(() {
      if (controller.selectedCount > 0) {
        return FloatingActionButton.extended(
          onPressed: () => _showBulkActionSheet(),
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.checklist),
          label: Text('${controller.selectedCount} Selected'),
        );
      }

      return FloatingActionButton(
        onPressed: () {
          Get.snackbar(
            'Info',
            'Add student feature coming soon!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.infoColor,
            colorText: Colors.white,
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      );
    });
  }

  // ══════════════════════════════════════════════════════════
  // FILTER BOTTOM SHEET - FIXED
  // ══════════════════════════════════════════════════════════
  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Fixed Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Header Row
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
                          TextButton.icon(
                            onPressed: () {
                              controller.clearFilters();
                              Get.back();
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Reset'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Scrollable Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Status Filter
                      _buildFilterSection(
                        'Status',
                        Icons.toggle_on,
                        controller.statusOptions,
                        controller.selectedStatus.value,
                        (status) => controller.filterByStatus(status),
                      ),
                      const SizedBox(height: 24),
                      // Gender Filter
                      _buildFilterSection(
                        'Gender',
                        Icons.wc,
                        controller.genderOptions,
                        controller.selectedGender.value,
                        (gender) => controller.filterByGender(gender),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                // Fixed Footer
                Container(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    16,
                    24,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildFilterSection(
    String title,
    IconData icon,
    List<String> options,
    String selectedValue,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onSelect(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // STUDENT DETAILS BOTTOM SHEET - FIXED
  // ══════════════════════════════════════════════════════════
  void _showStudentDetails(BuildContext context, StudentModel student) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Scrollable Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Avatar
                      Center(child: _buildDetailAvatar(student)),
                      const SizedBox(height: 16),

                      // Name
                      Center(
                        child: Text(
                          student.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status Badge
                      Center(child: _buildDetailStatusBadge(student)),
                      const SizedBox(height: 8),

                      // Roll Number
                      Center(
                        child: Text(
                          'Roll Number: ${student.roleNumber}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Gender',
                              student.gender,
                              student.gender.toLowerCase() == 'male'
                                  ? Icons.male
                                  : Icons.female,
                              student.gender.toLowerCase() == 'male'
                                  ? AppTheme.maleColor
                                  : AppTheme.femaleColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              'Status',
                              student.status,
                              student.isActive
                                  ? Icons.check_circle
                                  : Icons.pause_circle,
                              student.isActive
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 16),

                      // Contact Info
                      _buildContactInfo(
                        Icons.email_outlined,
                        'Email',
                        student.email,
                      ),
                      const SizedBox(height: 12),
                      _buildContactInfo(
                        Icons.phone_outlined,
                        'Phone',
                        student.fullMobileNumber,
                      ),
                      const SizedBox(height: 12),
                      _buildContactInfo(
                        Icons.verified_outlined,
                        'Mobile Verified',
                        student.mobileNumberVerified ? 'Yes' : 'No',
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 16),

                      // Timestamps
                      if (student.createdAt != null) ...[
                        _buildContactInfo(
                          Icons.calendar_today_outlined,
                          'Created',
                          _formatDate(student.createdAt!),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (student.updatedAt != null) ...[
                        _buildContactInfo(
                          Icons.update_outlined,
                          'Updated',
                          _formatDate(student.updatedAt!),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                // Fixed Footer with Action Buttons
                Container(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    16,
                    24,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _callStudent(student),
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Call'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: const BorderSide(
                                  color: AppTheme.primaryColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _sendEmail(student),
                              icon: const Icon(Icons.email, size: 18),
                              label: const Text('Email'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showStudentQR(student),
                          icon: const Icon(Icons.qr_code, size: 18),
                          label: const Text('View QR Code'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDetailAvatar(StudentModel student) {
    final bool isMale = student.gender.toLowerCase() == 'male';
    final Color avatarColor = isMale
        ? AppTheme.maleColor
        : AppTheme.femaleColor;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [avatarColor.withValues(alpha: 0.8), avatarColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: avatarColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          student.initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStatusBadge(StudentModel student) {
    Color badgeColor;
    switch (student.status.toLowerCase()) {
      case 'active':
        badgeColor = AppTheme.successColor;
        break;
      case 'inactive':
        badgeColor = AppTheme.warningColor;
        break;
      case 'blocked':
        badgeColor = AppTheme.errorColor;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            student.status,
            style: TextStyle(color: badgeColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // BULK ACTION SHEET - FIXED
  // ══════════════════════════════════════════════════════════
  void _showBulkActionSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(Get.context!).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${controller.selectedCount} Students Selected',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primaryColor),
              title: const Text('Send Email'),
              subtitle: const Text('Send email to selected students'),
              onTap: () {
                Get.back();
                Get.snackbar('Email', 'Feature coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sms, color: AppTheme.primaryColor),
              title: const Text('Send SMS'),
              subtitle: const Text('Send SMS to selected students'),
              onTap: () {
                Get.back();
                Get.snackbar('SMS', 'Feature coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: AppTheme.primaryColor),
              title: const Text('Export'),
              subtitle: const Text('Export selected students'),
              onTap: () {
                Get.back();
                _exportStudents();
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  controller.deselectAllStudents();
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel Selection'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ══════════════════════════════════════════════════════════
  // QR CODE DIALOG - FIXED
  // ══════════════════════════════════════════════════════════
  void _showStudentQR(StudentModel student) {
    Get.back();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Roll: ${student.roleNumber}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${student.id.length > 8 ? student.id.substring(0, 8) : student.id}...',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan this QR code to mark attendance',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            'Share',
                            'Share feature coming soon!',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _callStudent(StudentModel student) {
    Get.snackbar(
      'Call',
      'Calling ${student.fullMobileNumber}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }

  void _sendEmail(StudentModel student) {
    Get.snackbar(
      'Email',
      'Opening email to ${student.email}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _exportStudents() {
    final csv = controller.exportToCsv();
    debugPrint(csv);
    Get.snackbar(
      'Export',
      'Exported ${controller.filteredStudents.length} students',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }
}
