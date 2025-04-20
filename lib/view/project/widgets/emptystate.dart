// File: lib/widgets/common/empty_state_view.dart
import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;
  final Widget? actionButton;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              subMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionButton != null) ...[
            const SizedBox(height: 24),
            actionButton!,
          ],
        ],
      ),
    );
  }
}
