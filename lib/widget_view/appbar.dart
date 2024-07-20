import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
            fontFamily: 'inter', color: Colors.white, fontSize: 22),
      ),
      backgroundColor: const Color(0xff104993),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
