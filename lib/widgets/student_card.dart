// // lib/widgets/student_card.dart
// import 'package:flutter/material.dart';
// import '../models/student_model.dart';
// import '../app/theme/app_theme.dart';

// class StudentCard extends StatelessWidget {
//   final StudentModel student;
//   final VoidCallback? onTap;
//   final Widget? trailing;
//   final bool showCheckbox;
//   final bool isSelected;
//   final ValueChanged<bool?>? onCheckboxChanged;

//   const StudentCard({
//     Key? key,
//     required this.student,
//     this.onTap,
//     this.trailing,
//     this.showCheckbox = false,
//     this.isSelected = false,
//     this.onCheckboxChanged,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       elevation: 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: isSelected
//             ? const BorderSide(color: AppTheme.primaryColor, width: 2)
//             : BorderSide.none,
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               // Checkbox (optional)
//               if (showCheckbox)
//                 Checkbox(
//                   value: isSelected,
//                   onChanged: onCheckboxChanged,
//                   activeColor: AppTheme.primaryColor,
//                 ),

//               // Avatar
//               _buildAvatar(),
//               const SizedBox(width: 12),

//               // Student Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Name
//                     Text(
//                       student.name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 4),

//                     // Roll Number
//                     Row(
//                       children: [
//                         Icon(Icons.badge, size: 14, color: Colors.grey[500]),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Roll: ${student.rollNumber ?? "N/A"}',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 2),

//                     // Class & Section
//                     Row(
//                       children: [
//                         Icon(Icons.class_, size: 14, color: Colors.grey[500]),
//                         const SizedBox(width: 4),
//                         Text(
//                           student.classSection,
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Trailing Widget or Loading
//               if (student.isLoading)
//                 const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               else if (trailing != null)
//                 trailing!
//               else
//                 const Icon(Icons.chevron_right, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAvatar() {
//     return Stack(
//       children: [
//         CircleAvatar(
//           radius: 24,
//           backgroundColor: _getAvatarColor(),
//           backgroundImage: student.profileImage != null
//               ? NetworkImage(student.profileImage!)
//               : null,
//           child: student.profileImage == null
//               ? Text(
//                   student.initials,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 )
//               : null,
//         ),
//         // Sync indicator
//         if (student.isMarkedOnServer)
//           Positioned(
//             right: 0,
//             bottom: 0,
//             child: Container(
//               width: 14,
//               height: 14,
//               decoration: BoxDecoration(
//                 color: Colors.green,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 2),
//               ),
//               child: const Icon(
//                 Icons.check,
//                 size: 8,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         // Present indicator
//         if (student.isPresent && !student.isMarkedOnServer)
//           Positioned(
//             right: 0,
//             bottom: 0,
//             child: Container(
//               width: 14,
//               height: 14,
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 2),
//               ),
//               child: const Icon(
//                 Icons.schedule,
//                 size: 8,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Color _getAvatarColor() {
//     // Generate color based on name
//     final colors = [
//       Colors.blue,
//       Colors.green,
//       Colors.orange,
//       Colors.purple,
//       Colors.teal,
//       Colors.pink,
//       Colors.indigo,
//       Colors.cyan,
//     ];
    
//     final index = student.name.isNotEmpty
//         ? student.name.codeUnitAt(0) % colors.length
//         : 0;
    
//     return colors[index];
//   }
// }

// lib/widgets/student_card.dart

import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../app/theme/app_theme.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final Widget? leading;
  final bool showCheckbox;
  final bool isSelected;
  final ValueChanged<bool?>? onCheckboxChanged;
  final bool showStatus;
  final bool showGender;
  final bool compact;

  const StudentCard({
    super.key,
    required this.student,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.leading,
    this.showCheckbox = false,
    this.isSelected = false,
    this.onCheckboxChanged,
    this.showStatus = true,
    this.showGender = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? AppTheme.primaryColor.withValues(alpha: 0.3) 
              : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: Row(
              children: [
                // Checkbox (optional)
                if (showCheckbox) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: onCheckboxChanged,
                    activeColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Leading or Avatar
                leading ?? _buildAvatar(),

                const SizedBox(width: 12),

                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name Row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.fullName,
                              style: TextStyle(
                                fontSize: compact ? 15 : 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (showGender) _buildGenderIcon(),
                        ],
                      ),
                      
                      const SizedBox(height: 4),

                      // Roll Number
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Roll: ${student.roleNumber}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      if (!compact) ...[
                        const SizedBox(height: 4),

                        // Email
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                student.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Phone
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              student.fullMobileNumber,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ] else if (showStatus) ...[
                  const SizedBox(width: 8),
                  _buildStatusBadge(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final bool isMale = student.gender.toLowerCase() == 'male';
    final Color avatarColor = isMale ? AppTheme.maleColor : AppTheme.femaleColor;

    return Container(
      width: compact ? 44 : 52,
      height: compact ? 44 : 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            avatarColor.withValues(alpha: 0.8),
            avatarColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        boxShadow: [
          BoxShadow(
            color: avatarColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          student.initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: compact ? 16 : 18,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderIcon() {
    final bool isMale = student.gender.toLowerCase() == 'male';
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isMale 
            ? AppTheme.maleColor.withValues(alpha: 0.1) 
            : AppTheme.femaleColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        isMale ? Icons.male : Icons.female,
        size: 14,
        color: isMale ? AppTheme.maleColor : AppTheme.femaleColor,
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    IconData badgeIcon;
    
    switch (student.status.toLowerCase()) {
      case 'active':
        badgeColor = AppTheme.successColor;
        badgeIcon = Icons.check_circle;
        break;
      case 'inactive':
        badgeColor = AppTheme.warningColor;
        badgeIcon = Icons.pause_circle;
        break;
      case 'blocked':
        badgeColor = AppTheme.errorColor;
        badgeIcon = Icons.block;
        break;
      default:
        badgeColor = Colors.grey;
        badgeIcon = Icons.help_outline;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badgeIcon, size: 12, color: badgeColor),
              const SizedBox(width: 4),
              Text(
                student.status,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (student.isMarkedOnServer) ...[
          const SizedBox(height: 4),
          Icon(
            Icons.cloud_done,
            color: AppTheme.successColor,
            size: 16,
          ),
        ],
      ],
    );
  }
}