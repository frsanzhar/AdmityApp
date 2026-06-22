import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Full-screen detail for a Мероприятие. STUB — opportunities agent fills this in.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Мероприятие',
      subtitle: 'Детальная информация (в разработке)',
      icon: Icons.info_outline,
    );
  }
}
