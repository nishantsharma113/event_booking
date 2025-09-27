// Reports screen
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/utils/web_download_stub.dart'
    if (dart.library.html) '../../core/utils/web_download_web.dart';

import '../../providers/booking_provider.dart';
import '../../providers/turf_provider.dart';
import '../../providers/auth_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _statusFilter = 'All';
  String _turfFilter = 'All';
  DateTime? _from;
  DateTime? _to;

  @override
  Widget build(BuildContext context) {
    final bookingProv = context.watch<BookingProvider?>();
    final turfProv = context.watch<TurfProvider?>();
    final authProv = context.watch<AuthProvider?>();

    // Push date filters to provider for chart/bookings
    if (bookingProv != null) {
      bookingProv.filterFrom = _from;
      bookingProv.filterTo = _to == null ? null : DateTime(_to!.year, _to!.month, _to!.day, 23, 59, 59);
    }

    final mostBookedTurfName = _computeMostBookedTurfName(bookingProv, turfProv);
    final activeUsers = authProv?.totalUsers ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Most Booked Turf', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(mostBookedTurfName ?? '—')
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Users', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text(activeUsers.toString(), style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Revenue (Last 12 Months)', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    AspectRatio(
                      aspectRatio: 16 / 6,
                      child: LineChart(
                        LineChartData(
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                              const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                              final idx = v.toInt();
                              return Padding(padding: const EdgeInsets.only(top: 4), child: Text(months[idx % 12]));
                            })),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              spots: [
                                for (final entry in (bookingProv?.computeMonthlyRevenueFiltered() ?? List<double>.filled(12, 0)).asMap().entries)
                                  FlSpot(entry.key.toDouble(), entry.value),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Status:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
                ),
                const SizedBox(width: 24),
                const Text('Turf:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _turfFilter,
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text('All')),
                    for (final t in turfProv?.turfs ?? [])
                      DropdownMenuItem(value: t.id, child: Text(t.name)),
                  ],
                  onChanged: (v) => setState(() => _turfFilter = v ?? 'All'),
                ),
                const SizedBox(width: 24),
                const Text('From:'),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _from ?? DateTime.now().subtract(const Duration(days: 30)),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _from = picked);
                  },
                  child: Text(_from == null ? 'Any' : _from!.toString().substring(0, 10)),
                ),
                const SizedBox(width: 12),
                const Text('To:'),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _to ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _to = picked);
                  },
                  child: Text(_to == null ? 'Any' : _to!.toString().substring(0, 10)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      _from = now.subtract(const Duration(days: 6));
                      _to = now;
                    });
                  },
                  child: const Text('Last 7 days'),
                ),
                OutlinedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      _from = now.subtract(const Duration(days: 29));
                      _to = now;
                    });
                  },
                  child: const Text('Last 30 days'),
                ),
                OutlinedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      _from = now.subtract(const Duration(days: 89));
                      _to = now;
                    });
                  },
                  child: const Text('Last 90 days'),
                ),
                OutlinedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      _from = DateTime(now.year, 1, 1);
                      _to = now;
                    });
                  },
                  child: const Text('This year'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _from = null;
                      _to = null;
                    });
                  },
                  child: const Text('Reset'),
                )
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () async {
                  final csv = _buildBookingsCsv(
                    bookingProv,
                    statusFilter: _statusFilter,
                    turfIdFilter: _turfFilter,
                    from: _from,
                    to: _to,
                  );
                  downloadCsvWeb(csv, 'bookings.csv');
                  await _showCsvDialog(context, csv);
                },
                icon: const Icon(Icons.download),
                label: const Text('Export Bookings CSV'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _computeMostBookedTurfName(BookingProvider? bookingProv, TurfProvider? turfProv) {
  if (bookingProv == null || turfProv == null) return null;
  if (bookingProv.bookings.isEmpty) return null;
  final counts = <String, int>{};
  for (final b in bookingProv.bookings) {
    counts[b.turfId] = (counts[b.turfId] ?? 0) + 1;
  }
  String? bestId;
  int bestCount = -1;
  counts.forEach((key, value) {
    if (value > bestCount) {
      bestCount = value;
      bestId = key;
    }
  });
  final turf = turfProv.turfs.firstWhere((t) => t.id == bestId, orElse: () => turfProv.turfs.isNotEmpty ? turfProv.turfs.first : (throw StateError('no turf')));
  return turf.name;
}

String _buildBookingsCsv(BookingProvider? bookingProv, {String statusFilter = 'All', String turfIdFilter = 'All', DateTime? from, DateTime? to}) {
  final rows = <String>[];
  rows.add('id,turf_id,user_id,slot_id,status,total_price');
  if (bookingProv != null) {
    for (final b in bookingProv.bookings) {
      if (statusFilter != 'All' && b.status != statusFilter) continue;
      if (turfIdFilter != 'All' && b.turfId != turfIdFilter) continue;
      if (from != null && (b.bookedAt == null || b.bookedAt!.isBefore(from))) continue;
      if (to != null && (b.bookedAt == null || b.bookedAt!.isAfter(DateTime(to.year, to.month, to.day, 23, 59, 59)))) continue;
      rows.add('${b.id},${b.turfId},${b.userId},${b.slotId},${b.status},${b.totalPrice}');
    }
  }
  return rows.join('\n');
}

Future<void> _showCsvDialog(BuildContext context, String csv) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Bookings CSV'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: SelectableText(csv),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        FilledButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: csv));
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Copy'),
        ),
      ],
    ),
  );
}
