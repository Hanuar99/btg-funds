import 'package:flutter/material.dart';

class RouterErrorPage extends StatelessWidget {
  const RouterErrorPage({
    this.error,
    super.key,
  });

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Ruta no encontrada: $error'),
      ),
    );
  }
}
