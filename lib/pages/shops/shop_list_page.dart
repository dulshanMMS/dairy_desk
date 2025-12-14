import 'package:flutter/material.dart';
import '../daily_session_entry_page.dart';

class ShopListPage extends StatelessWidget {
  const ShopListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DailySessionEntryPage(
      businessType: 'shop',
      title: 'Shop Billing',
      themeColor: Color(0xFFFF9800),
    );
  }
}