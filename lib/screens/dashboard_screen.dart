// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);

  final DashboardController dashboardController = Get.find<DashboardController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
          onRefresh: dashboardController.fetchDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 20),
                
                const Text(
                  'Today\'s Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 24),
                
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecentActivity(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildWelcomeCard() {
    return Obx(() => Card(
      color: AppTheme.primaryColor,
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
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
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
    ));
  }

  Widget _buildStatsGrid() {
    return Obx(() => Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Students',
                dashboardController.totalStudents.value.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Present Today',
                dashboardController.presentToday.value.toString(),
                Icons.check_circle,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Absent Today',
                dashboardController.absentToday.value.toString(),
                Icons.cancel,
                AppTheme.errorColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Attendance %',
                '${dashboardController.attendancePercentage.value}%',
                Icons.pie_chart,
                AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ],
    ));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: Equal size boxes with fixed height
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'QR Scanner',
            Icons.qr_code_scanner,
            AppTheme.primaryColor,
            () => Get.toNamed(AppRoutes.qrScanner),  // ✅ Navigate to QR Scanner
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'Attendance',
            Icons.how_to_reg,
            AppTheme.primaryColor,
            () => Get.toNamed(AppRoutes.markAttendance),
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
            'Reports',
            Icons.assessment,
            AppTheme.secondaryColor,
            () => Get.toNamed(AppRoutes.students),
          ),
        ),
      ],
    );
  }

  // ✅ FIXED: Equal size with SizedBox height
  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 100,  // ✅ Fixed height
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          margin: EdgeInsets.zero,  // ✅ Remove default margin
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // ✅ Center content
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
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

  Widget _buildRecentActivity() {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final isPresent = index % 2 == 0;
          return ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: isPresent
                  ? AppTheme.successColor.withOpacity(0.1)
                  : AppTheme.errorColor.withOpacity(0.1),
              child: Icon(
                isPresent ? Icons.check : Icons.close,
                color: isPresent ? AppTheme.successColor : AppTheme.errorColor,
                size: 18,
              ),
            ),
            title: Text(
              'Student ${index + 1}',
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              isPresent ? 'Marked Present' : 'Marked Absent',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              '${index + 1}m ago',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() => UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppTheme.primaryColor, size: 40),
            ),
            accountName: Text(authController.currentUser.value?.name ?? 'Teacher'),
            accountEmail: Text(authController.currentUser.value?.email ?? ''),
          )),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () => Get.back()),
          _buildDrawerItem(Icons.people, 'Students', () {
            Get.back();
            Get.toNamed(AppRoutes.students);
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
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildBottomNav() {
    return Obx(() => BottomNavigationBar(
      currentIndex: dashboardController.selectedIndex.value,
      onTap: dashboardController.changeTab,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
        BottomNavigationBarItem(icon: Icon(Icons.how_to_reg), label: 'Attendance'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    ));
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }
}