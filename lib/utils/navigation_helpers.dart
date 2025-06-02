import 'package:flutter/material.dart';

void fadeTransitionTo(BuildContext context, Widget destinationPage) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => destinationPage,
      transitionsBuilder:
          (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
    ),
  );
}
