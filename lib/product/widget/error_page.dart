import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final Function() callBack;
  final Object? errorDetail;
  const ErrorPage({super.key, required this.callBack, this.errorDetail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Hata'),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: callBack, child: const Text('Yeniden dene')),
          Text("Hata ayrıntısı: $errorDetail")
        ],
      ),
    ));
  }
}
