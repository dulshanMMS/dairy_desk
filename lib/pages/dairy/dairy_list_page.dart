import 'package:flutter/material.dart';
import '../daily_session_entry_page.dart';

class DairyListPage extends StatelessWidget {
  const DairyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DailySessionEntryPage(
      businessType: 'dairy',
      title: 'Dairy Business',
      themeColor: Color(0xFF00BFA5),
    );
  }
}