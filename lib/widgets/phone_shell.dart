import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class PhoneShell extends StatelessWidget {
  const PhoneShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final framed = kIsWeb && size.width > 520;
    if (!framed) return child;
    return ColoredBox(
      color: const Color(0xFF070B16),
      child: Center(
        child: Container(
          width: 390,
          height: 844,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFF2C3858), width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 18)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: const Size(390, 844),
              padding: const EdgeInsets.only(top: 12, bottom: 16),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
