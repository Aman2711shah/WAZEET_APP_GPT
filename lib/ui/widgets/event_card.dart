import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String description;
  final VoidCallback? onRegister;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onRegister != null)
                  ElevatedButton(
                    onPressed: onRegister,
                    child: const Text('Register'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(location, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
