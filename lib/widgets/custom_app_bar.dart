import 'package:flutter/material.dart';
import '../widgets/app_colors.dart';
import '../widgets/custom_text.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: CustomText(
        text: title,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
      ),
      backgroundColor: AppColors.primary,
      centerTitle: true,
      elevation: 0.0,
      scrolledUnderElevation: 0.0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed:
                  onBack ??
                  () {
                    context.pop();
                  },
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
