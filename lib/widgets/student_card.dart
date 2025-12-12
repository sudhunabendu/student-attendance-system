// lib/widgets/student_card.dart
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../app/theme/app_theme.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showCheckbox;
  final bool isSelected;
  final ValueChanged<bool?>? onCheckboxChanged;

  const StudentCard({
    Key? key,
    required this.student,
    this.onTap,
    this.trailing,
    this.showCheckbox = false,
    this.isSelected = false,
    this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox (optional)
              if (showCheckbox)
                Checkbox(
                  value: isSelected,
                  onChanged: onCheckboxChanged,
                  activeColor: AppTheme.primaryColor,
                ),

              // Avatar
              _buildAvatar(),
              const SizedBox(width: 12),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Roll Number
                    Row(
                      children: [
                        Icon(Icons.badge, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'Roll: ${student.rollNumber ?? "N/A"}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Class & Section
                    Row(
                      children: [
                        Icon(Icons.class_, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          student.classSection,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing Widget or Loading
              if (student.isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (trailing != null)
                trailing!
              else
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _getAvatarColor(),
          backgroundImage: student.profileImage != null
              ? NetworkImage(student.profileImage!)
              : null,
          child: student.profileImage == null
              ? Text(
                  student.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              : null,
        ),
        // Sync indicator
        if (student.isMarkedOnServer)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.check,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
        // Present indicator
        if (student.isPresent && !student.isMarkedOnServer)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.schedule,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Color _getAvatarColor() {
    // Generate color based on name
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    
    final index = student.name.isNotEmpty
        ? student.name.codeUnitAt(0) % colors.length
        : 0;
    
    return colors[index];
  }
}