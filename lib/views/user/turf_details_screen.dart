// Turf details screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TurfDetailsScreen extends StatelessWidget {
  const TurfDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      appBar: AppBar(title: const Text('Turf Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                children: [
                  Expanded(child: _ImagesCarousel()),
                  const SizedBox(width: 24),
                  const Expanded(child: _DetailsPanel()),
                ],
              )
            : ListView(
                children: [
                  _ImagesCarousel(),
                  const SizedBox(height: 16),
                  const _DetailsPanel(),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () => context.go('/bookings'),
            icon: const Icon(Icons.calendar_month),
            label: const Text('Book Now'),
          ),
        ),
      ),
    );
  }
}

class _ImagesCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: PageView.builder(
        itemCount: 3,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.only(right: 8),
          color: Colors.green.shade100,
          child: const Center(child: Icon(Icons.image, size: 64)),
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Green Field Arena', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Row(children: const [Icon(Icons.place, size: 16), SizedBox(width: 4), Text('Downtown City')]),
        const SizedBox(height: 8),
        Row(children: const [Icon(Icons.star, color: Colors.amber, size: 16), SizedBox(width: 4), Text('4.6')]),
        const SizedBox(height: 16),
        const Text('Description'),
        const SizedBox(height: 8),
        const Text('Well-maintained turf with night lights and locker rooms.'),
        const SizedBox(height: 16),
        const Text('Available Slots'),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: List.generate(8, (i) => Chip(label: Text('${10 + i}:00')))),
      ],
    );
  }
}

