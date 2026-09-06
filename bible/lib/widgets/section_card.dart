import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.subtitle, required this.icon, this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  @override Widget build(BuildContext context) => Card(child: ListTile(onTap: onTap, minVerticalPadding: 14, leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(icon, color: Theme.of(context).colorScheme.primary)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right)));
}
