import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notice_controller.dart';
import 'notice_detail_screen.dart';
import '../widgets/notice_card.dart';
import '../widgets/notice_shimmer.dart';
import '../widgets/notice_filter_sheet.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NoticeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context, controller),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(controller),
          
          // Filter Chips
          _buildFilterChips(controller),
          
          // Notice List
          Expanded(
            child: _buildNoticeList(controller),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // APP BAR
  // ══════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    NoticeController controller,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF6366F1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Notices',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Filter Button
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () => _showFilterSheet(context, controller),
        ),
        // Refresh Button
        Obx(() => controller.isLoading.value
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: controller.refreshNotices,
              )),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // SEARCH BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildSearchBar(NoticeController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search notices...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FILTER CHIPS
  // ══════════════════════════════════════════════════════════
  Widget _buildFilterChips(NoticeController controller) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.statusOptions.length,
            itemBuilder: (context, index) {
              final status = controller.statusOptions[index];
              final isSelected = controller.selectedStatus.value == status;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (_) => controller.setStatusFilter(status),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade700,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          )),
    );
  }

  // ══════════════════════════════════════════════════════════
  // NOTICE LIST
  // ══════════════════════════════════════════════════════════
  Widget _buildNoticeList(NoticeController controller) {
    return Obx(() {
      // Loading State
      if (controller.isLoading.value && controller.notices.isEmpty) {
        return const NoticeShimmer();
      }

      // Error State
      if (controller.hasError.value && controller.notices.isEmpty) {
        return _buildErrorState(controller);
      }

      // Empty State
      if (controller.filteredNotices.isEmpty) {
        return _buildEmptyState(controller);
      }

      // Notice List
      return RefreshIndicator(
        onRefresh: controller.refreshNotices,
        color: const Color(0xFF6366F1),
        child: ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredNotices.length + 1,
          itemBuilder: (context, index) {
            // Load More Indicator
            if (index == controller.filteredNotices.length) {
              return _buildLoadMoreIndicator(controller);
            }

            final notice = controller.filteredNotices[index];
            return NoticeCard(
              notice: notice,
              onTap: () => Get.to(
                () => NoticeDetailScreen(notice: notice),
                transition: Transition.rightToLeft,
              ),
            );
          },
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════
  // EMPTY STATE
  // ══════════════════════════════════════════════════════════
  Widget _buildEmptyState(NoticeController controller) {
    return Center(
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
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'No notices found'
                : 'No notices available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'Try different search keywords'
                : 'New notices will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          if (controller.searchQuery.value.isNotEmpty)
            ElevatedButton.icon(
              onPressed: controller.clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ERROR STATE
  // ══════════════════════════════════════════════════════════
  Widget _buildErrorState(NoticeController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshNotices,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // LOAD MORE INDICATOR
  // ══════════════════════════════════════════════════════════
  Widget _buildLoadMoreIndicator(NoticeController controller) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6366F1),
            ),
          ),
        );
      }

      if (!controller.hasMoreData.value && controller.notices.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              '• End of notices •',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  // ══════════════════════════════════════════════════════════
  // FILTER BOTTOM SHEET
  // ══════════════════════════════════════════════════════════
  void _showFilterSheet(BuildContext context, NoticeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NoticeFilterSheet(controller: controller),
    );
  }
}