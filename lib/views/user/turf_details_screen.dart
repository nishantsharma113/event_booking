// Turf details screen

import 'package:event_booking/core/widgets/custom_image.dart';
import 'package:event_booking/models/turf.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/turf_provider.dart';

class TurfDetailsScreen extends StatelessWidget {
  final String turfId;
  const TurfDetailsScreen({super.key, required this.turfId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TurfProvider>();

    final turf = provider.getTurfById(turfId);

    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.canPop() ? context.pop() : context.go('/home');
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text('Turf Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                children: [
                  Expanded(child: _ImagesCarousel(turf: turf)),
                  const SizedBox(width: 24),
                  Expanded(child: _DetailsPanel(turf: turf)),
                ],
              )
            : ListView(
                children: [
                  turf!.images!.isNotEmpty
                      ? _ImagesCarousel(turf: turf)
                      : SizedBox.shrink(),
                  const SizedBox(height: 16),
                  _DetailsPanel(turf: turf),
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
  final Turf? turf;
  const _ImagesCarousel({required this.turf});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: PageView.builder(
        itemCount: turf?.images!.length,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.only(right: 8),
          color: Colors.green.shade100,
          child: Center(child: CustomImage(imagePath: turf!.images![i])),
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final Turf? turf;
  const _DetailsPanel({required this.turf});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          turf?.name ?? 'Turf Name',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.place, size: 16),
            SizedBox(width: 4),
            Text(turf?.location ?? 'Turf Location'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.star, color: Colors.amber, size: 16),
            SizedBox(width: 4),
            Text('4.6'),
          ],
        ),
        const SizedBox(height: 16),
        Text('Description', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Text(turf?.description ?? 'Turf Description'),
        const SizedBox(height: 16),
        Text('Available Slots', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Consumer<TurfProvider>(
          builder: (context, ref, _) {
            final slots = context.read<TurfProvider>().getSlot();
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                slots.length,
                (index) => InkWell(
                  onTap: () {
                    context.read<TurfProvider>().selectSlots(slots[index]);
                  },
                  child: Chip(
                    backgroundColor: ref.selectSlotList.contains(slots[index])
                        ? Colors.green
                        : Colors.grey.shade200,
                    label: Text(slots[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
