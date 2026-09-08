import 'dart:async';

import 'package:dompet/shared/widgets/dompet_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DompetSlidableAction extends StatelessWidget {
  const DompetSlidableAction({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isDestructive = false,
    super.key,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (ctx) {
        unawaited(
          isDestructive ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact(),
        );
        onPressed();
      },
      backgroundColor: Colors.transparent,
      foregroundColor: color,
      child: DompetIcon(
        icon: icon,
        color: color,
        size: DompetIconSize.small,
      ),
    );
  }
}
