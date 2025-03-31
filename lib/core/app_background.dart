import 'package:flutter/material.dart';

class InternalBackground extends StatelessWidget {
  final Widget child;

  const InternalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDarkTheme
                ? const Color.fromARGB(255, 35, 35, 35)
                : const Color.fromARGB(255, 218, 218, 218),
            isDarkTheme
                ? const Color.fromARGB(255, 10, 10, 10)
                : const Color.fromARGB(255, 244, 244, 244),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
