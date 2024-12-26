import 'package:flutter/material.dart';

class ReloadError extends StatelessWidget {
  final VoidCallback onReload;

  const ReloadError({super.key, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Internet Error.\n Please check your connection.',
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onReload,
            child: const Text('Reload'),
          ),
        ],
      ),
    );
  }
}
