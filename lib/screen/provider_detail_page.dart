import 'package:flutter/material.dart';
import '../models/provider.dart';
import 'booking_page.dart';

class ProviderDetailPage extends StatelessWidget {
  const ProviderDetailPage({super.key, required this.provider});
  final ProviderProfile provider;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 38, child: Text(provider.name[0])),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${provider.location}  •  ★ ${provider.rating} (${provider.reviewCount} reviews)',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metric(context, '${provider.completedJobs}', 'Jobs'),
              _metric(context, '${provider.experienceYears} yrs', 'Experience'),
              _metric(context, 'LKR ${provider.hourlyRate}', 'Per hour'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            provider.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Text(
            'Skills',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: provider.skills
                .map((skill) => Chip(label: Text(skill)))
                .toList(),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: provider.isAvailable
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingPage(provider: provider),
                    ),
                  )
                : null,
            icon: const Icon(Icons.calendar_month),
            label: Text(provider.isAvailable ? 'Book now' : 'Currently busy'),
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String value, String label) => SizedBox(
    width: 100,
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
