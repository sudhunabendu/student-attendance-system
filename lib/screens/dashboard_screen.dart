// // lib/screens/dashboard_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/dashboard_controller.dart';
// import '../app/routes/app_routes.dart';
// import '../app/theme/app_theme.dart';

// class DashboardScreen extends StatelessWidget {
//   DashboardScreen({super.key});

//   final DashboardController dashboardController =
//       Get.find<DashboardController>();
//   final AuthController authController = Get.find<AuthController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: authController.logout,
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(),
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: dashboardController.fetchDashboardData,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildWelcomeCard(),
//                 const SizedBox(height: 20),

//                 // ✅ NEW: Auto-scroll Carousel
//                 _buildImageCarousel(),
//                 const SizedBox(height: 24),

//                 const Text(
//                   'Quick Actions',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildQuickActions(),
//                 const SizedBox(height: 24),

//                 const Text(
//                   'Recent Activity',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildRecentActivity(),

//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   // ✅ NEW: Image Carousel Widget
//   Widget _buildImageCarousel() {
//     return Column(
//       children: [
//         CarouselSlider(
//           carouselController: dashboardController.carouselController,
//           options: CarouselOptions(
//             height: 180,
//             autoPlay: true,
//             autoPlayInterval: const Duration(seconds: 3),
//             autoPlayAnimationDuration: const Duration(milliseconds: 800),
//             autoPlayCurve: Curves.fastOutSlowIn,
//             enlargeCenterPage: true,
//             enlargeFactor: 0.2,
//             viewportFraction: 0.92,
//             onPageChanged: dashboardController.onCarouselPageChanged,
//           ),
//           items: dashboardController.carouselItems.map((item) {
//             return Builder(
//               builder: (BuildContext context) {
//                 return _buildCarouselItem(item);
//               },
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 12),
//         // Carousel Indicators
//         _buildCarouselIndicators(),
//       ],
//     );
//   }

