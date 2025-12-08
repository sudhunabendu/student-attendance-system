// lib/widgets/student_card.dart
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../app/theme/app_theme.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback? onTap;
  final bool showAttendanceToggle;
  final VoidCallback? onAttendanceToggle;

  const StudentCard({
    Key? key,
    required this.student,
    this.onTap,
    this.showAttendanceToggle = false,
    this.onAttendanceToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  student.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Roll: ${student.rollNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Class: ${student.className} - ${student.section}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (showAttendanceToggle)
                GestureDetector(
                  onTap: onAttendanceToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: student.isPresent
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.isPresent ? 'Present' : 'Absent',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
