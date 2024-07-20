import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/models/anekdot.dart';
import 'package:intl/intl.dart';

class AnekdotCard extends ConsumerWidget {
  final AnekdotModel anekdot;
  const AnekdotCard({
    super.key,
    required this.anekdot,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              anekdot.bulan,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              anekdot.id,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(anekdot.analisisCapaian),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Created at: ${DateFormat('MM-dd-yyyy').format(anekdot.createdAt)}',
              style: const TextStyle(fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }
}
