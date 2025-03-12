import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Notification>>(
        future: _getNotifications(), // This should be the logic to fetch notifications.
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final notification = snapshot.data![index];
                return ListTile(
                  title: Text(notification.title),
                  subtitle: Text(notification.body),
                );
              },
            );
          } else {
            return const Center(child: Text("No new notifications!"));
          }
        },
      ),
    );
  }

  Future<List<Notification>> _getNotifications() async {
    // Fetch notifications from the storage or local notifications plugin
    return [];
  }
}

class Notification {
  final String title;
  final String body;

  Notification({required this.title, required this.body});
}
