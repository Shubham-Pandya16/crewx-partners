import 'package:flutter/material.dart';
import '../../core/widgets/crewx_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CrewXAppBar(title: 'Notifications'),
      body: Center(
        child: Text('Notifications — coming soon', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
