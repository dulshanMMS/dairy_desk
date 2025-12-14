import 'package:flutter/material.dart';
import '../daily_session_entry_page.dart';

class FarmListPage extends StatelessWidget {
  const FarmListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DailySessionEntryPage(
      businessType: 'farm',
      title: 'Farm Business',
      themeColor: Color(0xFF4CAF50),
    );
  }
}