import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
    this.tone = CustomButtonTone.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final CustomButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final background = switch (tone) {
      CustomButtonTone.primary => AppColors.primary,
      CustomButtonTone.danger => AppColors.high,
      CustomButtonTone.ghost => AppColors.surface,
    };
    final child = Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppColors.text,
      ),
    );
    return SizedBox(
      width: expand ? double.infinity : null,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: AppColors.border,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: child,
      ),
    );
  }
}

enum CustomButtonTone { primary, danger, ghost }
