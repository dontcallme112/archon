import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: AppSizes.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.lightGrey, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleLogo(size: 22),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'Продолжить с Google',
                    style: AppTypography.button
                        .copyWith(color: AppColors.dark),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 * 0.75;
    final sw = size.width * 0.18;

    void arc(Color color, double start, double sweep) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }

    arc(const Color(0xFFEA4335), -1.2, 2.0); // red
    arc(const Color(0xFF4285F4), 0.8, 2.0);  // blue
    arc(const Color(0xFF34A853), 2.8, 1.2);  // green
    arc(const Color(0xFFFBBC05), -0.4, 1.2); // yellow
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
