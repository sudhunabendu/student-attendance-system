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
      body: RefreshIndicator(
        onRefresh: dashboardController.fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              
              // Stats Cards
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
              
              // Quick Actions
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
              
              // Recent Activity
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildRecentActivity(),
            ],
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
    return Obx(() => GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Total Students',
          dashboardController.totalStudents.value.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Present Today',
          dashboardController.presentToday.value.toString(),
          Icons.check_circle,
          AppTheme.successColor,
        ),
        _buildStatCard(
          'Absent Today',
          dashboardController.absentToday.value.toString(),
          Icons.cancel,
          AppTheme.errorColor,
        ),
        _buildStatCard(
          'Attendance %',
          '${dashboardController.attendancePercentage.value}%',
          Icons.pie_chart,
          AppTheme.warningColor,
        ),
      ],
    ));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'Mark Attendance',
            Icons.how_to_reg,
            AppTheme.primaryColor,
            () => Get.toNamed(AppRoutes.markAttendance),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'View Students',
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
            AppTheme.warningColor,
            () => Get.toNamed(AppRoutes.reports),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Column(
        children: List.generate(
          5,
          (index) => ListTile(
            leading: CircleAvatar(
              backgroundColor: index % 2 == 0
                  ? AppTheme.successColor.withOpacity(0.1)
                  : AppTheme.errorColor.withOpacity(0.1),
              child: Icon(
                index % 2 == 0 ? Icons.check : Icons.close,
                color: index % 2 == 0
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
              ),
            ),
            title: Text('Student ${index + 1}'),
            subtitle: Text(
              index % 2 == 0 ? 'Marked Present' : 'Marked Absent',
            ),
            trailing: Text(
              '${index + 1}m ago',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
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