//   // ✅ Carousel Item with Image
//   Widget _buildCarouselItem(Map<String, String> item) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Image
//             CachedNetworkImage(
//               imageUrl: item['image']!,
//               fit: BoxFit.cover,
//               placeholder: (context, url) => Container(
//                 color: Colors.grey[200],
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: AppTheme.primaryColor,
//                   ),
//                 ),
//               ),
//               errorWidget: (context, url, error) => Container(
//                 color: Colors.grey[300],
//                 child: const Icon(
//                   Icons.image_not_supported,
//                   size: 50,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//             // Gradient Overlay
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
//                 ),
//               ),
//             ),
//             // Text Content
//             Positioned(
//               bottom: 16,
//               left: 16,
//               right: 16,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     item['title']!,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     item['subtitle']!,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ Carousel Dot Indicators
//   Widget _buildCarouselIndicators() {
//     return Obx(
//       () => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: dashboardController.carouselItems.asMap().entries.map((
//           entry,
//         ) {
//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             width: dashboardController.currentCarouselIndex.value == entry.key
//                 ? 24
//                 : 8,
//             height: 8,
//             margin: const EdgeInsets.symmetric(horizontal: 3),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(4),
//               color: dashboardController.currentCarouselIndex.value == entry.key
//                   ? AppTheme.primaryColor
//                   : AppTheme.primaryColor.withOpacity(0.3),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildWelcomeCard() {
//     return Obx(
//       () => Card(
//         color: AppTheme.primaryLight,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Hello, ${authController.currentUser.value?.name ?? 'Teacher'}!',
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Today is ${_getFormattedDate()}',
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ],
//                 ),
//               ),
//               const CircleAvatar(
//                 radius: 30,
//                 backgroundColor: Colors.white24,
//                 child: Icon(Icons.person, color: Colors.white, size: 30),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickActions() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildActionCard(
//             'QR Scanner',
//             Icons.qr_code_scanner,
//             AppTheme.primaryColor,
//             () => Get.toNamed(AppRoutes.qrScanner),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildActionCard(
//             'Students',
//             Icons.people_outline,
//             AppTheme.secondaryColor,
//             () => Get.toNamed(AppRoutes.students),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildActionCard(
//             'Teacher QR Scanner',
//             Icons.qr_code_scanner,
//             AppTheme.secondaryColor,
//             () => Get.toNamed(AppRoutes.teacherQrScanner),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionCard(
//     String title,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return SizedBox(
//       height: 100,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Card(
//           margin: EdgeInsets.zero,
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(icon, color: color, size: 24),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentActivity() {
//     return Card(
//       child: ListView.separated(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: 5,
//         separatorBuilder: (context, index) =>
//             Divider(height: 1, color: Colors.grey[200]),
//         itemBuilder: (context, index) {
//           final isPresent = index % 2 == 0;
//           return ListTile(
//             dense: true,
//             visualDensity: VisualDensity.compact,
//             leading: CircleAvatar(
//               radius: 18,
//               backgroundColor: isPresent
//                   ? AppTheme.successColor.withOpacity(0.1)
//                   : AppTheme.errorColor.withOpacity(0.1),
//               child: Icon(
//                 isPresent ? Icons.check : Icons.close,
//                 color: isPresent ? AppTheme.successColor : AppTheme.errorColor,
//                 size: 18,
//               ),
//             ),
//             title: Text(
//               'Student ${index + 1}',
//               style: const TextStyle(fontSize: 14),
//             ),
//             subtitle: Text(
//               isPresent ? 'Marked Present' : 'Marked Absent',
//               style: const TextStyle(fontSize: 12),
//             ),
//             trailing: Text(
//               '${index + 1}m ago',
//               style: TextStyle(color: Colors.grey[500], fontSize: 11),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDrawer() {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           Obx(
//             () => UserAccountsDrawerHeader(
//               decoration: const BoxDecoration(color: AppTheme.primaryColor),
//               currentAccountPicture: const CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Icon(
//                   Icons.person,
//                   color: AppTheme.primaryColor,
//                   size: 40,
//                 ),
//               ),
//               accountName: Text(
//                 authController.currentUser.value?.name ?? 'Teacher',
//               ),
//               accountEmail: Text(authController.currentUser.value?.email ?? ''),
//             ),
//           ),
//           _buildDrawerItem(Icons.dashboard, 'Dashboard', () => Get.back()),
//           _buildDrawerItem(Icons.people, 'Students', () {
//             Get.back();
//             Get.toNamed(AppRoutes.students);
//           }),
//           _buildDrawerItem(Icons.how_to_reg, 'Mark Attendance', () {
//             Get.back();
//             Get.toNamed(AppRoutes.markAttendance);
//           }),
//           _buildDrawerItem(Icons.history, 'Attendance History', () {
//             Get.back();
//             Get.toNamed(AppRoutes.attendanceHistory);
//           }),
//           _buildDrawerItem(Icons.assessment, 'Reports', () {
//             Get.back();
//             Get.toNamed(AppRoutes.reports);
//           }),
//           const Divider(),
//           _buildDrawerItem(Icons.person, 'Profile', () {
//             Get.back();
//             Get.toNamed(AppRoutes.profile);
//           }),
//           _buildDrawerItem(Icons.settings, 'Settings', () {
//             Get.back();
//             Get.toNamed(AppRoutes.settings);
//           }),
//           _buildDrawerItem(Icons.logout, 'Logout', authController.logout),
//         ],
//       ),
//     );
//   }

//   Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
//     return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
//   }

//   Widget _buildBottomNav() {
//     return Obx(
//       () => BottomNavigationBar(
//         currentIndex: dashboardController.selectedIndex.value,
//         onTap: dashboardController.changeTab,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: AppTheme.primaryColor,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.how_to_reg),
//             label: 'Attendance',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }

//   String _getFormattedDate() {
//     final now = DateTime.now();
//     final months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return '${now.day} ${months[now.month - 1]}, ${now.year}';
//   }
// }

// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/notice_controller.dart'; // ✅ Add this import
import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';
import '../models/notice_model.dart'; // ✅ Add this import

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final AuthController authController = Get.find<AuthController>();
  final NoticeController noticeController =
      Get.find<NoticeController>(); // ✅ Add this

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard, // ✅ Updated refresh method
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 20),

                // ✅ Auto-scroll Carousel
                _buildImageCarousel(),
                const SizedBox(height: 24),

                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 24),

                // ✅ UPDATED: Recent Notices Section
                _buildSectionHeader(
                  title: 'Recent Notices',
                  onViewAll: () =>
                      Get.toNamed(AppRoutes.notice), // Add route if exists
                ),
                const SizedBox(height: 12),
                _buildRecentNoticeActivity(), // ✅ New method

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ✅ Refresh method that includes notices
  Future<void> _refreshDashboard() async {
    await Future.wait([
      dashboardController.fetchDashboardData(),
      noticeController.fetchNotices(refresh: true),
    ]);
  }

  // ✅ Section Header with View All button
  Widget _buildSectionHeader({required String title, VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text(
              'View All',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ✅ NEW: Recent Notice Activity Widget
  Widget _buildRecentNoticeActivity() {
    return Obx(() {
      // Loading state
      if (noticeController.isLoading.value &&
          noticeController.filteredNotices.isEmpty) {
        return Card(
          child: Container(
            height: 200,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
        );
      }

      // Error state
      if (noticeController.hasError.value &&
          noticeController.filteredNotices.isEmpty) {
        return Card(
          child: Container(
            height: 200,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'Failed to load notices',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => noticeController.fetchNotices(refresh: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      // Empty state
      if (noticeController.filteredNotices.isEmpty) {
        return Card(
          child: Container(
            height: 150,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No notices available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }

      // Show only first 5 notices
      final recentNotices = noticeController.filteredNotices.take(5).toList();

      return Card(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentNotices.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: Colors.grey[200]),
          itemBuilder: (context, index) {
            final notice = recentNotices[index];
            return _buildNoticeItem(notice);
          },
        ),
      );
    });
  }

  // ✅ Individual Notice Item
  Widget _buildNoticeItem(NoticeModel notice) {
    return ListTile(
      onTap: () => _showNoticeDetail(notice),
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: _buildNoticeIcon(notice),
      title: Text(
        notice.title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Row(
            children: [
              _buildStatusBadge(notice.status ?? 'Active'),
              const SizedBox(width: 8),
              if (notice.isForAll == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'All',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatDate(notice.createdAt),
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
          const SizedBox(height: 4),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  // ✅ Notice Icon based on file type
  Widget _buildNoticeIcon(NoticeModel notice) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    if (notice.isImage) {
      iconData = Icons.image;
      iconColor = Colors.green;
      bgColor = Colors.green.withValues(alpha: 0.1);
    } else if (notice.isPdf) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
      bgColor = Colors.red.withValues(alpha: 0.1);
    } else {
      iconData = Icons.notifications;
      iconColor = AppTheme.primaryColor;
      bgColor = AppTheme.primaryColor.withValues(alpha: 0.1);
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: bgColor,
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  // ✅ Status Badge
  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.successColor.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          color: isActive ? AppTheme.successColor : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ✅ Format date to readable string
  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // ✅ Show Notice Detail Dialog/Bottom Sheet
  void _showNoticeDetail(NoticeModel notice) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildNoticeIcon(notice),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title ?? 'Untitled Notice',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(notice.status ?? 'Active'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Details
            _buildDetailRow('File Name', notice.fileName ?? 'N/A'),
            _buildDetailRow('File Size', notice.formattedFileSize),
            _buildDetailRow('File Type', notice.fileType ?? 'N/A'),
            _buildDetailRow(
              'Created At',
              notice.createdAt != null
                  ? '${notice.createdAt!.day}/${notice.createdAt!.month}/${notice.createdAt!.year}'
                  : 'N/A',
            ),
            _buildDetailRow('For All', notice.isForAll == true ? 'Yes' : 'No'),

            const SizedBox(height: 20),

            // View File Button (if file exists)
            if (notice.fileUrl != null && notice.fileUrl!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openFile(notice),
                  icon: Icon(notice.isImage ? Icons.image : Icons.open_in_new),
                  label: Text(notice.isImage ? 'View Image' : 'Open File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ✅ Detail Row for Bottom Sheet
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Open file (image viewer or URL launcher)
  void _openFile(NoticeModel notice) {
    Get.back(); // Close bottom sheet first

    if (notice.isImage && notice.fileUrl != null) {
      // Show image in full screen
      Get.dialog(
        Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: notice.fileUrl!,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error, color: Colors.white, size: 50),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 16,
                right: 16,
                child: Text(
                  notice.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // For PDF or other files, you can use url_launcher
      // launchUrl(Uri.parse(notice.fileUrl!));
      Get.snackbar(
        'Open File',
        'Opening ${notice.fileName}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // EXISTING METHODS (keep as they are)
  // ══════════════════════════════════════════════════════════

  Widget _buildImageCarousel() {
    // ... keep existing code
    return Column(
      children: [
        CarouselSlider(
          carouselController: dashboardController.carouselController,
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            viewportFraction: 0.92,
            onPageChanged: dashboardController.onCarouselPageChanged,
          ),
          items: dashboardController.carouselItems.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return _buildCarouselItem(item);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildCarouselIndicators(),
      ],
    );
  }

  Widget _buildCarouselItem(Map<String, String> item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: item['image']!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['subtitle']!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: dashboardController.carouselItems.asMap().entries.map((
          entry,
        ) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: dashboardController.currentCarouselIndex.value == entry.key
                ? 24
                : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: dashboardController.currentCarouselIndex.value == entry.key
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Obx(
      () => Card(
        color: AppTheme.primaryLight,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${authController.currentUser.value?.name ?? 'Teacher'}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Today is ${_getFormattedDate()}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'QR Scanner',
            Icons.qr_code_scanner,
            AppTheme.primaryColor,
            () => Get.toNamed(AppRoutes.qrScanner),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'Students',
            Icons.people_outline,
            AppTheme.secondaryColor,
            () => Get.toNamed(AppRoutes.students),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'Teacher QR',
            Icons.qr_code_scanner,
            AppTheme.secondaryColor,
            () => Get.toNamed(AppRoutes.teacherQrScanner),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 100,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(
            () => UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primaryColor),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ),
              accountName: Text(
                authController.currentUser.value?.name ?? 'Teacher',
              ),
              accountEmail: Text(authController.currentUser.value?.email ?? ''),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () => Get.back()),
          _buildDrawerItem(Icons.people, 'Students', () {
            Get.back();
            Get.toNamed(AppRoutes.students);
          }),
          _buildDrawerItem(Icons.notifications, 'Notice', () {
            Get.back();
            Get.toNamed(AppRoutes.notice); // Add this route
          }),
          _buildDrawerItem(Icons.how_to_reg, 'Mark Attendance', () {
            Get.back();
            Get.toNamed(AppRoutes.markAttendance);
          }),
          _buildDrawerItem(Icons.history, 'Attendance History', () {
            Get.back();
            Get.toNamed(AppRoutes.attendanceHistory);
          }),
          _buildDrawerItem(Icons.assessment, 'Reports', () {
            Get.back();
            Get.toNamed(AppRoutes.reports);
          }),
          const Divider(),
          _buildDrawerItem(Icons.person, 'Profile', () {
            Get.back();
            Get.toNamed(AppRoutes.profile);
          }),
          _buildDrawerItem(Icons.settings, 'Settings', () {
            Get.back();
            Get.toNamed(AppRoutes.settings);
          }),
          _buildDrawerItem(Icons.logout, 'Logout', authController.logout),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }

  Widget _buildBottomNav() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: dashboardController.selectedIndex.value,
        onTap: dashboardController.changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }
}
