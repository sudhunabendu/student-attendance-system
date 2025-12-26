import 'package:flutter/material.dart';
import '../../../models/notice_model.dart';

class NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final VoidCallback? onTap;

  const NoticeCard({
    super.key,
    required this.notice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black..withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon/Image
                _buildLeadingWidget(),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notice.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // File Info
                      if (notice.hasAttachment)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                _getFileIcon(),
                                size: 14,
                                color: _getFileColor(),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${notice.fileExtension} • ${notice.formattedFileSize}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Bottom Row
                      Row(
                        children: [
                          // Audience Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: notice.isForAll
                                  ? Colors.blue.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  notice.isForAll
                                      ? Icons.groups
                                      : Icons.group,
                                  size: 12,
                                  color: notice.isForAll
                                      ? Colors.blue.shade700
                                      : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  notice.isForAll ? 'All' : 'Selected',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: notice.isForAll
                                        ? Colors.blue.shade700
                                        : Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Time
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                notice.relativeTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingWidget() {
    if (notice.isImage && notice.fileUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          notice.fileUrl!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildIconWidget(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildIconWidget();
          },
        ),
      );
    }
    return _buildIconWidget();
  }

  // Widget _buildIconWidget() {
  //   return Container(
  //     width: 60,
  //     height: 60,
  //     decoration: BoxDecoration(
  //       color: _getFileColor().withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Icon(
  //       _getFileIcon(),
  //       color: _getFileColor(),
  //       size: 28,
  //     ),
  //   );
  // }

  Widget _buildIconWidget() {
  return Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      color: _getFileColor().withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      _getFileIcon(),
      color: _getFileColor(),
      size: 28,
    ),
  );
}


  Widget _buildStatusBadge() {
    final isActive = notice.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        notice.status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    if (notice.isImage) return Icons.image;
    if (notice.isPdf) return Icons.picture_as_pdf;
    if (notice.isDocument) return Icons.description;
    if (notice.hasAttachment) return Icons.attach_file;
    return Icons.notifications;
  }

  Color _getFileColor() {
    if (notice.isImage) return Colors.blue;
    if (notice.isPdf) return Colors.red;
    if (notice.isDocument) return Colors.orange;
    return const Color(0xFF6366F1);
  }
}