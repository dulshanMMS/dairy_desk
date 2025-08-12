import 'package:flutter/material.dart';

class ShopListPage extends StatelessWidget {
  const ShopListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Billing')),
      body: const Center(child: Text("Shop and billing info will appear here.")),
    );
  }
}
